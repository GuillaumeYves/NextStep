# Changelog

All notable changes to NextStep are documented here.

## 0.2.1 - 2026-08-16

### Added

- Automatic locale selection from the WoW client
- Complete English fallback for missing or unsupported locale strings
- French translations for the main window, recommendations, settings, chat feedback, and debug headings

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
