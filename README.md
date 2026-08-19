# NextStep

Know what matters for you next.

NextStep is a World of Warcraft Retail addon that turns reliable character and weekly progression data into a short, explained plan. It is designed for new, returning, casual, regular, and alt-focused players who want direction without another dense dashboard.

## What it does

The first production milestone provides:

- A concise What Matters Next plan with up to five recommendations by default
- Character level, class, specialization, and item level summary
- Great Vault category routes with next and following thresholds
- Great Vault example item levels, exact raid encounter progress, and current-week Mythic Plus run analysis
- Equipped-item upgrade tracks, remaining ranks, and maximum item levels
- Character-specific Season 2 gear and Dungeon Vault reward breakpoints
- Character-specific Hero and Myth crafted-gear routes that target the weakest non-tier equipped slot
- Equipment-aware World, Normal, Heroic, and Mythic Tidebound Grotto reward routes
- Verified 12.1 Mistcrest balances and standard-cost gaps
- All five Mistcrests with live icons, balances, and client-provided weekly or cumulative cap progress
- Exact XP progress and rested XP visibility below maximum level
- Completed quest turn-in recommendations when XP rewards are known
- Current tracked quest guidance
- Exact level-appropriate dungeon choices when Dungeon Finder is usable and returns names
- Conservative empty equipment guidance
- A configurable currency tracking pipeline
- A friendly fallback when no important action can be detected
- Saved settings and window position
- Automatic locale selection from the WoW client
- Automatic experience, campaign and unlock, gear, mount, battle pet, and achievement category analysis
- A locally shipped 12.1 route pack for leveling, story chapters, zone and activity unlocks, Delves, raid access, gearing, mounts, and battle pets
- A public 12.1 catalog snapshot covering 64 mount spells, 36 collectible pet species, and 149 achievements
- Localized collection names, icons, sources, descriptions, rewards, and completion state read from the Retail client
- Character-aware route selection using level, item level, quest completion, achievement progress, season state, and collection ownership
- Ordered route details with live criteria progress, missing objectives, source, confidence, patch, and review metadata
- A movable compact window with a category selector, current route, short reason, and Open Plan button
- A main plan organized into character, Great Vault, reset, and per-category route carousels
- Native Retail Vault artwork, locked and unlocked cards, checkmarks, and category panels
- Exact completed raid encounters and generated reward links in Vault tooltips when the client exposes them
- Multiple concrete routes per supported category, visible ordered steps, target reward icons, acquisition labels, and bounded carousel navigation
- Fixed character and account completion bars below the season status, with detailed hover counts
- Red, orange, yellow, and green completion bars that become greener as tracked work approaches completion
- Native reward-item hovers for item-backed mounts and gear, native achievement hovers in the achievement category, and Mount Journal fallback hovers when no reward item exists
- Optional incomplete 4-piece class-set guidance when equipped set detection is reliable
- A movable settings window with a saved position
- Structured state and rule diagnostics

Every recommendation includes a title, a short instruction, an importance label, and a reason. NextStep does not invent activity durations, item value, best-in-slot status, or unavailable rewards.

## Installation

1. Copy this repository folder to `_retail_/Interface/AddOns/NextStep`.
2. Confirm that `NextStep.toc` is directly inside that folder.
3. Start or restart World of Warcraft Retail.
4. Enable NextStep in the AddOns list.
5. Log in and run `/nextstep`.

The compact next step window appears automatically for each character unless it is disabled in settings. Its category selector changes the visible objective without suppressing analysis in other categories.

The current manifest targets Retail interface `120100`, corresponding to the reviewed 12.1.0 live UI source.

WoW addons cannot download current web guides while the game is running. NextStep therefore ships reviewed route packs locally. The addon loads the configured pack and adapts it to the normalized character state. A pack is suppressed if its reviewed interface version does not match the running client. Updating advice for a new patch means reviewing the sources and replacing or adding files under `Config/RoutePacks/`.

## Slash commands

- `/nextstep` or `/ns` toggles the main window.
- `/ns debug` toggles debug logging.
- `/ns debug state` opens the normalized PlayerState inspector.
- `/ns debug recommendations` opens rule and recommendation diagnostics.
- `/ns reset` restores default settings and window position.

