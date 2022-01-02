ARG victag=stable
FROM vic-nvim:${victag}

# Install treesitter syntaxes related to Go
RUN nvim --headless "+TSInstallSync go" +qall

# Install Go
USER 0:0
ARG goversion=1.17.5
RUN wget https://go.dev/dl/go${goversion}.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go${goversion}.linux-amd64.tar.gz && \
    rm go${goversion}.linux-amd64.tar.gz
ENV PATH="${PATH}:/usr/local/go/bin:${HOME}/go/bin"
USER $VICUID:$VICGID

# Install Go language server
RUN go install golang.org/x/tools/gopls@v0.7.4

# Point packages into workspace to reduce download overhead
ENV GOMODCACHE=/host/workspace/pkg/mod

COPY go.lua $HOME/.config/nvim/ftplugin/

WORKDIR /host/code
CMD nvim .

# docker build . -t vic-go-1.17:stable --build-arg goversion=1.17.5
