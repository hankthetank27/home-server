#!/bin/sh
### Tmux dev enviroment ###
# Attach or create tmux session named the same as current directory, or path passed as argument.

path_name=$PWD

if [ ! -z "$1" ]; then
    if [ -d "$1" ]; then
        path_name=$(cd "$1" && pwd -P)
    else
        echo Invalid directory path: $1
        exit 1
    fi
fi

session_name="$(basename "$path_name" | tr . -)"


not_in_tmux() {
    [ -z "$TMUX" ]
}

session_exists() {
    { tmux has-session -t "=$session_name"; } 2> /dev/null
}

create_detached_session() {
    tmux new-session -s $session_name -d -x "$(tput cols)" -y "$(tput lines)" -c $path_name
    tmux rename-window -t "$session_name:0" 'main'
    tmux send-keys -t "$session_name:0.0" "vim $path_name" Enter
    # tmux splitw -v -t "$session_name:0.0" -c $path_name
    tmux neww -d -a -t "$session_name:main" -c $path_name
    tmux selectw -t "$session_name:main"
    tmux select-pane -t "$session_name:0.0"

    # spilt_ratio=$(($(tput lines) / 7))
    # if (($spilt_ratio < 8)); then
    #     tmux resize-pane -t "$session_name:0.1" -y 8
    # else
    #     tmux resize-pane -t "$session_name:0.1" -y $spilt_ratio
    # fi
}

create_if_needed_and_attach() {
    if not_in_tmux; then
        if ! session_exists; then
            create_detached_session
        fi 
        tmux a -t $session_name
    else
        if ! session_exists; then
            TMUX=''
            create_detached_session
        fi
        tmux switch-client -t "$session_name"
    fi
}

create_if_needed_and_attach

