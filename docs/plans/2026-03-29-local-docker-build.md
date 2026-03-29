# Local Docker Build Implementation Plan

## Execution Status

- [x] Task 1: Inspect current build inputs + add `Makefile` skeleton
- [x] Task 2: Implement Docker-backed build targets (digest-pinned image + local caches)
- [x] Task 3: Replace reusable CI workflow with repo-owned `make build` workflow
- [x] Task 4: Document local build usage in `README.md`
- [x] Task 5: Validate, push branch, and poll/fix CI until green

### Notes captured during execution
- Docker image pin was tightened from `:stable` to immutable digest:
  `zmkfirmware/zmk-build-arm@sha256:edb1c953438c6f720ddb79c3762f3972013b7fbbaf4fff3592fc869983e7afc5`
- Local build performance improved with persisted cache directories:
  - `.cache/zmk/zephyr`
  - `.cache/zmk/ccache`
- `west` setup is memoized via `.west/.setup-complete`.
- CI run `23704747626` failed in `Build firmware` because `west zephyr-export` state was not persisted across Docker invocations; fixed by running `west zephyr-export` in each build target.
- CI run `23704805519` succeeded for build/upload but warned that cache save failed due root-owned files; fixed by adding a workflow step to `chown` build/cache directories before post-cache save.
- CI run `23704891170` passed with `Build firmware`, `Upload artifacts`, and cache post-step all successful.

---

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a Docker-based `make build` workflow that produces all firmware artifacts locally and make GitHub Actions use the same path.

**Architecture:** Add a repository `Makefile` whose recipes invoke a pinned ZMK Docker build image directly and write outputs to `artifacts/`. Replace the current reusable GitHub Actions workflow with an in-repo workflow that checks out the repo, runs `make build`, uploads `artifacts/`, and is then validated by polling CI until the workflow passes.

**Tech Stack:** GNU Make, Docker, GitHub Actions, ZMK firmware build tooling, Markdown docs, `gh` CLI for CI polling

---

### Task 1: Inspect the current build inputs and define the command surface

**Files:**
- Read: `build.yaml`
- Read: `.github/workflows/build.yml`
- Modify: `README.md`
- Create: `Makefile`

**Step 1: Write the failing verification target expectation**

Document the intended command surface in a scratch note before implementation:
- `make build` must build `lily58_left`, `lily58_right`, and `settings_reset`
- outputs must be placed in `artifacts/`
- Docker-only path, no host toolchain fallback

**Step 2: Verify the repository does not already provide this interface**

Run: `make -n build`
Expected: FAIL with `No rule to make target 'build'` or equivalent because `Makefile` does not yet exist.

**Step 3: Inspect current CI/build inputs**

Run: `python - <<'PY'
from pathlib import Path
print(Path('build.yaml').read_text())
print('---')
print(Path('.github/workflows/build.yml').read_text())
PY`
Expected: `build.yaml` lists the three current build targets and the workflow uses the upstream reusable ZMK workflow.

**Step 4: Write the minimal `Makefile` skeleton**

Create `Makefile` with explicit targets:
```make
IMAGE ?= zmkfirmware/zmk-build-arm:stable
ARTIFACTS_DIR ?= artifacts

.PHONY: build build-left build-right build-reset clean

build: build-left build-right build-reset
```

**Step 5: Commit**

```bash
git add Makefile
git commit -m "feat(build): add make build skeleton"
```

### Task 2: Implement Docker-backed build targets in Makefile

**Files:**
- Modify: `Makefile`

**Step 1: Write the failing dry-run expectation**

Add a note for expected target behavior:
- `build-left` builds `nice_nano` with `lily58_left nice_view_adapter nice_view`
- `build-right` builds `nice_nano` with `lily58_right nice_view_adapter nice_view`
- `build-reset` builds `nice_nano` with `settings_reset`
- each target copies its resulting `.uf2` into `artifacts/`

**Step 2: Verify dry-run still does not show real build commands**

Run: `make -n build`
Expected: output is incomplete or only shows placeholder targets before Docker recipes are added.

**Step 3: Write minimal Docker recipes directly in `Makefile`**

Implement inline recipes that:
- create `artifacts/`
- run `docker run --rm` with the repo mounted into the container
- invoke the ZMK build for each target using the pinned image
- copy each built `.uf2` into `artifacts/` with stable names

A concrete structure is expected in the plan, e.g.:
```make
build-left:
	mkdir -p $(ARTIFACTS_DIR)
	docker run --rm \
	  -v $(PWD):/work \
	  -w /work \
	  $(IMAGE) \
	  bash -lc '... build left ... copy uf2 ...'
```
Repeat for `build-right` and `build-reset`.

**Step 4: Verify the command shape**

Run: `make -n build`
Expected: dry-run shows three Docker invocations and artifact copy commands.

