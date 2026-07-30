# Arma Reforger Dedicated Server — Docker via Git Tags

This repository uses a GitHub Actions CI pipeline that automatically builds and pushes an **Arma Reforger dedicated server** Docker image to Docker Hub whenever a git tag is pushed. No manual workflow triggering is needed — just push a tag in the right format.

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

| Git Tag | Docker tags produced | Steam branch |
| --- | --- | --- |
| `1.6.0.119.stable` | `arsa-test:stable`, `arsa-test:1.6.0.119` | Stable (App ID 1874900) |
| `1.7.0.24.experimental` | `arsa-test:experimental`, `arsa-test:1.7.0.24` | Experimental (App ID 1890870) |

> **Tip:** Match the tag to the official Arma Reforger version number shown in-game or on the
> [Arma Reforger news page](https://reforger.armaplatform.com/news) so it's clear which game build the image contains.

---

## How It Works

1. The pipeline splits the tag on the last `.` to extract:
   - **VERSION** — everything before the last dot (e.g. `1.6.0.119`)
   - **BRANCH_NAME** — the last segment (`stable` or `experimental`)
2. If `BRANCH_NAME` is `experimental`, Steam downloads from App ID `1890870` (the experimental branch); otherwise it uses `1874900` (stable).
3. Two Docker tags are pushed to Docker Hub:
   - `thewillard/arsa-test:<branch>` — floating tag, always points to the latest build on that channel
   - `thewillard/arsa-test:<version>` — pinned tag for this exact game version

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
