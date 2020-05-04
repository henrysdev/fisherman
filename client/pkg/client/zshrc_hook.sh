output_pipe="/tmp/fisherman_fifo"
stderr_buff="/tmp/fisherman_stderr"

function printbefore () {
if [ -p "$output_pipe" ]
    then
        exec 2> >(tee "$stderr_buff")
        pid="$$"
        cmd="$1"
        cmd_msg="${pid} 0 ${cmd}"
        echo "$cmd_msg" > "$output_pipe"
fi
}

function printafter () {
if [ -p "$output_pipe" ]
    then
        pid="$$"
        err="$(cat $stderr_buff)"
        err_msg="${pid} 1 ${err}"
        echo "$err_msg" > "$output_pipe"
        exec 2> >(tee "$stderr_buff")
fi
}

autoload -Uz  add-zsh-hook

add-zsh-hook preexec printbefore
add-zsh-hook precmd printafter