# laboot

Public, curl-able bootstrap installer for [labrain](https://github.com/thinkinclabs/labrain) (private). This repo exists only to solve the chicken-and-egg problem of fetching a private repo's setup script from a machine that has nothing installed yet — `laboot` itself is public, so `curl` works with zero setup; it then installs and authenticates the GitHub CLI (`gh`) locally, and *that* is what's allowed to reach the private `labrain` repo.

This repo has **no `main`-branch code** — `main` is docs only. Each supported OS is a separate branch holding that OS's scripts. Pick your branch:

| OS | One-liner |
|---|---|
| macOS | `curl -fsSL https://raw.githubusercontent.com/thinkinclabs/laboot/mac/scripts/setup_labrain.sh \| bash` |
| Linux | `curl -fsSL https://raw.githubusercontent.com/thinkinclabs/laboot/linux/scripts/setup_labrain.sh \| bash` |
| Windows (PowerShell) | `irm https://raw.githubusercontent.com/thinkinclabs/laboot/windows/scripts/setup_labrain.ps1 \| iex` |

## How it fits together

Two scripts per branch, one dependency direction:

- **`scripts/setup_gh.sh`** (`.ps1` on `windows`) — ensures `gh` is installed and authenticated. Idempotent: already installed / already logged in just skips ahead.
- **`scripts/setup_labrain.sh`** (`.ps1` on `windows`) — depends on `setup_gh`, fetching and running it first (`curl`/`irm` against the same branch, not a local file — the entrypoint is always a single remote file, so the dependency has to be fetched too). Once `gh` is ready, it fetches and runs labrain's own `scripts/setup-labrain.sh` via the GitHub API (`Accept: application/vnd.github.raw`), which is the one authenticated hop into the private repo.

```
setup_labrain.sh  →  setup_gh.sh  →  (installs + auths gh)
       └──────────────→  gh api .../labrain/.../setup-labrain.sh | bash
```

## Maintaining this repo

- **Every branch's two scripts must stay logically parallel**: same flow (check → install if missing → check auth → login if needed → hand off), same function names (`info`), same exit behavior. If you fix a bug on one branch, check whether the same bug exists on the others.
- **Adding a new OS**: branch off `main`, add `scripts/setup_gh.<ext>` and `scripts/setup_labrain.<ext>` following the flow above, copy the `.github/workflows/smoke.yml` pattern from an existing branch (adjust the runner), then add a row to this table.
- **CI**: each OS branch runs a smoke test on push (`.github/workflows/smoke.yml`) that exercises the already-installed/already-authenticated fast path on a matching GitHub-hosted runner — it can't test a real first-time install (no interactive prompt in CI), but it catches syntax errors and confirms the idempotent no-op path stays a no-op.
- `laboot` only ever provisions `gh` and calls into `labrain`'s own script — it should never need labrain-specific logic. If labrain's bootstrap contract changes (e.g. the API path), update the one `gh api ...` line on every branch.
