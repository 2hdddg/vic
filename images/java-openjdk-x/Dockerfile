ARG victag=stable
FROM vic-nvim:${victag}

# Install Java
USER 0:0
ARG javaversion=11
RUN apt install -y openjdk-${javaversion}-jdk
ENV JAVA_HOME=/usr/lib/jvm/java-${javaversion}-openjdk-amd64
USER $VICUID:$VICGID

# Install Maven, need newer than Debian has
RUN wget https://dlcdn.apache.org/maven/maven-3/3.8.3/binaries/apache-maven-3.8.3-bin.tar.gz && \
    tar xzvf apache-maven-3.8.3-bin.tar.gz && \
    rm apache-maven-3.8.3-bin.tar.gz
ENV PATH="${HOME}/apache-maven-3.8.3/bin:${PATH}"

# Download and extract Eclipse JDT language server
RUN wget -O jdt-language-server.tar.gz https://download.eclipse.org/jdtls/snapshots/jdt-language-server-1.6.0-202111031403.tar.gz && \
    mkdir eclipse.jdt.ls && cd eclipse.jdt.ls && \
    tar -xvzf ../jdt-language-server.tar.gz && cd .. && \
    rm jdt-language-server.tar.gz
# Clone and build VSCode debug plugin (to Eclipse)
#RUN git clone --depth 1 --branch main https://github.com/microsoft/java-debug.git && \
#    cd java-debug && ./mvnw verify -DskipTests && cd .. && \
#    rm -rf $HOME/.m2/repository

COPY java.lua $HOME/.config/nvim/ftplugin/
COPY settings.xml $HOME/.m2/

# docker build . -t vic-java-openjdk-11:stable --build-arg javaversion=11
# docker run --name xx --rm -it --mount type=bind,source=/home/peter/code/neo-technology/neo4j-4.x,destination=/host/code --mount type=bind,source=/home/peter/temp_ws,destination=/host/workspace vic-java-openjdk-11:stable /bin/bash

