FROM ubuntu:19.04

RUN apt-get update && apt-get install --no-install-recommends -y \
    lsof \
    gpg \
    curl \
    dumb-init \
    git \
    sudo \
    gdb \
    build-essential \
    # Node JS
    nodejs \
    npm \
    # JDK
    default-jdk-headless \
    gradle \
    # Code-Server
    bsdtar \
    openssl \
    locales \
    net-tools \
    cmake

RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# Add utility scripts
ADD scripts /opt/code-freak

# Install Coder
ENV CODE_VERSION="3.0.2"
RUN mkdir -p /opt/code-server-${CODE_VERSION} \
    && curl -sL https://github.com/cdr/code-server/releases/download/${CODE_VERSION}/code-server-${CODE_VERSION}-linux-x86_64.tar.gz \
       | tar --strip-components=1 -zx -C /opt/code-server-${CODE_VERSION} \
    && ln -s /opt/code-server-${CODE_VERSION}/code-server /usr/local/bin/code-server


# Create user and allow sudoing
RUN groupadd -r coder \
    && useradd -m coder -g coder -s /bin/bash \
    && echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd
USER coder
WORKDIR /tmp

# Install coder extensions
ENV VSCODE_USER "/home/coder/.local/share/code-server/User"
ENV VSCODE_EXTENSIONS "/home/coder/.local/share/code-server/extensions"

RUN mkdir -p $VSCODE_USER $VSCODE_EXTENSIONS

# Config
COPY  --chown=coder:coder settings/ $VSCODE_USER

# Various Extensions
ARG VSCODE_JAVA_VERSION=0.55.1
ARG VSCODE_JAVA_DEBUG_VERSION=0.25.1
ARG VSCODE_CPPTOOLS_VERSION=0.27.0
ARG VSCODE_SONARLINT_VERSION=1.15.0

RUN mkdir -p ${VSCODE_EXTENSIONS}/java \
    && curl -JLs --retry 5 https://github.com/redhat-developer/vscode-java/releases/download/v${VSCODE_JAVA_VERSION}/redhat.java-${VSCODE_JAVA_VERSION}.vsix | bsdtar --strip-components=1 -xf - -C ${VSCODE_EXTENSIONS}/java extension

RUN mkdir -p ${VSCODE_EXTENSIONS}/java-debugger \
    && curl -JLs --retry 5 https://github.com/microsoft/vscode-java-debug/releases/download/${VSCODE_JAVA_DEBUG_VERSION}/vscode-java-debug-${VSCODE_JAVA_DEBUG_VERSION}.vsix | bsdtar --strip-components=1 -xf - -C ${VSCODE_EXTENSIONS}/java-debugger extension

RUN mkdir -p ${VSCODE_EXTENSIONS}/cpptools \
    && curl -JLs --retry 5 https://github.com/microsoft/vscode-cpptools/releases/download/${VSCODE_CPPTOOLS_VERSION}/cpptools-linux.vsix | bsdtar --strip-components=1 -xf - -C ${VSCODE_EXTENSIONS}/cpptools extension
 
RUN mkdir -p ${VSCODE_EXTENSIONS}/sonarlint \
    && curl -JLs --retry 5 https://github.com/SonarSource/sonarlint-vscode/releases/download/${VSCODE_SONARLINT_VERSION}/sonarlint-vscode-${VSCODE_SONARLINT_VERSION}.vsix | bsdtar --strip-components=1 -xf - -C ${VSCODE_EXTENSIONS}/sonarlint extension
 
RUN mkdir -p /home/coder/project
WORKDIR /home/coder/project
CMD dumb-init code-server \
    --disable-telemetry \
    --disable-ssh \
    --disable-updates \
    --auth none \
    --port 3000 \
    --host 0.0.0.0 \
    /home/coder/project