## Localization

NextStep reads the WoW client locale automatically. English and French are currently included. Unsupported client locales use the complete English table, and every translated locale falls back to English for missing keys. No addon setting is required.

## Architecture

```text
Blizzard APIs
    -> API and data collection modules
    -> normalized PlayerState
    -> independent recommendation rules
    -> validation, deduplication, and scoring
    -> concise planner
    -> reusable UI components
```

The recommendation engine and planner never call Blizzard APIs. Volatile season and currency values belong under `Config/`.

```text
Config/RoutePacks/12_1/*.lua
    -> Data/CuratedRoutes.lua
    -> normalized PlayerState.curatedRoutes
    -> CuratedRoutes recommendation rule
    -> category planner
    -> compact window and recommendation cards
```

Each recommendation declares the categories it supports. The planner evaluates every supported category, while the compact selector controls only which category is visible in that window.

## Verified patch content

NextStep combines dynamic character state from Blizzard APIs with curated patch content. Route and guide data must be reviewed for the current live patch before it is added. Every curated entry should identify its patch, source, requirements, steps, and known uncertainty.

Claims such as fastest route, best farm, or best upgrade path require direct and current evidence. When that evidence is unavailable, NextStep uses precise neutral wording or omits the recommendation.

The 12.1 pack was reviewed on 2026-08-19 and currently contains:

- Blizzard's current progression path through Exile's Reach, Dragonflight, The War Within, and Midnight
- A community-optimized Midnight alt route using one-time Delver's Calls, zone quests, and optional first-time profession crafts
- The complete Season 2 Mythic Plus end-of-run and Great Vault reward bands
- Reward breakpoints at +2, +4, +7, and +10
- Mythic 0 item level 292 Champion 1/6 rewards with the current weekly pre-season lockout
- World Lair item level 279 Veteran 1/6 guidance only for equipped slots below that reward
- Normal, Heroic, and Mythic Tidebound Grotto guidance at item levels 292, 305, and 318, selected from the character's equipped item level and useful slots
- Hero and Myth crafted-gear guidance for item levels 305-318 and 318-331, including the weakest non-tier slot and the exact 80-Mistcrest cost or remaining gap
- Legacy of the Amani campaign completion through Dead End, followed by the Coiled Isle activity unlock route
- Coiled Isle public event and Curse Surge steps, including the documented Cursed Fishing unlock
- Separate Vaults of Atal'Utek public-event and Tokka local-story and reputation routes
- The three new 12.1 Delves as playable content unlocks through Journeys
- Venomous Abyss access and Great Vault boss thresholds without encounter or combat guidance
- Raid Vault routes that direct the player through Raid Info before joining a run and state the exact number of additional uncleared bosses required for the next slot
- Dynamic weekly Great Vault and character-specific gearing work kept under Gear instead of Campaign and Unlocks
- Adventurer, Veteran, Champion, Hero, and Myth Mistcrest definitions
- The Dusk Grimlynx route through the History Lesson quest
- The Akiki battle pet route through the Dead End quest
- The guaranteed Delver's Arcane Golem treasure in Gnarldor Isle
- The 22-criterion Treasures of the Coiled Isle route for the Auriferous Venomfang
- The chance-based Writhing Brood route, active only while Mythic Plus is active
- The Season 2 Prey unlock through A Slithering Threat, followed by the level 8 Preyhunter's Prismguard and level 10 Preyhunter's Fury reward routes
- The Midnight Keystone Legend: Season 2 route for Breath of Ruin at Mythic Plus rating 3000
- The No Egg Scramble route for Ula'took and the Mythic Ula'tek chance route for Primeval Skyfriend
- The eight-species Coiled Isle Safari route for the Zesty battle pet
- Every public achievement in the reviewed 12.1 database snapshot, filtered against live character completion
- Every supported 12.1 mount and collectible pet record, filtered against the live Mount and Pet Journals

At the 2026-08-18 review point, Season 2 activates with the August 18 Americas reset and August 19 European reset. Mythic 0 changes from its pre-season weekly lockout to a daily lockout, Bountiful Delves and keys activate, Venomous Abyss opens its first Raid Finder wing and organized difficulties, and higher Lair difficulties activate. NextStep uses the live Mythic Plus state to keep these routes dormant until the season is active for the character's region.

