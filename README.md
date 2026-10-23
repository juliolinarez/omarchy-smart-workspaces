# Smart Workspaces

A bar widget for [Omarchy](https://omarchy.org) Quattro that makes the workspace strip say more at a glance.

![preview](preview.png?v=2)

## What it shows

- **Bold** — the workspaces that live on the monitor this bar is drawn on. Each screen tells you its own set; nothing is configured.
- **Dot underneath** — that workspace has windows, whether it belongs to this screen or the other one.
- **Filled box with the number cut out** — the workspace you are on, instead of the stock glyph.
- **Dim** — the workspace lives on the other monitor, so it never reads as "here".
- **Click a number** — jumps to that workspace, on whichever monitor is showing it.

The widget reads live Hyprland state only: it adds no rules and changes no configuration.

## Install

```bash
omarchy plugin add https://github.com/juliolinarez/omarchy-smart-workspaces.git --enable
```

It lands in the left section of the bar. If another workspaces widget is still there, remove it (Setup → Bar, or `omarchy bar` subcommands) so you don't get two.

## Remove

```bash
omarchy plugin remove io.github.juliolinarez.smart-workspaces
```

## Notes and limits

- Hyprland only knows about workspaces that exist. An empty workspace that has never been opened has no monitor, so it cannot be drawn bold or badged.
- If you pin workspaces to monitors with rules and `persistent = true` (for example 1–3 on one screen and 4–6 on the other), all of them always exist and the markers are complete. Without rules, the markers simply follow the workspaces you actually have open.
- One bar surface exists per monitor, so "this monitor" is the screen where that bar is drawn. Wayland output names are compared with the names Hyprland reports.
- Colours come from the bar's foreground/background and the shell spacing scale, so it follows any theme and works in a vertical bar too.

## Requirements

- Omarchy Quattro (4.x) with `omarchy-shell` / Quickshell.
- No external dependencies.

## License

MIT. Derived from Omarchy's own Workspaces widget, which is MIT and copyright (c) David Heinemeier Hansson. See [LICENSE](LICENSE).
