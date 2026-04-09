# GitHub Automation

Use this as the checklist for fully automated GitHub delivery from Codex.

## Required Access

- network access from the Codex environment
- push access to the repo remote
- GitHub authentication via one of:
  - `gh` installed and logged in
  - `GITHUB_TOKEN` or fine-grained PAT

Minimum GitHub permissions:

- `Issues`: write
- `Pull requests`: write
- `Contents`: write
- `Metadata`: read

## Standard Flow

1. Create issue from the feature request.
2. Create or switch to a feature branch.
3. Implement and validate locally.
4. Commit and push the branch.
5. Open a pull request linked to the issue.
6. Wait for required checks/reviews.
7. Squash merge the PR.
8. Optionally delete the remote branch.

## Notes

- If `gh` is unavailable, GitHub REST API calls can be used instead.
- Branch protection still applies; Codex should not bypass required checks or reviews.
- For future runs, use the local skill at `/Users/tangshua/.codex/skills/github-automation/SKILL.md`.
