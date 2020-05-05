pid="$$"
output_pipe="/tmp/fisherman/cmdpipe"
stderr_buff="/tmp/fisherman/${pid}_stderr"
bin_name="fishermand"

function startcapture() {
    exec 2> >(tee $stderr_buff)
}

function endcapture() {
    pkill -x tee "$stderr_buff"
    rm "$stderr_buff"
}

trap "rm ${stderr_buff}" EXIT

function writecmd () {
if pgrep -x "$bin_name" > /dev/null && [ -p "$output_pipe" ]
    then
        if [ ! -f "$stderr_buff" ]
            then
                startcapture
        fi
        cmd="$1"
        cmd_msg="${pid} 0 ${cmd}"
        echo "$cmd_msg" > "$output_pipe"
fi
}

function writestderr () {
if pgrep -x "$bin_name" > /dev/null && [ -p "$output_pipe" ]
    then
        if [ ! -f "$stderr_buff" ]
            then
                startcapture
            else
                err="$(cat $stderr_buff)"
                err_msg="${pid} 1 ${err}"
                echo "$err_msg" > "$output_pipe"
                endcapture
        fi
fi
}

autoload -Uz  add-zsh-hook

add-zsh-hook preexec writecmd
add-zsh-hook precmd writestderr
