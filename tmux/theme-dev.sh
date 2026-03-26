#!/bin/bash

SESSION="Theme-Dev"
SESSIONEXISTS=$(tmux list-session | rg $SESSION)

if ["$SESSIONEXISTS" = ""]
then
  tmux new-session -d -s $SESSION

  tmux rename-window -t 1 'Main'
  tmux send-keys -t 'Main' 'z flex' C-m 'vg' C-m

  tmux split-window -h
  tmux send-keys -t 'Main' 'z flex' C-m 'npm run lint' C-m

  tmux new-window -t $SESSION:2 -n 'Watch'
  tmux send-keys -t 'Watch' 'z flex' C-m 'npm run dev' C-m
fi

tmux attach-session -t $SESSION:1
