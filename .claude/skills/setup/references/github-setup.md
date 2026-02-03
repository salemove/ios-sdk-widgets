# GitHub CLI Integration Setup

This guide covers setting up GitHub CLI (`gh`) integration for Claude Code to interact with GitHub repositories.

## Overview

Claude has direct access to GitHub repositories via GitHub CLI (`gh`) MCP integration for:
- Viewing pull requests and issues
- Searching code and repositories
- Creating issues and comments
- Listing commits and branches
- Reading file contents

## Prerequisites

- macOS
- Internet connection
- GitHub account with access to `salemove/*` repositories

## Installation

Install GitHub CLI using Homebrew:

```bash
brew install gh
```

**Verify Installation:**

```bash
gh --version
# Should show: gh version 2.x.x (or later)
```

## Authentication

GitHub CLI uses browser-based OAuth for secure authentication.

### Step 1: Login

```bash
gh auth login
```

### Step 2: Follow the prompts

1. **What account do you want to log into?**
   - Select: **GitHub.com**

2. **What is your preferred protocol for Git operations?**
   - Select: **HTTPS**

3. **Authenticate Git with your GitHub credentials?**
   - Select: **Yes**

4. **How would you like to authenticate GitHub CLI?**
   - Select: **Login with a web browser**

5. **Copy the one-time code** (e.g., `XXXX-XXXX`)
   - Press **Enter**
   - Browser opens automatically
   - Paste the code
   - Click **Authorize github**

### Step 3: Verify Authentication

```bash
gh auth status
```

Expected output:
```
github.com
  ✓ Logged in to github.com as <your-username> (<config-file>)
  ✓ Git operations for github.com configured to use https protocol.
  ✓ Token: *******************
```

## Install gh-mcp Extension

The `gh-mcp` extension enables Claude Code to use GitHub CLI.

```bash
gh extension install shuymn/gh-mcp
```

### Verify Extension

```bash
gh extension list
```

Should show:
```
gh mcp	shuymn/gh-mcp	<version>
```

## Test GitHub Access

### Test 1: View Repository

```bash
gh repo view salemove/ios-sdk-widgets --json name,description,url
```

Expected: JSON output with repository details

### Test 2: List Pull Requests

```bash
gh pr list --repo salemove/ios-sdk-widgets --limit 5
```

Expected: List of recent pull requests

### Test 3: Search Code

```bash
gh search code --repo salemove/ios-sdk-widgets "FlowCoordinator" --limit 5
```

Expected: Code search results

## Usage Examples

Once configured, Claude can use these commands:

### Pull Requests
```bash
gh pr list --repo salemove/ios-sdk-widgets
gh pr view 456 --repo salemove/ios-sdk-widgets
gh pr create --repo salemove/ios-sdk-widgets --title "..." --body "..."
```

### Issues
```bash
gh issue list --repo salemove/ios-sdk-widgets
gh issue view 123 --repo salemove/ios-sdk-widgets
gh issue create --repo salemove/ios-sdk-widgets --title "..." --body "..."
```

### Repository Info
```bash
gh repo view salemove/ios-sdk-widgets
gh repo view salemove/ios-sdk --json name,description
```

### Code Search
```bash
gh search code --repo salemove/ios-sdk-widgets "Theme.Button"
```

## Permissions

Your GitHub account needs access to:
- `salemove/ios-sdk-widgets` (this repository)
- `salemove/ios-sdk` (GliaCore SDK)
- `salemove/ios-widgets-snapshots` (snapshot tests)
- `salemove/ios-bundle` (XCFramework releases)

If you get permission denied errors, contact your team lead to grant repository access.

## Troubleshooting

### Error: "gh: command not found"

**Cause:** GitHub CLI not installed

**Fix:**
```bash
brew install gh  # macOS
```

### Error: "HTTP 401: Bad credentials"

**Cause:** Not authenticated or token expired

**Fix:**
```bash
gh auth login
# Follow browser OAuth flow
```

### Error: "HTTP 404: Not Found"

**Cause:** Repository doesn't exist or you don't have access

**Fix:**
- Verify repository name is correct
- Check you have access to the repository
- Contact team lead to grant access

### Error: "extension not found: mcp"

**Cause:** gh-mcp extension not installed

**Fix:**
```bash
gh extension install shuymn/gh-mcp
```

## Benefits

✅ **Browser-based OAuth** - No manual token creation
✅ **No tokens stored in files** - Uses `gh` credentials securely
✅ **Automatic token refresh** - Handled by `gh` automatically
✅ **Same auth for Git operations** - Unified authentication
✅ **Easy team onboarding** - Simple setup process

## Additional Resources

- [GitHub CLI Documentation](https://cli.github.com/manual/)
- [gh-mcp Extension](https://github.com/shuymn/gh-mcp)
- [GitHub CLI Authentication](https://cli.github.com/manual/gh_auth_login)
