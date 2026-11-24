# Featherway development brief

- Current milestone is V0.0.1. The app ships one SwiftUI home screen for iPhone. Spot a Bird, Start a Round, My Birds and History show preview alerts. The three collection tiles are static samples.
- The two PNGs in `references/` are the approved design. Use the home mockup for composition and both for visual styling. The sighting mockup is a design reference for a future milestone.
- Use Apple frameworks and bundled assets. Wait for explicit milestone approval before adding camera capture, AI, persistence, network calls, round tracking, or functional destinations.
- Codex and Claude Code use this same folder and repository sequentially. Check `git status --short --branch` before editing. Preserve existing changes and ask the user who owns any overlapping unfinished work before touching it.
- At handoff, share the branch and last commit, what changed, build and QA results, and open issues. Commit verified work locally in a focused commit. Wait for user QA before starting another milestone.
- Claude Code can take a bounded architecture review or difficult debugging task when the user requests a handoff. Start with review when possible and return findings before either tool resumes edits.
