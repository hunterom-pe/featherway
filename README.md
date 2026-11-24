# Featherway V0.0.8

Featherway is a native SwiftUI birdwatching app for golfers. On an iPhone running iOS 17 or later, Spot a Bird opens the native still camera. Use Photo opens a preview with optional bird name, golf course and hole number. Save Sighting keeps the photo in Featherway’s private collection on the iPhone. Discard Photo returns home.

## Open and run

1. Open `Featherway.xcodeproj` in Xcode.
2. Select the shared **Featherway** scheme and an iPhone simulator. For a connected iPhone, choose your signing team under **Signing & Capabilities**.
3. Press **Run** (⌘R).

The approved design references are in `references/`. The home mockup drives the layout, and the Great Blue Heron sighting mockup informs the visual style. The app bundles cropped artwork and a heron mark derived from the home mockup. **Start a Round** sits below the primary action. The collection shows three sample species until the first save, then shows saved sightings newest first.

## QA for this milestone

- Start a round with a course and hole. Relaunch, take a photo, and check the prefilled location. Change the hole for just that sighting. Tap the active course on Home to update the round or end it, then check the next capture.

- Save a sighting with a course and hole, then reopen it from History. Check both values after relaunch. Tap a selected hole again to clear it. Check that a sighting can also be saved with either field blank.

- Open History. Check the newest sighting appears first with the local save date and time. Tap a row, then Done to return to History. Check an older photo as well.

- Open My Birds. Check that saved photos appear newest first with their names. Tap a photo, tap Done, and switch back to Home. With an empty collection, use Spot a Bird from the My Birds tab.

- Enter a bird name, save, relaunch, and tap the sighting to see its name. Save another with the field empty. Earlier sightings should still open.

- On iPhone, take a photo and choose **Use Photo → Save Sighting**. Check the collection count and tap the new thumbnail to review the photo.
- Save a second photo. Close and relaunch Featherway and verify both photos reopen in the expected order and orientation.
- Discard a third photo and cancel a capture. Verify the count stays at two. Camera, Settings recovery, and placeholders follow the previous milestone.
- The local store writes each JPEG atomically to Application Support. A failed save leaves the captured photo available for retry. Sightings count individual photos.
- V0.0.3 unsigned device and simulator builds passed. A local storage check verified empty state, unique saves, newest-first ordering, exact JPEG recovery after reopening, and write-failure isolation.
- V0.0.2 camera QA was approved on iPhone. V0.0.3 local sighting QA was approved. V0.0.4 naming QA was approved. V0.0.5 My Birds QA was approved. History QA was approved. Course and hole entry and the compact footer were approved. Active rounds await on-device QA.

## Shared Git workflow

Open this same folder in Codex or Claude Code and use one editor at a time. Start with `git status --short --branch`. Finish a handoff by recording the current branch and commit, build and QA results, and any open issues. Read `AGENTS.md` for shared scope and handoff details.

The GitHub remote is configured as `origin`. The approved V0.0.7 checkpoint is on GitHub. Push each milestone after user approval and before starting the next phase. The existing planning documents in `Docs/` are kept out of Git. Wait for user QA before starting the next milestone.
