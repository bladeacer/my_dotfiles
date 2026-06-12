#
# ~/.bash_profile
#

# Source - https://superuser.com/a
# Posted by Gilles 'SO- stop being evil', modified by community. See post 'Timeline' for change history
# Retrieved 2026-01-19, License - CC BY-SA 3.0

if [ -r ~/.profile ]; then . ~/.profile; fi
case "$-" in *i*) if [ -r ~/.bashrc ]; then . ~/.bashrc; fi;; esac
