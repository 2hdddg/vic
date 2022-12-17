ARG victag=stable
FROM vic-nvim:${victag}

# Install compilers and libraries
USER 0:0
ARG clangversion=14
ARG clangdversion=14
RUN apt update && apt install -y \
    clang-${clangversion} clang-tools-${clangversion} libc++-${clangversion}-dev \
    clangd-${clangdversion} \
    ninja-build \
    && rm -rf /var/cache/apt/lists
RUN ln -s /usr/bin/clangd-${clangdversion} /usr/bin/clangd
USER $VICUID:$VIGGID

WORKDIR /host/code
CMD nvim +Fex
