# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versions follow major.minor.hotfix (e.g. 1.2.3).

## [3.0.0] - 2026-07-10

A foundational rewrite: the addon previously failed to load at all on a real Vanilla
1.12.1 client (every file errored at line 1) despite claiming `## Interface: 11200`.
This release makes it actually work there, on top of the guild/friends data-layer
compatibility work already done in earlier, unversioned commits.

### Added
- A details side panel: clicking a roster row now shows their level, class, zone, and
  notes in a panel docked to the main window (spanning its full height), instead of
  printing to the default chat window on every click. Closes automatically whenever
  the main window does.
- An Options setting for which side (left/right) the details panel docks to, alongside
  the existing show-name / show-numbers / show-notes / scale settings — all now
  presented in a standalone frame (see Changed) instead of Blizzard's Settings panel.
- `/trf` as an additional slash command alongside the existing `/roster`, since `/rf`
  (this addon's informal short form) collides with the RollFor addon's own command.

### Changed
- Renamed from `RosterFilter` to `TeronRosterFilter` (folder, `.toc`, and the
  `ADDON_LOADED` self-check).
- Replaced the entire Lua 5.1 module bootstrap (`select(2, ...) 'modulename'`, relying
  on chunk-level vararg and the `select()` function) with a Lua-5.0-compatible
  equivalent using a shared global table — vanilla's file loader never passes
  `(addonName, addonTable)` to a chunk the way later clients do, and neither construct
  exists in Lua 5.0 at all. The module/`require` system's actual mechanics (per-module
  environments, cross-module exports) are unchanged.
- Replaced the Settings-panel registration in the options window
  (`Settings.RegisterCanvasLayoutCategory`, a Dragonflight-only API) with a standalone
  movable frame toggled by a new "Options" button on the main window, since vanilla has
  no Interface-Options-panel system at all. The checkbox/slider widgets underneath were
  already vanilla-compatible and are unchanged.

### Fixed
- Every internal use of `...`/`select()` outside a bare vararg-function declaration
  (which Lua 5.0 doesn't support at all) rewritten to Lua 5.0's `arg` table convention.
- Every widget script (`OnClick`, `OnMouseDown`, `OnDragStart`, `OnValueChanged`,
  `OnVerticalScroll`, etc.) rewritten from the modern `function(self, ...)` parameter
  style to vanilla's pre-Cataclysm convention, where the frame is the global `this` and
  payload values (mouse button, slider value, scroll offset) arrive via `arg1`, not
  function parameters.
- `#` length operator (3 sites in `gui/listing.lua`) replaced with `getn(...)` — not
  available in Lua 5.0.
- `SetColorTexture` (13 sites) replaced with `SetTexture`, which already accepts solid
  RGBA values natively in vanilla.
- `SOUNDKIT` sound-name polyfill added (vanilla has no such table), merged key-by-key
  rather than an all-or-nothing guard so it can coexist with another addon
  (TeronModernSpellBook) polyfilling the same global.
- `InviteUnit` (doesn't exist in vanilla) replaced with `InviteByName` in both the
  Guild and Friends tabs' right-click "Invite" action.
- `SetPoint("CENTER")` (single-argument form, rejected by this client) given explicit
  zero offsets.
- A `CreateFrame("Slider", f, f, ...)` call was passing a frame object where a string
  name is expected — fixed, and the slider's `Low`/`High`/`Text` sub-widgets accessed
  via vanilla's `_G[name.."Suffix"]` naming convention (no `parentKey` support for
  direct `.Low`/`.High` fields in this era's templates).
- A circular callback in the scale slider (`OnValueChanged` → save → sync callback →
  `SetValue` → re-fires `OnValueChanged` → ...) caused a C stack overflow; guarded with
  a re-entrancy flag.
- A pre-existing typo (`self.group.selected` instead of `._selected`) in the tab-click
  highlight comparison, and an `OnUpdate` handler referencing an undeclared `self`
  (always would have errored) — both caught incidentally while fixing the surrounding
  vanilla-compat issues.
