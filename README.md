## My dotfiles

In this repository, you can find the dotfiles I use. WIP.

#### Configurations included

- `tmux`
- `.vimrc`
- `fzf` and `rg` aliases
- `waybar`
- `hyprland`

#### Installation

Run the following in your home directory

```bash
git clone https://github.com/bladeacer/my_dotfiles.git
cd dotfiles
stow vim
stow tmux
stow bash
stow .config
stow <other_dirs>
```

### Fastfetch and wallpaper
Credit to https://codeberg.org/LainOS/LainOS-ricer-arch.

For the wallpaper on Linux, symlink or copy to `/usr/share`

#### Vim on Windows

- Git clone as usual
- Enable 64 bit support
- Symlink files to your preference

```md
cmd.exe > mklink C:\Users\example\_vimrc C:\Users\example\<your_dotfiles_path>\_vimrc
```

Ensure both files do not exist before symbolic linking.
> Copy over file content from _temp_vimrc to the first file in the command above.

- Need admin on `cmd.exe`
