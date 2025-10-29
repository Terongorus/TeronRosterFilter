# TeronRosterFilter

A Turtle WoW guild frame addon based on aux's style.

## GUI controls
![rosterfilter](https://user-images.githubusercontent.com/678207/35249442-033ff192-ffa0-11e7-81e1-8cbca0b08d71.png)

You can access the GUI with the `/roster` slash command or you could alternatively set a keybinding in the Key Bindings menu.

If you want to change the scaling use: `/roster scale <value>` e.g.: `/roster scale 0.8`. You can also resize the window using **CTRL + drag**

## Filtering players

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
Filters are combined with `/`. Here are some examples:

- `class/rogue/rank/raider+/raid` all rogues with rank `raider` or higher that are currently in your raid group.

- `online/lvl/60/raid-` online level 60s not currently in your raid group.
