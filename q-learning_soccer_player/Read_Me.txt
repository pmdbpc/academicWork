This document is a step-by-step guide to run the MATLAB Q-learning Agent with the GRID SOCCER SIMULATOR

(The source code of the Grid Soccer Simulator can be built using only Microsoft Visual Basic 2010 or SharpDevelop 4 - Other versions are not compatible.)

Step 1: Download the Grid Soccer Simulator Source code from the link: http://gridsoccer.codeplex.com/

Step 2: Extract all files. 

Step 3: In the extracted files folder, go to "\Grid-Soccer Simulator and Agents 1.0.1\Source". Open the file "AllInOne2010.sln" in the Microsoft Visual Basic 2010.

Step 4: After the project solution file is opened. Build the project. Check for "Build Successful with 0 errors" comment in the status bar of the software. Close the MS Visual Basic 2010 application.

Step 5: Go to "\Grid-Soccer Simulator and Agents 1.0.1\Bin" Folder. Find the file "GridSoccerSimulator.exe". This is the simulator server executable.

Step 6: Now, go to "\Grid-Soccer Simulator and Agents 1.0.1\Source\MatlabSampleClient" Folder. Replace the "agent1.m" file with the "agent1.m" file sent along with this attachment.

Step 7: TO start the match, first run the "GridSoccerSimulator.exe".

Step 8: Next, to start the Q-learning agent, open the "agent1.m" file in MATLAB and run the code.

Step 9: Finally to select the opponent, go to "\Grid-Soccer Simulator and Agents 1.0.1\Bin" and select the opponent executable as required from: HandCodedClient.exe or DPClient.exe

Step 10: Once two players are visible on the Simulator grid, press the "Play" button to start the learning.

Step 11: To speed up learning, press "Enable Turbo" button. To increase speed further, disable screen updates.

Step 12: Press stop button from the Simulator window to stop training. This will end the session and the plots of the Q-learning training will be displayed by MATLAB.

