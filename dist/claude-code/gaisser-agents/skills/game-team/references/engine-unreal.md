# Unreal reference

Checked against: Unreal Engine 5.8 documentation, 2026-11-08.

## Detect

- A `*.uproject` file at the project root.
- The version is `EngineAssociation` in the `.uproject` file.
- Find the engine folder and the editor executable from the game context file or the path. Never guess an install folder.

## Project layout

- `<Name>.uproject`, `Source/<Module>/` for C++, `Config/*.ini` for settings, and `Content/` for assets.
- `Content/` holds binary `.uasset` and `.umap` files that agents cannot read or merge.
- C++ builds need a compiler toolchain for the platform.

## Limits and workarounds

- Never hand-edit `.uasset` or `.umap` files. Blueprint and material graphs are binary, so put behavior in C++ with `UPROPERTY` parameters, and keep Blueprints thin: they only set values.
- Create assets and place actors with Python editor scripts, kept in the repository so they can be re-run. Run one with the Python Editor Script Plugin enabled:
  `UnrealEditor-Cmd <path>.uproject -ExecutePythonScript="<script.py>"`
- Keep tables in CSV files that the project imports as data tables.
- Anything only visible in the editor or in a play session goes on the playtest list as a `manual:` check.
- Engine commands change between versions; the Unreal forums report test filter changes in 5.3. When a documented command fails, read the editor log and the tool's own help (`RunUAT BuildCookRun -help`) instead of guessing flags.

## Build

- Build, cook, and stage with the Unreal Automation Tool:
  `Engine/Build/BatchFiles/RunUAT.bat BuildCookRun -project=<path>.uproject -platform=Win64 -clientconfig=Development -build -cook -stage -pak`
  Use `RunUAT.sh` on Mac and Linux. List the other options with `RunUAT BuildCookRun -help`.

## Test

- Run automation tests from the editor command line:
  `UnrealEditor-Cmd <path>.uproject -ExecCmds="Automation RunTest <Filter>;Quit" -ReportExportPath="<dir>"`
  Filter forms are `A+B`, `Set.SubSet`, and `Group:Name`.
- Or run them through Gauntlet:
  `RunUAT RunUnreal -test=UE.EditorAutomation -runtest=<Filter> -project=<path> -build=editor`
- `-unattended` and `-nullrhi` are common additions that are not on the cited documentation page. Add them only when the project's CI already does, and label them as unverified.
- Write C++ tests with the Automation Test Framework, and keep game rules in plain C++ classes so tests do not need a world.

## Performance

- Write an automation test that runs a scripted scenario and samples `FApp::GetDeltaTime()`, then compute the average and the 95th percentile as `playtest-checks.md` says.
- `stat unit` shows frame, game, and draw time in the editor; list it as a `manual:` check.
- Headless numbers (`-nullrhi`) measure CPU logic only. Label them as not representative of rendering.

## Networking

- Replicate state with `UPROPERTY(Replicated)` and implement `GetLifetimeReplicatedProps`.
- Send client requests with `UFUNCTION(Server, Reliable)` and validate them on the server before applying them.
- Keep the server authoritative for score, damage, and position.

## Editor bridge

- No official Epic MCP server was verified. Use a community server only when the project already configures one.

## Sources

- Run automation tests: https://dev.epicgames.com/documentation/en-us/unreal-engine/run-automation-tests-in-unreal-engine
- BuildCookRun: https://dev.epicgames.com/documentation/unreal-engine/build-operations-cooking-packaging-deploying-and-running-projects-in-unreal-engine
- Gauntlet RunUnreal: https://dev.epicgames.com/documentation/en-us/unreal-engine/running-gauntlet-tests-in-unreal-engine
- Python editor scripting: https://dev.epicgames.com/documentation/en-us/unreal-engine/scripting-the-unreal-editor-using-python
