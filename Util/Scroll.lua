local _, NS = ...

NS.Util = NS.Util or {}
local Scroll = {}
NS.Util.Scroll = Scroll

function Scroll:ClampOffset(offset, contentHeight, viewportHeight)
    offset = tonumber(offset) or 0
    contentHeight = tonumber(contentHeight) or 0
    viewportHeight = tonumber(viewportHeight) or 0
    local maximum = math.max(0, contentHeight - viewportHeight)
    return math.max(0, math.min(maximum, offset))
end

function Scroll:RestoreOffset(scrollFrame, offset, contentHeight)
    local viewportHeight = scrollFrame:GetHeight()
    scrollFrame:SetVerticalScroll(self:ClampOffset(offset, contentHeight, viewportHeight))
end
