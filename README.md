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
| `setup-labrain` | all | Bootstraps [labrain](https://github.com/thinkinclabs/labrain) (private) — depends on `setup-gh`, run through `laboot` itself. |
| `setup-gh` | all | Ensures the GitHub CLI is installed and authenticated. On macOS/Linux, falls back to Homebrew via `setup-brew` if no native package manager is found; on Windows, uses `winget`. |
| `setup-brew` | macOS, Linux | Ensures Homebrew is installed. |
| `setup-sdkman` | macOS, Linux, Windows (via Git Bash) | Ensures [SDKMAN](https://sdkman.io) is installed. No native Windows installer, so the Windows command runs the same bash script through Git for Windows' bundled `bash.exe`. |
| `setup-nvm` | macOS, Linux, Windows (via Git Bash) | Ensures [nvm](https://github.com/nvm-sh/nvm) is installed. Same Git Bash delegation as `setup-sdkman`. |

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
- **A tool with no native Windows installer** (e.g. `setup-nvm`, `setup-sdkman`) still gets a `.ps1` command on `windows` — it just delegates to the same bash script mac/linux use, run through Git for Windows' bundled `bash.exe` (`Get-GitBash` in `utils.ps1`). Only reach for this when the underlying tool is genuinely POSIX-shell-based and works under Git Bash — Homebrew, for example, doesn't (it needs real POSIX syscalls Git Bash can't provide), so `setup-brew` has no Windows variant.
- **CI**: each platform branch runs a smoke test on push (`.github/workflows/smoke.yml`) that installs `laboot`, then exercises each command's already-installed/already-authenticated fast path on a matching GitHub-hosted runner. It can't test a real first-time interactive install, but it catches syntax errors and confirms the idempotent no-op paths stay no-ops.
