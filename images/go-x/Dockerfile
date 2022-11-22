ARG victag=stable
FROM vic-nvim:${victag}

# Install Go
USER 0:0
ARG goversion=1.18.2
RUN wget https://go.dev/dl/go${goversion}.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go${goversion}.linux-amd64.tar.gz && \
    rm go${goversion}.linux-amd64.tar.gz
ENV PATH="${PATH}:/usr/local/go/bin:${HOME}/go/bin"
USER $VICUID:$VICGID

# Install treesitter syntaxes related to Go
RUN nvim --headless -c "TSInstallSync go" -c qall

# Install Go language server
RUN go install golang.org/x/tools/gopls@v0.8.3

# Point packages into workspace to reduce download overhead
ENV GOMODCACHE=/host/workspace/pkg/mod

COPY go.lua $HOME/.config/nvim/ftplugin/

WORKDIR /host/code
CMD nvim .
