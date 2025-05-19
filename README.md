# Windows 10/11 EfficiencyFix

This is more of a "Workaround" as I know many others have desktop computers, and that is why I created this fix/workaround, as "Efficiency Mode" is mainly geared towards battery life on mobile devices.  

After searching and finding a bunch of stuff that doesn't work. From changing the properties in program shortcuts to registry changes, nothing seems to work. So I had to go another route since many of us are fighting the dreaded Efficiency Mode on various Programs that sap resources rather than freeing them up. 

So I created a PowerShell script that sets:
1. A text file for known executables (mainly browsers) that, on a schedule (At logon every 5 minutes, indefinitely), will remove the Efficiency flag from them. *You can go to the file and add/remove names, no need to add the .exe*
2. Created a PS1 file that will remove the flag from the executables based on those in the txt file (You can actually edit the txt file to add/remove, but you will need to know the exe name)
3. Creates the XML file for Task Scheduler
4. Creates the Task Schedule
5. Starts the task Schedule for EfficencyFix

All of the above creates a file directory under Program Files\EfficencyFix

I have also added logging so that you can see when/if the task runs. 

For the package, there are two files:
1. A batch file that checks for elevated rights
2. Runs the EfficiencyFix.ps1 to set it up

Then, in Task Scheduler, the Efficiency fix will start on logon (immediately after set up) and then run every 10 minutes indefinitely afterward. 
