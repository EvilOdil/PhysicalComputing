//Pan/Tilt Face Tracking Sketch mimicking my dog Xing
// By Lisa Ho

import processing.serial.*;
import cc.arduino.*;
import gab.opencv.*;
import org.opencv.imgproc.Imgproc;
import processing.video.*;
import java.awt.Rectangle;

Serial myPort;  //Create Serial object

Capture video;
OpenCV opencv;

int cols, rows;    //in video coordinates (i.e. smaller scale)
int vwidth, vheight;
int VSCALE = 5;    //how many times to make display bigger (3 is default)

//Variables for keeping track of the current servo positions.
char servoTiltPosition = 90;
char servoPanPosition = 90;
//The pan/tilt servo ids for the Arduino serial command interface.
char tiltChannel = 0;
char panChannel = 1;
char pressureChannel = 2;
char pressureChannelB = 3;
int xdiff = 0, ydiff = 0;

//Setting
int offset = 40;

//Trigger
int SecondsDelay = 50;
boolean isOn = false;
boolean JustTrigger;
int DelayCounter = 0;

int Btn1;
int Btn2;

int count = 0;


void setup()
{
  size(960, 720);

  println(Serial.list());
  myPort = new Serial(this, Serial.list()[1], 57600);   //Baud rate is set to 57600 to match the Arduino baud rate.


  //Send the initial pan/tilt angles to the Arduino to set the device up to look straight forward.
  myPort.write(tiltChannel);    //Send the Tilt Servo ID
  myPort.write(servoTiltPosition);  //Send the Tilt Position (currently 90 degrees)
  myPort.write(panChannel);         //Send the Pan Servo ID
  myPort.write(servoPanPosition);   //Send the Pan Position (currently 90 degrees)

  cols = width/VSCALE;
  rows = height/VSCALE;
  vwidth = cols*2;
  vheight = rows*2;
  video = new Capture(this, cols, rows); 
  opencv = new OpenCV(this, cols, rows);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
  video.start();
}

//void serialEvent (Serial myPort) {
//  // get the byte:
//  int inByte = myPort.read();
//  // print it:
//  println(inByte);

//}

void draw()
{
  background(100);
  fill(255);
  //while(myPort.read() > 50){

  opencv.loadImage(video);
  Rectangle[] faces = opencv.detect();
  scale(VSCALE);

  //After Pressing
  if (JustTrigger)
  {
    DelayCounter++; 
    println(DelayCounter);
    if (DelayCounter > SecondsDelay)
    {
      JustTrigger = false;
      DelayCounter = 0;
      println("Reset");
    }
  }

  //Listen from Arduino
  while (myPort.available() > 0)
  {
    
    Btn1 = myPort.read();
    Btn2 = myPort.read();

    //Pressure Trigger   
    if (Btn2 > 30 && !JustTrigger && isOn)
    {
      JustTrigger = true;
      //isOn = false;
      println("OFF");
    }

    /*else*/    if (Btn1 > 30 && !JustTrigger)
    {
      JustTrigger = true;
      isOn = true;
      println("ON");
    }
  }
  
   println (Btn1 + " " + Btn2);

  //Camera
  if (faces.length>0) 
  {
    faces[0].x += faces[0].width/2;  //middle of face
    faces[0].y += faces[0].height/2;

    //println("FX" + faces[0].x);
    //println("FY" + faces[0].y);

    if (isOn)
    {
      //Panning
      myPort.write(panChannel);
      float PanAngle = map(faces[0].x, 30, 150, 0 + offset, 180 - offset);
      //println(PanAngle);
      if (PanAngle >= 0)
      {
        myPort.write(int(PanAngle));
      }
    }

    //Show the Video
    video.loadPixels();  //To highlight the face.
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {            
        // Calculate the 1D location from a 2D grid
        int loc = i + j*video.width;      
        // Get the red, green, blue values from a pixel      
        float r = red  (video.pixels[loc]);
        float g = green(video.pixels[loc]);
        float b = blue (video.pixels[loc]);
        if (dist(i, j, faces[0].x, faces[0].y) < faces[0].width/2) {
          r *= 1.5; 
          g *= 1.5; 
          b *= 1.5;  //Highlight face location.
        }
        // Constrain RGB to make sure they are within 0-255 color range      
        r = constrain(r, 0, 255);      
        g = constrain(g, 0, 255);      
        b = constrain(b, 0, 255);
        // Make a new color and set pixel in the window      
        color c = color(r, g, b);      
        video.pixels[loc] = c;
      }
    }
    updatePixels();
    image(video, 0, 0);
    ////no face is found (not looking)
  } else {
    image(video, 0, 0);
  }
}

// An event for when a new frame is available
void captureEvent(Capture video) {  
  video.read();
}