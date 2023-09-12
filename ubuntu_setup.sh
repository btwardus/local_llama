#!/bin/bash

# -----------------
# System Update
# -----------------
sudo apt update 
sudo apt full-upgrade -y

# -----------------
# Install Pre-Requirements
# -----------------
sudo apt install build-essential procps curl file git

# Check if brew is installed
if ! command -v brew &> /dev/null; then
    # Install brew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    (echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> ~/.bashrc
    brew doctor
fi

# Install brew packages
brew install pipx direnv

pipx ensurepath

# Install python dependencies
sudo apt update 
sudo apt install build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev curl \
libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

# Install pyenv
if ! command -v pyenv &> /dev/null; then
    curl https://pyenv.run | bash

    # Add pyenv configuration to .bashrc if not present
    if ! grep -q "PYENV_ROOT" ~/.bashrc; then
        echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
        echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
        echo 'eval "$(pyenv init -)"' >> ~/.bashrc
        echo "Added pyenv configuration to .bashrc"
    else
        echo "Pyenv configuration already exists in .bashrc"
    fi
    
    # Check if pyenv setup is correct
    if ! pyenv doctor; then
        echo "There seems to be an issue with the pyenv setup. Exiting..."
        exit 1
    fi
fi

# Install Python using pyenv
pyenv install 3.11
pyenv global 3.11

# Install poetry using pipx
pipx install poetry --python $(pyenv which python3)

# Add pyenv configuration to .bash_profile
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bash_profile
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(pyenv init -)"' >> ~/.bash_profile

# Restart shell
exec "$SHELL"

pipx inject poetry pip-system-certs

# Configure poetry
poetry config virtualenvs.in-project true
poetry config virtualenvs.prefper-active-python true
