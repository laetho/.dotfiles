# dotfiles 

> Adapted from https://github.com/Siilwyn/my-dotfiles

## Initial setup on "source" computer

```sh
git init --bare $HOME/.dotfiles
alias dotfiles='git --git-dir=$HOME/.my-dotfiles/ --work-tree=$HOME'
dotfiles remote add origin git@github.com:laetho/.dotfiles.git
dotfiles config status.showUntrackedFiles no
dotfiles remote set-url origin git@github.com:laetho/.dotfiles.git
```


## Steps for setting up on another computer 

Use this steps to set up the dotfiles repo on a new machine.

```sh
git clone --separate-git-dir=$HOME/.dotfiles https://github.com/laetho/.dotfiles.git dotfiles-tmp
rsync --recursive --verbose --exclude '.git' dotfiles-tmp/ $HOME/
rm --recursive dotfiles-tmp
alias dotfiles='git --git-dir=$HOME/.my-dotfiles/ --work-tree=$HOME'
dotfiles config status.showUntrackedFiles no

```

## Usage
```sh
dotfiles status
dotfiles add .gitconfig
dotfiles commit -m 'Add gitconfig'
dotfiles push
```
