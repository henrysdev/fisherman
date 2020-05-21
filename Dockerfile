FROM base

WORKDIR /root/go/src/github.com/henrysdev/fisherman
COPY . /go/src/github.com/henrysdev/fisherman

# Install Go resources
RUN go get -d -v ./fishermand...
RUN go build -v fishermand/cmd/fishermand/main.go

# Run client Daemon
CMD ./fishermand/scripts/rundev.sh