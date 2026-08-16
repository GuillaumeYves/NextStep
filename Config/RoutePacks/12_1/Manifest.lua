local _, NS = ...

NS.RoutePacks = NS.RoutePacks or {}

NS.RoutePacks["12.1"] = {
    id = "12.1",
    patch = "12.1.0",
    interface = 120100,
    reviewedAt = "2026-08-16",
    phase = "patch_12_1",
    routes = {},
    sources = {
        blizzardStarterGuide = {
            kind = "official",
            titleKey = "SOURCE_BLIZZARD_STARTER_GUIDE",
            url = "https://worldofwarcraft.blizzard.com/en-us/news/24266319",
        },
        blizzardPatchOverview = {
            kind = "official",
            titleKey = "SOURCE_BLIZZARD_PATCH_OVERVIEW",
            url = "https://worldofwarcraft.blizzard.com/en-gb/news/24294370",
        },
        blizzardQuestExperience = {
            kind = "official",
            titleKey = "SOURCE_BLIZZARD_QUEST_EXPERIENCE",
            url = "https://worldofwarcraft.blizzard.com/en-us/news/24288418/quality-of-life-improvements-coming-in-curse-of-ulatek",
        },
        blizzardSeason2Schedule = {
            kind = "official",
            titleKey = "SOURCE_BLIZZARD_SEASON_2_SCHEDULE",
            url = "https://news.blizzard.com/en-us/article/24294369/the-shadows-deepen-midnight-season-2-begins-august-18",
        },
        wowheadMidnightAltLeveling = {
            kind = "community_guide",
            titleKey = "SOURCE_WOWHEAD_ALT_LEVELING",
            url = "https://www.wowhead.com/news/best-way-to-level-alts-fast-in-midnight-380598",
        },
        wowheadMidnightAdventureUnlock = {
            kind = "database",
            titleKey = "SOURCE_WOWHEAD_MIDNIGHT_ADVENTURE_UNLOCK",
            url = "https://www.wowhead.com/quest=95008/adventuring-in-midnight",
        },
        wowheadSeason2Schedule = {
            kind = "secondary",
            titleKey = "SOURCE_WOWHEAD_SEASON_SCHEDULE",
            url = "https://www.wowhead.com/news/midnight-season-2-launches-august-18th-382287",
        },
        wowheadMythicZero = {
            kind = "secondary",
            titleKey = "SOURCE_WOWHEAD_MYTHIC_ZERO",
            url = "https://www.wowhead.com/news/mythic-0-and-great-vault-clarifications-during-week-0-of-midnight-season-2-382296",
        },
        wowheadMythicPlusSeason2 = {
            kind = "secondary",
            titleKey = "SOURCE_WOWHEAD_MYTHIC_PLUS_SEASON_2",
            url = "https://www.wowhead.com/guide/midnight/mythic-plus-season-overview",
        },
        wowheadGreatVault = {
            kind = "secondary",
            titleKey = "SOURCE_WOWHEAD_GREAT_VAULT",
            url = "https://www.wowhead.com/ptr-2/guide/systems/the-great-vault",
        },
        wowheadMistcrests = {
            kind = "secondary",
            titleKey = "SOURCE_WOWHEAD_MISTCRESTS",
            url = "https://www.wowhead.com/guide/midnight/item-level-gear-upgrades-dawncrests",
        },
        wowheadLairs = {
            kind = "secondary",
            titleKey = "SOURCE_WOWHEAD_LAIRS",
            url = "https://www.wowhead.com/news/lairs-preview-in-patch-12-1-world-difficulty-solo-queue-382309",
        },
        wowheadAmaniCampaignRewards = {
            kind = "secondary",
            titleKey = "SOURCE_WOWHEAD_AMANI_CAMPAIGN_REWARDS",
            url = "https://www.wowhead.com/news/chapter-1-of-curse-of-ulatek-patch-12-1-campaign-now-live-382105",
        },
        wowheadDuskGrimlynx = {
            kind = "database",
            titleKey = "SOURCE_WOWHEAD_DUSK_GRIMLYNX",
            url = "https://www.wowhead.com/item=246731/dusk-grimlynx",
        },
        wowheadHistoryLesson = {
            kind = "database",
            titleKey = "SOURCE_WOWHEAD_HISTORY_LESSON",
            url = "https://www.wowhead.com/quest=92899/history-lesson",
        },
        wowheadHagarsInvitation = {
            kind = "database",
            titleKey = "SOURCE_WOWHEAD_HAGARS_INVITATION",
            url = "https://www.wowhead.com/quest=92895/hagars-invitation",
        },
        wowheadAkiki = {
            kind = "database",
            titleKey = "SOURCE_WOWHEAD_AKIKI",
            url = "https://www.wowhead.com/npc=260149/akiki",
        },
        wowheadDeadEnd = {
            kind = "database",
            titleKey = "SOURCE_WOWHEAD_DEAD_END",
            url = "https://www.wowhead.com/quest=93012/dead-end",
        },
        icyVeinsGnarldor = {
            kind = "community_guide",
            titleKey = "SOURCE_ICY_VEINS_GNARLDOR",
            url = "https://www.icy-veins.com/wow/gnarldor-isle-delve-guide",
        },
        wowheadArcaneGolem = {
            kind = "database",
            titleKey = "SOURCE_WOWHEAD_ARCANE_GOLEM",
            url = "https://www.wowhead.com/item=262496/delvers-arcane-golem",
        },
        icyVeinsCoiledIsle = {
            kind = "community_guide",
            titleKey = "SOURCE_ICY_VEINS_COILED_ISLE",
            url = "https://www.icy-veins.com/wow/the-coiled-isle-guide",
        },
        wowheadAuriferousVenomfang = {
            kind = "database",
            titleKey = "SOURCE_WOWHEAD_AURIFEROUS_VENOMFANG",
            url = "https://www.wowhead.com/item=275656/auriferous-venomfang",
        },
        wowheadWrithingBrood = {
            kind = "database",
            titleKey = "SOURCE_WOWHEAD_WRITHING_BROOD",
            url = "https://www.wowhead.com/item=276804/the-writhing-brood",
        },
        wowheadAltarOfFangs = {
            kind = "community_guide",
            titleKey = "SOURCE_WOWHEAD_ALTAR_OF_FANGS",
            url = "https://www.wowhead.com/guide/midnight/altar-of-fangs-dungeon-overview-location-rewards",
        },
        wowheadCoiledIsleSafari = {
            kind = "database",
            titleKey = "SOURCE_WOWHEAD_COILED_ISLE_SAFARI",
            url = "https://www.wowhead.com/achievement=62492/the-coiled-isle-safari",
        },
        wowheadPatchMountCatalog = {
            kind = "database",
            titleKey = "SOURCE_WOWHEAD_PATCH_MOUNT_CATALOG",
            url = "https://www.wowhead.com/ptr/mount-spells?filter=21;3;120100",
        },
        wowheadPatchPetCatalog = {
            kind = "database",
            titleKey = "SOURCE_WOWHEAD_PATCH_PET_CATALOG",
            url = "https://www.wowhead.com/ptr/battle-pets?filter=3;3;120100",
        },
        wowheadPatchAchievementCatalog = {
            kind = "database",
            titleKey = "SOURCE_WOWHEAD_PATCH_ACHIEVEMENT_CATALOG",
            url = "https://www.wowhead.com/ptr/achievements?filter=17;3;120100",
        },
        wowheadRalkalaRewards = {
            kind = "secondary",
            titleKey = "SOURCE_WOWHEAD_RALKALA_REWARDS",
            url = "https://www.wowhead.com/news/defeat-ralkala-fifty-times-to-earn-special-prey-achievement-in-patch-12-1-382164",
        },
    },
}
