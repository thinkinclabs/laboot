# laboot

`laboot` runs multi-platform commands from a single source: `laboot <url>` fetches a URL and forwards it into your platform's default shell (`bash` on macOS/Linux, PowerShell on Windows). Named commands (`laboot <name>`) are shorthand for a URL on this repo. Bootstrapping [labrain](https://github.com/thinkinclabs/labrain) (private) is just the first command that happens to live here — `laboot` itself is generic.

This repo has **no `main`-branch code** — `main` is docs only. Each supported platform is a separate branch holding that platform's scripts.

## Platforms

| Platform | Branch | Shell |
|---|---|---|
| macOS | `mac` | bash |
| Linux | `linux` | bash |
| Windows | `windows` | PowerShell |

## Commands

Command names are **dash-separated** (`setup-labrain`, not `setup_labrain`).

> **Note:** commands were originally underscore-named (`setup_labrain`). Renamed to dashes for consistency with normal CLI-tool naming conventions. If you have anything hardcoding an old `setup_*` name, update it — the underscored files no longer exist on any branch.

| Name | Platforms | Does |
|---|---|---|
| `install` | all | Installs or updates the `laboot` CLI itself. |
| `setup` | all | Meta-command: runs `setup-labrain` then `setup-obsidian`. |
| `setup-labrain` | all | Clones [labrain](https://github.com/thinkinclabs/labrain) (private) if needed and persists `$LABRAIN_PATH` — depends on `setup-gh`, run through `laboot` itself. This logic used to live in labrain's own repo; it's a laboot command now, labrain has no bootstrap script of its own anymore. |
| `setup-obsidian` | all | Installs/refreshes [kepano/obsidian-skills](https://github.com/kepano/obsidian-skills) into labrain's `./.claude`. Resolves `$LABRAIN_PATH` by *sourcing* `setup-labrain.sh` (not calling it as a `laboot` subprocess) so the variable lands in this shell too. |
| `setup-gh` | all | Ensures the GitHub CLI is installed and authenticated. On macOS/Linux, falls back to Homebrew via `setup-brew` if no native package manager is found; on Windows, uses `winget`. |
| `setup-brew` | macOS, Linux | Ensures Homebrew is installed. |
| `setup-sdkman` | macOS, Linux, Windows (via Git Bash) | Ensures [SDKMAN](https://sdkman.io) is installed. No native Windows installer, so the Windows command runs the same bash script through Git for Windows' bundled `bash.exe`. SDKMAN's own installer needs `zip`/`unzip`, which a bare Git for Windows install doesn't ship (no package manager to add it either) — install those yourself first if it fails. |
| `setup-nvm` | macOS, Linux, Windows (via Git Bash) | Ensures [nvm](https://github.com/nvm-sh/nvm) is installed. Same Git Bash delegation as `setup-sdkman`. |
| `setup-backend` | macOS | Backend dev prerequisites — currently just SDKMAN, via `setup-sdkman`. Afterwards, inside a repo with an `.sdkmanrc`, run `sdk env install`. |
| `setup-web` | macOS | Web dev prerequisites: nvm (via `setup-nvm`), Node (from `./.nvmrc` if present, else latest LTS) and Yarn via corepack. Ends by offering the native suite (`setup-native`) — the prompt reads `/dev/tty` (stdin is the pipe under `curl \| bash`); non-interactive runs skip it, `LABOOT_NATIVE=1`/`0` forces/silences it. |
| `setup-native` | macOS | Meta-command: runs `setup-android` then `setup-ios`. |
| `setup-android` | macOS | Android native tooling: adb (`android-platform-tools` cask) + Android Studio cask, and persists `ANDROID_HOME`/`PATH` to your shell rc (SDK's own `platform-tools` first, so it wins over the Homebrew adb once the SDK exists). Open Android Studio once to let its wizard download the SDK/emulator, create a virtual device in Device Manager, then `adb reverse tcp:8080 tcp:8080` works against any attached device/emulator. |
| `setup-ios` | macOS | iOS native tooling: Xcode Command Line Tools, watchman, CocoaPods. Full Xcode (simulator) needs an App Store login and can't be installed unattended — the command checks for it and prints instructions instead. |

Every command is `scripts/<name>.sh` (`.ps1` on `windows`) on the matching platform branch. The general shape for running any command directly, without `laboot` installed, is the same fetch-and-forward `laboot <url>` does internally:

```sh
COMMAND=setup-labrain
BRANCH=mac   # or linux, or windows
curl -fsSL "https://raw.githubusercontent.com/thinkinclabs/laboot/$BRANCH/scripts/$COMMAND.sh" | bash
```

## Installing laboot

The one raw one-liner you ever need — everything after this goes through `laboot` itself.

**macOS / Linux:**
```sh
curl -fsSL https://raw.githubusercontent.com/thinkinclabs/laboot/mac/scripts/install.sh | bash
```

**Windows:**
```powershell
irm https://raw.githubusercontent.com/thinkinclabs/laboot/windows/scripts/install.ps1 | iex
```

This installs `laboot` onto your `PATH`. From then on:

**Run a named command:**
```sh
laboot setup-labrain
```

**Update laboot itself — same mechanism, self-hosted:**
```sh
laboot install
```

**Forward any URL straight to your shell:**
```sh
laboot https://example.com/x
```

## Maintaining this repo

- **Adding a new command**: add `scripts/<name>.sh` (`.ps1` on `windows`) to every platform branch that should support it, keep the flow (check → install if missing → check auth → login if needed → do the thing) parallel across branches, then add a row to the Commands table above.
- **`laboot` and `install` are commands too** — they live at `scripts/laboot.sh`/`scripts/install.sh` and follow the exact same cross-branch-parity rule as any other command. `install` fetches the current branch's `laboot.sh` and writes it to a `PATH` location; `laboot` itself just resolves a name or URL and forwards it to the shell — keep it that thin, all real logic belongs in the individual command scripts.
- **Shared helpers live in `scripts/utils.sh`/`utils.ps1`** (per branch) — the `info`/`Info` banner and anything else common to multiple commands. `laboot.sh`/`laboot.ps1` sources it once and shares it with every command it runs (bash: `export -f`; PowerShell: `Invoke-Expression` already runs in the calling scope). A command invoked standalone (no `laboot` installed yet) sources it itself, guarded so it's a no-op when already defined — see any `setup-*` script for the pattern.
- **A command's own prerequisites go through `laboot` too** — e.g. `setup-labrain` needs `setup-gh`, `setup-gh` may need `setup-brew`. Never hand-roll a second fetch for a dependency; ensure `laboot` is installed (same guard pattern used everywhere), then call `laboot <dependency-name>`. One dependency mechanism, not two.
- **Never `source <(curl ...)`** — always download to a temp file and `source` that (`_u=$(mktemp) && curl -fsSL "URL" -o "$_u" && source "$_u" && rm -f "$_u"`). macOS ships bash 3.2 as `/bin/bash` (frozen since ~2007, GPLv3 avoidance), and its process substitution does not reliably persist functions defined via `source` into the calling shell — this bit `mac`'s CI once already.
- **macOS's bash 3.2 breaks tools that require Bash 4+ too**, not just `source`/process substitution — SDKMAN's own installer refuses to run under it. When a command's underlying installer needs a modern bash, ensure Homebrew (via `laboot setup-brew`) and explicitly run the installer through `/opt/homebrew/bin/bash` or `/usr/local/bin/bash` (installing the `bash` formula first if neither exists) instead of the bare `bash` in `PATH` — see `setup-sdkman.sh` on `mac`.
- **A tool with no native Windows installer** (e.g. `setup-nvm`, `setup-sdkman`) still gets a `.ps1` command on `windows` — it just delegates to the same bash script mac/linux use, run through Git for Windows' bundled `bash.exe` (`Get-GitBash` in `utils.ps1`). Only reach for this when the underlying tool is genuinely POSIX-shell-based and works under Git Bash — Homebrew, for example, doesn't (it needs real POSIX syscalls Git Bash can't provide), so `setup-brew` has no Windows variant.
- **`install` must never write straight to the file it's replacing** — `laboot install` means that file is the one currently executing. Download to a temp file and atomically move it into place (`mv` on bash, `Move-Item -Force` on PowerShell — both atomic renames on the same volume) instead of writing/`-OutFile`-ing directly onto the live path, which can corrupt or duplicate the read mid-execution. Also compare the new content against the old before replacing, so a no-op `laboot install` stays silent instead of printing "Installed" every time.
- **`laboot <name>` is a subprocess — its exports never reach the caller.** If a command needs a variable another command sets (e.g. `setup-obsidian` needs `$LABRAIN_PATH`, which `setup-labrain` resolves and exports), calling `laboot setup-labrain` from inside `setup-obsidian.sh` would resolve it in a *child* shell and lose it. Fetch that dependency's script to a temp file and `source` it directly instead — same temp-file mechanics as the `utils.sh` sourcing pattern, just applied to another command's script.
- **CI**: each platform branch runs a smoke test on push (`.github/workflows/smoke.yml`) that installs `laboot`, then exercises each command's already-installed/already-authenticated fast path on a matching GitHub-hosted runner. It can't test a real first-time interactive install, but it catches syntax errors and confirms the idempotent no-op paths stay no-ops.
