# Usage Guide

This guide explains how to use the GitLab Code Review application to export, review, and track feedback from GitLab merge requests.

## Overview

The GitLab Code Review app helps you:
1. Export all comments from a GitLab merge request
2. Review feedback items systematically
3. Track which items have been addressed
4. Sync review status back to GitLab with emoji reactions

## Getting Started

### Accessing the Application

Once the application is running, navigate to:

```
http://localhost:3000
```

You'll see the main dashboard showing all exported merge requests.

## Core Workflows

### 1. Exporting a Merge Request

**Step 1: Navigate to New Export**

From the main dashboard, click "New Export" or navigate to:

```
http://localhost:3000/exports/new
```

**Step 2: Enter Merge Request URL**

Paste the full URL of the GitLab merge request you want to export. The URL should look like:

```
https://gitlab.com/project-name/repo-name/-/merge_requests/123
```

Or for other GitLab instances:

```
https://gitlab.com/username/project/-/merge_requests/456
```

**Step 3: Submit**

Click "Export" to start the export process.

**What Happens:**
- The app fetches the merge request details (title, author, state)
- All discussions and comments are retrieved
- For each comment, the app checks if it has a ✅ (white_check_mark) reaction
- Comments with check marks are automatically marked as "reviewed"
- The export is saved to the database

### 2. Reviewing Feedback

**Step 1: Open an Export**

From the main dashboard, click on any exported merge request to view its details.

**Step 2: View Feedback Items**

The export detail page shows:
- **Merge Request Info**: Title, author, source/target branches, state
- **Feedback List**: All comments from the merge request

Each feedback item displays:
- **Author**: Who wrote the comment
- **File & Line**: Where the comment was made (if applicable)
- **Body**: The comment text
- **Review Status**: Whether it has been reviewed

**Step 3: Mark Items as Reviewed**

For each feedback item:
- If it shows as "Not reviewed", you can mark it as reviewed
- Click the "Mark as Reviewed" button next to the feedback item
- The item will be visually updated to show it's been reviewed
- A ✅ reaction is automatically added to the comment in GitLab

**Automatic Detection:**
- If a comment already has a ✅ in GitLab before export, it's automatically marked as reviewed
- You don't need to re-mark these items

### 3. Tracking Export Status

**Mark Entire Export as Reviewed**

Once you've reviewed all feedback items, you can mark the entire export as reviewed:

1. Go to the exports list (main dashboard)
2. Find the export you've completed
3. Click "Mark as Reviewed"
4. The export status changes to "Reviewed"

This helps you track which merge requests have been completely processed.

**Unmark if Needed**

If you need to revisit an export:
1. Click "Mark as Unreviewed" on a reviewed export
2. The status changes back to "Unreviewed"

### 4. Viewing Export History

The main dashboard (`http://localhost:3000`) shows all exports in reverse chronological order (newest first).

For each export, you'll see:
- **MR Title**: The merge request title
- **Project**: The GitLab project path
- **MR IID**: The merge request number
- **Author**: Who created the merge request
- **State**: Open, Merged, Closed
- **Review Status**: Whether you've marked this export as reviewed
- **Created At**: When the export was created

## API Usage

The application also provides a JSON API for programmatic access.

### Export via API

**Endpoint:**
```
POST /api/export
```

**Parameters:**
```json
{
  "mr_url": "https://gitlab.com/project/repo/-/merge_requests/123"
}
```

**Response:**
```json
{
  "id": 1,
  "mr_url": "https://gitlab.com/project/repo/-/merge_requests/123",
  "mr_iid": 123,
  "project_path": "project/repo",
  "mr_title": "Add new feature",
  "mr_author": "username",
  "mr_state": "opened",
  "reviewed": false,
  "data": {
    "merge_request": { ... },
    "feedback": [ ... ]
  }
}
```

### List All Exports

**Endpoint:**
```
GET /exports.json
```

**Response:**
```json
[
  {
    "id": 1,
    "mr_title": "Add new feature",
    "mr_iid": 123,
    ...
  }
]
```

### Get Single Export

**Endpoint:**
```
GET /exports/:id.json
```

