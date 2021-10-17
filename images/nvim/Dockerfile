FROM debian:bookworm-slim

# Install general goodies and everything needed to build neovim
# Run this as root
RUN apt update && apt install -y \
    git ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip wget silversearcher-ag
# Build and install neovim
RUN git clone --depth 1 --branch v0.5.1 https://github.com/neovim/neovim.git && cd neovim && make -j4 && make install && cd .. && rm -rf neovim

# Setup the user
ARG vicuid=1000
ARG vicuser=peter
ARG vicgid=1000
ENV VICUID=${vicuid}
ENV VICGID=${vicgid}
RUN useradd -r -m -d /home/${vicuser} -u ${vicuid} ${vicuser}
USER ${vicuid}:${vicgid}
ENV HOME=/home/${vicuser}
WORKDIR $HOME

# Install neovim plugin handler
#RUN sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
RUN mkdir -p $HOME/.local/share/nvim/site/autoload/
RUN wget https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim && mv plug.vim $HOME/.local/share/nvim/site/autoload/
# Download my neovim config
RUN mkdir -p .config/nvim
#RUN mkdir -p ~/.config/nvim && git clone https://github.com/2hdddg/nvimsettings ~/.config/nvim/
# Install neovim plugins, use only plug config initially
COPY plugs.vim .config/nvim/init.vim
RUN nvim --headless +PlugInstall +qall
# Setup treesitter stuff, copy plugs again to real name and the real config
COPY init.vim  .config/nvim/
COPY plugs.vim .config/nvim/
RUN nvim --headless "+TSInstallSync all" +qall

# Make room for filetype plugins
RUN mkdir .config/nvim/ftplugin

# docker build . -t vic-nvim:stable
# docker run --name xx --rm -it vic-nvim:5.1 /bin/bash

