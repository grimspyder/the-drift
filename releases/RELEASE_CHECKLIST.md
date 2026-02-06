# The Drift - Release Checklist

Use this checklist before each release to ensure everything is properly prepared.

## Pre-Release (1-2 days before)

- [ ] **Code Freeze**
  - [ ] All features for this version complete
  - [ ] No outstanding critical bugs
  - [ ] All tests passing

- [ ] **Documentation**
  - [ ] Update README.md with new features
  - [ ] Create RELEASE_NOTES_vX.X.X.md from template
  - [ ] Update BUILD_INSTRUCTIONS.md if needed
  - [ ] Update CHANGELOG if using one

- [ ] **Testing**
  - [ ] Test gameplay on all target platforms
  - [ ] Verify all controls work (keyboard + gamepad)
  - [ ] Test menu navigation
  - [ ] Check performance on minimum spec hardware
  - [ ] Verify no crashes or major bugs

- [ ] **Assets**
  - [ ] Ensure all art assets are optimized
  - [ ] Verify audio is properly encoded
  - [ ] Check icon/logo quality

## Build Day

- [ ] **Version Preparation**
  - [ ] Decide on version number (semantic versioning)
  - [ ] Update version in appropriate files:
    - [ ] project.godot (if version tracking exists)
    - [ ] README.md
    - [ ] Any other version-tracked files

- [ ] **Build Process**
  ```bash
  # Set Godot path if needed
  export GODOT_BIN=/path/to/godot
  
  # Build for all platforms
  ./scripts/build.sh X.X.X
  ```
  - [ ] Windows build completes successfully
  - [ ] Linux build completes successfully
  - [ ] macOS build completes successfully (if on macOS)
  - [ ] All artifacts are in releases/ directory

- [ ] **Verify Builds**
  - [ ] Test Windows executable runs
  - [ ] Test Linux executable runs and is executable
  - [ ] Test macOS bundle opens (if available)
  - [ ] Verify game launches without errors
  - [ ] Quick gameplay test on each platform

- [ ] **Prepare Release Notes**
  - [ ] Copy RELEASE_NOTES_TEMPLATE.md to RELEASE_NOTES_vX.X.X.md
  - [ ] Fill in all sections:
    - [ ] Overview
    - [ ] New Features
    - [ ] Improvements
    - [ ] Bug Fixes
    - [ ] Known Issues
  - [ ] Proofread for typos
  - [ ] Add links to relevant issues/PRs if available

## GitHub Release

- [ ] **Create Git Tag**
  ```bash
  git add -A
  git commit -m "Release vX.X.X"
  git tag -a vX.X.X -m "Release vX.X.X: [Short description]"
  git push origin main
  git push origin vX.X.X
  ```
  - [ ] Commit pushed to main
  - [ ] Tag pushed to origin

- [ ] **GitHub Actions**
  - [ ] Wait for GitHub Actions build to complete (usually 5-15 min)
  - [ ] Verify all platform builds succeeded
  - [ ] Check build artifacts are available

- [ ] **Manual Release** (if not using automated tags)
  - [ ] Go to GitHub → Releases → Draft New Release
  - [ ] Select appropriate tag (vX.X.X)
  - [ ] Title: "Release vX.X.X: [Description]"
  - [ ] Description: Paste RELEASE_NOTES content
  - [ ] Upload build artifacts:
    - [ ] Windows executable
    - [ ] Linux executable
    - [ ] macOS DMG (if available)
  - [ ] Mark as pre-release if beta/alpha
  - [ ] Publish release

## itch.io Upload (Optional)

- [ ] **Prepare itch.io**
  - [ ] Game page created and configured
  - [ ] Cover image uploaded
  - [ ] Screenshots uploaded
  - [ ] Description filled out
  - [ ] Tags added

- [ ] **Upload Builds**
  ```bash
  # Ensure butler is installed and authenticated
  butler login
  
  # Upload to beta channel
  ./scripts/push-itch.sh X.X.X beta
  ```
  - [ ] Windows upload completes
  - [ ] Linux upload completes
  - [ ] macOS upload completes (if available)
  - [ ] itch.io page shows new version

- [ ] **Verify itch.io**
  - [ ] Game page shows latest version
  - [ ] Download links work
  - [ ] Version shown correctly
  - [ ] All platforms listed

## Post-Release

- [ ] **Announcements** (if applicable)
  - [ ] Post on social media
  - [ ] Share in relevant communities
  - [ ] Email newsletter (if applicable)
  - [ ] Update blog/website (if applicable)

- [ ] **Community**
  - [ ] Monitor for early feedback
  - [ ] Respond to bug reports
  - [ ] Update pinned release post

- [ ] **Clean Up**
  - [ ] Archive old release notes (optional)
  - [ ] Remove old build artifacts from releases/ (optional)
  - [ ] Create next version milestone on GitHub (if using)

- [ ] **Documentation**
  - [ ] Update any relevant wikis/docs
  - [ ] Update roadmap if applicable
  - [ ] Note any known issues for next version

## Version-Specific Checklists

### Beta Release (v0.X.X-beta)

- [ ] Clearly mark as beta in all release notes
- [ ] Set itch.io visibility to "Beta"
- [ ] Include known limitations/issues
- [ ] Set expectations in description
- [ ] Ask for feedback explicitly
- [ ] Plan for hotfix releases if needed

### Stable Release (vX.X.X)

- [ ] Extensive testing on all platforms
- [ ] Production-ready builds
- [ ] Professional release notes
- [ ] Updated press materials
- [ ] Clear upgrade path for beta users
- [ ] Announce widely

### Hotfix Release (vX.X.Y)

- [ ] Document specific bug fixed
- [ ] Minimal changelog
- [ ] Fast-track testing
- [ ] Update beta channel first if applicable
- [ ] Announce to current players immediately

## Rollback Procedure (if critical issue found)

- [ ] [ ] Stop promoting release
- [ ] [ ] Remove from itch.io stable channel (move to archive)
- [ ] [ ] Post notice on GitHub (pin issue)
- [ ] [ ] Document what went wrong
- [ ] [ ] Fix issue and retest
- [ ] [ ] Release hotfix version (vX.X.Y+1)

## Metrics to Track (Post-Release)

- [ ] Downloads by platform
- [ ] Crash reports
- [ ] Common issues reported
- [ ] Player feedback sentiment
- [ ] Performance on different hardware
- [ ] Community engagement

## Sign-Off

**Release Version:** vX.X.X  
**Date:** YYYY-MM-DD  
**Released By:** (Your name)  
**Verified By:** (QA/Testing person)  

**Notes/Issues:**
(Any notable issues or observations)

---

**Pro Tip:** Create a new copy of this checklist for each release and check items as you go. This ensures nothing is forgotten and provides documentation of the release process.
