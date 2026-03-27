# cnb-sync-skill

Reusable skill to add CNB sync files into any GitHub fork repository.

## What it installs

- `.github/workflows/cnb_sync.yml`
- `.cnb.yml`
- `.ide/Dockerfile`

## Why

When you frequently fork GitHub projects and want automatic sync with cnb.cool,
this script applies a consistent setup with configurable owners.

## Usage

Run in the target repository root:

```bash
bash tools/cnb-sync-skill/install.sh \
  --cnb-owner "<your-cnb-owner>" \
  --github-owner "<your-github-owner>" \
  --write-root-files \
  --commit
```

Options:

- `--cnb-owner` (required): owner/group on cnb.cool for mirror target.
- `--github-owner` (required): owner on GitHub used in `.cnb.yml` target URL.
- `--cnb-imports-url` (optional): full CNB imports URL for `env.yml`.
  - Default: `https://cnb.cool/<cnb-owner>/my-keys/-/blob/main/env.yml`
- `--write-root-files` (optional): materialize the 3 files into repo root.
- `--commit` (optional): auto `git add` + `git commit`.
- `--force` (optional): overwrite files if they already exist.

## One-command remote usage

If this repo is public, you can also run:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/<your-user>/<your-repo>/main/tools/cnb-sync-skill/install.sh) \
  --cnb-owner "<your-cnb-owner>" \
  --github-owner "<your-github-owner>" \
  --write-root-files \
  --commit
```

## Optional gh alias

```bash
gh alias set cnbify '!bash <(curl -fsSL https://raw.githubusercontent.com/<your-user>/<your-repo>/main/tools/cnb-sync-skill/install.sh) "$@"'
```

Then in any fork repo:

```bash
gh cnbify --cnb-owner "<your-cnb-owner>" --github-owner "<your-github-owner>" --write-root-files --commit
```

