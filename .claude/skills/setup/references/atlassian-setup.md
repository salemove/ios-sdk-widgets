# Atlassian Integration Setup (Jira & Confluence)

This guide covers setting up Atlassian integrations for Claude Code to interact with Jira tickets and Confluence pages.

## Overview

Claude has access to Atlassian services using **two different tools**:
- **Jira:** Atlassian CLI (`acli`) - Token-efficient for ticket operations
- **Confluence:** Atlassian MCP Server - Better content access for documentation

## Tool Selection Rules

🔴 **IMPORTANT:**
- **Jira operations:** ALWAYS use `acli` CLI - NO EXCEPTIONS
- **Confluence operations:** ALWAYS use Atlassian MCP Server

**Why?** CLI is more token-efficient for Jira, while MCP provides better Confluence content access.

---

## Part 1: Atlassian CLI (`acli`) for Jira

### Installation

Install Atlassian CLI using Homebrew:

```bash
brew install acli
```

**Verify Installation:**

```bash
acli --version
```

### Authentication

ACLI uses browser-based OAuth for secure authentication.

#### Step 1: Login

```bash
acli jira auth login --web
```

#### Step 2: Browser OAuth Flow

1. Browser opens automatically
2. Log in to your Atlassian account (if not already logged in)
3. **Select your Glia site** when prompted (e.g., `glia.atlassian.net`)
4. Click **Accept** to authorize the CLI
5. Browser shows "Authentication successful"

#### Step 3: Verify Authentication

```bash
acli jira auth status
```

Expected output:
```
Authenticated as: <your-email>
Site: glia.atlassian.net
```

### Test Jira Access

```bash
# Test 1: View a known ticket
acli jira workitem view MOB-4009

# Test 2: Search for your issues
acli jira workitem search --jql "assignee = currentUser() AND status != Done" --limit 5
```

### Usage Examples

#### View Tickets
```bash
acli jira workitem view MOB-1234
acli jira workitem view MOB-1234 --json
acli jira workitem view MOB-1234 --web  # Opens in browser
```

#### Search with JQL
```bash
# My open issues
acli jira workitem search --jql "assignee = currentUser() AND status != Done"

# Project issues
acli jira workitem search --jql "project = MOB AND status = Open" --paginate

# Recent updates
acli jira workitem search --jql "assignee = currentUser() AND updated >= -30d ORDER BY updated DESC"
```

#### List Issues
```bash
acli jira workitem list --jql "project = MOB" --limit 20
```

### Permissions Required

Your Jira account needs:
- Access to `MOB` project (Mobile team)
- Access to other relevant projects (check with team lead)
- Standard user permissions (view, comment, edit assigned tickets)

---

## Part 2: Atlassian MCP Server for Confluence

### Configuration

The Atlassian MCP server is already configured in [.mcp.json](../../../.mcp.json).

**No additional setup needed** - it uses the same OAuth credentials as `acli` from Part 1.

### Verify Confluence Access

Claude can test Confluence access by searching for pages:

```
Search Confluence for "release process"
```

### Usage Examples

Once configured, Claude can use these MCP tools:

#### Search Pages
```
Search Confluence for "UI design guidelines"
Search Confluence pages in the ENG space
```

#### Read Page Content
```
Get Confluence page with ID 3139960837
Read the Release Process page from Confluence
```

#### List Spaces
```
List all Confluence spaces
Show pages in the ENG Confluence space
```

#### CQL Queries
```
Search Confluence using CQL: title ~ "release" AND type = page
```

### Confluence Spaces

Common spaces in Glia's Confluence:
- **ENG** - Engineering documentation
- **PROD** - Product documentation
- **CS** - Customer Success
- **DOCS** - Public documentation

---

## Troubleshooting

### Jira: Error "Command not found: acli"

**Cause:** ACLI not installed

**Fix:**
```bash
brew install acli  # macOS
```

### Jira: Error "Unauthorized" or "Not authenticated"

**Cause:** Not logged in or session expired

**Fix:**
```bash
acli jira auth login --web
# Complete browser OAuth flow
```

### Jira: Error "Site not selected"

**Cause:** During login, you didn't select the Glia site

**Fix:**
```bash
acli jira auth login --web
# When prompted, select: glia.atlassian.net
```

### Confluence: MCP server not responding

**Cause:** MCP server not started or authentication issue

**Fix:**
1. Verify `acli` authentication works (Part 1)
2. Restart Claude Code
3. Check `.mcp.json` configuration

### Confluence: "Access denied" errors

**Cause:** Insufficient Confluence permissions

**Fix:**
- Verify you have access to the space
- Check with team lead for permission grants
- Try accessing the page in browser first

---

## Pre-Approved Commands

The following commands are pre-approved in [.claude/settings.json](../../../settings.json) and won't require permission prompts:

### Jira (acli)
- `acli jira workitem view *`
- `acli jira workitem *`

### Confluence (MCP)
- `mcp__atlassian__search`
- `mcp__atlassian__getConfluencePage`
- `mcp__atlassian__getPagesInConfluenceSpace`
- `mcp__atlassian__getConfluenceSpaces`
- `mcp__atlassian__searchConfluenceUsingCql`

---

## Usage Patterns for Claude

### Jira Workflows

**View Ticket:**
```
Get details on Jira ticket MOB-1234
What's the status of MOB-4009?
```

**Search Issues:**
```
Find all open issues assigned to me
What issues did I work on last week?
Show me all high-priority bugs in MOB project
```

**Sprint Info:**
```
What's in the current sprint?
List all issues in the active sprint assigned to me
```

### Confluence Workflows

**Search Documentation:**
```
Search Confluence for mobile SDK release process
Find documentation about theme customization
```

**Read Pages:**
```
Show me the Release Process page
Get the iOS development guidelines from Confluence
```

**Browse Spaces:**
```
What pages are in the ENG Confluence space?
List all documentation in the MOBILE space
```

---

## Benefits

### Jira (acli)
✅ **Browser-based OAuth** - No manual token creation
✅ **Token-efficient** - Lower Claude Code context usage
✅ **Full JQL support** - Powerful query capabilities
✅ **Fast operations** - Direct CLI access

### Confluence (MCP)
✅ **Rich content access** - Full page content with formatting
✅ **Search capabilities** - CQL query support
✅ **Shared authentication** - Uses same OAuth as acli
✅ **Space browsing** - Easy navigation of documentation

---

## Additional Resources

- **ACLI Documentation:** [https://developer.atlassian.com/cloud/acli/](https://developer.atlassian.com/cloud/acli/)
- **JQL Guide:** [https://www.atlassian.com/software/jira/guides/expand-jira/jql](https://www.atlassian.com/software/jira/guides/expand-jira/jql)
- **CQL Guide:** [https://developer.atlassian.com/cloud/confluence/cql/](https://developer.atlassian.com/cloud/confluence/cql/)
- **Glia Jira:** [https://glia.atlassian.net](https://glia.atlassian.net)
- **Glia Confluence:** [https://glia.atlassian.net/wiki](https://glia.atlassian.net/wiki)
