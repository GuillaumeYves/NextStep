# NextStep TODO

## Verified Next Features

- Expand the 12.1 pack with reviewed delve, raid, crafted gear, and outdoor progression routes.
- Promote catalog entries into curated routes as exact bosses, vendors, currencies, quests, coordinates, or achievements are verified.
- Add a weekly progression summary from APIs verified for Retail 12.1.
- Add currency selection controls for the verified seasonal currencies.
- Add richer empty-state details without increasing the primary plan size.
- Add verified translations for additional WoW client locales.

## Needs API Research

- Build a class and specialization filtered Encounter Journal loot browser for Vault activity sources. Keep example rewards distinct from a complete loot pool.
- Research reliable discounted upgrade-cost visibility away from an upgrade vendor.
- Research current reward APIs for character-specific raid, crafted, delve, and world gear routes.
- Determine whether the client exposes queue bonus rewards without relying on legacy global APIs.
- Research map and quest APIs for route grouping without fabricated travel-time estimates.
- Research stable APIs for delve completion, renown ranks, and campaign chapter progress.
- Determine whether additional weekly systems expose stable normalized progress.
- Review Great Vault world and concession categories across character states.
- Recheck the pre-season item level 298 guidance ceiling when Season 2 activates.
- Add collection drop percentages only when a current reliable source exposes a defensible rate and sample context.

## Future Product Ideas

- Tonight planner with player-defined session context, without fabricated duration estimates
- Character-specific weekly planning
- Alt awareness and account-wide goals
- Dungeon and raid progression summaries
- Reputations, professions, collections, housing, and user-created goals
- Optional import and export formats
- Locale-aware number and grammar helpers for future translated rules

## Seasonal Data

- Record the active season identifier only after a primary source confirms it.
- Add tracked currency IDs with source and season comments.
- Recheck Vault category behavior at each major Retail patch.

## Technical Debt

- Expand automated Lua tests with additional normalized PlayerState fixtures.
- Add fixtures for leveling, rested XP, quest turn-ins, empty gear, and Vault threshold routes.
- Add a packaging script that validates manifest paths and interface metadata.
- Add a SavedVariables migration registry before schema version 4 is needed.
- Add UI layout validation at small and large UI scales.
