# dotfiles

This is my dotfiles. I use the following development environment.

### Terminal
- [wezterm](https://wezfurlong.org/wezterm/) (configured under [mywezterm](file:///home/oomor/dotfiles/mywezterm))

### Shell
- [zsh](https://www.zsh.org/) (configured under [zdotdir](file:///home/oomor/dotfiles/zdotdir) and [zshenv](file:///home/oomor/dotfiles/zshenv))
- [sheldon](https://github.com/rossmacarthur/sheldon) (plugin manager, configured under [sheldon](file:///home/oomor/dotfiles/sheldon))
- [starship](https://starship.rs/) (prompt engine, configured under [starship](file:///home/oomor/dotfiles/starship))

### Git Client
- [lazygit](https://github.com/jesseduffield/lazygit) (configured under [lazygit](file:///home/oomor/dotfiles/lazygit))

### Editor
- Neovim (Note: Neovim configurations are currently not included in this repository)

---

## Usage

### 1. Zsh Setup

Change `$ZDOTDIR` using `.zshenv`. See [mastering-zsh](https://github.com/rothgar/mastering-zsh/blob/master/docs/config/general.md#files) for details.

```zsh
# Link zshenv to home directory
ln -s ~/dotfiles/zshenv ~/.zshenv

# Link zdotdir configuration directory
ln -s ~/dotfiles/zdotdir ~/.config/zdotdir
```

### 2. WezTerm Setup

The terminal settings are inspired by [KevinSilvester's config](https://github.com/KevinSilvester/wezterm-config) but customized and tracked directly inside [mywezterm](file:///home/oomor/dotfiles/mywezterm).

```zsh
ln -s ~/dotfiles/mywezterm ~/.config/wezterm
```

### 3. Sheldon (Zsh Plugins) Setup

```zsh
ln -s ~/dotfiles/sheldon/plugins.toml ~/.config/sheldon/plugins.toml
```

### 4. Starship Prompt Setup

```zsh
ln -s ~/dotfiles/starship/starship.toml ~/.config/starship.toml
```

### 5. Lazygit Setup

```zsh
ln -s ~/dotfiles/lazygit ~/.config/lazygit
```

