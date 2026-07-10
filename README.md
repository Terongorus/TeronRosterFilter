# Teron's Roster Filter

A **World of Warcraft Vanilla 1.12.1** guild and friends roster browser — a full
replacement for the default Guild and Friends windows, with text-based search/filter
syntax, sortable columns, and quick right-click actions (whisper, invite, edit notes,
remove friend), instead of Blizzard's plain member list.

This is Kaloyan "Terongorus" Kolev's personal fork of **RosterFilter**, a Retail addon
originally by **Starhammer**, back-ported to run natively on pure Vanilla 1.12.1 clients
(e.g. TwinStar Kronos V) as well as Turtle WoW.

---

## Features

- **Guild tab** — every guild member, with name, level, class, rank, zone, and notes,
  sortable by any column. Right-click a member for Whisper / Invite / Edit Note / Edit
  Officer Note / Copy Name.
- **Friends tab** — your full friends list with online/offline status, level, class,
  zone, and notes. Right-click a friend for Whisper / Invite / Remove Friend.
- **Text filter syntax** (Guild tab) — type a query in the search box to narrow the
  list down. See [Filtering players](#filtering-players) below.
- **Details panel** — click any row to open a side panel (docked to the left or right
  of the main window, spanning its full height, similar to the default Guild UI's
  member-info panel) showing level, class, zone, and notes, instead of printing to chat.
  Closes automatically whenever the main window does.
- **Options panel** (via the "Options" button on the main window) — toggle showing the
  guild name, member counts, and guild notes column, adjust the window scale, and pick
  which side the details panel docks to.
- **Class-colored names** in the guild roster (Vanilla-compatible `RAID_CLASS_COLORS`
  0-1 range).

## Installation

1. Download or clone this repository into your `Interface\AddOns\` folder.
2. Make sure the folder is named exactly `TeronRosterFilter` — WoW requires the folder
   name to match the `.toc` filename inside it, or the client won't detect the addon.
3. Restart the game client (or `/reload`).

## Usage

Open the window with `/roster` or `/trf` (both work identically — `/trf` exists because
`/rf` is already used by the RollFor addon), or bind a key to it in the Key Bindings
menu ("Roster Filter" category, "Toggle Window").

- **Move** the window by dragging it; **resize** it by holding **Ctrl** and dragging.
- Adjust the window scale directly from the command line too: `/roster scale <value>`
  (e.g. `/roster scale 0.8`), or from the Options panel.

## Filtering players

Type filters into the Guild tab's search box (defaults to `online`). Available filters:

```
class/<class name>
rank/<rank name>
rank/<rank name>+
rank/<rank name>-
zone/<zone name>
raid
raid-
online
offline/<days>
lvl/<level>
lvl/<min>-<max>
role/<heal/tank/dps/melee/ranged/caster>
```

Filters are combined with `/`. Anything that doesn't match a known filter name is
treated as a plain text search across name, level, class, rank, zone, and notes.
Examples:

- `class/rogue/rank/raider+/raid` — all rogues with rank "raider" or higher currently
  in your raid group.
- `online/lvl/60/raid-` — online level 60s not currently in your raid group.

The Friends tab has no search box — it always shows your full friends list, sortable by
column.

## Compatibility

- **Pure Vanilla 1.12.1** (e.g. TwinStar Kronos V) — primary target of this fork.
- **Turtle WoW** — also works, since Turtle hasn't changed the UI elements this addon
  touches from vanilla's originals.

## Credits

- Original **RosterFilter** addon by **Starhammer**.
- Initial Vanilla 1.12.1 compatibility pass by **GitHub Copilot** and **ivanovlk**.
- Further Vanilla compatibility fixes (module/event system, widget script conventions,
  API differences), the details panel, and ongoing maintenance of this fork by
  **Terongorus**.
