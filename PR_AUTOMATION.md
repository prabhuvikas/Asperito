# Pull request quality gate

The workflow `.github/workflows/ios.yml` runs on PRs (opened, updated, reopened, ready for review) and pushes to `main`.

## Automated checks

1. Validate the Xcode project and privacy manifest using `plutil`.
2. Build the native app on a GitHub-hosted macOS runner for iOS Simulator.
3. Choose an available iPhone simulator, run the XCTest suite and record code coverage.
4. Always upload build logs, test logs and a TestResults.xcresult artifact.

The suite covers all 12 overlays in portrait/landscape; unique guide identifiers; grid line counts/bounds; custom grid limits; spiral rotation/mirroring; safe-area/cinematic framing ratios; eye-line clamping; zero-sized geometry; 12 local tutorial lessons; and capture aspect-ratio constants.

## Require checks for merge

When the first GitHub Actions run finishes, enable a branch ruleset for `main` in **Settings → Rules → Rulesets** (or Branches → Branch protection rules). Require the check **Simulator build & unit tests**, and optionally one approving review. A workflow alone does not automatically block merging.

## Limits of simulator automation

Physical camera, hardware flash, photo saving permissions, real-device orientation and shutter framing remain manual device/TestFlight acceptance checks. The workflow is not evidence of real iPhone camera correctness.

## Debugging

Open the PR → **Checks** → **Simulator build & unit tests**. Download the `frameguide-ios-ci-<run-id>` artifact for Xcode logs and the test result bundle.
