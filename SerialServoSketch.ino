#include <Servo.h>  //Used to control the Pan/Tilt Servos

//These are variables that hold the servo IDs.
char tiltChannel = 0, panChannel = 1, pressureChannel = 2,pressureChannelB = 3;

//These are the objects for each servo.
Servo servoTilt, servoPan;

//This is a character that will hold data from the Serial port.
char serialChar = 0;

void setup() {
  servoTilt.attach(3);  //The Tilt servo is attached to pin 2.
  servoPan.attach(2);   //The Pan servo is attached to pin 3.
  servoTilt.write(0);  //Initially put the servos both
  servoPan.write(80);      //at 90 degress.

  pinMode(A3,INPUT);  
  pinMode(A5,INPUT);
 

  Serial.begin(57600);  //Set up a serial connection for 57600 bps.
}

void loop() {

  //To Processing
  int analogValue = analogRead(A3) /4; // read the sensor value
  int analogValueB = analogRead(A5) /4;
  
//  Serial.println(analogValue);
  //1st Btn
  Serial.write(analogValue);
  //2nd Btn
  Serial.write(analogValueB);

//  delay(100);


  while (Serial.available() <= 0); //Wait for a character on the serial port.
  serialChar = Serial.read();     //Copy the character from the serial port to the variable
  if (serialChar == tiltChannel) { //Check to see if the character is the servo ID for the tilt servo
    while (Serial.available() <= 0); //Wait for the second command byte from the serial port.
      servoTilt.write(Serial.read());  //Set the tilt servo position to the value of the second command byte received on the serial port
  }
  else if (serialChar == panChannel) { //Check to see if the initial serial character was the servo ID for the pan servo.
    while (Serial.available() <= 0); //Wait for the second command byte from the serial port.
      servoPan.write(Serial.read());   //Set the pan servo position to the value of the second command byte received from the serial port.
  }


  //If the character is not the pan or tilt servo ID, it is ignored.
}
