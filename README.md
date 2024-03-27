# mp4-bulk-mac-optimizer
File for terminal to perform bulk optimization of mp4 (phone) videos with control of progress and temperature metrics. 
Currently works on libx264 -crf 25 -tune zerolatency -movflags +faststart
For MacOS M1
Intruction of use:
1) download the file "optimize.command"
2) create a folder for this work, name i.e. "optimization", put command in it
3) grant execution rights "cd optimization; chmod 777 optimize.command"
4) copy .mp4 files and folders with .mp4 files in "optimization" folder
5) double click on "optimize.command"
6) it will open terminal window and begin optimization. You will see the progress in it.

To prevent overheat, the program is checking both temperature sensors and do idle cycle without any works if any of sensors reached limit.
Ideas for future: create multiplatform (macos+windows) GUI interface with drag and drop, settings setup, more precise temperature check and performace statistics.
