# Unity reference

Checked against: Unity 6.6 documentation, 2026-11-08.

## Detect

- `ProjectSettings/ProjectVersion.txt` and an `Assets/` folder at the project root.
- The version is `m_EditorVersion` in `ProjectVersion.txt`.
- Find the editor executable from the game context file or the path. Never guess an install folder.

## Project layout

- `Assets/` holds the project's content and code; `Packages/manifest.json` lists packages; `ProjectSettings/` holds settings.
- Code compiles per assembly definition (`.asmdef`). Put rules, state, and math in a logic assembly with `"noEngineReferences": true`, so EditMode tests run fast and without the engine API.
- Editor-only code lives in an `Editor` folder, for example `Assets/Editor/`.
- Every asset has a `.meta` file with its GUID. Keep each `.meta` with its source, and never regenerate or delete one by hand.

## Limits and workarounds

- Scenes and prefabs are ID-heavy YAML with GUID references. Do not hand-edit them. Create them from editor scripts with `EditorSceneManager` and `PrefabUtility.SaveAsPrefabAsset`, and keep those scripts in the repository so they can be re-run.
- Shader Graph and the Animator are graph assets. Build them by script, or list the work as a `manual:` check.
- UI Toolkit UXML and USS are text and can be edited directly.
- Batch mode fails while the same project is open in an editor, and it needs an activated license. Report both as `not tested` with the reason, never as code failures.
- `-nographics` cannot bake global illumination.
- When a documented command fails, read the editor log (`-logFile -` prints it to the console) and the command line arguments page for the installed version instead of guessing flags.

## Build

- Run a static method from an `Editor` folder that calls `BuildPipeline.BuildPlayer`:
  `<Unity> -batchmode -nographics -quit -projectPath <dir> -executeMethod <Ns.Class.Method> -logFile -`
  An exception in the method gives exit code 1.
- Or build from a build profile: `-activeBuildProfile "<Assets/...asset>" -build <path>`.
- Or use the platform switches `-buildWindows64Player <path>` and `-buildLinux64Player <path>`, with `-buildTarget <name>` to pick the target.

## Test

- Run the Unity Test Framework from the command line:
  `<Unity> -runTests -batchmode -projectPath <dir> -testPlatform EditMode -testResults <file.xml>`
  Use `-testPlatform PlayMode` for PlayMode tests. The results are NUnit XML.
- Optional filters: `-testFilter`, `-testCategory`, and `-assemblyNames`.
- The documented command has no `-quit`. Do not add it.
- Put game rules in the logic assembly and test them in EditMode. Use PlayMode tests only for behavior that needs the engine loop.

## Performance

- Write a PlayMode test that runs a scripted scenario and samples `Time.unscaledDeltaTime` each frame and `Profiler.GetTotalAllocatedMemoryLong()` at the end. Compute the average and the 95th percentile as `playtest-checks.md` says.
- With `-nographics`, numbers measure CPU logic only. Label them as not representative of rendering and move GPU checks to the playtest list.

## Networking

- When the project has Netcode for GameObjects, use it: server-authoritative state with `NetworkVariable`, and `ServerRpc` calls validated on the server. Do not add a networking package the plan does not name.
- Check the installed package's documentation for the API of its version.

## Editor bridge

- Unity 6 has an MCP integration through the AI Assistant package. Its status varies by package version, so treat it as optional and check the installed version's documentation.
- Use it for play-mode smoke checks, console output, and screenshots. Edit through it only when the user asks.

## Sources

- Unity 6.6 command line arguments: https://docs.unity.com/en-us/engine/current/manual/unity-editor/command-line-arguments/editor
- Unity Test Framework command line: https://docs.unity3d.com/Packages/com.unity.test-framework@1.4/manual/reference-command-line.html
- Unity MCP (AI Assistant package): https://docs.unity3d.com/Packages/com.unity.ai.assistant@2.0/manual/unity-mcp-overview.html
