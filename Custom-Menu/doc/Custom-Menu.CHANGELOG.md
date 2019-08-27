# Changelog
All notable changes to this project will be documented in this file.

## [0.1.2] - 22-07-2019
### Added
- Gradient effect.
### Changed
- Changed Gui00 back to click though (+E0x20) and used a hwnd check for the inner circle instead.
### Fixed
- Eliminated the possibility of a Gui being selected when it should not by adding Gui00 detection.

## [0.1.1] - 20-07-2019
### Added
- Banner to describe current action.
- Mouse detection to allow for Gui selection beyond the Gui.
### Changed
- Removed some redundant variables.
- Rewrote some over-complicated Ternary Operators.
### Fixed
- Eliminated the possibility of a Gui being selected when it should not by adding Gui00 detection.

## [0.1.0] - 18-07-2019
### Added
- Mouseover detection.
- Hotkeys to select a Gui without mouse movement.
- Support for fake sections.
### Changed
- Gui referencing to accommodate 10 or more total Gui.
- Gui creation on script load rather than on keypress.
### Fixed
- Fake sections offsetting sGui variant positioning because I chose to create them concurrently rather than simultaneously as that would require additional Gdi+ graphics to allow for separate colors.