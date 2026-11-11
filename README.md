# Arma Reforger Dedicated Server — Docker via Git Tags

This repository uses a GitHub Actions CI pipeline that automatically builds and pushes an **Arma Reforger dedicated server** Docker image to the GitHub Container Registry (`ghcr.io/gruppe-adler/ars-image`) whenever a git tag is pushed. No manual workflow triggering is needed — just push a tag in the right format.

---

## Tag Format

Tags must follow this four-part format, matching the Arma Reforger version number exactly:

```
<major>.<minor>.<patch>.<build>.<branch>
```

| Segment | Description | Example |
| --- | --- | --- |
| `major` | Major version | `1` |
| `minor` | Minor version | `6` |
| `patch` | Patch number | `0` |
| `build` | Build number | `119` |
| `branch` | Release channel | `stable` or `experimental` |

### Examples

| Git Tag | Tags produced | Steam branch |
| --- | --- | --- |
| `1.6.0.119.stable` | `ars-image:stable`, `ars-image:1.6.0.119` | Stable (App ID 1874900) |
| `1.7.0.24.experimental` | `ars-image:experimental`, `ars-image:1.7.0.24` | Experimental (App ID 1890870) |

> **Tip:** Match the tag to the official Arma Reforger version number shown in-game or on the
> [Arma Reforger news page](https://reforger.armaplatform.com/news) so it's clear which game build the image contains.

---

## How It Works

1. The pipeline splits the tag on the last `.` to extract:
   - **VERSION** — everything before the last dot (e.g. `1.6.0.119`)
   - **BRANCH_NAME** — the last segment (`stable` or `experimental`)
2. If `BRANCH_NAME` is `experimental`, Steam downloads from App ID `1890870` (the experimental branch); otherwise it uses `1874900` (stable).
3. Two tags are pushed to the GitHub Container Registry:
   - `ghcr.io/gruppe-adler/ars-image:<branch>` — floating tag, always points to the latest build on that channel
   - `ghcr.io/gruppe-adler/ars-image:<version>` — pinned tag for this exact game version

---

## Runtime User

The server runs as the unprivileged user `ubuntu` (`1000:1000`) with `HOME=/home/ubuntu`. The installation in `/ars` stays owned by root and is only read and executed; the server writes to the `-profile` and `-addonDownloadDir` directories and `/tmp`.

[arsa-backend](https://github.com/gruppe-adler/arsa-backend) also runs as `1000:1000` and owns the mounted config, profile and mod directories. It starts the server containers with that user explicitly (`ARSA_ARS_USER`), with all capabilities dropped and `no-new-privileges`, so older tags of this image that default to root run unprivileged as well.

When running the image by hand, the mounted directories must be writable for `1000:1000`.

---

## Creating a Release

### Prerequisites

- Write access to this repository
- Git installed locally

### Stable release

```bash
# Pull latest changes first
git checkout main
git pull

# Tag with the current stable Arma Reforger version
git tag 1.6.0.119.stable
git push --tags
```

### Experimental release

```bash
git tag 1.7.0.24.experimental
git push --tags
```

The CI pipeline starts automatically. Monitor progress under the **Actions** tab in GitHub.

---

## Deleting a Tag

If you need to retag or redo a build:

```bash
# Delete locally
git tag -d 1.6.0.119.stable

# Delete on remote
git push -f --tags
```

Then recreate and push the tag as normal.

---

## Branch Channels

| Branch name | Purpose | Steam App ID |
| --- | --- | --- |
| `stable` (or anything else) | Stable production server builds | `1874900` |
| `experimental` | Experimental / beta server builds | `1890870` |

Any branch name other than `experimental` is treated as a stable release.
