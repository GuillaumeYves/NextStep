# NextStep

Know what matters for you next.

NextStep is a World of Warcraft Retail addon that turns reliable character and weekly progression data into a short, explained plan. It is designed for new, returning, casual, regular, and alt-focused players who want direction without another dense dashboard.

## What it does

The first production milestone provides:

- A concise What Matters Next plan with up to five recommendations by default
- Character level, class, specialization, and item level summary
- Great Vault category routes with next and following thresholds
- Exact XP progress and rested XP visibility below maximum level
- Completed quest turn-in recommendations when XP rewards are known
- Current tracked quest guidance
- Level-appropriate dungeon guidance when Dungeon Finder is usable
- Conservative empty equipment guidance
- A configurable currency tracking pipeline
- A friendly fallback when no important action can be detected
- Saved settings and window position
- Automatic locale selection from the WoW client
- Structured state and rule diagnostics

Every recommendation includes a title, a short instruction, an importance label, and a reason. NextStep does not invent activity durations, item value, best-in-slot status, or unavailable rewards.

## Installation

1. Copy this repository folder to `_retail_/Interface/AddOns/NextStep`.
2. Confirm that `NextStep.toc` is directly inside that folder.
3. Start or restart World of Warcraft Retail.
4. Enable NextStep in the AddOns list.
5. Log in and run `/nextstep`.

The current manifest targets Retail interface `120100`, corresponding to the reviewed 12.1.0 live UI source.

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

## Currency configuration

Tracked currency IDs live only in `Config/CurrencyConfig.lua`. The initial list is intentionally empty because no active seasonal currency ID was accepted without a verified source. Add a verified entry in this form:

```lua
{
    currencyID = 1234,
    enabled = true,
    description = "Short player-facing purpose.",
}
```

Document the source and season beside each added ID.

## Development status

Version 0.2.1 adds automatic client-locale selection and a French translation. The original 0.1.0 build was confirmed to load successfully by the project owner. Changes after 0.1.0 still require manual in-game validation. Equipment upgrade eligibility, exact drop routing, and verified seasonal currency defaults are not implemented.

## Known limitations

- Great Vault data may be empty briefly after login. Event-driven refreshes and a delayed login refresh handle the common case.
- Vault routes optimize threshold order within each category. They do not compare dungeon, raid, PvP, and world activity time.
- The addon does not claim that one leveling method is universally fastest.
- Quest scanning can miss quests hidden by the client's visible quest log structure, but the super-tracked quest is queried separately.
- Leveling dungeon guidance confirms client availability but does not estimate queue time.
- Currency tracking has no default IDs until active season values are verified.
- Item levels can be temporarily unavailable and are shown as unavailable instead of guessed.
- Empty slots are detectable, but equipment upgrade eligibility and exact gear sources are not implemented.
- Changes after 0.1.0 have not been tested inside a live WoW client in this repository session.
- Localized layouts and French wording still require in-game review.
- Client locales other than English and French currently fall back to English.

## Addon policy philosophy

NextStep is a progression planning addon, not a combat-decision addon. It does not provide rotations, interrupts, dispels, target selection, encounter solving, combat optimization, or protected-action automation. The player decides. NextStep explains and organizes.

This boundary follows Blizzard's published goal that addons should not automate combat decisions. NextStep does not inspect or reconstruct restricted combat state. Refresh work is deferred during combat.

## Development notes

- Keep changes small and scoped.
- Verify current Retail APIs before adding data collection.
- Keep Blizzard calls inside `API/` and `Data/`.
- Keep priorities inside `Recommendation/Scoring.lua`.
- Keep user-facing strings centralized for future localization.
- Add speculative features to `TODO.md` instead of silently implementing them.
- Include exact manual in-game test steps with every implementation change.

## Continuous integration

The GitHub Actions workflow validates Lua 5.1 syntax, every manifest path, duplicate manifest entries, locale parity, locale format tokens, automatic English fallback, forbidden dash characters, and trailing whitespace.

Run the repository validators locally from the addon root:

```bash
find . -type f -name '*.lua' -not -path './.git/*' -print0 | sort -z | xargs -0 -r -n1 luac5.1 -p
bash tools/validate-toc.sh NextStep.toc
lua5.1 tools/validate-locales.lua NextStep.toc
```

## API review

Reviewed against the extracted live 12.1.0 Blizzard UI source and generated API documentation on 2026-08-16.

