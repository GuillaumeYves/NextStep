local function loadAddonFile(path, namespace)
    local chunk = assert(loadfile(path))
    return chunk("NextStep", namespace)
end

local namespace = {
    UI = {},
    Util = {},
}

loadAddonFile("Util/Scroll.lua", namespace)
loadAddonFile("UI/VaultPanel.lua", namespace)

local Scroll = namespace.Util.Scroll
assert(Scroll:ClampOffset(175, 800, 300) == 175, "valid scroll offset should be preserved")
assert(Scroll:ClampOffset(700, 800, 300) == 500, "offset should clamp to the new maximum")
assert(Scroll:ClampOffset(-20, 800, 300) == 0, "offset should not become negative")
assert(Scroll:ClampOffset(40, 200, 300) == 0, "short content should remain at the top")

local restoredOffset
local scrollFrame = {
    GetHeight = function()
        return 300
    end,
    SetVerticalScroll = function(_, value)
        restoredOffset = value
    end,
}
Scroll:RestoreOffset(scrollFrame, 700, 800)
assert(restoredOffset == 500, "restoring a scroll frame should use the clamped offset")

local VaultPanel = namespace.UI.VaultPanel
assert(VaultPanel:GetDividerOffset(1) == -120, "first divider should be centered in its row gap")
assert(VaultPanel:GetDividerOffset(2) == -236, "second divider should be centered in its row gap")
assert(
    VaultPanel.LAYOUT.dividerHeight < VaultPanel.LAYOUT.rowGap,
    "divider should leave clearance above and below adjacent rows"
)

print("ui layout tests passed")
