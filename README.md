Code FREAK IDE Docker Image
==
[![Build Status](https://travis-ci.com/codefreak/ide.svg?branch=master)](https://travis-ci.com/codefreak/ide)
[![Docker Image Version](https://img.shields.io/docker/v/cfreak/ide?sort=semver)](https://hub.docker.com/r/cfreak/ide)

This is the default IDE image used by [Code FREAK](https://github.com/codefreak/codefreak). It spins up
an editor on the server that is accessible via browser.  
Currently we use [`code-server`](https://github.com/cdr/code-server) as IDE.

**Please open issues on the [main repository](https://github.com/codefreak/codefreak)!**

# Build

Run Docker build in the repository main directory:
```
docker build -t cfreak/ide .
```

# Run / Install
To run the IDE in the current directory:
```
docker run -it --rm -v $PWD:/home/coder/project -p 3000:3000 cfreak/ide:test
```
The IDE will be listening on `http://localhost:3000`

# Pre-Installed Languages (+ VSCode Plugins)

* NodeJS 12.16.3 LTS (+ npm & yarn)
  * [`dbaeumer.vscode-eslint`](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint)
* Python 3.8
  * [`ms-python.python`](https://marketplace.visualstudio.com/items?itemName=ms-python.python)
* OpenJDK 11 LTS
  * [`redhat.java`](https://marketplace.visualstudio.com/items?itemName=redhat.java)
  * [`vscjava.vscode-java-debug`](https://marketplace.visualstudio.com/items?itemName=vscjava.vscode-java-debug)
* C / C++ (gcc, cmake)
  * [`ms-vscode.cpptools`](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools)
* C# by Mono 6.8.0 + Microsoft .NET Core SDK 3.1
  * [`ms-dotnettools.csharp`](https://marketplace.visualstudio.com/items?itemName=ms-dotnettools.csharp)
* Other plugins
  * [`formulahendry.code-runner`](https://marketplace.visualstudio.com/items?itemName=formulahendry.code-runner)