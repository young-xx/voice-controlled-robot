# Readme

## File description

### main.m

Main document includes basic functions and extended functions . After operation, voice recognition can be carried out to control the car to move forward, backward, turn left, turn right, recognize blue, green, red targets and reverse. All speech commands are in Chinese

#### main_English.m

It is the main document that can be used by English speech command.

#### getcolor.m

A function that identifies a specific color, processes the input picture, and returns a picture with a specific color

#### rbz1.m

Using infrared sensors to avoid obstacles

#### turnleft.m、turnright.m

Control the car to turn left and right

#### ras_control_net.m

It uses training network to realize basic functions, which is just for supplement

#### NetTraining.m、gkc_net4.mat

The convolutional neural network for speech recognition is trained and verified, and the pre training network gkc_net4.mat is obtained  The gkc_net4.mat is used in ras_control_net.m.



## Operating instructions

Run main.m

After receiving the "begin" feedback, send speech commands. The types of voice commands and corresponding actions of the car are as follows.

![image](https://github.com/young-xx/voice-controlled-robot/blob/main/image-20220602222423100.png)

After running, use "system (mypi,'sudo shutdown -h now')"  to shut down the car.