Present-tense pre-season guidance is capped at item level 298. This is a conservative local ceiling based on the current live reward state, not a claim that Blizzard published a universal 298 cap. Vault item levels still come from the client's preview links. During pre-season, those values are labeled as next-reset previews and are never presented as rewards already available this week.

Supported target routes carry a reward icon, typed native target data, acquisition type, evidence, and optional documented drop rate. Item-backed mounts carry both their verified reward item ID and their Mount Journal identity. Item tooltips can load directly from the item ID before the full item link is cached. Guaranteed quest, treasure, and achievement rewards are labeled clearly. Chance rewards show a percentage only when a current reliable source publishes one. The Writhing Brood currently has no defensible published rate, so NextStep says that the rate is unavailable.

The alt leveling route is marked with medium confidence because it is a community optimization and results vary. Other included routes use official progression guidance or documented reward records. Hover any task to see its reason, progress, route steps, and evidence. Vault slots expose progress and the exact client preview in the same way.

### Updating a route pack

1. Review the current patch and season using official sources first.
2. Use current database or community guides only where Blizzard does not publish enough detail.
3. Update the manifest metadata and sources.
4. Change only the relevant objective file, such as `Leveling.lua` or `Mounts.lua`.
5. Record level, quest, item level, or collection requirements that the addon can verify.
6. Keep unsupported claims out of the pack.
7. Update localized route strings and run the route selection tests.

## Currency configuration

Tracked currency IDs live only in `Config/CurrencyConfig.lua`. The verified 12.1 Mistcrest IDs are enabled there. Add future verified entries in this form:

```lua
{
    currencyID = 1234,
    enabled = true,
    description = "Short player-facing purpose.",
}
```

Document the source and season beside each added ID.

## Development status

Version 0.10.0 adds concrete multi-step 12.1 routes, curated Season 2 collection paths, character-specific crafted-gear and Lair guidance, practical raid-lockout steps, fixed character and account completion bars, visible threshold colors, Blizzard-style progress framing, stable scroll state, and typed native hovers for item, mount, and achievement targets. These changes require manual in-game validation.

## Known limitations

- Great Vault data may be empty briefly after login. Event-driven refreshes and a delayed login refresh handle the common case.
- Dungeon Vault routes optimize exact run counts at a selected Season 2 reward breakpoint. They do not compare dungeon, raid, PvP, and world activity time.
- The addon does not claim that one leveling method is universally fastest. The optimized alt route is explicitly labeled as community evidence.
- Quest scanning can miss quests hidden by the client's visible quest log structure, but the super-tracked quest is queried separately.
- Leveling dungeon guidance names the client-provided choices but does not rank their speed, estimate queue time, or inspect their loot tables.
- Item levels can be temporarily unavailable and are shown as unavailable instead of guessed.
- Upgrade eligibility is read from equipped item data. Exact discounted upgrade cost is unavailable away from an upgrade vendor, so the addon reports the standard 20 Mistcrest gap and states that discounts can lower it.
- Gear routes use published reward bands and known slots below each band. They cannot promise that a random drop will usefully replace a specific item.
- Crafted-gear routes identify a weak non-tier slot and the relevant Mistcrest tier, but they cannot inspect known recipes, chosen stats, embellishments, commission costs, or the final crafting-order result. Confirm the preview before placing an order.
- Raid Vault guidance combines the live Vault boss count with a concrete Raid Info procedure. The addon does not read the saved status of each raid boss directly, so Raid Info remains authoritative before joining a group.
- Curated data is static until the addon files are updated. It is not downloaded while WoW is running.
- The public patch catalog uses the client source text when an exact curated route is unavailable. If the client source is vague or absent, NextStep says so instead of inventing steps.
- The addon cannot observe every intermediate route step. It shows up to three verified ordered steps in each route row and keeps the full path in the card tooltip.
- Version 0.10.0 changes have not been tested inside a live WoW client in this repository session.
- Localized layouts and French wording still require in-game review.
- Client locales other than English and French currently fall back to English.
- Chance-based rewards are labeled as chance-based and never show an invented drop rate.
- Collection target icons depend on client item cache or collection APIs. A category icon is used until the target icon becomes available.
- The Weekly Rewards API exposes example reward items and generated rewards, not a complete character-specific Vault loot pool. NextStep labels examples and does not present them as the full pool.
- The item level 298 pre-season guidance ceiling is conservative and must be reviewed at the Season 2 reset. Client Vault previews remain authoritative and are labeled as future during pre-season.
- Category selection changes the compact view. It does not filter the character analysis or estimate completion time.

