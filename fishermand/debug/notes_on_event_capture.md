
# Ways to captures commands
- `fish_preexec` captures command before being run
- `fish_postexec` captures command after being run
- auditd is a unix utility that can capture commands run with metadata about them (user, timestamp, etc)

# Ways to capture stderr
- Shell redirection ie `COMMAND_HERE 2> >(tee -a stderr.log >&2)`
- https://stackoverflow.com/questions/32890389/can-you-redirect-stderr-for-an-entire-bash-session
- https://unix.stackexchange.com/questions/81861/redirect-all-stderr-of-a-console-and-subsequent-commands-to-a-file
- BEST: https://stackoverflow.com/questions/692000/how-do-i-write-stderr-to-a-file-while-using-tee-with-a-pipe
- `exec 2> >(tee -a error.log)`
- `exec fish 2> log` (this one works)
- `exec fish 2> >(tee -a stderr.log >&2)`
