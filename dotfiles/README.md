# dotfiles

My config files, managed with [GNU Stow](https://www.gnu.org/software/stow/).

The real files live in this repo. Stow creates symlinks to them in `$HOME`, so programs read the usual path (`~/<path>`) while the actual file is inside the repo.

Clone the repo anywhere. Every command below is run from the repo root and uses `-t ~` ("link into my home directory"), so the location doesn't matter.

## Layout

The repo mirrors `$HOME`. Whatever path a file has in your home, give it the same path here:

```
<repo>/
├── <file-in-home>              ->  ~/<file-in-home>
├── <dir-in-home>/<file>        ->  ~/<dir-in-home>/<file>
└── .config/<app>/<file>        ->  ~/.config/<app>/<file>
```

## Install on a new machine

1. Install Stow with your package manager:

   ```bash
   <package-manager> install stow
   ```

2. Clone the repo and go into it:

   ```bash
   git clone <repo-url> <path-to-repo>
   cd <path-to-repo>
   ```

3. Move away any existing file that would be in the way (Stow won't overwrite real files):

   ```bash
   mv ~/<path> ~/<path>.bak
   ```

4. Make sure the parent folders exist, then stow:

   ```bash
   mkdir -p ~/.config
   stow --no-folding -t ~ .
   ```

   `--no-folding` links individual files instead of whole directories, so apps that write extra files into a config folder don't put them in this repo.

5. Check it worked:

   ```bash
   ls -l ~/<path>
   # ~/<path> -> <path-to-repo>/<path>
   ```

## Everyday use

Edit files at their normal location (`~/<path>`). You are really editing the repo's copy. Then, from the repo root:

```bash
git add -A
git commit -m "<message>"
git push
```

## Add a new file or folder

Move it into the repo at the same path it has in `$HOME`, then restow. From the repo root:

```bash
mkdir -p <parent-dirs-of-path>
mv ~/<path> <path>
stow --no-folding -R -t ~ .
```

## Unlink everything

From the repo root:

```bash
stow -D -t ~ .
```

This removes the symlinks only. The files stay in the repo.

## Troubleshooting

- **"existing target is not owned by stow"**: a real file is already at that path. Move or delete it, then stow again. Or run `stow --adopt --no-folding -t ~ .` to pull the existing file into the repo, then check `git diff` (it overwrites the repo's version with yours).
- **Dry run first**: `stow -n -v --no-folding -t ~ .` shows what would happen without changing anything.
- **Repo files (README, .git) showing up in home**: make sure `.stow-local-ignore` exists (see below).

## Files Stow should ignore

Put this in `.stow-local-ignore` at the repo root:

```
\.git
\.gitignore
README.*
\.stow-local-ignore
```

## Don't commit secrets

Keep SSH keys, API tokens, and passwords out of this repo.
