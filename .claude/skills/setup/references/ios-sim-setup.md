# Mobile MCP Integration Setup

This guide covers setting up Mobile MCP for Claude Code to interact with iOS simulators for UI testing and debugging.

## Overview

Claude has direct access to iOS Simulators via the **Mobile MCP** server for:
- Listing available simulators and devices
- Taking screenshots of simulator screens
- Inspecting UI elements and view hierarchy
- Performing tap, swipe, and gesture interactions
- Typing text input
- Listing installed apps on simulators
- Launching and terminating apps
- Changing device orientation

## Prerequisites

- **Xcode** installed with at least one iOS Simulator
- **macOS** (iOS Simulators only run on macOS)
- **Simulator must be booted** before using MCP commands
- **Node.js/npm** installed (for `npx`)

## MCP Server Configuration

The Mobile MCP server is already configured in [.mcp.json](../../../.mcp.json):

```json
{
  "mcpServers": {
    "mobile-mcp": {
      "type": "stdio",
      "command": "npx",
      "description": "Mobile automation for iOS/Android simulators and real devices",
      "args": [
        "-y",
        "@mobilenext/mobile-mcp@latest"
      ]
    }
  }
}
```

**No manual installation needed** - Claude Code automatically installs and manages the MCP server via `npx`.

## Enable in Settings

The Mobile MCP server is already enabled in [.claude/settings.json](../../../settings.json):

```json
{
  "enabledMcpjsonServers": [
    "mobile-mcp"
  ]
}
```

## Pre-Approved Commands

The following simulator operations are pre-approved and won't require permission prompts:

- `mcp__mobile-mcp__mobile_list_available_devices`
- `mcp__mobile-mcp__mobile_list_apps`
- `mcp__mobile-mcp__mobile_launch_app`
- `mcp__mobile-mcp__mobile_take_screenshot`
- `mcp__mobile-mcp__mobile_list_elements_on_screen`
- `mcp__mobile-mcp__mobile_click_on_screen_at_coordinates`

## What Mobile MCP Can Do

### Device Discovery
- List all available simulators and their IDs
- Get screen size and orientation
- Identify booted vs shutdown simulators

### App Operations
- List installed apps on the simulator
- Launch apps by bundle ID
- Terminate running apps

### UI Interaction
- Take screenshots
- List all UI elements with accessibility labels
- Tap at specific coordinates
- Swipe in any direction
- Long press gestures
- Type text into focused fields
- Double tap

### Device Control
- Change orientation (portrait/landscape)
- Get current orientation

## Usage Examples

Ask Claude to perform these operations:

### Device Management
```
List available iOS simulators
Get screen size of the simulator
Change simulator orientation to landscape
```

### App Management
```
List all apps installed on the simulator
Launch app with bundle ID com.glia.widgets.testing
Terminate the GliaWidgets TestingApp
```

### UI Interaction
```
Take a screenshot of the current screen
Tap the button at coordinates (200, 400)
Swipe up from the bottom of the screen
Type "test message" into the focused field
Long press at (150, 300) for 2 seconds
```

### UI Inspection
```
List all UI elements on screen
Show me the view hierarchy
Find elements with "Start Chat" in their label
```

## Important Limitations

### MCP Cannot:
- ❌ Boot or shutdown simulators
- ❌ Create new simulators
- ❌ Install apps on simulators
- ❌ Build Xcode projects

### You Must Manually:
1. **Boot the simulator** before using MCP
   - Open Simulator.app, or
   - Use: `open -a Simulator`

2. **Install your app** on the simulator before launching
   - Build from Xcode, or
   - Use: `xcrun simctl install booted /path/to/YourApp.app`

3. **Ensure Xcode is installed** and simulators are available

## Typical Workflow

### First-Time Setup
1. Install Xcode from Mac App Store
2. Open Xcode and install iOS simulators (Xcode → Settings → Platforms)
3. Accept Xcode license: `sudo xcodebuild -license accept`

### Before Using MCP
1. **Boot a simulator:**
   - Option A: Open Simulator.app
   - Option B: `open -a Simulator`

2. **Install your app** (if not already installed):
   ```bash
   # Build for simulator first
   xcodebuild -workspace GliaWidgets.xcworkspace \
     -scheme TestingApp \
     -configuration Debug \
     -sdk iphonesimulator \
     -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

   # Find the built app
   find ~/Library/Developer/Xcode/DerivedData -name "TestingApp.app" -type d

   # Install on booted simulator
   xcrun simctl install booted /path/to/TestingApp.app
   ```

### Using MCP
3. **Now ask Claude:**
   ```
   List available simulators
   Launch TestingApp
   Take a screenshot
   List all UI elements
   Tap the "Start Chat" button
   ```

## Troubleshooting

### Error: "No devices found"

**Cause:** No simulator is booted

**Fix:** Boot a simulator first:
```bash
open -a Simulator
```

### Error: "App not found"

**Cause:** App not installed on the simulator

**Fix:** Build and install your app:
```bash
# After building in Xcode
xcrun simctl install booted /path/to/YourApp.app
```

### Error: "MCP server not found"

**Cause:** Mobile MCP server not configured or `npx` not available

**Fix:**
- Verify [.mcp.json](../../../.mcp.json) contains `mobile-mcp` configuration
- Check that Node.js is installed: `which npx`
- Restart Claude Code

### Error: "Permission denied"

**Cause:** MCP command not pre-approved

**Fix:**
- Check [.claude/settings.json](../../../settings.json) permissions
- Add missing commands to `permissions.allow` array

### Screenshots Not Saving

**Cause:** Invalid file path specified

**Fix:**
```
Save screenshot to ~/Desktop/simulator-screenshot.png
# Always use absolute paths
```

## Automated Testing Workflows

### Snapshot Testing
```
1. Manually boot simulator and install app
2. Ask Claude: "Launch TestingApp"
3. Ask Claude: "Navigate to chat screen"
4. Ask Claude: "Take screenshot for snapshot comparison"
```

### Bug Reproduction
```
1. Ask Claude: "Take screenshot of current state"
2. Ask Claude: "Tap button at (200, 400)"
3. Ask Claude: "Take screenshot after tap"
4. Compare screenshots to verify behavior
```

### Accessibility Testing
```
1. Ask Claude: "List all UI elements with accessibility labels"
2. Verify all interactive elements are accessible
3. Check label clarity and VoiceOver compatibility
```

## Benefits

✅ **Automated UI interaction** - No manual tapping/swiping needed
✅ **Quick visual debugging** - Screenshot on demand
✅ **UI element inspection** - View hierarchy and accessibility info
✅ **Testing workflows** - Reproduce bugs step-by-step
✅ **Accessibility verification** - Ensure VoiceOver support

## Limitations

⚠️ **Simulator must be booted first** - MCP can't start simulators
⚠️ **App must be installed first** - MCP can't install apps
⚠️ **macOS only** - iOS Simulators require macOS
⚠️ **Simulators only** - Real device testing not supported

## Additional Resources

- **Mobile MCP Server:** [https://www.npmjs.com/package/@mobilenext/mobile-mcp](https://www.npmjs.com/package/@mobilenext/mobile-mcp)
- **Apple Simulator Guide:** [https://developer.apple.com/documentation/xcode/running-your-app-in-simulator-or-on-a-device](https://developer.apple.com/documentation/xcode/running-your-app-in-simulator-or-on-a-device)
- **GliaWidgets TestingApp:** See project README for build instructions