**Response:**
```json
{
  "id": 1,
  "data": {
    "merge_request": { ... },
    "feedback": [
      {
        "id": 456,
        "author": "reviewer",
        "body": "This needs improvement",
        "file": "app/models/user.rb",
        "line": 42,
        "has_check_mark": true,
        "reviewed": true
      }
    ]
  }
}
```

### Mark Feedback as Reviewed (API)

**Endpoint:**
```
PATCH /exports/:export_id/feedbacks/:feedback_id/mark_reviewed
```

**Response:**
```json
{
  "success": true,
  "feedback": {
    "id": 1,
    "feedback_id": "456",
    "reviewed": true
  }
}
```

## Use Cases

### Use Case 1: Code Review Checklist

When conducting code reviews:
1. Export the merge request before starting your review
2. Open the export in the app
3. Go through each feedback item methodically
4. Mark items as reviewed as you address them
5. When done, mark the entire export as reviewed

### Use Case 2: Tracking Review Progress

For large merge requests with many comments:
1. Export the MR
2. Review items incrementally over multiple sessions
3. The app tracks which items you've already reviewed
4. Return anytime to see remaining items

### Use Case 3: Team Coordination

When multiple reviewers work on the same MR:
1. Comments marked with ✅ in GitLab are automatically tracked
2. Team members can see which feedback has been addressed
3. Reduces duplicate work and confusion

### Use Case 4: Review Metrics

Track your review activity:
1. View all exports to see MRs you've reviewed
2. See review dates and completion status
3. Export data via API for analytics

## Tips & Best Practices

### Organizing Your Reviews

- **Export early**: Create an export as soon as you start reviewing an MR
- **Regular updates**: Re-export if significant new comments are added
- **Mark as you go**: Mark feedback items as reviewed immediately after addressing them
- **Complete the export**: Mark the entire export as reviewed when finished

### Working with GitLab

- **Check marks sync**: Marking items in the app adds ✅ to GitLab automatically
- **Manual marks work too**: You can add ✅ directly in GitLab before exporting
- **Token permissions**: Ensure your GitLab token has `api` scope for full functionality

### Handling Errors

**"Invalid GitLab MR URL"**
- Ensure the URL follows the correct format
- Must contain `/-/merge_requests/` with a number

**"GitLab API error"**
- Check your token is valid and not expired
- Verify the merge request exists and you have access to it
- Ensure `GITLAB_ENDPOINT` is correctly configured

**"Not Found"**
- The merge request may have been deleted
- Check the project path and MR number are correct

## Keyboard Shortcuts

Currently, the application doesn't have keyboard shortcuts, but you can:
- Use browser navigation (Back/Forward)
- Bookmark frequently accessed exports
- Use browser search (Ctrl+F / Cmd+F) on the exports list page

## Data Management

### Exports are Persistent

- All exports are saved to the database
- You can return to any export at any time
- Review status is tracked independently per export

### Re-exporting

If you need to re-export a merge request:
1. Create a new export with the same URL
2. Both exports will exist independently
3. This is useful if significant changes occur in the MR

### Deleting Exports

Currently, there's no UI for deleting exports. To remove exports, use Rails console:

```bash
rails console
```

```ruby
# Delete a specific export
Export.find(id).destroy

# Delete all exports for a specific MR
Export.where(mr_iid: 123).destroy_all
```

## Advanced Usage

### Custom GitLab Instances

The app works with any GitLab instance. Update the `.env` file:

```bash
GITLAB_ENDPOINT=https://your-gitlab-instance.com/api/v4
```

### Multiple Tokens

To use different tokens for different projects, you can temporarily modify the `.gitlab.pwd` file or set the environment variable directly.

### Batch Processing

To export multiple merge requests, you can use the API endpoint in a script:

```bash
#!/bin/bash

MR_URLS=(
  "https://gitlab.com/project/repo/-/merge_requests/1"
  "https://gitlab.com/project/repo/-/merge_requests/2"
  "https://gitlab.com/project/repo/-/merge_requests/3"
)

for url in "${MR_URLS[@]}"; do
  curl -X POST http://localhost:3000/api/export \
    -H "Content-Type: application/json" \
    -d "{\"mr_url\": \"$url\"}"
done
```

## Questions & Support

For issues or questions:
1. Check the [README.md](README.md) for setup troubleshooting
2. Review the Rails logs for detailed error messages
3. Verify your GitLab token and endpoint configuration
