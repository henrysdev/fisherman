pid="$$"
output_pipe="/tmp/fisherman/cmdpipe"
stderr_buff="/tmp/fisherman/${pid}_stderr"
bin_name="fishermand"

# Createds the temp proces to redirect stderr output to appropriate temp file
function startcapture() {
    exec 2> >(tee $stderr_buff)
}

# Cleans up the temp processes and files related to captures stderror output
function endcapture() {
    exec 2> /dev/tty
    pkill -x tee "$stderr_buff"
    rm "$stderr_buff"
}

# Always remove temp file on exit
trap "rm ${stderr_buff}" EXIT

# Ran on preexec (after a user enters a command but before it is executed).
# If capturing, it will write every command as in the appropriate format to the
# fifo socket that the daemon process is reading from
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

# Ran on precmd (before command prompt comes up). This effectively is run once 
# the first time before preexec (when the shell is initialized and the prompt
# comes up), and then subsequently will run after precmd every time after.
# If capturing, it will write the stderr temp file in the appropriate format to
# the fifo socket that the daemon process is reading from
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
