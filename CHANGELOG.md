# Changelog

All notable changes to NextStep are documented here.

## 0.10.0 - 2026-08-18

### Added

- Up to three ordered route steps directly in each selected category route
- Achievement-backed mount and pet routes in both their reward category and the achievement category
- A maximum-level Campaign and Unlocks category for storyline, zone access, public activities, reputations, and new playable content
- Character-gated Legacy of the Amani, Coiled Isle, Vaults of Atal'Utek, Tokka reputation, and 12.1 Delve routes
- Fixed character and account completion bars below the season status
- Red, orange, yellow, and green completion states on visible progress bars
- Native item, mount, and achievement links plus client collection details on route hover targets
- A Season-gated Venomous Abyss access and reward route under Gear
- Explicit coverage metadata and tests for campaign, weekly, Delve and outdoor, gear, raid, guaranteed or achievement collections, and chance collections

### Changed

- Dynamic Great Vault and character-specific gearing routes remain under Gear instead of appearing in Campaign and Unlocks
- The 12.1 route pack review date and official Blizzard sources now cover the live Season 2 rollout

### Fixed

- Curated routes and patch catalog entries no longer disappear when their recommendation rules run

## 0.9.0 - 2026-08-16

### Added

- A complete public 12.1 snapshot of 64 mount spells, 36 collectible pet species, and 149 achievements
- Character-filtered mount, pet, and achievement categories using localized Retail journal data
- Exact missing achievement criteria and rewards in collection task tooltips
- Exact raid encounter names and generated reward links in Great Vault tooltips
- Cached patch catalog collection so unrelated currency and equipment refreshes do not rescan every collection record
- A live Mistcrest strip with all five crest icons, current amounts, and client-provided cap progress
- Up to five selectable target previews in every category row, with hover details and Ctrl-click collection previews
- Ctrl-click previews for supported item, mount, and battle pet target icons
- Class-colored character name and lowest equipped item level with its slot
- Verified Akiki and Zesty species IDs for collection journal previews
- Optional incomplete 4-piece class-set progression when equipped set data is reliable
- Equipment-aware World Lair guidance for slots below item level 279

### Changed

- The Vault panel now uses the full width for three larger native-style rows and no longer repeats its own title or season notice
- Vault example items are explicitly labeled and never described as the complete personal loot pool
- Category task controls remain visible, stop at both ends, and expose every planned task
- The Vault summary uses compact native category and reward artwork without stretching the full-screen Vault frame atlas
- The category content is inset evenly so icons no longer sit beneath the scrollbar or outside the panel
- The main plan now uses Blizzard's portrait frame and inset panel structure
- Relevant categories are analyzed automatically, with leveling hidden at maximum level
- Vault and task rows are more compact and use clearer native panel hierarchy
- Previous and next task buttons stop at the first and final tasks
- Pre-season item upgrade text distinguishes the current guidance ceiling from later track ranks
- The leveling category is hidden at maximum level
- Mythic 0 guidance states the weekly pre-season lockout and item level 292 reward
- Task cards show only new or upcoming patch badges instead of internal evidence labels

### Removed

- First-login goal selection and character goal filtering

## 0.8.0 - 2026-08-16

### Added

- Current Retail Weekly Rewards atlases for Vault category artwork, reward cards, checkmarks, frame backing, and decoration
- Target reward icons and item links in normalized recommendation metadata
- Carousel target cards with acquisition labels and item or route tooltips
- Explicit acquisition types for guaranteed, achievement, chance, verified, and live-client targets
- Pre-season baseline, current guidance ceiling, future-preview, and above-ceiling state in normalized progression data
- Automated coverage for target icons, unpublished drop rates, Vault preview icons, and the pre-season ceiling

### Changed

- The main window is wider and uses a Midnight background, portrait treatment, and a larger built-in style Vault presentation
- Vault values are labeled as next-reset previews while Season 2 is not active
- Present-tense upgrade guidance stops at item level 298 during the reviewed pre-season week
- Chance rewards now state that no reliable percentage is published when the local route has no documented rate

### Fixed

- Future Season 2 item levels can no longer read as currently obtainable pre-season recommendations

## 0.7.0 - 2026-08-16

### Added

- Live achievement and criterion progress normalization for curated routes
- Guaranteed Delver's Arcane Golem and achievement-based Auriferous Venomfang routes
- A season-gated, explicitly chance-based Writhing Brood route
- An eight-species Coiled Isle Safari route with missing criteria for the Zesty battle pet
- Shared rich tooltips for every recommendation and every Great Vault slot
- Vault progress bars, category icons, task hover states, and native-style title bands
- Achievement and criteria refresh events plus automated API and route coverage

### Changed

- Collection routes now disappear when their reward is collected or their required achievement is complete
- Tooltips now expose current progress, remaining criteria, exact route steps, evidence confidence, and reviewed sources
- Dynamic leveling and gearing recommendations receive the same hover explanation treatment as curated routes
- Guaranteed collection rewards rank above achievement grinds and chance drops

## 0.6.0 - 2026-08-16

### Added

- A category selector and Open Plan button in the compact window
- Per-category previous and next task navigation in both windows
- A dedicated Great Vault grid showing locked and unlocked slots, progress, and live preview item levels
- A local-time weekly reset reminder with the current client region
- Persisted dragging for the settings window
- Explicit active-season and pre-season progression state
- Current Amani campaign reward evidence for the included mount and battle pet routes

### Changed

