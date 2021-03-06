ARG victag=stable
FROM vic-nvim:${victag}

# Install treesitter syntaxes related to Java
RUN nvim --headless "+TSInstallSync java" +qall
RUN nvim --headless "+TSInstallSync scala" +qall
RUN nvim --headless "+TSInstallSync kotlin" +qall

# Install Java and other Java specific tooling
USER 0:0
ARG javaversion=17
RUN apt update && apt install -y \
    openjdk-${javaversion}-jdk && \
    rm -rf /var/cache/apt/lists
ENV JAVA_HOME=/usr/lib/jvm/java-${javaversion}-openjdk-amd64
USER $VICUID:$VICGID

# Install Maven, need newer than Debian has
ARG mavenversion=3.8.6
RUN wget https://dlcdn.apache.org/maven/maven-3/${mavenversion}/binaries/apache-maven-${mavenversion}-bin.tar.gz && \
    tar xzvf apache-maven-${mavenversion}-bin.tar.gz && \
    rm apache-maven-${mavenversion}-bin.tar.gz
ENV PATH="${HOME}/bin:${PATH}"
RUN mkdir ${HOME}/bin
ENV PATH="${HOME}/apache-maven-${mavenversion}/bin:${PATH}"

# Download and extract Eclipse JDT language server
RUN wget -O jdt-language-server.tar.gz https://download.eclipse.org/jdtls/snapshots/jdt-language-server-1.12.0-202205060359.tar.gz && \
    mkdir eclipse.jdt.ls && cd eclipse.jdt.ls && \
    tar -xvzf ../jdt-language-server.tar.gz && cd .. && \
    rm jdt-language-server.tar.gz

COPY java.lua $HOME/.config/nvim/ftplugin/
COPY settings.xml $HOME/.m2/

# Copy prebuilt VSCode Eclipse debug plugin to a place where Eclips can pick it up
RUN mkdir $HOME/eclipse_plugins
COPY com.microsoft.java.debug.plugin-0.37.0.jar $HOME/eclipse_plugins/
# Copy prebuilt Palantir java formatter
COPY palantir-java-format-2.22.0.tar $HOME/
RUN tar -xvf palantir-java-format-*.tar && rm palantir-java-format-*.tar && ln -s ${HOME}/palantir-java-format-2.22.0/bin/palantir-java-format ${HOME}/bin/palantir-java-format

WORKDIR /host/code
CMD nvim .

# docker build . -t vic-java-openjdk-17:v0.7.0_C --build-arg javaversion=17 --build-arg victag=v0.7.0_A
# docker build . -t vic-java-openjdk-11:v0.7.0_C --build-arg javaversion=11 --build-arg victag=v0.7.0_C --build-arg mavenversion=3.6.3
# docker run --name xx --rm -it --mount type=bind,source=/home/peter/code/neo-technology/neo4j-4.x,destination=/host/code --mount type=bind,source=/home/peter/temp_ws,destination=/host/workspace vic-java-openjdk-11:stable /bin/bash

