# Bracket+4 Alt+F4 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Make the physical `[` key plus `4` send `Alt+F4`, and remove the older `Alt + 4 -> F4` behavior.

**Architecture:** Update the ZMK combo in `config/lily58.keymap` so it targets the physical `[` key position and emits `LA(F4)` directly. Then update the repository documentation to describe the new combo accurately.

**Tech Stack:** ZMK device-tree keymap config, Markdown docs, git

---

### Task 1: Update the combo implementation

**Files:**
- Modify: `config/lily58.keymap`

**Step 1: Inspect the existing combo**

Run: `rg -n "combo_alt4_f4|key-positions|bindings = <&kp F4>;" config/lily58.keymap`
Expected: find the existing combo using `<50 4>` and `F4`.

**Step 2: Write the minimal implementation**

Change the combo so it:
- uses the physical `[` key position together with `4`
- sends `LA(F4)` directly
- gets a clearer name such as `combo_lbkt4_altf4`

**Step 3: Verify the file content**

Run: `rg -n "combo_.*altf4|key-positions = <27 4>|bindings = <&kp LA\(F4\)>;" config/lily58.keymap`
Expected: one combo definition with the new key positions and `LA(F4)`.

### Task 2: Update documentation

**Files:**
- Modify: `README.md`
- Modify: `docs/vial-notes.md`

**Step 1: Replace the old combo description**

Update docs from:
- `LALT + 4 -> F4`

to:
- `[ + 4 -> Alt+F4`

**Step 2: Verify docs match**

Run: `rg -n "Alt\+F4|\[ \+ 4|LALT \+ 4 -> F4" README.md docs/vial-notes.md`
Expected: new wording present, old wording absent.

### Task 3: Validate and publish

**Files:**
- Modify: `config/lily58.keymap`
- Modify: `README.md`
- Modify: `docs/vial-notes.md`
- Create: `docs/plans/2026-03-29-bracket-4-altf4-design.md`
- Create: `docs/plans/2026-03-29-bracket-4-altf4.md`

**Step 1: Run final verification**

Run: `git diff -- config/lily58.keymap README.md docs/vial-notes.md docs/plans/2026-03-29-bracket-4-altf4-design.md docs/plans/2026-03-29-bracket-4-altf4.md`
Expected: diff only shows the approved combo and doc changes.

**Step 2: Commit**

```bash
git add config/lily58.keymap README.md docs/vial-notes.md docs/plans/2026-03-29-bracket-4-altf4-design.md docs/plans/2026-03-29-bracket-4-altf4.md
git commit -m "fix(keymap): map [ plus 4 to Alt+F4"
```

**Step 3: Push**

Run: `git push`
Expected: branch updates on remote successfully.
