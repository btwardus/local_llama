#updgrade 
sudo apt update 
sudo apt full-upgrade -y

# Install pre requirements for brew and brew
sudo apt install build-essential procps curl file git

#install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add Linuxbrew to ~/.profile
#echo 'export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"' >>~/.profile
#echo 'export MANPATH="/home/linuxbrew/.linuxbrew/share/man:$MANPATH"' >>~/.profile
#echo 'export INFOPATH="/home/linuxbrew/.linuxbrew/share/info:$INFOPATH"' >>~/.profile

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
(echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> /home/$USER/.bashrc
brew doctor

# stop perl complaints 
#echo 'export LC_ALL=C.UTF-8' >> ~/.profile
#echo 'export LANG=C.UTF-8' >> ~/.profile


brew install pipx direnv
# Open ssl issue
brew unlink curl
brew unlink

hash curl 
curl https://pyenv.run | bash

# install specific python versions
for i in 3.10 3.11 3.12; do
    pyenv install $1
done 
pyenv gloabl 3.11

#relink homebrew packages
brew link openssl@1.1
brew link curl

#install poetry
pipx install poetry --python $(pyenv which python3)

#pyenv
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bash_profile
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(pyenv init -)"' >> ~/.bash_profile
exec "$SHELL" #restart shell

#python deps
sudo apt update; sudo apt install build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev curl \
libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

pipx inject poetry pip-system-certs

poetry config virtualenvs.in-project true
poetry config virtualenvs.prefper-active-python true