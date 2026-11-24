# Featherway development brief

- Current milestone is V0.0.2. Spot a Bird uses the iPhone still camera and displays the accepted photo in memory until Done. Start a Round, My Birds and History are placeholders. The collection has three static samples.
- Use both PNGs in `references/` for the approved design. The sighting mockup guides the camera review screen.
- Use Apple frameworks and bundled assets. Wait for user QA and further approval before adding AI, storage, networking, or round tracking.
- Codex and Claude Code use this same folder and repository sequentially. Check `git status --short --branch` before editing. Preserve existing changes and ask the user who owns any overlapping unfinished work before touching it.
- At handoff, share the branch and last commit, what changed, build and QA results, and open issues. Commit each milestone locally for QA. Once the user approves it, push its commit to GitHub before starting the next milestone.
- Claude Code can take a bounded architecture review or difficult debugging task when the user requests a handoff. Start with review when possible and return findings before either tool resumes edits.
