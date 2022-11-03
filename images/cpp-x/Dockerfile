ARG victag=stable
FROM vic-nvim:${victag}

# Install compilers and libraries
USER 0:0
ARG clangversion=14
ARG clangdversion=14
RUN apt update && apt install -y \
    clang-${clangversion} clang-tools-${clangversion} libc++-${clangversion}-dev \
    clangd-${clangdversion} \
    && rm -rf /var/cache/apt/lists
RUN ln -s /usr/bin/clangd-${clangdversion} /usr/bin/clangd
USER $VICUID:$VIGGID

# Treesitter syntaxes
RUN nvim --headless "+TSInstallSync cpp" +qall; exit 0
RUN nvim --headless "+TSInstallSync cmake" +qall; exit 0
RUN nvim --headless "+TSInstallSync make" +qall; exit 0
RUN nvim --headless "+TSInstallSync meson" +qall; exit 0
RUN nvim --headless "+TSInstallSync ninja" +qall; exit 0

COPY cpp.lua $HOME/.config/nvim/ftplugin/


WORKDIR /host/code
CMD nvim +Fex
