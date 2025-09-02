#!/bin/bash

set -e

DOTFILES_REPO="https://github.com/craftzdog/dotfiles-public.git"
DOTFILES_DIR="$HOME/dotfiles"
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

echo "📁 Cloning dotfiles..."
if [ ! -d "$DOTFILES_DIR" ]; then
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
  echo "Dotfiles already cloned."
fi

echo "🔗 Creating symlinks..."
cd "$DOTFILES_DIR"

# Backup and link dotfiles
for file in .zshrc .gitconfig .tmux.conf .config/nvim .config/alacritty; do
  target="$HOME/$file"
  source="$DOTFILES_DIR/$file"
  if [ -e "$target" ] || [ -L "$target" ]; then
    echo "🔁 Backing up existing $file"
    mv "$target" "$target.bak"
  fi
  ln -s "$source" "$target"
done

echo "🛠️ Installing dependencies..."

if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  if ! command -v brew &> /dev/null; then
    echo "🍺 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  echo "📦 Installing packages from Brewfile..."
  brew bundle --file="$DOTFILES_DIR/Brewfile"
else
  # Ubuntu/Debian
  sudo apt update
  sudo apt install -y zsh git tmux curl fzf neovim ripgrep unzip python3-pip
fi

echo "💡 Installing oh-my-zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

echo "🎨 Installing zsh plugins..."
# Powerlevel10k
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
fi

# Autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# Syntax highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

echo "💻 Setting Zsh as default shell..."
chsh -s "$(which zsh)"

echo "🔧 Installing Neovim plugins..."
if command -v nvim &> /dev/null; then
  nvim --headless "+Lazy! sync" +qa
fi

echo "✅ Done! Restart your terminal to apply changes."