## Addon policy philosophy

NextStep is a progression planning addon, not a combat-decision addon. It does not provide rotations, interrupts, dispels, target selection, encounter solving, combat optimization, or protected-action automation. The player decides. NextStep explains and organizes.

This boundary follows Blizzard's published goal that addons should not automate combat decisions. NextStep does not inspect or reconstruct restricted combat state. Refresh work is deferred during combat.

## Development notes

- Keep changes small and scoped.
- Verify current Retail APIs before adding data collection.
- Keep Blizzard calls inside `API/` and `Data/`.
- Keep priorities inside `Recommendation/Scoring.lua`.
- Keep user-facing strings centralized for future localization.
- Keep speculative features out of implementation until they are explicitly requested.
- Include exact manual in-game test steps with every implementation change.

## Continuous integration

The GitHub Actions workflow validates Lua 5.1 syntax, every manifest path, duplicate manifest entries, locale parity, locale format tokens, automatic English fallback, category planning, SavedVariables migration, forbidden dash characters, and trailing whitespace.

Run the repository validators locally from the addon root:

```bash
find . -type f -name '*.lua' -not -path './.git/*' -print0 | sort -z | xargs -0 -r -n1 luac5.1 -p
bash tools/validate-toc.sh NextStep.toc
lua5.1 tools/validate-locales.lua NextStep.toc
lua5.1 tests/preferences.lua
lua5.1 tests/recommendation-navigation.lua
lua5.1 tests/leveling-dungeons.lua
lua5.1 tests/curated-routes.lua
lua5.1 tests/route-api.lua
lua5.1 tests/tooltips.lua
lua5.1 tests/patch-catalog.lua
lua5.1 tests/patch-progress.lua
lua5.1 tests/ui-layout.lua
lua5.1 tests/progression-analysis.lua
```

## API review

Reviewed against the extracted live 12.1.0 Blizzard UI source and generated API documentation on 2026-08-19.

