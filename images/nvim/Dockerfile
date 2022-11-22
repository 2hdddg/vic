FROM debian:bookworm-slim

ARG vicuid=1000
ARG vicuser=peter
ARG vicgid=1000
ARG nvimversion=x

# Install general goodies and everything needed to build neovim
# Run this as root
RUN apt update && apt install -y \
    git gnupg ninja-build gettext libtool libtool-bin autoconf automake cmake g++ \
    pkg-config unzip wget silversearcher-ag && \
    rm -rf /var/cache/apt/lists
# Build and install neovim
RUN git clone --depth 1 --branch v${nvimversion} https://github.com/neovim/neovim.git && cd neovim && make -j4 && make install && cd .. && rm -rf neovim

# Setup the host user
ENV VICUID=${vicuid}
ENV VICGID=${vicgid}
RUN useradd -r -m -d /home/${vicuser} -u ${vicuid} ${vicuser}
USER ${vicuid}:${vicgid}
ENV HOME=/home/${vicuser}
WORKDIR $HOME

# Copy vim config
COPY init.lua .config/nvim/
COPY lua/ .config/nvim/lua/
# This will install plugins and exit
RUN nvim --headless
# Setup treesitter stuff, install a bunch of languages
RUN nvim --headless -c "TSInstallSync bash" -c qall; exit 0

# Save bash history in host workspace
ENV HISTFILE=/host/workspace/.bash_history
