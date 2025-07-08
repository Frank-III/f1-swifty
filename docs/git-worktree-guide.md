# Git Worktree Guide for Multiple Claude Instances

## Overview
Git worktrees allow multiple working directories for the same repository, enabling parallel development on different features without switching branches.

## Basic Commands

### Creating a Worktree
```bash
# Create a new worktree for an existing branch
git worktree add <path> <branch-name>

# Create a new worktree with a new branch
git worktree add -b <new-branch-name> <path> <base-branch>

# Examples
git worktree add ../f1-dash-auth feature/authentication
git worktree add -b feature/new-ui ../f1-dash-ui main
```

### Managing Worktrees
```bash
# List all worktrees
git worktree list

# Remove a worktree (after deleting the directory)
git worktree remove <path>

# Prune stale worktree entries
git worktree prune
```

## Multiple Claude Instance Workflow

### Example Setup
```bash
# Main repository location
cd ~/projects/learn_swift/f1-dash-swift

# Claude Instance 1: Authentication Feature
git worktree add -b feature/auth ../f1-dash-auth main
# Work in: ~/projects/learn_swift/f1-dash-auth

# Claude Instance 2: Real-time Updates
git worktree add -b feature/realtime ../f1-dash-realtime main
# Work in: ~/projects/learn_swift/f1-dash-realtime

# Claude Instance 3: Bug Fixes
git worktree add -b hotfix/weather-api ../f1-dash-hotfix main
# Work in: ~/projects/learn_swift/f1-dash-hotfix
```

### Directory Structure
```
~/projects/learn_swift/
├── f1-dash-swift/          # Main worktree (main branch)
├── f1-dash-auth/           # Auth feature worktree
├── f1-dash-realtime/       # Real-time feature worktree
└── f1-dash-hotfix/         # Hotfix worktree
```

## Best Practices

### 1. Naming Conventions
- Use descriptive names matching the branch purpose
- Keep worktree directory names consistent with branch names
- Use prefixes: `feature/`, `hotfix/`, `bugfix/`, etc.

### 2. Organization
- Place worktrees as siblings to the main repository
- Use a consistent parent directory for all worktrees
- Consider grouping by feature type

### 3. Workflow Tips
- Each Claude instance should work in its own worktree
- Commit and push changes before switching between worktrees
- Pull latest changes in main before creating new worktrees
- Remove worktrees when features are merged

### 4. Cleanup
```bash
# Remove worktree after feature is merged
cd ~/projects/learn_swift
git worktree remove f1-dash-auth
git branch -d feature/auth

# Clean up all prunable worktrees
git worktree prune
```

## Common Scenarios

### Scenario 1: Quick Hotfix While Working on Feature
```bash
# Currently in feature worktree
cd ~/projects/learn_swift/f1-dash-feature

# Create hotfix worktree without leaving current work
git worktree add -b hotfix/critical-bug ../f1-dash-hotfix main

# Fix bug in new terminal/Claude instance
cd ../f1-dash-hotfix
# ... make fixes, commit, push, create PR ...

# Continue feature work in original worktree
```

### Scenario 2: Testing Integration Between Features
```bash
# Create integration branch combining two features
git worktree add -b feature/integration ../f1-dash-integration main

cd ../f1-dash-integration
git merge origin/feature/auth
git merge origin/feature/realtime
# Test integration...
```

### Scenario 3: Code Review in Separate Worktree
```bash
# Review a PR without disrupting current work
git fetch origin pull/123/head:review/pr-123
git worktree add ../f1-dash-review review/pr-123
```

## Troubleshooting

### Worktree Already Exists
```bash
# If worktree path exists but git doesn't know about it
git worktree prune
git worktree add <path> <branch>
```

### Branch Already Checked Out
```bash
# Error: branch is already checked out at another worktree
git worktree list  # Find where it's checked out
# Either use that worktree or remove it first
```

### Locked Worktree
```bash
# If worktree is locked
git worktree unlock <path>
```

## Quick Reference

| Command | Purpose |
|---------|---------|
| `git worktree add <path> <branch>` | Create worktree |
| `git worktree list` | Show all worktrees |
| `git worktree remove <path>` | Remove worktree |
| `git worktree prune` | Clean up stale entries |
| `git worktree lock <path>` | Prevent auto-cleanup |
| `git worktree unlock <path>` | Allow auto-cleanup |

## Tips for Claude Instances

1. **Start each session** by checking which worktree you're in:
   ```bash
   pwd
   git branch --show-current
   ```

2. **Before creating PR**, ensure you're in the right worktree:
   ```bash
   git worktree list
   ```

3. **Keep main branch updated** in the main worktree:
   ```bash
   cd ~/projects/learn_swift/f1-dash-swift
   git checkout main
   git pull origin main
   ```

4. **Use descriptive commit messages** that reference the worktree/feature

5. **Document which Claude instance** is working on what:
   - Instance 1: Auth system (f1-dash-auth)
   - Instance 2: Real-time updates (f1-dash-realtime)
   - Instance 3: Bug fixes (f1-dash-hotfix)