# ph’s dotfiles

Dotfiles managed with a **bare git repo** in `$HOME` and a `cfg` alias.  
No stow, no symlinks, just git.

---

## Setup on this machine

Init bare repo and alias:

```sh
git init --bare "$HOME/.cfg"

# Add to ~/.zshrc (or ~/.bashrc)
alias cfg='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
```

Hide untracked home junk from `cfg status`:

```sh
cfg config status.showUntrackedFiles no
```

Add a global ignore in `$HOME/.gitignore` (already in this repo):

```sh
cfg add .gitignore
cfg commit -m "Add global gitignore"
```

---

## Cloning on a new machine

```sh
git clone --bare git@github.com:<user>/dotfiles.git "$HOME/.cfg"

# Add alias + completion to ~/.zshrc as above, then:
source ~/.zshrc

cfg config status.showUntrackedFiles no

# Check out the files into $HOME
cfg checkout
```

If checkout complains about existing files, move them away and run `cfg checkout` again.

---

## Day-to-day usage

**See what changed:**

```sh
cfg status
cfg diff
```

**Stage only modified tracked files (no new files):**

```sh
cfg add -u
# or interactively choose hunks:
cfg add -p
```

**Commit:**

```sh
cfg commit -m "Describe the change"
# or stage & commit modified tracked files in one go:
cfg commit -am "Describe the change"
```

**Push:**

```sh
cfg push
```

---

## Undo / fix-ups

**Unstage a file (reverse `cfg add`):**

```sh
cfg restore --staged path/to/file
```

**Unstage everything:**

```sh
cfg restore --staged .
```

**Discard changes to a file (dangerous, loses edits):**

```sh
cfg restore path/to/file
```

---

## What’s tracked

Only specific config files/scripts in `$HOME` are tracked (see `cfg ls-files`).  
Secrets, browser profiles, caches, history files etc. are excluded via `$HOME/.gitignore`.
