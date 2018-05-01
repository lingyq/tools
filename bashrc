//说明1：若存在 ~/.bash_profile 此时 ~/.bashrc 可能会默认不生效，在 ~/.bash_profile 文件尾部添加以下语句即可
[lingyq@ubuntu:~]$ vim ~/.bash_profile
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi
[lingyq@ubuntu:~]$ source ~/.bash_profile

//说明2：在 ~/.bashrc 文件的尾部加入以下语句，实现个性化配色方案与git分支路径的显示
[lingyq@ubuntu:~]$ vim ~/.bashrc
## Parses out the branch name from .git/HEAD:
find_git_branch () {
    local dir=. head
    until [ "$dir" -ef / ]; do
        if [ -f "$dir/.git/HEAD" ]; then
            head=$(< "$dir/.git/HEAD")
            if [[ $head = ref:\ refs/heads/* ]]; then
                git_branch=" → ${head#*/*/}"
            elif [[ $head != '' ]]; then
                git_branch=" → (detached)"
            else
                git_branch=" → (unknow)"
            fi
            return
        fi
        dir="../$dir"
    done
    git_branch=''
}
PROMPT_COMMAND="find_git_branch; $PROMPT_COMMAND"
# Here is bash color codes you can use
black=$'\[\e[1;30m\]'
red=$'\[\e[1;31m\]'
green=$'\[\e[1;32m\]'
yellow=$'\[\e[1;33m\]'
blue=$'\[\e[1;34m\]'
magenta=$'\[\e[1;35m\]'
cyan=$'\[\e[1;36m\]'
white=$'\[\e[1;37m\]'
normal=$'\[\e[m\]'
PS1="$white[$magenta\u$white@$green\h$white:$cyan\w$yellow\$git_branch$white]\$ $normal"
export TERM=xterm-color
[lingyq@ubuntu:~]$ source ~/.bashrc
