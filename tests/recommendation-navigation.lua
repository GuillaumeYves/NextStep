local NS = { Util = {} }

local chunk, loadError = loadfile("Util/RecommendationNavigation.lua")
assert(chunk, loadError)
chunk("NextStep", NS)

local navigation = NS.Util.RecommendationNavigation
local recommendations = {
    { id = "first" },
    { id = "second" },
    { id = "third" },
}

assert(navigation:ResolveIndex(recommendations, nil, nil) == 1, "Navigation should start at the first step.")
assert(navigation:ResolveIndex(recommendations, 1, "second") == 2, "Navigation should preserve a visible recommendation.")
assert(navigation:ResolveIndex(recommendations, 3, "missing") == 3, "Navigation should preserve a valid index.")
assert(navigation:ResolveIndex(recommendations, 8, nil) == 3, "Navigation should clamp a stale index.")
assert(navigation:ResolveIndex({}, 1, nil) == 0, "An empty plan should not select a step.")
assert(navigation:Move(1, 3, 1) == 2, "Next should advance one step.")
assert(navigation:Move(2, 3, -1) == 1, "Previous should go back one step.")
assert(navigation:Move(1, 3, -1) == 1, "Previous should stop at the first step.")
assert(navigation:Move(3, 3, 1) == 3, "Next should stop at the final step.")

print("Recommendation navigation tests passed.")
