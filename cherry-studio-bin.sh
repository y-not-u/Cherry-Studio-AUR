#!/bin/bash

XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-~/.config}

# Allow users to override command-line options
if [[ -f $XDG_CONFIG_HOME/cherry-studio-flags.conf ]]; then
   CHERRY_STUDIO_USER_FLAGS="$(sed 's/#.*//' $XDG_CONFIG_HOME/cherry-studio-flags.conf | tr '\n' ' ')"
fi

# Launch
exec /opt/cherry-studio-bin/cherry-studio.AppImage "$@" $CHERRY_STUDIO_USER_FLAGS