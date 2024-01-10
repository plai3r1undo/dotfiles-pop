#!/bin/bash

feh --bg-fill ~/Pictures/wallpapers/wallhaven-skeleton.jpg

# picom is a x compositore therefore it won't finish executing or at least that's what I think
# migh cause problems
slstatus &
picom &
sxhkd &
