FROM ubuntu:20.04

# Prevent interactive questions by tzdata and other packages
ENV DEBIAN_FRONTEND noninteractive

# Install common packages & basic setup
RUN apt-get update \
    && apt-get install --no-install-recommends -y lsof openssl apt-transport-https ca-certificates curl dumb-init locales build-essential vim less nano git jq unzip \
    # Create non-root user
    && groupadd -r coder && useradd -m coder -g coder -s /bin/bash \
    && touch /home/coder/.bash_aliases && chown coder:coder /home/coder/.bash_aliases \
    # set default locale
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LANG en_US.utf8

# Add utility scripts used by Code FREAK
ADD scripts /opt/code-freak

# Install code-server from GitHub
ARG CODE_VERSION="3.9.0"
RUN curl -LsSo /tmp/code-server.deb https://github.com/cdr/code-server/releases/download/v${CODE_VERSION}/code-server_${CODE_VERSION}_amd64.deb \
    && dpkg -i /tmp/code-server.deb \
    && rm /tmp/code-server.deb \
    && su coder -- code-server --install-extension formulahendry.code-runner

# Apply default configuration
COPY --chown=coder:coder settings/ /home/coder/.local/share/code-server/User/

# Python 3.8
RUN apt-get install --no-install-recommends -y python3 python3-pip \
    # linking "python" to "python3" globally may interfere with apt
    # create an alias for the coder user instead
    && echo "alias python='$(which python3)'" >> /home/coder/.bash_aliases \
    && su coder -- code-server --install-extension ms-python.python

# C / C++ support with CMake
# code-server downloads the extension for the wrong CPU architecture so we manually download the vsix
# see https://github.com/cdr/code-server/issues/2120
RUN apt-get install --no-install-recommends -y gdb cmake \
    && curl -LsSo /tmp/cpptools-linux.vsix https://github.com/microsoft/vscode-cpptools/releases/download/1.2.1/cpptools-linux.vsix  \
    && su coder -c "code-server --install-extension /tmp/cpptools-linux.vsix" \
    && su coder -c "code-server --install-extension twxs.cmake" \
    && rm /tmp/cpptools-linux.vsix

# NodeJS 12.04 via nodesource PPA + npm & yarn
RUN curl -sSL https://deb.nodesource.com/setup_12.x | bash - \
    && curl -sSL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get install --no-install-recommends -y nodejs yarn \
    && su coder -- code-server --install-extension dbaeumer.vscode-eslint

# OpenJDK 11 LTS + Gradle + Maven
RUN apt-get install --no-install-recommends -y openjdk-11-jdk-headless gradle maven \
    && su coder -- code-server --install-extension redhat.java \
    && su coder -- code-server --install-extension vscjava.vscode-java-debug

# Mono 6.8.0 + MS .NET Core SDK 3.1
RUN curl -LsSo /tmp/packages-microsoft-prod.deb https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb \
    && dpkg -i /tmp/packages-microsoft-prod.deb \
    && rm /tmp/packages-microsoft-prod.deb \
    && apt-get update \
    && apt-get install --no-install-recommends -y  mono-complete dotnet-sdk-3.1 \
    && su coder -- code-server --install-extension ms-dotnettools.csharp \
    # Pre-install runtime dependecies of C# extension
    && su coder -- /opt/code-freak/install-ext-runtime-deps.sh /home/coder/.local/share/code-server/extensions/ms-dotnettools.csharp-*

# Run everything as non-root user
USER coder
RUN mkdir -p /home/coder/project
WORKDIR /home/coder/project
CMD dumb-init code-server \
    --disable-telemetry \
    --auth none \
    --port 3000 \
    --host 0.0.0.0 \
    /home/coder/project
