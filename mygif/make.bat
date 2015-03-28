@echo off
call drunr mygif
call imconvert -delay 2 -coalesce -layers Optimize a???.png a.gif
C:\Downloads\gifsicle-1.87-win64\gifsicle-1.87\gifsicle -O9 a.gif -o a-opt.gif
