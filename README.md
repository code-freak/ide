Code FREAK IDE Docker Image
==
[![Build Status](https://travis-ci.com/code-freak/ide.svg?branch=master)](https://travis-ci.com/code-freak/ide)

This is the default IDE image used by [`code-freak`](https://github.com/code-freak/code-freak). It spins up
an editor on the server that is accessible via browser.  
Currently we use [`code-server`](https://github.com/cdr/code-server) as IDE.

**Please open Issues on the [main repository](https://github.com/code-freak/code-freak)!**

# Pre-Installed Languages (+ VSCode Plugins)

* NodeJS 12.16.3 LTS (+ npm & yarn)
 * [`dbaeumer.vscode-eslint`](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint)
* Python 3.8
  * [`ms-python.python`](https://marketplace.visualstudio.com/items?itemName=ms-python.python)
* OpenJDK 11 LTS
 * [`redhat.java`](https://marketplace.visualstudio.com/items?itemName=redhat.java)
 * [`vscjava.vscode-java-debug`](https://marketplace.visualstudio.com/items?itemName=vscjava.vscode-java-debug)
* C / C++
 * [`ms-vscode.cpptools`](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools)
* Mono 6.8.0 + Microsoft .NET Core SDK 3.1
 * [`ms-dotnettools.csharp`](https://marketplace.visualstudio.com/items?itemName=ms-dotnettools.csharp)

 ## Additional useful Plugins
* [`formulahendry.code-runner`](https://marketplace.visualstudio.com/items?itemName=formulahendry.code-runner)