| API | Used in | Verification | Caveats | Event dependencies |
| --- | --- | --- | --- | --- |
| `GetLocale` | `API/WoW.lua`, `Localization/Init.lua` | Confident, generated Locale docs | Selected once while addon files load; unsupported locales fall back to English | None |
| `GetBuildInfo` | `API/WoW.lua`, `Data/CuratedRoutes.lua` | Confident, generated Build docs | Curated routes are suppressed when the live interface does not match their reviewed interface | `PLAYER_LOGIN`, `PLAYER_ENTERING_WORLD` |
| `UnitName`, `UnitLevel`, `UnitClass`, `GetRealmName` | `API/WoW.lua` | Confident | Values may not be ready before login | `PLAYER_LOGIN`, `PLAYER_ENTERING_WORLD`, `UNIT_LEVEL` |
| `C_ClassColor.GetClassColor` | `API/WoW.lua`, `UI/CharacterSummary.lua` | Confident, current namespaced class color API | Falls back to NextStep gold if unavailable | `PLAYER_LOGIN` |
| `IsModifiedClick`, `HandleModifiedItemClick` | `API/WoW.lua`, `UI/Tooltips.lua` | Confident, used by Blizzard live item buttons | Preview occurs only for the player's configured dress-up modified click | User click |
| `CollectionsJournal_LoadUI`, `SetCollectionsJournalShown` | `API/WoW.lua` | Confident, used by Blizzard live collection UI | Loads the Blizzard collection UI only when the player requests a preview | User click |
| `MountJournal_SelectByMountID`, `PetJournal_SelectSpecies` | `API/WoW.lua`, `UI/Tooltips.lua` | Confident, used by Blizzard live collection UI | Requires a verified mount ID or battle pet species ID | User click |
| `GetMaxLevelForPlayerExpansion` | `API/WoW.lua` | Confident, generated Expansion docs | Returns the cap available to the player's account | `PLAYER_LOGIN` |
| `C_SpecializationInfo.GetSpecialization` | `API/WoW.lua` | Confident, generated SpecializationInfo docs | Index can be unavailable during initialization | `PLAYER_SPECIALIZATION_CHANGED`, `PLAYER_LOGIN` |
| `C_SpecializationInfo.GetSpecializationInfo` | `API/WoW.lua` | Confident, generated SpecializationInfo docs | Name can be nil while data initializes | `PLAYER_SPECIALIZATION_CHANGED`, `PLAYER_LOGIN` |
| `GetAverageItemLevel` | `API/WoW.lua` | Confident, used by Blizzard `PaperDollFrame.lua` in live source | Values may be unavailable temporarily | `PLAYER_EQUIPMENT_CHANGED`, `PLAYER_LOGIN` |
| `UnitXP`, `UnitXPMax`, `GetXPExhaustion` | `API/WoW.lua` | Confident, generated Unit and PlayerScript docs | Maximum XP is zero at level cap | `PLAYER_XP_UPDATE`, `UPDATE_EXHAUSTION`, `UNIT_LEVEL` |
| `C_QuestLog.GetNumQuestLogEntries`, `GetInfo`, `ReadyForTurnIn`, `GetTitleForQuestID` | `API/WoW.lua` | Confident, generated QuestLog docs | Entry iteration follows the visible quest log; super-tracked quest is queried separately | `QUEST_LOG_UPDATE`, `QUEST_TURNED_IN` |
| `GetQuestLogRewardXP` | `API/WoW.lua` | Confident, used by Blizzard live UI source | Can return zero or no value when an XP reward is unavailable | `QUEST_LOG_UPDATE` |
| `C_SuperTrack.GetSuperTrackedQuestID` | `API/WoW.lua` | Confident, generated SuperTrackManager docs | Can return nil | `SUPER_TRACKING_CHANGED` |
| `C_QuestLog.IsQuestFlaggedCompleted` | `API/WoW.lua`, `Data/CuratedRoutes.lua` | Confident, generated Quest Log docs | Unknown API state suppresses routes that require historical quest completion | `QUEST_LOG_UPDATE`, `QUEST_TURNED_IN` |
| `C_LFGInfo.CanPlayerUseLFD`, `GetLevelUpInstances`, `GetDungeonInfo` | `API/WoW.lua` | Confident, generated LFGInfo docs | Returns localized available choices and metadata, not speed or reward ranking | `UNIT_LEVEL`, `PLAYER_ENTERING_WORLD`, `LFG_UPDATE_RANDOM_INFO` |
| `C_MountJournal.GetMountFromItem`, `GetMountInfoByID` | `API/WoW.lua`, `Data/CuratedRoutes.lua` | Confident, generated Mount Journal docs | A missing item mapping or unavailable collection result suppresses the route | `NEW_MOUNT_ADDED`, `PLAYER_ENTERING_WORLD` |
| `C_MountJournal.GetMountFromSpell`, `GetMountInfoExtraByID`, `GetMountLink` | `API/WoW.lua`, `Data/PatchCatalog.lua` | Confident, current generated Mount Journal docs | `GetMountLink` returns a mount-display link, so it is retained only as a fallback when no verified reward item exists | `NEW_MOUNT_ADDED`, `PLAYER_ENTERING_WORLD` |
| `C_PetJournal.GetNumPetsInJournal` | `API/WoW.lua`, `Data/CuratedRoutes.lua` | Confident, generated Pet Journal docs | Uses the documented creature ID count and suppresses the route when unavailable | `PET_JOURNAL_LIST_UPDATE`, `PLAYER_ENTERING_WORLD` |
| `C_PetJournal.GetPetInfoBySpeciesID` | `API/WoW.lua`, `Data/CuratedRoutes.lua` | Confident, used by Blizzard live Pet Collection UI | Name and icon can be unavailable while collection data loads | `PET_JOURNAL_LIST_UPDATE`, `PLAYER_ENTERING_WORLD` |
| `C_PetJournal.GetNumCollectedInfo` | `API/WoW.lua`, `Data/PatchCatalog.lua` | Confident, current generated Pet Journal docs | Collection count is character-account journal state; entries marked unobtainable by the client are suppressed | `PET_JOURNAL_LIST_UPDATE`, `PLAYER_ENTERING_WORLD` |
| `GetAchievementInfo`, `GetAchievementNumCriteria`, `GetAchievementCriteriaInfo`, `GetAchievementLink` | `API/WoW.lua`, `Data/CuratedRoutes.lua` | Confident, current global API and Blizzard live Achievement UI usage | Achievement completion can be account-wide; unavailable criteria suppress the dependent route | `ACHIEVEMENT_EARNED`, `CRITERIA_UPDATE`, `PLAYER_ENTERING_WORLD` |
| `GameTooltip:SetAchievementByID`, `SetItemByID`, `SetHyperlink` | `UI/Tooltips.lua` | Confident, current GameTooltip widget methods and Blizzard live UI usage | Typed IDs are preferred; full hyperlinks remain safe fallbacks when the specialized method is unavailable | User hover |
| `GetInventoryItemID` | `API/WoW.lua` | Confident, used throughout Blizzard live equipment UI | Off-hand is excluded because two-handed weapons make an empty off-hand valid | `PLAYER_EQUIPMENT_CHANGED` |
| `GetInventoryItemLink`, `C_Item.GetDetailedItemLevelInfo` | `API/WoW.lua`, `Data/Equipment.lua`, `Data/GreatVault.lua` | Confident, used by Blizzard live equipment and Weekly Rewards UI | Item data can be temporarily uncached | `PLAYER_EQUIPMENT_CHANGED`, `GET_ITEM_INFO_RECEIVED` |
| `C_Item.GetItemInfo`, `C_Item.GetItemUpgradeInfo` | `API/WoW.lua`, `Data/Equipment.lua`, `Data/CuratedRoutes.lua`, `Data/GreatVault.lua` | Confident, generated Item docs and Blizzard Weekly Rewards usage | Names, links, and icons can be absent until item data is cached. Upgrade information can be absent outside the current upgrade system | `PLAYER_EQUIPMENT_CHANGED`, `GET_ITEM_INFO_RECEIVED` |
| `C_Item.IsItemSpecificToPlayerClass` and `C_Item.GetItemInfo` set ID | `API/WoW.lua`, `Data/Equipment.lua` | Confident, used by Blizzard live Weekly Rewards UI | Counts equipped class-specific set pieces only in the five tier slots. Active-season advice remains suppressed until current tier set IDs are verified in seasonal configuration | `PLAYER_EQUIPMENT_CHANGED`, `GET_ITEM_INFO_RECEIVED` |
| `C_CurrencyInfo.GetCurrencyInfo` | `API/WoW.lua`, `Data/Currency.lua`, `UI/CurrencyStrip.lua` | Confident, generated CurrencyInfo docs | Uses the client's `quantityEarnedThisWeek`, `maxWeeklyQuantity`, `totalEarned`, `maxQuantity`, and `useTotalEarnedForMaxQty` fields. Unknown IDs can return no data | `CURRENCY_DISPLAY_UPDATE`, `PLAYER_LOGIN` |
| `C_CurrencyInfo.GetCurrencyLink` | `API/WoW.lua`, `Data/Currency.lua`, `UI/CurrencyStrip.lua` | Confident, generated CurrencyInfo docs | Link can be unavailable while currency data initializes, so the tooltip falls back to normalized text | `CURRENCY_DISPLAY_UPDATE`, `PLAYER_LOGIN` |
| `C_WeeklyRewards.GetActivities` | `API/WoW.lua` | Confident, generated WeeklyRewards docs and Blizzard Weekly Rewards UI | Empty results can be valid or temporarily incomplete | `WEEKLY_REWARDS_UPDATE`, `PLAYER_ENTERING_WORLD` |
| `C_WeeklyRewards.GetExampleRewardItemHyperlinks` | `API/WoW.lua`, `Data/GreatVault.lua` | Confident, generated WeeklyRewards docs and Blizzard Weekly Rewards UI | Links are examples used to report item level, not a complete possible loot pool | `WEEKLY_REWARDS_UPDATE`, `GET_ITEM_INFO_RECEIVED` |
| `C_WeeklyRewards.GetActivityEncounterInfo`, `EJ_GetEncounterInfo` | `API/WoW.lua`, `Data/GreatVault.lua` | Confident, current Weekly Rewards docs and Blizzard live UI usage | Exact encounter data is available for raid activities only and can be absent during initialization | `WEEKLY_REWARDS_UPDATE`, `PLAYER_ENTERING_WORLD` |
| `C_WeeklyRewards.GetItemHyperlink` | `API/WoW.lua`, `Data/GreatVault.lua` | Confident, current Weekly Rewards docs | Resolves rewards already generated by the client; it does not enumerate all possible Vault items | `WEEKLY_REWARDS_UPDATE`, `GET_ITEM_INFO_RECEIVED` |
| `C_WeeklyRewards.GetNextActivitiesIncrease` | `API/WoW.lua`, `Data/GreatVault.lua` | Confident, generated WeeklyRewards docs | Season data can be unavailable before season activation | `WEEKLY_REWARDS_UPDATE` |
| `C_WeeklyRewards.IsWeeklyChestRetired` | `API/WoW.lua` | Confident, generated WeeklyRewards docs | A retired system suppresses recommendations | `WEEKLY_REWARDS_UPDATE` |
| `C_WeeklyRewards.HasAvailableRewards` | `API/WoW.lua` | Confident, generated WeeklyRewards docs | Indicates availability only, not the selected reward | `WEEKLY_REWARDS_UPDATE` |
| `C_MythicPlus.IsMythicPlusActive`, `GetRunHistory` | `API/WoW.lua`, `Data/MythicPlus.lua` | Confident, generated Mythic Plus docs | Run history is filtered to the current season; activity state controls pre-season guidance | `CHALLENGE_MODE_COMPLETED`, `WEEKLY_REWARDS_UPDATE`, `PLAYER_ENTERING_WORLD` |
| `C_DateAndTime.GetSecondsUntilWeeklyReset` | `API/WoW.lua`, `Data/Weekly.lua` | Confident, generated Date and Time docs | Converted to an absolute timestamp at refresh time and formatted in the player's local time | Normal data refresh |
| `C_Expansion.GetCurrentRegionName` | `API/WoW.lua`, `Data/Weekly.lua` | Confident, generated Expansion docs | Region name can be unavailable during early initialization | `PLAYER_LOGIN`, `PLAYER_ENTERING_WORLD` |
| `GetServerTime` | `API/WoW.lua` | Confident | Falls back to `time()` if unavailable | None |
| `InCombatLockdown` | `API/WoW.lua`, `Core/Events.lua` | Confident | Used only to defer refresh work | `PLAYER_REGEN_ENABLED` |
| `C_Timer.After` | `Core/Events.lua` | Confident, used throughout Blizzard live UI | Used for debounce and initial data readiness | Event coordinator |

