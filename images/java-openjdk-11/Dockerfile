ARG victag=stable
FROM vic-nvim:${victag}

# Install Java
ARG javaversion=11
RUN apt install -y openjdk-${javaversion}-jdk
ENV JAVA_HOME=/usr/lib/jvm/java-${javaversion}-openjdk-amd64

# Install Maven, need newer than Debian has
RUN wget https://dlcdn.apache.org/maven/maven-3/3.8.3/binaries/apache-maven-3.8.3-bin.tar.gz && \
    tar xzvf apache-maven-3.8.3-bin.tar.gz && \
    rm apache-maven-3.8.3-bin.tar.gz
ENV PATH="/apache-maven-3.8.3/bin:${PATH}"
ENV M2_HOME=/maven

# Clone and build Eclipse Java language server
RUN git clone --depth 1 --branch master https://github.com/eclipse/eclipse.jdt.ls.git
RUN cd eclipse.jdt.ls && ./mvnw verify -DskipTests && cd ..
# Clone and build VSCode debug plugin (to Eclipse)
RUN git clone --depth 1 --branch master https://github.com/microsoft/java-debug.git
RUN cd java-debug && ./mvnw verify -DskipTests && cd..

# TODO: clean /root/.m2/repository

COPY java.lua /root/.config/nvim/ftplugin/

# docker build . -t vic-java-openjdk-11:stable
# docker run --name xx --rm -it --mount type=bind,source=/home/peter/code/neo-technology/neo4j-4.x,destination=/code vic-java-openjdk-11:stable /bin/bash

