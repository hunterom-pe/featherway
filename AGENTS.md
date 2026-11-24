# Featherway development brief

- Current milestone is V0.0.4. A sighting can carry a manually entered bird name. Spot a Bird uses the iPhone still camera and offers Save Sighting or Discard Photo after capture. Saved photos live in Application Support and open from the home collection. Start a Round, My Birds and History are placeholders. The empty collection shows three samples.
- Use both PNGs in `references/` for the approved design. The sighting mockup guides the camera review screen.
- Use Apple frameworks and bundled assets. Wait for user QA and further approval before adding AI, networking, or round tracking.
- Codex and Claude Code use this same folder and repository sequentially. Check `git status --short --branch` before editing. Preserve existing changes and ask the user who owns any overlapping unfinished work before touching it.
- At handoff, share the branch and last commit, what changed, build and QA results, and open issues. Commit each milestone locally for QA. The user’s word “good” means approve and continue. Once the user approves a milestone, push its commit to GitHub before starting the next milestone.
- Claude Code can take a bounded architecture review or difficult debugging task when the user requests a handoff. Start with review when possible and return findings before either tool resumes edits.