- The compact window now shows only category, current step, and a short reason
- The main window now presents title, tagline, character, Great Vault, reset, and selected category rows in that order
- Future Season 2 Mythic Plus reward tables are used only when the client reports Mythic Plus active
- Pre-season gearing uses the published item level 292 Mythic 0 baseline
- Long task text uses a first complete sentence in compact layouts, with reviewed route details available in tooltips
- SavedVariables schema advanced to version 3 for settings-window position

### Fixed

- Upgrade-route tooltip steps no longer leak into the leveling-dungeon rule

## 0.5.0 - 2026-08-16

### Added

- A sourced local Season 2 progression table for Mythic Plus end rewards, Vault rewards, reward breakpoints, Lairs, and all five Mistcrest tiers
- Per-slot equipped item level, upgrade rank, upgrade track, and maximum upgrade item level normalization
- Current-week Mythic Plus run history and season activity state normalization
- Exact Great Vault preview item levels and next reward-increase data from the Retail client
- Character-specific item upgrade, fast gearing breakpoint, and optimized Dungeon Vault recommendations
- Exact standard Mistcrest gaps with a clear caveat for character discounts
- Refreshes after item data arrives and after a Mythic Plus completion
- Automated progression-analysis coverage

### Changed

- The generic Mythic 0 route is replaced by equipment-aware Season 2 analysis
- Dungeon Vault guidance now counts runs at the selected key level instead of only repeating the raw Vault threshold
- Seasonal currency IDs are enabled from the verified local 12.1 data pack

## 0.4.0 - 2026-08-16

### Added

- A local, versioned 12.1 route pack split into leveling, gearing, mount, and battle pet data files
- Character-aware route requirements for level ranges, maximum level, item level, completed quests, and collection ownership
- Official new-player paths from Exile's Reach through Midnight
- A sourced Midnight alt route with explicit community-guide confidence
- A Season 2 Mythic 0 item level 292 baseline route for eligible max-level characters
- Exact Dusk Grimlynx and Akiki quest-reward collection routes
- Ordered route steps, source URLs, evidence type, confidence, patch, and review date in normalized state
- Route detail tooltips on recommendation cards
- Refresh events for newly collected mounts and battle pet journal changes
- Automated route selection tests

### Changed

- Curated leveling routes replace the generic leveling card when a verified patch route applies
- The compact window shows the first actionable step of a curated route
- Version-specific guide data can now be refreshed without changing recommendation or UI logic

## 0.3.1 - 2026-08-16

### Added

- Previous and next controls for browsing the compact plan
- A compact step counter that shows the current plan position
- Exact localized Dungeon Finder names in leveling guidance when the client provides them
- Normalized Dungeon Finder IDs, names, icons, and links for future route details
- Automated tests for compact recommendation navigation

### Changed

- The compact window preserves the visible recommendation across data refreshes
- Navigation controls stop at the first and final recommendation
- Leveling dungeon guidance no longer reports only a generic activity count when names are available
- Leveling fallback guidance shows the exact XP remaining to the next level when that value is available

## 0.3.0 - 2026-08-16

### Added

- First-run setup for each character
- Per-character experience, gear, mount, and battle pet goals
- Movable compact window showing the highest-priority next step
- Character controls for reopening setup and disabling the compact window
- Goal metadata on normalized recommendations
- Automated tests for character defaults, migration, goal filtering, and critical recommendations

### Changed

- Main, settings, debug, recommendation, and summary panels use a WoW-style dark and gold theme
- The planner filters non-critical recommendations using the current character's selected goals
- SavedVariables schema advanced to version 2 with additive character profile defaults
- Reset now restores account settings and the active character profile

## 0.2.1 - 2026-08-16

### Added

- Automatic locale selection from the WoW client
- Complete English fallback for missing or unsupported locale strings
- French translations for the main window, recommendations, settings, chat feedback, and debug headings
- GitHub Actions validation for Lua syntax, manifest integrity, localization, and text policy
- Local manifest and localization validation scripts

### Changed

- User-facing importance labels, item summaries, Vault activity names, and plural nouns now come from locale tables
- Localization now loads after the API wrapper so locale detection remains isolated from recommendation and UI logic

## 0.2.0 - 2026-08-16

### Added

- Exact XP progress and rested XP normalization
- Completed quest turn-in detection with known XP rewards
- Super-tracked quest guidance
- Level-appropriate Dungeon Finder guidance
- Conservative empty equipment detection
- Leveling quest and dungeon activities in normalized PlayerState
- XP, quest, tracking, and rested-state event refreshes
- Lightweight XP-only refreshes without repeated equipment or Vault scans

### Changed

- Leveling plans now favor character-specific evidence over generic advice
- Vault recommendations show category names and the next two unfinished thresholds
- Vault world and PvP progress use generic progress wording where units are not safely known
- Recommendation cards support longer route descriptions

## 0.1.0 - 2026-08-15

### Added

- Retail 12.1.0 addon manifest and modular namespace
- Versioned SavedVariables with basic settings and character presence records
- Event-driven, debounced refresh coordination with combat deferral
- Character, equipment summary, currency, and Great Vault data modules
- Normalized PlayerState, Activity, and Recommendation models
- Independent leveling and Great Vault recommendation rules
- Central scoring, validation, deduplication, tracing, and concise planning
- Movable main window with reusable recommendation cards and fallback state
- Settings and structured debug windows
- Slash commands for window, diagnostics, and reset
- API review, development rules, roadmap, and project documentation
