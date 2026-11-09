# Godot reference

Checked against: Godot 4.7 documentation, 2026-11-08.

## Detect

- `project.godot` at the project root. A `*.csproj` beside it means a C# project.
- The version is in `config/features` of `project.godot`.
- Find the `godot` executable from the game context file or the path. Never guess an install folder.

## Project layout

- `project.godot`, the `res://` root, and `export_presets.cfg` for export presets.
- Never edit or commit the `.godot/` folder. Keep each `.uid` file with its source.
- `.tscn` scenes and `.tres` resources are text, so they can be read and diffed.

## Limits and workarounds

- Text scenes are editable, but large node trees are error-prone by hand. Build them in code, or generate them from `@tool` scripts or `--script` GDScript kept in the repository.
- Shaders are text (`.gdshader`) and can be written directly.
- Visual layout and animation that only a human can judge go on the playtest list as `manual:` checks.
- When a documented command fails, read the output and `godot --help` instead of guessing flags.

## Build

- Export with a preset from `export_presets.cfg`:
  `godot --headless --export-release "<preset>" <path>`
  Export templates must be installed, and the output folder must exist.
- Use `--export-debug` for a debug build and `--export-pack` for a pack.
- `--import` imports the project's assets and then quits.
- Parse check for a script: `godot --headless --check-only --script <res://path.gd>`

## Test

- GUT: `godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit` exits 0 when tests pass and 1 when any fail.
- gdUnit4: run `addons/gdUnit4/runtest.cmd` (or `runtest.sh`) with `-a <dir>`; it writes JUnit XML. Check the installed version's docs for other flags, because they are not verified here.
- Keep game rules in plain scripts with no scene dependencies so tests stay fast.

## Performance

- Sample `Performance.get_monitor(Performance.TIME_PROCESS)` each frame in a scripted scenario and read `Performance.MEMORY_STATIC` at the end. Compute the average and the 95th percentile as `playtest-checks.md` says.
- `--headless` measures CPU logic only. Label the numbers as not representative of rendering.

## Networking

- Use the high-level multiplayer API: `MultiplayerSpawner` and `MultiplayerSynchronizer` for state, and `@rpc` functions with authority checks on the receiving side.
- Keep the server authoritative and validate every `@rpc` argument.

## Editor bridge

- No official MCP server was verified. Use a community server only when the project already configures one.

## Sources

- Godot command line tutorial: https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html
- GUT command line: https://gut.readthedocs.io/en/latest/Command-Line.html
- gdUnit4 command line: https://mikeschulze.github.io/gdUnit4/advanced_testing/cmd
