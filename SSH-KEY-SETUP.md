Per-repo SSH key setup
======================

This repository is configured to use a specific SSH key for Git operations so you don't need to set `GIT_SSH_COMMAND` every time.

To set the repo-local Git SSH command (already applied in this repo):

```bash
git config --local core.sshCommand "ssh -i ~/.ssh/id_ed25519_dn -o IdentitiesOnly=yes"
```

- Effect: only this repository will use the `id_ed25519_dn` key for SSH connections to GitHub.
- To remove the per-repo setting:

```bash
git config --local --unset core.sshCommand
```

If you need to push from a different account temporarily, you can still use `GIT_SSH_COMMAND` for a one-off override, for example:

```bash
GIT_SSH_COMMAND='ssh -i ~/.ssh/id_ed25519 -o IdentitiesOnly=yes' git push origin master
```

If you have any questions or want this documented inside README.md instead, tell me and I'll move it there.
