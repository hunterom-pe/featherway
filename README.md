# Featherway V0.0.1

Featherway is a native SwiftUI birdwatching app for golfers. This milestone is a single home screen for iPhone on iOS 17 or later, with no third-party dependencies.

## Open and run

1. Open `Featherway.xcodeproj` in Xcode.
2. Select the shared **Featherway** scheme and an iPhone simulator. For a connected iPhone, choose your signing team under **Signing & Capabilities**.
3. Press **Run** (⌘R).

The approved design references are in `references/`. The home mockup drives the layout, and the Great Blue Heron sighting mockup informs the visual style. The app bundles cropped artwork and a heron mark derived from the home mockup. **Start a Round** sits below the primary action. The collection shows three sample species.

## QA for this milestone

- Check the brand, course image, button hierarchy, sample collection, and bottom navigation against the home mockup. Scroll on a smaller iPhone to see the full collection.
- Tap **Spot a Bird**, **Start a Round**, **My Birds**, and **History**. Each opens a dismissible preview alert. **Home** stays selected.
- Builds passed for the generic iOS device and simulator destinations in Xcode 27.2. The device build was unsigned. This environment's CoreSimulator service is older than the version Xcode expects, so a simulator launch, visual checks, and interaction checks are pending. There is no automated test target.
- Camera capture, AI, persistence, external APIs, round tracking, and functional destinations are outside this milestone.

## Shared Git workflow

Open this same folder in Codex or Claude Code and use one editor at a time. Start with `git status --short --branch`. Finish a handoff by recording the current branch and commit, build and QA results, and any open issues. Read `AGENTS.md` for shared scope and handoff details.

The GitHub remote is configured as `origin`. The first checkpoint is local on `main`. The existing planning documents in `Docs/` are kept out of Git. Wait for user QA before starting the next milestone.