| API | Used in | Verification | Caveats | Event dependencies |
| --- | --- | --- | --- | --- |
| `GetLocale` | `API/WoW.lua`, `Localization/Init.lua` | Confident, generated Locale docs | Selected once while addon files load; unsupported locales fall back to English | None |
| `UnitName`, `UnitLevel`, `UnitClass`, `GetRealmName` | `API/WoW.lua` | Confident | Values may not be ready before login | `PLAYER_LOGIN`, `PLAYER_ENTERING_WORLD`, `UNIT_LEVEL` |
| `GetMaxLevelForPlayerExpansion` | `API/WoW.lua` | Confident, generated Expansion docs | Returns the cap available to the player's account | `PLAYER_LOGIN` |
| `C_SpecializationInfo.GetSpecialization` | `API/WoW.lua` | Confident, generated SpecializationInfo docs | Index can be unavailable during initialization | `PLAYER_SPECIALIZATION_CHANGED`, `PLAYER_LOGIN` |
| `C_SpecializationInfo.GetSpecializationInfo` | `API/WoW.lua` | Confident, generated SpecializationInfo docs | Name can be nil while data initializes | `PLAYER_SPECIALIZATION_CHANGED`, `PLAYER_LOGIN` |
| `GetAverageItemLevel` | `API/WoW.lua` | Confident, used by Blizzard `PaperDollFrame.lua` in live source | Values may be unavailable temporarily | `PLAYER_EQUIPMENT_CHANGED`, `PLAYER_LOGIN` |
| `UnitXP`, `UnitXPMax`, `GetXPExhaustion` | `API/WoW.lua` | Confident, generated Unit and PlayerScript docs | Maximum XP is zero at level cap | `PLAYER_XP_UPDATE`, `UPDATE_EXHAUSTION`, `UNIT_LEVEL` |
| `C_QuestLog.GetNumQuestLogEntries`, `GetInfo`, `ReadyForTurnIn`, `GetTitleForQuestID` | `API/WoW.lua` | Confident, generated QuestLog docs | Entry iteration follows the visible quest log; super-tracked quest is queried separately | `QUEST_LOG_UPDATE`, `QUEST_TURNED_IN` |
| `GetQuestLogRewardXP` | `API/WoW.lua` | Confident, used by Blizzard live UI source | Can return zero or no value when an XP reward is unavailable | `QUEST_LOG_UPDATE` |
| `C_SuperTrack.GetSuperTrackedQuestID` | `API/WoW.lua` | Confident, generated SuperTrackManager docs | Can return nil | `SUPER_TRACKING_CHANGED` |
| `C_LFGInfo.CanPlayerUseLFD`, `GetLevelUpInstances` | `API/WoW.lua` | Confident, generated LFGInfo docs | Used only for availability and count, not speed or reward ranking | `UNIT_LEVEL`, `PLAYER_ENTERING_WORLD` |
| `GetInventoryItemID` | `API/WoW.lua` | Confident, used throughout Blizzard live equipment UI | Off-hand is excluded because two-handed weapons make an empty off-hand valid | `PLAYER_EQUIPMENT_CHANGED` |
| `C_CurrencyInfo.GetCurrencyInfo` | `API/WoW.lua` | Confident, generated CurrencyInfo docs | Unknown or undiscovered IDs can return no data | `CURRENCY_DISPLAY_UPDATE`, `PLAYER_LOGIN` |
| `C_WeeklyRewards.GetActivities` | `API/WoW.lua` | Confident, generated WeeklyRewards docs and Blizzard Weekly Rewards UI | Empty results can be valid or temporarily incomplete | `WEEKLY_REWARDS_UPDATE`, `PLAYER_ENTERING_WORLD` |
| `C_WeeklyRewards.IsWeeklyChestRetired` | `API/WoW.lua` | Confident, generated WeeklyRewards docs | A retired system suppresses recommendations | `WEEKLY_REWARDS_UPDATE` |
| `C_WeeklyRewards.HasAvailableRewards` | `API/WoW.lua` | Confident, generated WeeklyRewards docs | Indicates availability only, not the selected reward | `WEEKLY_REWARDS_UPDATE` |
| `GetServerTime` | `API/WoW.lua` | Confident | Falls back to `time()` if unavailable | None |
| `InCombatLockdown` | `API/WoW.lua`, `Core/Events.lua` | Confident | Used only to defer refresh work | `PLAYER_REGEN_ENABLED` |
| `C_Timer.After` | `Core/Events.lua` | Confident, used throughout Blizzard live UI | Used for debounce and initial data readiness | Event coordinator |

Primary review sources:

- [Blizzard generated Locale API documentation](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/LocaleDocumentation.lua)
- [Blizzard generated Weekly Rewards API documentation](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/WeeklyRewardsDocumentation.lua)
- [Blizzard generated Currency Info API documentation](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/CurrencyInfoDocumentation.lua)
- [Blizzard generated Specialization API documentation](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/SpecializationInfoDocumentation.lua)
- [Blizzard generated Expansion API documentation](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/ExpansionDocumentation.lua)
- [Blizzard generated Quest Log API documentation](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/QuestLogDocumentation.lua)
- [Blizzard generated LFG Info API documentation](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/LFGInfoDocumentation.lua)
- [Blizzard generated Unit API documentation](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/UnitDocumentation.lua)
- [Blizzard generated Super Track API documentation](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/SuperTrackManagerDocumentation.lua)
- [Blizzard live quest XP reward usage](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_FrameXML/Mainline/AlertFrames.lua)
- [Blizzard live Paper Doll UI source](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_UIPanels_Game/Mainline/PaperDollFrame.lua)
- [Blizzard current new player starter guide](https://worldofwarcraft.blizzard.com/en-us/news/24266319)
- [Blizzard combat addon philosophy](https://worldofwarcraft.blizzard.com/en-us/news/24246290)
