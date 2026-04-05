# VCS Detection

Before running any version control command, identify which VCS the working
directory uses:

- If under a Mercurial repo (`hg root` succeeds): use `hg` commands only.
  Common: `hg amend`, `hg sl`, `hg rebase`, `hg next`, `hg prev`, `hg diff`
- If under a Git repo (`git rev-parse --git-dir` succeeds): use `git` commands only.
  Common: `git commit`, `git push`, `git log`, `git rebase`

NEVER mix hg and git commands in the same repo.
When uncertain, run the detection commands above before proceeding.
