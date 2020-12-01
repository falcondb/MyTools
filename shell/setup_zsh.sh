OMZURL=https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh

set -e

curl -fsSL --output omz_installer.sh $OMZURL

zsh omz_installer.sh

upgrade_oh_my_zsh

git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k

echo "ZSH_THEME=\"powerlevel10k/powerlevel10k\"" >> ~/.zshrc

. ~/.zshrc

git clone https://github.com/zsh-users/zsh-autosuggestions \
${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# doesn't work with Macos
sed -i '^plugins=(*)/plugins=( git zsh-syntax-highlighting zsh-autosuggestions)'  ~/.zshrc
