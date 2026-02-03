---
name: setup
description: This skill should be used when the user asks to "setup development environment", "configure integrations", "onboard to project", "setup GitHub/Jira/Confluence", or mentions first-time setup for GliaWidgets SDK.
version: 0.1.0
---

# GliaWidgets SDK Development Setup

Welcome to the GliaWidgets SDK! This guide will help you configure Claude Code integrations for working with this project.

## What This Covers

This setup configures **Claude Code-specific integrations**:
- ✅ Glia organizational plugins installation
- ✅ GitHub CLI (`gh`) integration
- ✅ Atlassian CLI (`acli`) for Jira
- ✅ Atlassian MCP for Confluence
- ✅ iOS Simulator MCP for mobile testing

**Not covered here** (see project README):
- ❌ CocoaPods installation
- ❌ Xcode configuration
- ❌ Snapshot repository cloning
- ❌ Swift toolchain setup

## Prerequisites Check

Let me verify what's already installed:

```bash
# Check GitHub CLI
which gh && gh --version

# Check Atlassian CLI
which acli && acli --version

# Check if gh-mcp extension is installed
gh extension list | grep gh-mcp
```

## Setup Process

I'll guide you through each integration. Based on the prerequisites check above, we'll configure what's needed.

### 0. Glia Plugins Installation (Required First)

Before setting up individual integrations, you need to install Glia's organizational plugins that provide commands, skills, and tools for development workflows.

**What This Installs:**
- `glia-commands` - Commands like `/research-codebase`, `/validate-plan`, `/implement-plan`
- `quick-agents` - Token-efficient Haiku-powered agents
- `glia-docs` - Access to Glia REST API documentation
- `glia-media-infra` - WebRTC/media infrastructure insights
- `integrations` - Jira integration skill
- `commit-messages` - Commit message generation

**Setup Steps:**

1. **Update the marketplace cache:**
   ```bash
   claude plugin marketplace update glia-plugins
   ```

2. **Install all Glia plugins:**
   ```bash
   claude plugin install glia-commands@glia-plugins
   claude plugin install quick-agents@glia-plugins
   claude plugin install glia-docs@glia-plugins
   claude plugin install glia-media-infra@glia-plugins
   ```

   Note: `integrations` and `commit-messages` plugins should already be installed. If not:
   ```bash
   claude plugin install integrations@glia-plugins
   claude plugin install commit-messages@glia-plugins
   ```

3. **Verify installation:**
   ```bash
   claude plugin list
   ```

   You should see all glia-plugins listed with status "installed".

**Verification:**
After restarting your Claude Code session, the following commands will be available:
- `/research-codebase`
- `/validate-plan`
- `/implement-plan`
- `/jira`

**Note:** The plugins are installed at the user level (globally) but are enabled per-project in `.claude/settings.json`.

### 1. GitHub CLI Integration

The GitHub CLI (`gh`) enables Claude to interact with GitHub repositories directly.

**Status Check:**
- If `gh` command found: ✅ Installed
- If not found: ❌ Needs installation

**Setup Steps:**

If not installed, you'll need to:
1. Install GitHub CLI: `brew install gh`
2. Authenticate: `gh auth login` (browser-based OAuth)
3. Install gh-mcp extension: `gh extension install shuymn/gh-mcp`

**Verification:**
```bash
# Test GitHub access
gh repo view salemove/ios-sdk-widgets --json name,description
```

**Detailed Guide:** See [references/github-setup.md](references/github-setup.md)

### 2. Atlassian (Jira) Integration

The Atlassian CLI (`acli`) enables Claude to interact with Jira tickets.

**Status Check:**
- If `acli` command found: ✅ Installed
- If not found: ❌ Needs installation

**Setup Steps:**

If not installed, you'll need to:
1. Install: `brew install acli`
2. Authenticate: `acli jira auth login --web` (browser-based OAuth)

**Verification:**
```bash
# Test Jira access - fetch a known ticket
acli jira workitem view MOB-4009
```

**Detailed Guide:** See [references/atlassian-setup.md](references/atlassian-setup.md)

### 3. Confluence Integration

Confluence uses the Atlassian MCP server (already configured in `.mcp.json`).

**Status Check:**
- MCP server configured: ✅ (uses same auth as acli)
- Authentication: Shares credentials with acli from step 2

**Verification:**
I can test Confluence access by searching for pages:
```
Search Confluence for "release process"
```

**Detailed Guide:** See [references/atlassian-setup.md](references/atlassian-setup.md)

### 4. iOS Simulator MCP Integration

The iOS Simulator MCP enables Claude to interact with iOS simulators for testing.

**Status Check:**
- MCP server configured: ✅ (in `.mcp.json`)
- Requires: Xcode and iOS Simulators installed

**Verification:**
I can test simulator access by listing available devices:
```
List available iOS simulators
```

**Detailed Guide:** See [references/ios-sim-setup.md](references/ios-sim-setup.md)

## Interactive Setup Workflow

Based on the prerequisites check, I'll now guide you through any missing setup:

1. **Install Glia plugins** (must be done first - provides organizational commands and skills)
2. **Identify what's missing** from the prerequisites checks above
3. **Provide installation commands** for each missing tool
4. **Guide through authentication** (most use browser-based OAuth)
5. **Verify each integration** with test commands
6. **Confirm everything works** before you start development

## Common Issues & Troubleshooting

### GitHub CLI not authenticated
**Symptom:** `gh` commands return 401 or authentication errors

**Fix:**
```bash
gh auth login
# Select: GitHub.com → HTTPS → Yes → Login with web browser
```

### Atlassian CLI not authenticated
**Symptom:** `acli` commands return "unauthorized" errors

**Fix:**
```bash
acli jira auth login --web
# Browser will open for OAuth flow
# Select your Glia site when prompted
```

### iOS Simulator MCP not working
**Symptom:** Simulator commands fail or return empty results

**Fix:**
- Ensure Xcode is installed
- Open Xcode at least once to accept license
- Ensure at least one simulator is installed (Xcode → Preferences → Components)

## Next Steps

Once setup is complete:

1. ✅ Review [.claude/CLAUDE.md](../../CLAUDE.md) for project architecture and coding guidelines
2. ✅ Check project README for CocoaPods, Xcode, and snapshot repo setup
3. ✅ Ask Claude to verify integrations work: "Check if GitHub, Jira, and Confluence integrations are working"

## Process

When this skill is invoked, I will:

1. Guide you through installing Glia organizational plugins
2. Run prerequisite checks to see what's installed
3. Present results in a clear table format
4. Provide specific installation/auth commands for missing items
5. Guide you step-by-step through each setup
6. Verify each integration with actual API calls
7. Confirm you're ready to start development

## Support

If you encounter issues during setup:
- Check the detailed guides in the `references/` directory
- Verify you have necessary permissions (GitHub repo access, Jira site access)
- Ensure you're connected to the internet (authentication requires network access)
- Try running commands manually in your terminal to see detailed error messages
