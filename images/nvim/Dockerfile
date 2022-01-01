FROM debian:bookworm-slim

# Install general goodies and everything needed to build neovim
# Run this as root
RUN apt update && apt install -y \
    git gnupg ninja-build gettext libtool libtool-bin autoconf automake cmake g++ \
    pkg-config unzip wget silversearcher-ag && \
    rm -rf /var/cache/apt/lists
# Build and install neovim
RUN git clone --depth 1 --branch v0.6.0 https://github.com/neovim/neovim.git && cd neovim && make -j4 && make install && cd .. && rm -rf neovim

# Setup the host user
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
RUN mkdir -p $HOME/.local/share/nvim/site/autoload/
RUN wget https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim && mv plug.vim $HOME/.local/share/nvim/site/autoload/
# Download my neovim config
RUN mkdir -p .config/nvim
# Install neovim plugins, use only plug config initially
COPY plugs.vim .config/nvim/init.vim
RUN nvim --headless +PlugInstall +qall
# Setup treesitter stuff, install a bunch of languages
# Since these are a bit time consuming, do this before copying the config for faster builds
RUN nvim --headless "+TSInstallSync lua" +qall
RUN nvim --headless "+TSInstallSync bash" +qall
RUN nvim --headless "+TSInstallSync vim" +qall
# Setup the final config
COPY init.vim  .config/nvim/
COPY plugs.vim .config/nvim/
COPY terminal.vim .config/nvim/
# Make room for filetype plugins
RUN mkdir .config/nvim/ftplugin

# Save bash history in host workspace
ENV HISTFILE=/host/workspace/.bash_history

# docker build . -t vic-nvim:stable
# docker run --name xx --rm -it vic-nvim:5.1 /bin/bash

