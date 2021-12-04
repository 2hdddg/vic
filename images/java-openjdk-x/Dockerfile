ARG victag=stable
FROM vic-nvim:${victag}

# Install Java
USER 0:0
ARG javaversion=11
RUN apt install -y openjdk-${javaversion}-jdk
ENV JAVA_HOME=/usr/lib/jvm/java-${javaversion}-openjdk-amd64
USER $VICUID:$VICGID

# Install Maven, need newer than Debian has
ARG mavenversion=3.8.4
RUN wget https://dlcdn.apache.org/maven/maven-3/${mavenversion}/binaries/apache-maven-${mavenversion}-bin.tar.gz && \
    tar xzvf apache-maven-${mavenversion}-bin.tar.gz && \
    rm apache-maven-${mavenversion}-bin.tar.gz
ENV PATH="${HOME}/apache-maven-${mavenversion}/bin:${PATH}"

# Download and extract Eclipse JDT language server
RUN wget -O jdt-language-server.tar.gz https://download.eclipse.org/jdtls/snapshots/jdt-language-server-1.7.0-202112022229.tar.gz && \
    mkdir eclipse.jdt.ls && cd eclipse.jdt.ls && \
    tar -xvzf ../jdt-language-server.tar.gz && cd .. && \
    rm jdt-language-server.tar.gz

COPY java.lua $HOME/.config/nvim/ftplugin/
COPY settings.xml $HOME/.m2/

# Copy prebuilt VSCode Eclipse debug plugin to a place where Eclips can pick it up
RUN mkdir $HOME/eclipse_plugins
COPY com.microsoft.java.debug.plugin-0.34.0.jar $HOME/eclipse_plugins/

# docker build . -t vic-java-openjdk-11:stable --build-arg javaversion=11
# docker run --name xx --rm -it --mount type=bind,source=/home/peter/code/neo-technology/neo4j-4.x,destination=/host/code --mount type=bind,source=/home/peter/temp_ws,destination=/host/workspace vic-java-openjdk-11:stable /bin/bash

