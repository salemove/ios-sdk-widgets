# Claude Code: GliaWidgets SDK

This repository contains the **GliaWidgets SDK** - a UI/UX framework for iOS that provides pre-built, customizable widgets for customer engagement. It consumes the [GliaCoreSDK](https://github.com/salemove/ios-sdk) and provides out-of-the-box views for video/audio calls, chat, and secure conversations. The SDK is designed for banking and financial services customer support.

---

## Agentic Development Tools

This repository is configured with **Claude Code custom commands** to streamline development workflows. See [.claude/commands/README.md](.claude/commands/README.md) for full documentation.

### Atlassian Integration (Jira & Confluence)

Claude has access to Atlassian services with **tool selection by service type**:

**🔴 IMPORTANT: Tool Selection Rules**
- **Jira:** ALWAYS use Atlassian CLI (`acli`) - NO EXCEPTIONS
- **Confluence:** ALWAYS use Atlassian MCP Server
- **Reason:** CLI is more token-efficient for Jira, MCP provides better Confluence content access

**Atlassian CLI (`acli`) - For Jira ONLY:**
- **Use for:** All Jira operations (viewing tickets, searching issues, etc.)
- **View tickets:** `acli jira workitem view MOB-XXXX`
- **Search issues:** `acli jira workitem list --jql "project = MOB AND status = Open"`
- **Authentication:** Run `acli auth login --web` in terminal for browser-based OAuth
- **Pre-approved commands:** Configured in [.claude/settings.json](.claude/settings.json)

**Atlassian MCP Server - For Confluence ONLY:**
- **Use for:** All Confluence operations (searching pages, reading docs, listing spaces)
- **Pre-configured:** Set up in [.mcp.json](.mcp.json)
- **Pre-approved tools:** Configured in [.claude/settings.json](.claude/settings.json)
- **Capabilities:** Search pages, read full content, list spaces, CQL queries
- **No additional auth needed:** Uses same credentials as CLI

**Usage Examples:**
- "Search Confluence for UI design guidelines" → Use MCP
- "Get details on Jira ticket MOB-1234" → Use CLI (`acli`)
- "Find all open issues assigned to me" → Use CLI (`acli`)
- "Search Confluence pages in the ENG space" → Use MCP
- "What's the status of sprint issues?" → Use CLI (`acli`)

### GitHub Integration

Claude has direct access to GitHub repositories via GitHub CLI (`gh`) MCP integration:

**Setup:**
- **Pre-configured:** GitHub MCP server is already set up in [.mcp.json](.mcp.json)
- **Auto-enabled:** Automatically enabled for all team members via [.claude/settings.json](.claude/settings.json)
- **Uses GitHub CLI:** Leverages `gh` authentication (browser-based OAuth)

**Authentication (One-time per machine):**

1. **Install GitHub CLI** (if not already installed):
   ```bash
   brew install gh  # macOS
   # Or download from: https://cli.github.com/
   ```

2. **Authenticate with GitHub** (browser-based OAuth):
   ```bash
   gh auth login
   ```
   - Select: **GitHub.com**
   - Select: **HTTPS**
   - Authenticate Git: **Yes**
   - How to authenticate: **Login with a web browser**
   - Copy the one-time code → press Enter → browser opens → paste code → authorize

3. **Install gh-mcp extension:**
   ```bash
   gh extension install shuymn/gh-mcp
   ```

4. **Verify it works:**
   - Run `claude mcp list` to see GitHub server status
   - Or run `/mcp` in Claude Code

**Usage Examples:**
- "Review PR #456 and provide feedback"
- "Create an issue for the bug we just found"
- "Show me all open PRs assigned to me"
- "List recent commits on the master branch"
- "What's the status of issue MOB-1234?"
- "Search for code using 'Theme.Button' in the repository"

**Benefits:**
- ✅ Browser-based OAuth (no manual token creation)
- ✅ No tokens stored in files (uses `gh` credentials)
- ✅ Automatic token refresh handled by `gh`
- ✅ Same authentication used for git operations
- ✅ Easy team onboarding

### iOS Simulator Integration

Claude has direct access to iOS Simulators via two MCP servers for UI testing and debugging:

**iOS Simulator MCP (`ios-simulator`):**
- **Pre-configured:** Set up in [.mcp.json](.mcp.json)
- **Capabilities:** Screenshots, UI element inspection, tap/swipe gestures, text input
- **Use for:** Quick simulator interactions and UI debugging

**Mobile MCP (`mobile-mcp`):**
- **Pre-configured:** Set up in [.mcp.json](.mcp.json)
- **Capabilities:** Advanced device control, app management, orientation changes
- **Use for:** Comprehensive mobile testing automation

**Usage Examples:**
- "Take a screenshot of the current simulator screen"
- "List all UI elements visible on the screen"
- "Tap the button at coordinates (200, 400)"
- "Install the test app on the simulator"
- "Change simulator orientation to landscape"

**Benefits:**
- ✅ No manual simulator navigation needed
- ✅ Automated UI testing workflows
- ✅ Quick visual debugging
- ✅ Integration with snapshot testing

---

## Parallel Execution Best Practices

Claude Code performs better when you request multiple independent operations in parallel. This reduces context switching and speeds up analysis.

### Recommended Patterns

**File Exploration** - Request multiple file reads together:
```
Read these files to understand the Theme system:
- GliaWidgets/Sources/Theme/Theme.swift
- GliaWidgets/Public/Configuration/Configuration.swift
- GliaWidgets/Sources/Coordinator/FlowCoordinator.swift
```

**Codebase Search** - Parallel grep for related patterns:
```
Find all usages of: Theme.Button, Configuration, EngagementKind
```

**Build Validation** - Run checks concurrently:
```
In parallel: Run SwiftLint, build the framework, and execute snapshot tests
```

### Benefits
- **Faster responses**: Multiple tool calls in single message
- **Lower token usage**: Less context switching overhead
- **Better workflow**: Complete analysis before making changes

---

## Project Architecture

### Framework Type
- **Distribution:** Swift Framework (source + binary XCFramework)
- **Deployment Target:** iOS 15.1+
- **Swift Version:** 5.3+
- **UI Frameworks:** SwiftUI + UIKit (hybrid approach)

### Core Architectural Patterns
- **MVVM Architecture:** View Models coordinate between UI and Core SDK
- **Theme System:** Centralized styling via `Theme` with remote configuration support
- **Coordinator Pattern:** `FlowCoordinator` manages navigation and screen flow
- **Dependency on Core SDK:** Consumes GliaCoreSDK as binary framework
- **Protocol-Oriented Design:** Testable components via protocol abstractions
- **Environment Pattern:** Dependency injection via `.Environment` structs

### Primary Entry Point
- **Glia.sharedInstance:** Singleton providing SDK configuration and engagement management
- **Main Features:**
  - `startEngagement()` - Launch chat, audio, or video engagements
  - `configure()` - Initialize SDK with site credentials
  - `startSecureConversation()` - Launch secure messaging flows
- **Engagement Types:** `.none`, `.chat`, `.audioCall`, `.videoCall`, `.messaging`

### UI Component Structure
```
GliaWidgets/
├── Public/               # Public API surface
│   ├── Glia/            # Main SDK interface
│   ├── Configuration/   # SDK configuration types
│   └── Theme/           # Public theme customization
├── Sources/             # Internal implementation
│   ├── Theme/           # Theme system
│   ├── Coordinator/     # Navigation coordination
│   ├── CallVisualizer/  # Video/Audio call UI
│   ├── Chat/            # Chat UI components
│   └── Component/       # Reusable UI components
└── SecureConversations/ # Secure messaging UI
```

---

## Tech Stack

### UI Frameworks
**Primary:** SwiftUI (Modern screens) + UIKit (Legacy compatibility)
- SwiftUI used for newer features (Secure Conversations, modern UI)
- UIKit for established components (Chat, Call Visualizer)
- Hybrid approach using `UIHostingController` for SwiftUI in UIKit

### Reactive Programming
**Primary:** Combine
- `@Published` properties for observable state
- `ObservableObject` for view models
- `AnyCancellable` for subscription management
- Used extensively in view models and coordinators

**Secondary:** ReactiveSwift (via GliaCoreDependency)
- Only for Core SDK interop
- Deprecated, no new features should include it

### Concurrency Model
- **Async/Await:** Primary async pattern for modern code
- **Completion Handlers:** `@escaping` closures for callbacks
- **GCD:** Dispatch queues for main thread coordination

### Styling System
**Theme-Based Customization**

Location: `GliaWidgets/Sources/Theme/`

Implementation:
- **Theme Protocol:** Centralized styling for all UI components
- **Remote Configuration:** Backend-driven theme updates
- **Accessibility Support:** Built-in accessibility labels and traits
- **Color System:** Base colors with dynamic variants
- **Typography:** Font styles with dynamic type support

Components styled via Theme:
- Chat UI (messages, attachments, input)
- Call UI (buttons, operator view, video layout)
- Alerts and snack bars
- Secure conversations UI

### Testing Frameworks
**Snapshot Testing** (Primary for UI validation)
- Stored in separate git repo: `ios-widgets-snapshots`
- Tests in `SnapshotTests/` directory
- Uses Git LFS for PNG storage
- Devices: Multiple iOS versions and screen sizes

**Unit Testing**
- **Quick:** BDD-style testing framework (`*Spec.swift` files)
- **Nimble:** Expressive assertion matchers
- **XCTest:** Apple's standard testing framework
- Mixed approach: Both Quick/Nimble and pure XCTest

### Dependencies
External frameworks (via CocoaPods/SPM):
- **GliaCoreSDK** (2.5.1) - Core business logic and networking
- **GliaCoreDependency** (2.4.0) - Shared utilities
- **WebRTC-lib** (119.0.0) - Video/audio rendering
- **TwilioVoice** (6.8.0) - VoIP call handling
- **PhoenixChannelsClient** (1.1.3) - WebSocket communication
- **GliaOpenTelemetry** (1.0.8) - Tracing and observability

---

## Security & Compliance Standards

### Data Storage
- **NEVER:** Store credentials, tokens, or PII directly in Widgets SDK
- **Delegate to Core SDK:** All secure storage via GliaCoreSDK
- **UserDefaults:** Only for non-sensitive UI preferences (theme selections, etc.)
- **No Custom Storage:** Do not implement custom persistence layers

### Networking
- **No Direct Networking:** All API calls routed through Core SDK
- **Core SDK Dependency:** Use `GliaCoreSDK` protocols for data access
- **No Custom HTTP Clients:** Never bypass Core SDK networking layer

### Logging Compliance
- **NEVER use `print()` directly** - Use Core SDK's logging system via environment
- **PII Handling:** **ALWAYS** avoid logging user input, operator names, or chat content
- **UI Events Only:** Log UI interactions, navigation, and errors only
- **Autoclosure:** Defer expensive log string construction

### UI-Specific Security
- **Screen Recording:** Properly handle screen recording notifications
- **Screenshot Prevention:** Respect sensitive content flags for secure conversations
- **Background Mode:** Hide sensitive UI when app enters background
- **Accessibility:** Balance VoiceOver support with privacy (don't read sensitive data aloud)

---

## Testing Infrastructure

### Snapshot Testing (Primary)
**Framework:** iOS Snapshot Testing
**Repository:** Separate git repo with Git LFS
**Location:** `SnapshotTests/` directory

**Workflow:**
```bash
# Clone snapshots repo (first time only)
make clone-snapshots

# Run tests and update snapshots
# (Xcode test scheme handles snapshot comparison)

# Commit snapshot changes
make commit-snapshots

# Push to snapshots repo
make push-snapshots
```

**Test Coverage:**
- All UI components across multiple devices
- Dynamic type font sizes
- VoiceOver accessibility
- Light/dark mode variations
- Different screen sizes (iPhone SE, iPhone 15 Pro Max, etc.)

**Best Practices:**
- ALWAYS update snapshots when changing UI
- Test on device versions matching production targets
- Review snapshot diffs carefully before committing
- Use descriptive test names indicating component and variant

### Unit Testing
**Frameworks:**
- **Quick/Nimble:** BDD-style tests (`*Spec.swift` files)
- **XCTest:** Standard unit tests (`*Tests.swift` files)

**Test Organization:**
```
GliaWidgetsTests/
├── CallVisualizer/      # Video/audio call UI tests
├── Chat/                # Chat component tests
├── Coordinator/         # Navigation flow tests
├── Mocks/               # Mock implementations
└── SecureConversations/ # Secure messaging tests
```

**Mocking Strategy:**
- Mock Core SDK protocols for isolation
- Use `.Failing` implementations for error testing
- Environment-based dependency injection
- Protocol abstractions for all external dependencies

---

## Coding Guidelines

### Swift API Design
- **Naming:** Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- **Clarity:** Prioritize clarity at the point of use over brevity
- **Self-Documenting Code:** Use descriptive method, type, and variable names that reveal intent
- **Consistency:** Match existing patterns in the codebase
- **Public API Stability:** Breaking changes require major version bumps

### Code Comments Philosophy
- **Prefer Self-Documenting Code:** Write clear, descriptive names that make code self-explanatory
- **Avoid Obvious Comments:** Don't add comments where the logic is self-evident from well-named variables/methods
- **Comment Only When Necessary:**
  - Complex UI layout calculations or constraints
  - Non-obvious accessibility implementations
  - Workarounds for iOS bugs or API limitations
  - Business logic that differs from obvious UI behavior
  - Performance optimizations that aren't self-evident
  - Rationale for architectural decisions that may seem unusual
- **DocC Comments for Public APIs:** Every `public` and `open` symbol MUST have `///` documentation
  - Document parameters and return values
  - Provide code examples for complex APIs
  - Use `@available(*, deprecated, message: "...")` with migration guidance
  - Include usage examples for theme customization

**Good Example:**
```swift
// ❌ BAD: Unnecessary comment
// Set button background color
button.backgroundColor = theme.primaryColor

// ✅ GOOD: Self-documenting
button.backgroundColor = theme.primaryColor

// ❌ BAD: Comment explains what code does
// Create constraint for button width
let widthConstraint = button.widthAnchor.constraint(equalToConstant: 200)

// ✅ GOOD: Descriptive name
let minimumTapTargetWidthConstraint = button.widthAnchor.constraint(equalToConstant: 200)

// ✅ GOOD: Comment explains WHY (non-obvious iOS behavior)
// UIKit renders clear backgrounds as nil, causing snapshot test failures
// on iOS 15.0-15.2 due to FB9876543. Use .white.withAlphaComponent(0.01) instead.
view.backgroundColor = .white.withAlphaComponent(0.01)
```

### Error Handling
- **Custom Errors:** Use `GliaError` enum for SDK-specific errors
- **Core SDK Errors:** Propagate Core SDK errors with proper wrapping
- **User-Facing Errors:** Provide localized error messages for UI display
- **Never Throw Generic:** Always use typed errors

### SwiftUI Best Practices
- **State Management:** Use `@StateObject` for view model ownership
- **Environment:** Use `.environment()` for dependency injection
- **PreferenceKeys:** For child-to-parent communication
- **View Composition:** Break down complex views into smaller components
- **Performance:** Use `equatable()` and `id()` for list optimization

### UIKit Best Practices
- **Auto Layout:** Prefer Auto Layout over frame-based layout
- **Accessibility:** Set accessibility labels, traits, and hints
- **Dynamic Type:** Support dynamic type for all text
- **Safe Area:** Respect safe area insets
- **Dark Mode:** Support both light and dark appearance

### Theme Customization
- **Never Hardcode Colors/Fonts:** Always use Theme system
- **Remote Config Support:** Theme properties may be overridden remotely
- **Fallback Values:** Provide sensible defaults for all theme properties
- **Accessibility:** Theme colors must meet WCAG contrast requirements

---

## Architecture Deep Dive

### Theme System
Location: `GliaWidgets/Sources/Theme/`

**Pattern:**
```swift
public struct Theme {
    public var chat: ChatTheme
    public var call: CallTheme
    public var alert: AlertTheme
    // ... other components
}

public struct ChatTheme {
    public var background: ColorType
    public var visitorMessageStyle: MessageStyle
    public var operatorMessageStyle: MessageStyle
}
```

**Features:**
- Centralized styling for entire SDK
- Remote configuration override capability
- Type-safe color and font definitions
- Accessibility-aware styling
- Support for light/dark mode

**Usage:**
- Configure via `Configuration` during SDK setup
- Theme applied automatically to all components
- Customizable per-component or globally

### Coordinator Pattern
Location: `GliaWidgets/Sources/Coordinator/`

**Components:**
- `FlowCoordinator` - Main navigation coordinator
- Screen-specific coordinators for each feature
- Manages view controller lifecycle
- Handles navigation transitions
- Coordinates between Widgets SDK and Core SDK

**Responsibilities:**
- Create and configure view controllers
- Manage navigation stack
- Handle deeplinks and external navigation
- Coordinate engagement state changes
- Manage modal presentations

### Environment Pattern
**Dependency Injection via `.Environment`:**

```swift
struct SomeView {
    struct Environment {
        var themeProvider: () -> Theme
        var notificationCenter: NotificationCenter
    }

    var environment: Environment
}
```

**Benefits:**
- Testable components via environment injection
- Mock dependencies easily in tests
- Consistent pattern across codebase
- Protocol-based abstractions

---

## "NEVER" Rules

### Code Prohibitions
1. **NEVER modify `public` APIs without coordination** - Breaking changes require deprecation cycle
2. **NEVER use `print()` directly** - Use Core SDK's logging via environment
3. **NEVER hardcode colors or fonts** - Use Theme system exclusively
4. **NEVER bypass Core SDK** - All data access goes through GliaCoreSDK
5. **NEVER skip snapshot tests** - All UI changes require snapshot verification
6. **NEVER use force unwrap (`!`) without justification** - SwiftLint enforces this
7. **NEVER commit without running SwiftLint** - Linting is part of CI/CD
8. **NEVER implement custom networking** - Use Core SDK's network layer
9. **NEVER store sensitive data** - Delegate all persistence to Core SDK
10. **NEVER ignore accessibility** - All custom controls need accessibility support
11. **NEVER add obvious comments** - Use self-documenting code with clear names instead

### UI/UX Violations
1. **NEVER ignore theme system** - All styling must go through Theme
2. **NEVER hardcode strings** - Use localization system for all user-facing text
3. **NEVER skip dynamic type** - All text must support dynamic type sizes
4. **NEVER ignore safe area** - Respect safe area insets on all devices
5. **NEVER create inaccessible UI** - VoiceOver support is mandatory
6. **NEVER use absolute frames** - Use Auto Layout or SwiftUI layout system
7. **NEVER ignore dark mode** - Support both light and dark appearance

### Testing Anti-Patterns
1. **NEVER skip snapshot tests for UI changes** - Visual regressions must be caught
2. **NEVER commit without updating snapshots** - Outdated snapshots block CI
3. **NEVER use `sleep()` in tests** - Use expectations or mock schedulers
4. **NEVER test private implementation details** - Test public behavior only
5. **NEVER ignore flaky tests** - Fix or file a bug, don't disable
6. **NEVER mock value types** - Only mock protocol-based dependencies
7. **NEVER commit snapshot diffs without review** - Visual changes need approval

### Architecture Violations
1. **NEVER create singletons** - Use dependency injection via Environment
2. **NEVER bypass Coordinator** - All navigation goes through FlowCoordinator
3. **NEVER tightly couple to Core SDK implementation** - Use protocol abstractions
4. **NEVER use `DispatchQueue.main.sync`** - Causes deadlocks
5. **NEVER leak view controllers** - Always use weak references in closures

---

## Snapshot Testing Workflow

### Initial Setup
```bash
# Clone snapshots repository (one-time setup)
make clone-snapshots

# Configure git hooks
make integrate-githooks
```

### Daily Workflow
```bash
# Pull latest snapshots before starting work
make pull-snapshots

# Make UI changes in Xcode
# Run snapshot tests (⌘U or specific test scheme)

# Review snapshot diffs in SnapshotTests/__Snapshots__/
# Verify changes are intentional

# Commit snapshots if changes are correct
make commit-snapshots

# Push updated snapshots
make push-snapshots

# Commit code changes to main repo
git add GliaWidgets/
git commit -m "Update button styling"
git push
```

### Troubleshooting
- **Snapshots out of sync:** Run `make pull-snapshots` to get latest
- **Test failures:** Check Xcode test results for image diffs
- **Missing snapshots:** Run tests to generate initial snapshots
- **Git LFS issues:** Ensure Git LFS is installed: `git lfs install`

---

## Additional Resources

- **GitHub (Widgets):** [https://github.com/salemove/ios-sdk-widgets](https://github.com/salemove/ios-sdk-widgets)
- **GitHub (Core SDK):** [https://github.com/salemove/ios-sdk](https://github.com/salemove/ios-sdk)
- **iOS Bundle Repo:** [https://github.com/salemove/ios-bundle](https://github.com/salemove/ios-bundle) (XCFramework releases)
- **Snapshots Repo:** [https://github.com/salemove/ios-widgets-snapshots](https://github.com/salemove/ios-widgets-snapshots) (Snapshot test images)
- **Swift API Guidelines:** [https://swift.org/documentation/api-design-guidelines/](https://swift.org/documentation/api-design-guidelines/)
- **Documentation:** Generated via Jazzy, published to S3

---
