FROM golang:1.13

WORKDIR /root/go/src/github.com/henrysdev/fisherman
COPY . .

# Install system resources
RUN ["apt-get", "update"]
RUN ["apt-get", "install", "-y", "zsh"]
RUN ["apt-get", "install", "-y", "sudo"]
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true
RUN ["/bin/sh", "-c", "echo 'source shells/zsh/fisherman.plugin.zsh' >> ~/.zshrc"]

# Install Go resources
RUN go get -d -v ./...
RUN go build -v ./...

# Run client Daemon
CMD ./fishermand/scripts/rundev.sh