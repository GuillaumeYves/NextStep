local _, NS = ...

local Constants = NS:RegisterModule("Constants", {})

Constants.SCHEMA_VERSION = 2
Constants.CHARACTER_SCHEMA_VERSION = 1
Constants.DEFAULT_MAX_RECOMMENDATIONS = 5
Constants.MIN_RECOMMENDATIONS = 1
Constants.MAX_RECOMMENDATIONS = 10
Constants.REFRESH_DELAY = 0.2

Constants.GOAL = {
    EXPERIENCE = "experience",
    GEAR = "gear",
    MOUNTS = "mounts",
    PETS = "pets",
}

Constants.GOAL_ORDER = {
    "experience",
    "gear",
    "mounts",
    "pets",
}

Constants.IMPORTANCE = {
    CRITICAL = "CRITICAL",
    HIGH = "HIGH",
    USEFUL = "USEFUL",
    OPTIONAL = "OPTIONAL",
    COMPLETED = "COMPLETED",
}

Constants.IMPORTANCE_SCORE = {
    CRITICAL = 100,
    HIGH = 80,
    USEFUL = 50,
    OPTIONAL = 20,
    COMPLETED = 0,
}

Constants.IMPORTANCE_LABEL = {
    CRITICAL = "CRITICAL",
    HIGH = "HIGH VALUE",
    USEFUL = "USEFUL",
    OPTIONAL = "OPTIONAL",
    COMPLETED = "COMPLETED",
}

Constants.STATUS = {
    AVAILABLE = "available",
    COMPLETED = "completed",
    UNAVAILABLE = "unavailable",
    UNKNOWN = "unknown",
}

Constants.ACTIVITY_TYPE = {
    LEVELING = "leveling",
    GREAT_VAULT = "great_vault",
    DUNGEON = "dungeon",
    RAID = "raid",
        WEEKLY = "weekly",
        QUEST = "quest",
        GEAR_UPGRADE = "gear_upgrade",
    CURRENCY = "currency",
    WORLD_CONTENT = "world_content",
}
