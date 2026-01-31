# Push Command

Commit and push all changes to GitHub.

## Instructions

1. Run `git status` to see all changes (staged, unstaged, and untracked files)
2. Run `git diff` to review the changes
3. Add all relevant files (exclude sensitive files like .env, credentials, etc.)
4. Create a commit with a clear, descriptive message that summarizes all changes
5. Push to the remote repository
6. Report the commit hash and confirm the push was successful

## Commit Message Format

- Use imperative mood ("Add feature" not "Added feature")
- Keep the first line under 50 characters if possible
- Add a body if needed to explain the "why" behind changes
- Always include: `Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>`

## Safety

- Never commit files containing secrets (.env, credentials.json, API keys)
- Warn the user if there are no changes to commit
- If push fails, explain the error and suggest solutions
