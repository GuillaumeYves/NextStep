local tocPath = arg[1] or "NextStep.toc"

local function readFile(path)
    local file, openError = io.open(path, "rb")
    if not file then
        error(openError)
    end
    local content = file:read("*a")
    file:close()
    return content
end

local function manifestFiles()
    local files = {}
    for line in readFile(tocPath):gmatch("[^\r\n]+") do
        local trimmed = line:match("^%s*(.-)%s*$")
        if trimmed ~= "" and trimmed:sub(1, 1) ~= "#" then
            files[#files + 1] = trimmed:gsub("\\", "/")
        end
    end
    return files
end

local files = manifestFiles()

local function loadLocalization(clientLocale)
    local namespace = {
        API = {
            WoW = {
                GetLocale = function()
                    return clientLocale
                end,
            },
        },
    }

    for _, path in ipairs(files) do
        if path:match("^Localization/") then
            local chunk, loadError = loadfile(path)
            if not chunk then
                error(loadError)
            end
            chunk("NextStep", namespace)
        end
    end
    return namespace
end

local englishNamespace = loadLocalization("enUS")
local frenchNamespace = loadLocalization("frFR")
local fallbackNamespace = loadLocalization("deDE")
local locales = englishNamespace.Locales or {}
local english = locales.enUS

assert(type(english) == "table", "English locale is missing.")
assert(englishNamespace.selectedLocale == "enUS", "English locale selection failed.")
assert(frenchNamespace.selectedLocale == "frFR", "French locale selection failed.")
assert(fallbackNamespace.selectedLocale == "enUS", "Unsupported locale fallback failed.")
assert(frenchNamespace.L.TAGLINE == frenchNamespace.Locales.frFR.TAGLINE, "French locale merge failed.")
assert(fallbackNamespace.L.TAGLINE == fallbackNamespace.Locales.enUS.TAGLINE, "English locale fallback merge failed.")

local errors = {}

local function addError(message)
    errors[#errors + 1] = message
end

local function formatSignature(value, path)
    local signature = {}
    local position = 1

    while true do
        local percent = value:find("%", position, true)
        if not percent then
            break
        end

        local nextCharacter = value:sub(percent + 1, percent + 1)
        if nextCharacter == "%" then
            position = percent + 2
        else
            local tail = value:sub(percent)
            local specifier = tail:match("^%%[-+ #0%d%.%*]*([cdeEfgGiouqsxX])")
            if not specifier then
                addError("Invalid format token at " .. path)
                position = percent + 1
            else
                signature[#signature + 1] = specifier
                position = percent + 2
            end
        end
    end

    return table.concat(signature, ",")
end

local function compareLocale(base, translated, localeName, path)
    for key, baseValue in pairs(base) do
        local currentPath = path == "" and key or path .. "." .. key
        local translatedValue = translated[key]

        if translatedValue == nil then
            addError(localeName .. " is missing " .. currentPath)
        elseif type(baseValue) ~= type(translatedValue) then
            addError(localeName .. " has the wrong type for " .. currentPath)
        elseif type(baseValue) == "table" then
            compareLocale(baseValue, translatedValue, localeName, currentPath)
        elseif type(baseValue) == "string" then
            local baseSignature = formatSignature(baseValue, "enUS." .. currentPath)
            local translatedSignature = formatSignature(translatedValue, localeName .. "." .. currentPath)
            if baseSignature ~= translatedSignature then
                addError(localeName .. " has incompatible format tokens for " .. currentPath)
            end
        end
    end

    for key in pairs(translated) do
        if base[key] == nil then
            local currentPath = path == "" and key or path .. "." .. key
            addError(localeName .. " has unknown key " .. currentPath)
        end
    end
end

for localeName, translated in pairs(locales) do
    if localeName ~= "enUS" then
        compareLocale(english, translated, localeName, "")
    end
end

for _, path in ipairs(files) do
    if path:match("%.lua$") then
        for key in readFile(path):gmatch("NS%.L%.([A-Z][A-Z0-9_]*)") do
            if english[key] == nil then
                addError(path .. " references unknown English key " .. key)
            end
        end
    end
end

if #errors > 0 then
    for _, message in ipairs(errors) do
        io.stderr:write(message .. "\n")
    end
    os.exit(1)
end

local localeCount = 0
for _ in pairs(locales) do
    localeCount = localeCount + 1
end

print(string.format("Validated %d locale tables and automatic fallback.", localeCount))