Primary review sources:

- [Blizzard generated Locale API documentation](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/LocaleDocumentation.lua)
- [Blizzard generated Build API documentation](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/BuildDocumentation.lua)
- [Blizzard generated Weekly Rewards API documentation](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/WeeklyRewardsDocumentation.lua)
- [Blizzard generated Item API documentation](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/ItemDocumentation.lua)
- [Blizzard generated Mythic Plus API documentation](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/MythicPlusInfoDocumentation.lua)
- [Blizzard generated Currency Info API documentation](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/CurrencyInfoDocumentation.lua)
- [Blizzard generated Specialization API documentation](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/SpecializationInfoDocumentation.lua)
- [Blizzard generated Expansion API documentation](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/ExpansionDocumentation.lua)
- [Blizzard generated Date and Time API documentation](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/DateAndTimeDocumentation.lua)
- [Blizzard generated Quest Log API documentation](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/QuestLogDocumentation.lua)
- [Blizzard generated LFG Info API documentation](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/LFGInfoDocumentation.lua)
- [Blizzard generated Mount Journal API documentation](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/MountJournalDocumentation.lua)
- [Blizzard generated Pet Journal API documentation](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/PetJournalInfoDocumentation.lua)
- [Blizzard live Achievement UI source](https://github.com/Gethe/wow-ui-source/tree/live/Interface/AddOns/Blizzard_AchievementUI)
- [Blizzard generated Unit API documentation](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/UnitDocumentation.lua)
- [Blizzard generated Super Track API documentation](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/SuperTrackManagerDocumentation.lua)
- [Blizzard live quest XP reward usage](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_FrameXML/Mainline/AlertFrames.lua)
- [Blizzard live Paper Doll UI source](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_UIPanels_Game/Mainline/PaperDollFrame.lua)
- [Blizzard live Weekly Rewards UI source](https://github.com/Gethe/wow-ui-source/tree/live/Interface/AddOns/Blizzard_WeeklyRewards)
- [Blizzard current new player starter guide](https://worldofwarcraft.blizzard.com/en-us/news/24266319)
- [Blizzard 12.1 content overview](https://worldofwarcraft.blizzard.com/en-gb/news/24294370)
- [Blizzard 12.1 quest experience changes](https://worldofwarcraft.blizzard.com/en-us/news/24288418/quality-of-life-improvements-coming-in-curse-of-ulatek)
- [Blizzard Midnight Season 2 Americas schedule](https://news.blizzard.com/en-us/article/24294369/the-shadows-deepen-midnight-season-2-begins-august-18)
- [Blizzard Midnight Season 2 Europe schedule](https://news.blizzard.com/en-gb/article/24294369/the-shadows-deepen-midnight-season-2-begins-19-august)
- [Wowhead Midnight alt leveling route](https://www.wowhead.com/news/best-way-to-level-alts-fast-in-midnight-380598)
- [Wowhead Season 2 Mythic 0 clarification](https://www.wowhead.com/news/mythic-0-and-great-vault-clarifications-during-week-0-of-midnight-season-2-382296)
- [Wowhead Midnight Season 2 Mythic Plus rewards](https://www.wowhead.com/guide/midnight/mythic-plus-season-overview)
- [Wowhead Great Vault guide](https://www.wowhead.com/ptr-2/guide/systems/the-great-vault)
- [Wowhead Mistcrest upgrade guide](https://www.wowhead.com/guide/midnight/item-level-gear-upgrades-dawncrests)
- [Wowhead patch 12.1 Lair preview](https://www.wowhead.com/news/lairs-preview-in-patch-12-1-world-difficulty-solo-queue-382309)
- [Wowhead patch 12.1 Amani campaign rewards](https://www.wowhead.com/news/chapter-1-of-curse-of-ulatek-patch-12-1-campaign-now-live-382105)
- [Wowhead Dusk Grimlynx reward record](https://www.wowhead.com/item=246731/dusk-grimlynx)
- [Wowhead Akiki reward record](https://www.wowhead.com/npc=260149/akiki)
- [Icy Veins Gnarldor Isle treasure guide](https://www.icy-veins.com/wow/gnarldor-isle-delve-guide)
- [Icy Veins Coiled Isle achievement guide](https://www.icy-veins.com/wow/the-coiled-isle-guide)
- [Wowhead Coiled Isle Safari achievement](https://www.wowhead.com/achievement=62492/the-coiled-isle-safari)
- [Wowhead Altar of Fangs reward guide](https://www.wowhead.com/guide/midnight/altar-of-fangs-dungeon-overview-location-rewards)
- [Wowhead public 12.1 mount database snapshot](https://www.wowhead.com/ptr/mount-spells?filter=21;3;120100)
- [Retail ItemEffect table](https://wago.tools/db2/ItemEffect)
- [Retail ItemXItemEffect relationship table](https://wago.tools/db2/ItemXItemEffect)
- [Wowhead public 12.1 pet database snapshot](https://www.wowhead.com/ptr/battle-pets?filter=3;3;120100)
- [Wowhead public 12.1 achievement database snapshot](https://www.wowhead.com/ptr/achievements?filter=17;3;120100)
- [Wowhead Ral'kala reward research](https://www.wowhead.com/news/defeat-ralkala-fifty-times-to-earn-special-prey-achievement-in-patch-12-1-382164)
- [Blizzard combat addon philosophy](https://worldofwarcraft.blizzard.com/en-us/news/24246290)
