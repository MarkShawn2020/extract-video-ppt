#!/bin/bash

# Kill any existing instances
killall Video2PPT 2>/dev/null

# Launch the app with the file
if [ -n "$1" ]; then
    open -a "/Applications/Video2PPT.app" "$1"
else
    open -a "/Applications/Video2PPT.app"
fi