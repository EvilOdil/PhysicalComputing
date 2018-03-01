int photocellPin = A0; // the cell and 10K pulldown are connected to a0
int photocellReading; // the analog reading from the sensor divider
int trigPin = 13;
int echoPin = 12;
int LEDpin = 11; // connect Red LED to pin 11 (PWM pin)
int LEDbrightness; // 

void setup(void) {
// We'll send debugging information via the Serial monitor
 Serial.begin(9600); 
 pinMode(trigPin, OUTPUT); //trigPin is sending out the signal
 pinMode(echoPin, INPUT); //echoPin is retrieving information, therefore it is INPUT
 pinMode(LEDpin, OUTPUT);
}

void loop(void) {
photocellReading = analogRead(photocellPin); 

Serial.print("Analog reading = ");
Serial.println(photocellReading); // the raw analog reading

//// LED gets brighter the darker it is at the sensor
//// that means we have to -invert- the reading from 0-1023 back to 1023-0
//  photocellReading = 1023 - photocellReading;
////now we have to map 0-1023 to 0-255 since thats the range analogWrite uses
//  LEDbrightness = map(photocellReading, 0, 1023, 0, 255);
//  analogWrite(LEDpin, LEDbrightness);
//
//  delay(100);

  long duration, distance;
  digitalWrite(trigPin, LOW);  
  delayMicroseconds(2); 
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10); 
  digitalWrite(trigPin, LOW);
  duration = pulseIn(echoPin, HIGH);
  distance = (duration/2) / 29.1; //Time it took for the echo to be received and divided in half then divided by the speed of sound
  
  Serial.print(distance);
  Serial.println(" cm");
  delay(500); //delay half a second before repeating the loop
  
  if (distance < 10 && LEDbrightness < 400){
    
  digitalWrite(LEDpin, HIGH);
  
 }else{

  digitalWrite(LEDpin, LOW);

}
}

  


