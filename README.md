# NextStep

Know what matters for you next.

NextStep is a World of Warcraft Retail addon that turns reliable character and weekly progression data into a short, explained plan. It is designed for new, returning, casual, regular, and alt-focused players who want direction without another dense dashboard.

## What it does

The first production milestone provides:

- A concise What Matters Next plan with up to five recommendations by default
- Character level, class, specialization, and item level summary
- Great Vault activity normalization and incomplete threshold recommendations
- A focused leveling recommendation below maximum level
- A configurable currency tracking pipeline
- A friendly fallback when no important action can be detected
- Saved settings and window position
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

Version 0.1.0 is an MVP intended for static review and manual in-game validation. It includes the complete data flow, UI, settings, event coordination, and the first two recommendation areas. It does not yet identify equipment upgrade eligibility, track a verified seasonal currency by default, or model broader weekly activities.

## Known limitations

- Great Vault data may be empty briefly after login. Event-driven refreshes and a delayed login refresh handle the common case.
- Great Vault wording remains generic because the addon does not infer specific content rewards.
- Currency tracking has no default IDs until active season values are verified.
- Item levels can be temporarily unavailable and are shown as unavailable instead of guessed.
- Equipment slots exist in the normalized model, but upgrade eligibility is not implemented.
- No behavior has been tested inside a live WoW client in this repository session.

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

## API review

Reviewed against the extracted live 12.1.0 Blizzard UI source and generated API documentation on 2026-08-15.

| API | Used in | Verification | Caveats | Event dependencies |
| --- | --- | --- | --- | --- |
| `UnitName`, `UnitLevel`, `UnitClass`, `GetRealmName` | `API/WoW.lua` | Confident | Values may not be ready before login | `PLAYER_LOGIN`, `PLAYER_ENTERING_WORLD`, `UNIT_LEVEL` |
| `GetMaxLevelForPlayerExpansion` | `API/WoW.lua` | Confident, generated Expansion docs | Returns the cap available to the player's account | `PLAYER_LOGIN` |
| `C_SpecializationInfo.GetSpecialization` | `API/WoW.lua` | Confident, generated SpecializationInfo docs | Index can be unavailable during initialization | `PLAYER_SPECIALIZATION_CHANGED`, `PLAYER_LOGIN` |
| `C_SpecializationInfo.GetSpecializationInfo` | `API/WoW.lua` | Confident, generated SpecializationInfo docs | Name can be nil while data initializes | `PLAYER_SPECIALIZATION_CHANGED`, `PLAYER_LOGIN` |
| `GetAverageItemLevel` | `API/WoW.lua` | Confident, used by Blizzard `PaperDollFrame.lua` in live source | Values may be unavailable temporarily | `PLAYER_EQUIPMENT_CHANGED`, `PLAYER_LOGIN` |
| `C_CurrencyInfo.GetCurrencyInfo` | `API/WoW.lua` | Confident, generated CurrencyInfo docs | Unknown or undiscovered IDs can return no data | `CURRENCY_DISPLAY_UPDATE`, `PLAYER_LOGIN` |
| `C_WeeklyRewards.GetActivities` | `API/WoW.lua` | Confident, generated WeeklyRewards docs and Blizzard Weekly Rewards UI | Empty results can be valid or temporarily incomplete | `WEEKLY_REWARDS_UPDATE`, `PLAYER_ENTERING_WORLD` |
| `C_WeeklyRewards.IsWeeklyChestRetired` | `API/WoW.lua` | Confident, generated WeeklyRewards docs | A retired system suppresses recommendations | `WEEKLY_REWARDS_UPDATE` |
| `C_WeeklyRewards.HasAvailableRewards` | `API/WoW.lua` | Confident, generated WeeklyRewards docs | Indicates availability only, not the selected reward | `WEEKLY_REWARDS_UPDATE` |
| `GetServerTime` | `API/WoW.lua` | Confident | Falls back to `time()` if unavailable | None |
| `InCombatLockdown` | `API/WoW.lua`, `Core/Events.lua` | Confident | Used only to defer refresh work | `PLAYER_REGEN_ENABLED` |
| `C_Timer.After` | `Core/Events.lua` | Confident, used throughout Blizzard live UI | Used for debounce and initial data readiness | Event coordinator |

Primary review sources:

- [Blizzard generated Weekly Rewards API documentation](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/WeeklyRewardsDocumentation.lua)
- [Blizzard generated Currency Info API documentation](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/CurrencyInfoDocumentation.lua)
- [Blizzard generated Specialization API documentation](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/SpecializationInfoDocumentation.lua)
- [Blizzard generated Expansion API documentation](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/ExpansionDocumentation.lua)
- [Blizzard live Paper Doll UI source](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_UIPanels_Game/Mainline/PaperDollFrame.lua)
- [Blizzard combat addon philosophy](https://worldofwarcraft.blizzard.com/en-us/news/24246290)
