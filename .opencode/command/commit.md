---
description: Stage all changes and commit with an emoji-prefixed message. Pass optional message context as $ARGUMENTS.
agent: build
---

Run `git diff --stat` and `git status`. Based on the changed files, craft a commit message with an emoji prefix matching the category of changes.

If $ARGUMENTS was provided, incorporate that context into the commit message.

First, **show me the proposed commit message** and **ask me to confirm** before executing. Only commit after I explicitly approve.

Use `git add -A && git commit -m "emoji Short title" -m "Bullet points of key changes"`.
