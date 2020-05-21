[![Go Report Card](https://goreportcard.com/badge/github.com/henrysdev/fisherman)](https://goreportcard.com/report/github.com/henrysdev/fisherman)

# fisherman
fisherman is a project that aims to promote developer productivity and knowledge sharing among teams by collecting, analyzing, and correlating historical shell activity data.
## Overview
There are three primary parts of fisherman's architecture
1. fishermand (client-side)
2. Shell plugin (client-side)
3. Web server (TODO)
### fishermand
fishermand is a client daemon that listens for and consumes shell activity from local shell processes via IPC messaging. fishermand normalizes received ShellMessage objects before buffering them to be sent to the web server for further processing and persistence. Note that fishermand is only able to receive messages from shells with the fisherman shell plugin installed.
A ShellMessage contains the following fields
- Command (executed command)
- Error (any/all stderr output produced by the command)
- PID (process id of the executing shell)
- Timestamp
### Shell Plugin
The shell plugin is responsible for forwarding activity from shell processes to fishermand via IPC messaging. This plugin operates in the background of a user's shell session, capturing each executed command with its respective error output, building a ShellMessage object, and forwarding it to the fishermand process. Every executed command from a shell session (with the fisherman shell plugin installed) will produce a new ShellMessage and write it to fishermand. A ShellMessage is sent upon completed execution of a command. Due to this, it is important to note that long-running commands will not be sent until they have terminated in one way or another. ZSH is currently the only supported shell for use with fisherman.
### Web Server
TODO
## Installation Instructions
### Prerequisites
This project requires having Go, ZSH, and Docker installed. Specific installation instructions for these tools can be found below
- Go: https://golang.org/dl/
- ZSH: https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH
- Docker: https://docs.docker.com/get-docker/

### Go Project
Get the fisherman Go project
```bash
go get -u github.com/henrysdev/fisherman/...
```
### ZSH Plugin
#### Quick and Dirty Method
Add the fisherman shell plugin to your zsh config by adding the following line to your `.zshrc` file (typically located at $HOME/.zshrc)
```zsh
source $HOME/go/src/github.com/henrysdev/fisherman/shells/zsh/fisherman.plugin.zsh
```
#### Oh-My-Zsh Method
If you have oh-my-zsh installed and wish to install in a more proper manner
1. Create plugin directory for fisherman
```bash
mkdir $ZSH_CUSTOM/plugins/fisherman
```
2. Symlink fisherman script from repo to fisherman plugin directory
```bash
ln -s $HOME/go/src/github.com/henrysdev/fisherman/shells/zsh/fisherman.plugin.zsh $ZSH_CUSTOM/plugins/fisherman/fisherman.plugin.zsh
```
3. Add `fisherman` to your plugins list in your `.zshrc` file (typically located at $HOME/.zshrc)
ex: `plugins=(foo bar fisherman)`

Make sure to refresh your shell session to reflect changes to your `.zshrc` file.
## Run Instructions
### Local Development (Containerized)
1. Build the docker container
```bash
docker build -t fishermand .
```
2. Run the docker container
```bash
docker run -it --rm --name fishermand.container fishermand:latest
```
3. In a new shell session, start a zsh session in the context of the running container. All executed commands should be observably logged in the shell running the container
```bash
docker exec -it fishermand.container zsh
```
### Production (System-Level)
Make sure you have completed the installation instructions before attempting to run the program.
1. Run the `install.sh` script to build and install necessary resources. Note that you may be prompted for your root password as fisherman uses two privileged system directories to store binaries and temporary files (`/usr/local/bin` and `/tmp/` respectively)
```bash
$HOME/go/src/github.com/henrysdev/fisherman/fishermand/scripts/install.sh
```
2. Run the `exec.sh` script to start execution of the program.
```bash
$HOME/go/src/github.com/henrysdev/fisherman/fishermand/scripts/exec.sh
```
3. Open up additional shell sessions and start executing commands. All executed commands should be observably logged in the shell executing fishermand via `exec.sh`

If you wish to uninstall fisherman from your system, run `uninstall.sh`
```bash
$HOME/go/src/github.com/henrysdev/fisherman/fishermand/scripts/uninstall.sh
```