**Step 5: If feasible, run a real local build**

Run: `make build`
Expected: `artifacts/` contains the three `.uf2` files. If the environment lacks Docker or the build image, record the exact failure and continue with dry-run verification plus CI validation.

**Step 6: Commit**

```bash
git add Makefile
git commit -m "feat(build): add dockerized firmware targets"
```

### Task 3: Replace reusable CI with repo-owned workflow calling `make build`

**Files:**
- Modify: `.github/workflows/build.yml`

**Step 1: Write the failing workflow expectation**

Define the intended workflow behavior:
- trigger on the current config/build paths plus manual dispatch
- checkout the repo
- run `make build`
- upload files from `artifacts/`

**Step 2: Verify the current workflow does not yet use `make build`**

Run: `rg -n "make build|upload-artifact|build-user-config" .github/workflows/build.yml`
Expected: finds `build-user-config` and does not find `make build`.

**Step 3: Write the minimal workflow implementation**

Replace the reusable workflow with an explicit job, e.g.:
```yaml
name: Build

on:
  push:
    paths:
      - ".github/workflows/build.yml"
      - "build.yaml"
      - "config/**"
      - "Makefile"
  pull_request:
    paths:
      - ".github/workflows/build.yml"
      - "build.yaml"
      - "config/**"
      - "Makefile"
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build firmware
        run: make build
      - name: Upload artifacts
        uses: actions/upload-artifact@v4
        with:
          name: firmware
          path: artifacts/*
```
Add any minimal Docker setup only if GitHub-hosted runners require it.

**Step 4: Verify workflow content**

Run: `rg -n "make build|upload-artifact|actions/checkout" .github/workflows/build.yml`
Expected: workflow now contains the repo-owned steps and no longer references `build-user-config`.

**Step 5: Commit**

```bash
git add .github/workflows/build.yml
git commit -m "ci(build): run make build in GitHub Actions"
```

### Task 4: Document local build usage

**Files:**
- Modify: `README.md`

**Step 1: Write the failing documentation expectation**

Define the required doc updates:
- Docker prerequisite
- `make build` usage
- artifact output path
- note that CI uses the same command path

**Step 2: Verify docs do not yet mention `make build`**

Run: `rg -n "make build|Docker|artifacts/|GitHub Actions" README.md`
Expected: existing README mentions GitHub Actions and manual local setup, but not the new `make build` flow.

**Step 3: Write the minimal documentation changes**

Update the `README.md` build section to include text like:
```md
### Local Build

Requirements:
- Docker
- GNU Make

Run:
```bash
make build
```

Outputs are written to `artifacts/`.

GitHub Actions uses the same `make build` path.
```

**Step 4: Verify docs match implementation**

Run: `rg -n "make build|artifacts/|Docker|same .*make build|GitHub Actions uses" README.md`
Expected: README contains the new local-build instructions.

**Step 5: Commit**

```bash
git add README.md
git commit -m "docs(build): document dockerized make build workflow"
```

### Task 5: Validate, push, poll CI, and fix until green

**Files:**
- Modify as needed: `Makefile`
- Modify as needed: `.github/workflows/build.yml`
- Modify as needed: `README.md`

**Step 1: Run final local verification**

Run: `git diff --check && make -n build`
Expected: no diff formatting errors and dry-run shows the full Docker-based build path.

**Step 2: Review the exact final diff**

Run: `git diff -- Makefile .github/workflows/build.yml README.md docs/plans/2026-03-29-local-docker-build-design.md docs/plans/2026-03-29-local-docker-build.md`
Expected: diff contains only the approved build workflow and documentation changes.

**Step 3: Push the branch**

Run: `git push`
Expected: remote updates successfully.

**Step 4: Poll CI status**

Run: `gh run list --workflow build.yml --limit 5`
Expected: see the newly triggered run for the pushed commit.

**Step 5: Inspect failures if CI is not green**

Run one of:
- `gh run view <run-id> --log-failed`
- `gh run view <run-id> --job <job-id> --log`

Expected: obtain exact failing step output.

**Step 6: Fix the minimal issue and re-verify locally**

Make the smallest correction required by the CI evidence, then run:
- `git diff --check`
- `make -n build`
- `git add ...`
- `git commit -m "fix(ci): address docker build workflow issue"`
- `git push`

Expected: a new run is triggered.

**Step 7: Repeat polling and fixes until CI passes**

Run: `gh run list --workflow build.yml --limit 5`
Expected: eventually the latest run concludes with `success`.

**Step 8: Capture final evidence**

Run: `gh run view <successful-run-id>`
Expected: workflow conclusion is `success` and artifact upload step completed.

**Step 9: Final commit if needed**

```bash
git status --short
```
Expected: clean working tree or only intentionally untracked local directories.
