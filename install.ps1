<#
.SYNOPSIS
Manual installer for the gaisser-agents catalog (Claude Code and Codex) on Windows.

.DESCRIPTION
Copies the catalog's agents and skills into a Claude Code and/or Codex setup.
Existing files are never overwritten silently: identical files are reported as
unchanged, different files are skipped unless -Force is given, in which case the
old copy is moved to an agent-catalog-backups folder first.
Works in Windows PowerShell 5.1 and PowerShell 7 on Windows. On macOS and Linux
use install.sh.

Destinations (relative to -Base):
  claude  agents: .claude\agents\<name>.md      skills: .claude\skills\<skill>\
  codex   agents: .codex\agents\<name>.toml     skills: .agents\skills\<skill>\
          (agents go to $env:CODEX_HOME\agents when -Base is omitted and CODEX_HOME is set)

Exit codes: 0 success, 1 a file operation failed, 2 usage error.

.PARAMETER List
List the available plugins for the selected target(s) and exit.

.PARAMETER Target
claude (default), codex, or all.

.PARAMETER Plugin
Plugin to install. Accepts several values, or a comma-separated list. The catalog ships
one plugin, gaisser-agents, for every target.

.PARAMETER All
Install every plugin (the whole catalog).

.PARAMETER Base
Home-like root to install into. Default: your home folder. Relative paths resolve
against the current directory; the folder is created if missing.

.PARAMETER AgentsOnly
Codex only: install the agents but not the skill (use this when you installed the Codex plugin).

.PARAMETER Force
Overwrite files that differ. The old copy is moved to a backup folder first.

.PARAMETER DryRun
Show what would happen without creating or changing anything.

.PARAMETER Help
Show this help.

.EXAMPLE
.\install.ps1 -Target codex -Plugin gaisser-agents

