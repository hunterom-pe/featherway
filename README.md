# Featherway V0.0.2

Featherway is a native SwiftUI birdwatching app for golfers. On an iPhone running iOS 17 or later, Spot a Bird opens the native still camera. Use Photo opens a temporary in-memory preview. Done returns to the home screen.

## Open and run

1. Open `Featherway.xcodeproj` in Xcode.
2. Select the shared **Featherway** scheme and an iPhone simulator. For a connected iPhone, choose your signing team under **Signing & Capabilities**.
3. Press **Run** (⌘R).

The approved design references are in `references/`. The home mockup drives the layout, and the Great Blue Heron sighting mockup informs the visual style. The app bundles cropped artwork and a heron mark derived from the home mockup. **Start a Round** sits below the primary action. The collection shows three sample species.

## QA for this milestone

- On a physical iPhone, tap **Spot a Bird**, allow camera access, take a photo, choose **Retake**, then **Use Photo**. Verify portrait and landscape shots appear upright. **Done** should return home and release the photo.
- Reopen the camera and cancel. Check that the sample collection still shows three species.
- Deny camera access and check **Open Settings**. Enable Camera and return to Featherway. Devices with restricted camera access should offer a return home. A simulator without a camera should explain that a camera is unavailable.
- **Start a Round**, **My Birds**, and **History** still open their preview alerts. AI, storage, and round tracking are future milestones.
- V0.0.2 builds passed for generic iPhone and simulator destinations. Both built apps declare the camera permission message and iPhone device family. Camera permission, capture, Settings recovery, and orientation need hands-on iPhone QA. There is no automated test target.

## Shared Git workflow

Open this same folder in Codex or Claude Code and use one editor at a time. Start with `git status --short --branch`. Finish a handoff by recording the current branch and commit, build and QA results, and any open issues. Read `AGENTS.md` for shared scope and handoff details.

The GitHub remote is configured as `origin`. The approved V0.0.1 checkpoint is on GitHub. Push each milestone after user approval and before starting the next phase. The existing planning documents in `Docs/` are kept out of Git. Wait for user QA before starting the next milestone.
