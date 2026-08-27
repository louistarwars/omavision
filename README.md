# OmaVision

**A live visual map of your Omarchy system.**

OmaVision turns the Omarchy shell into a system observability surface: CPU/memory, workspaces, Hyprland windows, top processes, network socket count, GPU summary and a visual constellation of the current desktop.

## Features

- Live CPU, memory, uptime and TCP socket indicators.
- Workspace → window → process constellation.
- Top process table sorted by CPU.
- Hyprland window topology view.
- No root privileges.
- No network access.
- No telemetry.
- Uses Omarchy's supported Quickshell `panel` plugin contract.

## Install

```bash
omarchy plugin add https://github.com/louistarwars/omavision.git --enable
```

For a local copy:

```bash
omarchy plugin add ~/path/to/omavision --enable
```

## Open it

Summon the panel through Omarchy shell IPC:

```bash
omarchy-shell shell summon louistarwars.omavision '{}'
```

A Hyprland keybind can be added to make it instant. For example:

```ini
bind = SUPER, V, exec, omarchy-shell shell summon louistarwars.omavision '{}'
```

## Validate

```bash
omarchy plugin validate .
```

After editing QML, Omarchy's shell can reload the plugin automatically; a full restart is also available with:

```bash
omarchy restart shell
```

## Privacy

The plugin executes only local read-only commands (`ps`, `hyprctl`, `/proc`, `uname`, and optional `nvidia-smi`/`lspci`). It does not make network requests or collect data.

## Current limitations

This v1.0 intentionally focuses on reliable read-only visualization. It does not kill processes, reconfigure Hyprland, inspect packet contents, or claim to infer causal relationships it cannot know from the local APIs.

## Roadmap

- Process ancestry graph.
- Per-window CPU/memory attribution.
- Interactive “X-Ray” drill-down.
- Historical timeline and replay.
- Optional local AI explanations.
- Plugin API for Docker/Git/CTF integrations.

MIT License.


## v2.0

- Complete visual redesign
- Simplified Overview / Apps / System views
- Native Omarchy top-bar widget
- No custom keyboard shortcut required
- Live system data remains local-only