.EXAMPLE
.\install.ps1 -Target all -All -Base C:\work\my-project -DryRun
#>
param(
    [switch]$List,
    [ValidateSet('claude', 'codex', 'all')][string]$Target = 'claude',
    [string[]]$Plugin,
    [switch]$All,
    [string]$Base,
    [switch]$AgentsOnly,
    [switch]$Force,
    [switch]$DryRun,
    [switch]$Help
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($Help) {
    Get-Help -Full $PSCommandPath
    exit 0
}

$ScriptDir = $PSScriptRoot
$Targets = @()
if ($Target -eq 'all') { $Targets = @('claude', 'codex') } else { $Targets = @($Target) }

function Get-SrcRoot([string]$t) {
    if ($t -eq 'claude') { return (Join-Path $ScriptDir 'dist\claude-code') }
    return (Join-Path $ScriptDir 'dist\codex')
}

function Get-AgentExt([string]$t) {
    if ($t -eq 'claude') { return '.md' }
    return '.toml'
}

function Get-AvailablePlugins([string]$t) {
    $root = Get-SrcRoot $t
    if (-not (Test-Path -LiteralPath $root)) { return @() }
    return @(Get-ChildItem -LiteralPath $root -Directory | ForEach-Object { $_.Name })
}

function Get-PluginAgents([string]$t, [string]$p) {
    $dir = Join-Path (Join-Path (Get-SrcRoot $t) $p) 'agents'
    if (-not (Test-Path -LiteralPath $dir)) { return @() }
    $ext = Get-AgentExt $t
    return @(Get-ChildItem -LiteralPath $dir -File | Where-Object { $_.Extension -eq $ext } | ForEach-Object { $_.BaseName })
}

function Get-PluginSkills([string]$t, [string]$p) {
    $dir = Join-Path (Join-Path (Get-SrcRoot $t) $p) 'skills'
    if (-not (Test-Path -LiteralPath $dir)) { return @() }
    return @(Get-ChildItem -LiteralPath $dir -Directory | ForEach-Object { $_.Name })
}

if ($List) {
    foreach ($t in $Targets) {
        foreach ($p in (Get-AvailablePlugins $t)) {
            $a = (Get-PluginAgents $t $p) -join ', '
            $s = (Get-PluginSkills $t $p) -join ', '
            Write-Output ("[{0}] {1}   agents: {2}   skills: {3}" -f $t, $p, $a, $s)
        }
    }
    exit 0
}

# Valid plugin names across the selected targets.
$Valid = @()
foreach ($t in $Targets) {
    foreach ($p in (Get-AvailablePlugins $t)) {
        if ($Valid -notcontains $p) { $Valid += $p }
    }
}

$Selected = @()
if ($All) {
    $Selected = $Valid
}
elseif ($Plugin) {
    foreach ($item in $Plugin) {
        foreach ($name in ($item -split ',')) {
            $n = $name.Trim()
            if ($n -eq '') { continue }
            if ($Valid -notcontains $n) {
                [Console]::Error.WriteLine("install.ps1: unknown plugin '$n'. Valid plugins: " + ($Valid -join ', '))
                exit 2
            }
            if ($Selected -notcontains $n) { $Selected += $n }
        }
    }
}

if ($Selected.Count -eq 0) {
    [Console]::Error.WriteLine('No plugin selected. Available plugins: ' + ($Valid -join ', '))
    [Console]::Error.WriteLine('Use -Plugin NAME or -All. Run Get-Help .\install.ps1 -Full for usage.')
    exit 2
}

# Resolve the base folder.
$BaseGiven = $PSBoundParameters.ContainsKey('Base')
if (-not $BaseGiven) { $Base = $HOME }
if ([string]::IsNullOrWhiteSpace($Base)) {
    [Console]::Error.WriteLine('install.ps1: refusing to use an empty base folder')
    exit 2
}
if (-not [System.IO.Path]::IsPathRooted($Base)) {
    $Base = Join-Path (Get-Location).Path $Base
}
$Base = [System.IO.Path]::GetFullPath($Base)
if ($Base -eq [System.IO.Path]::GetPathRoot($Base)) {
    [Console]::Error.WriteLine('install.ps1: refusing to use a filesystem root as the base folder')
    exit 2
}
$Base = $Base.TrimEnd('\', '/')

$CodexHome = Join-Path $Base '.codex'
if ((-not $BaseGiven) -and $env:CODEX_HOME) {
    $CodexHome = [System.IO.Path]::GetFullPath($env:CODEX_HOME).TrimEnd('\', '/')
    if ($CodexHome -eq [System.IO.Path]::GetPathRoot($CodexHome)) {
        [Console]::Error.WriteLine('install.ps1: refusing to use a filesystem root as CODEX_HOME')
        exit 2
    }
}

$Stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$Prefix = ''
if ($DryRun) { $Prefix = '[dry-run] ' }
$script:Failed = $false
$script:Counts = @{ installed = 0; unchanged = 0; skipped = 0; overwritten = 0 }

function Write-Status([string]$status, [string]$t, [string]$label, [string]$extra) {
    $line = "{0}[{1}] {2}: {3}" -f $Prefix, $status, $t, $label
    if ($extra) { $line = $line + ' - ' + $extra }
    Write-Output $line
}

function Copy-Item2([string]$src, [string]$dst, [bool]$recurse) {
    if ($DryRun) { return }
    $parent = Split-Path -Parent $dst
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
    if ($recurse) {
        Copy-Item -LiteralPath $src -Destination $dst -Recurse -Force
    }
    else {
        Copy-Item -LiteralPath $src -Destination $dst -Force
    }
}

function Backup-Item([string]$dst, [string]$bpath) {
    if ($DryRun) { return }
    $parent = Split-Path -Parent $bpath
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
    Move-Item -LiteralPath $dst -Destination $bpath
}

function Test-SameFile([string]$a, [string]$b) {
    if (-not (Test-Path -LiteralPath $b -PathType Leaf)) { return $false }
    $ha = (Get-FileHash -Algorithm SHA256 -LiteralPath $a).Hash
    $hb = (Get-FileHash -Algorithm SHA256 -LiteralPath $b).Hash
    return ($ha -eq $hb)
}

function Test-SameFolder([string]$a, [string]$b) {
    if (-not (Test-Path -LiteralPath $b -PathType Container)) { return $false }
    $fa = @(Get-ChildItem -LiteralPath $a -Recurse -File | ForEach-Object { $_.FullName.Substring($a.Length).TrimStart('\', '/') } | Sort-Object)
    $fb = @(Get-ChildItem -LiteralPath $b -Recurse -File | ForEach-Object { $_.FullName.Substring($b.Length).TrimStart('\', '/') } | Sort-Object)
    if ($fa.Count -ne $fb.Count) { return $false }
    for ($i = 0; $i -lt $fa.Count; $i++) {
        if ($fa[$i] -ne $fb[$i]) { return $false }
        if (-not (Test-SameFile (Join-Path $a $fa[$i]) (Join-Path $b $fb[$i]))) { return $false }
    }
    return $true
}

function Install-Item([string]$t, [string]$kind, [string]$label, [string]$src, [string]$dst,
                      [string]$csrc, [string]$cdst, [string]$broot) {
    $rec = ($kind -eq 'skill')
    try {
        if (-not (Test-Path -LiteralPath $dst)) {
            Copy-Item2 $src $dst $rec
            Write-Status 'installed' $t $label ''
            $script:Counts.installed++
        }
        elseif ((($kind -eq 'skill') -and (Test-SameFolder $src $dst)) -or
                (($kind -ne 'skill') -and (Test-SameFile $csrc $cdst))) {
            Write-Status 'unchanged' $t $label ''
            $script:Counts.unchanged++
        }
        elseif (-not $Force) {
            Write-Status 'skipped' $t $label "differs from this repo's version (use -Force to overwrite)"
            $script:Counts.skipped++
        }
        else {
            $bpath = Join-Path (Join-Path (Join-Path $broot 'agent-catalog-backups') $Stamp) ($label.TrimEnd('/') -replace '/', '\')
            Backup-Item $dst $bpath
            # The destination must not exist when copying a folder (Copy-Item would nest it).
            Copy-Item2 $src $dst $rec
            Write-Status ("overwritten (backup: $bpath)") $t $label ''
            $script:Counts.overwritten++
        }
    }
    catch {
        Write-Status 'failed' $t $label $_.Exception.Message
        $script:Failed = $true
    }
}

foreach ($t in $Targets) {
    $script:Counts = @{ installed = 0; unchanged = 0; skipped = 0; overwritten = 0 }
    if ($t -eq 'claude') {
        $agentsDst = Join-Path $Base '.claude\agents'
        $skillsDst = Join-Path $Base '.claude\skills'
        $broot = Join-Path $Base '.claude'
    }
    else {
        $agentsDst = Join-Path $CodexHome 'agents'
        $skillsDst = Join-Path $Base '.agents\skills'
        $broot = $CodexHome
    }
    $ext = Get-AgentExt $t
    foreach ($p in $Selected) {
        $pdir = Join-Path (Get-SrcRoot $t) $p
        if (-not (Test-Path -LiteralPath $pdir)) {
            Write-Status 'n/a' $t $p 'not available for this tool'
            continue
        }
        $adir = Join-Path $pdir 'agents'
        if (Test-Path -LiteralPath $adir) {
            foreach ($f in (Get-ChildItem -LiteralPath $adir -File | Where-Object { $_.Extension -eq $ext })) {
                $dst = Join-Path $agentsDst $f.Name
                Install-Item $t 'agent' ("agents/" + $f.Name) $f.FullName $dst $f.FullName $dst $broot
            }
        }
        $sdir = Join-Path $pdir 'skills'
        if ((Test-Path -LiteralPath $sdir) -and (($t -ne 'codex') -or (-not $AgentsOnly))) {
            foreach ($d in (Get-ChildItem -LiteralPath $sdir -Directory)) {
                $dst = Join-Path $skillsDst $d.Name
                Install-Item $t 'skill' ("skills/" + $d.Name + "/") $d.FullName $dst `
                    (Join-Path $d.FullName 'SKILL.md') (Join-Path $dst 'SKILL.md') $broot
            }
        }
    }
    Write-Output ("{0}: Installed: {1}, unchanged: {2}, skipped: {3}, overwritten: {4}" -f $t,
        $script:Counts.installed, $script:Counts.unchanged, $script:Counts.skipped, $script:Counts.overwritten)
}

if ((-not $DryRun) -and (-not $script:Failed)) {
    Write-Output ''
    Write-Output 'Restart the tool (or start a new session) to load new agents and skills.'
    Write-Output "Claude manual installs are not namespaced: use 'dev-architect', not 'gaisser-agents:dev-architect', and call a team with its skill, for example /dev-team."
    Write-Output 'In Codex, call a team with its skill, for example $dev-team.'
    Write-Output 'To update later: git pull, then re-run this script with -Force.'
}

if ($script:Failed) { exit 1 }
exit 0
