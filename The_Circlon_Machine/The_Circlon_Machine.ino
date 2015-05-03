// ConstantSpeed.pde
// -*- mode: C++ -*-
//
// Shows how to run AccelStepper in the simplest,
// fixed speed mode with no accelerations
// Requires the AFMotor library (https://github.com/adafruit/Adafruit-Motor-Shield-library)
// And AccelStepper with AFMotor support (https://github.com/adafruit/AccelStepper)
// Public domain!
//
//Notes on spirodraw. The motor speed and direction is set via the serial port. 
//Open up a serial connection and send in variables separaded with commas.
//
// - First parameter is ping-pong mode off or on, in ping pong mode a motor
//   runs for a number of turns (set by the third parameter) in one direction 
//   and then changes direction once the number of turns is reached.
// - Second parameter is the speed, usually I use from 600-2500
// - Third parameter is number of turns before changing direction if ping-pong
//   mode is active.
// - Fourth parameter is the direction if ping-ping mode is inactive.
// - Parameter 5-8 is for the second motor but with the same functions as 1-4
//
//e.g    0,800,0,0,0,1200,0,1
//  That would tell the first motor to run in no-pingpong mode with a constant
//  speed of 800 in the direction 0 wich is counter clock wise. The second motor
//  would also run in a non ping-pong mode with a constant speed of 1200 and clockwise.

#include <AccelStepper.h>
#include <AFMotor.h>

AF_Stepper motor1(200, 1);
AF_Stepper motor2(200, 2);

//Perparing to wrap the motors in use the Accel stepper objects.
void forwardstep1() {
  motor1.onestep(FORWARD, INTERLEAVE);
}
void backwardstep1() {
  motor1.onestep(BACKWARD, INTERLEAVE);
}
// wrappers for the second motor!
void forwardstep2() {
  motor2.onestep(FORWARD, INTERLEAVE);
}
void backwardstep2() {
  motor2.onestep(BACKWARD, INTERLEAVE);
}


// Motor shield has two motor ports, now we'll wrap them in an AccelStepper object
AccelStepper stepper1(forwardstep1, backwardstep1);
AccelStepper stepper2(forwardstep2, backwardstep2);

int enableDisableMotormovementsPin = 2;
int stopMotors;
int motor1ControlPin = A4;
int motor2ControlPin = A5;
int motor1DirectionControlPin = A2;
int motor2DirectionControlPin = A3;
int motor1Inputval = 0;
int motor2Inputval = 0;
int motor1Direction = HIGH;
int motor2Direction = HIGH;  
long motor1Speed = 0.0000001;
long motor2Speed = 0.0000001;
long motor1SpeedLast;
long motor2SpeedLast;
int motor1DirectionLast;
int motor2DirectionLast;
boolean motor1ValuesChanged = true;
boolean motor2ValuesChanged = true;
static float motorspeed1 = 0;
static float motorspeed2 = 0;
boolean motor1PingPong = false;
boolean motor2PingPong = false;
boolean debug = false;
boolean debug2 = false;
boolean debug3 = false;
float motorMultiplier = 0.1;
String inputString = "";         // a string to hold incoming data
int inputStringToInt = 0;
int motor1PingPongNumberOfTurns = 0;
int motor2PingPongNumberOfTurns = 0;
int motor1LastPingPongDirection = 1;
int motor2LastPingPongDirection = 1;
boolean valueEntered = false;
int readMotor1PingPong = 0;
int readMotor2PingPong = 0;
boolean currentResult = false;
//Variables for reading from serialport
const int NUMBER_OF_FIELDS = 8; // how many comma separated fields we expect
int fieldIndex = 0;            // the current field being received
int values[NUMBER_OF_FIELDS];   // array holding values for all the fields
boolean dataAvailable = false;
boolean destinationNotReachedStepper2 = true;
boolean destinationNotReachedStepper1 = true;
boolean numberOfTurnsReached1 = true;
boolean numberOfTurnsReached2 = true;
int stepsLeft1 = 0;
int stepsLeft2 = 0;
long previousMillis1 = 0;
unsigned long currentMillis1;
long previousMillis2 = 0;
unsigned long currentMillis2;
int motorSpeedWithDir1 = 1;
int motorSpeedWithDir2 = 1;


void setup()
{  
   Serial.begin(9600);           // set up Serial library at 9600 bps
     while (!Serial) {
    ; // wait for serial port to connect. Needed for Leonardo only
  }
  
  establishContact();
 Serial.println("Serial active");

     // reserve 200 bytes for the inputString:
  inputString.reserve(200);
  stepper1.setMaxSpeed(400);
  stepper2.setMaxSpeed(400);
  pinMode(enableDisableMotormovementsPin, INPUT_PULLUP);
  pinMode(motor1ControlPin, INPUT);
  pinMode(motor2ControlPin, INPUT);
  pinMode(motor1DirectionControlPin, INPUT_PULLUP);
  pinMode(motor2DirectionControlPin, INPUT_PULLUP);
   //stepper1.setSpeed(150);
   //stepper2.setSpeed(-39);	
}

void loop()
{  
  //Serial.println("Loop");
  stopMotors = digitalRead(enableDisableMotormovementsPin);
  if (stopMotors == LOW){ 
  stopAllMotors();
  }
  
   if(Serial.available() > 0)
  {
  dataAvailable = true;
      if(debug3 == true)
      {
    Serial.println("data available triggered and debug mode 3 active");
    }  
  }
  
  
    
   while (dataAvailable == true)
  {
    char ch = Serial.read();
    if(ch >= '0' && ch <= '9') // is this an ascii digit between 0 and 9?
    {
      // yes, accumulate the value if the fieldIndex is within range
      // additional fields are not stored
      if(fieldIndex < NUMBER_OF_FIELDS) {
        values[fieldIndex] = (values[fieldIndex] * 10) + (ch - '0'); 
      }
    }
    else if (ch == ',')  // comma is our separator, so move on to the next field
    {
        fieldIndex++;   // increment field index 
    }
    else
    {
    //Set variables based on input
    motor1PingPong = values[0]; 
    motor1Speed = values[1]; 
    motor1PingPongNumberOfTurns = values[2]; 
    motor1Direction = values[3]; 
    motor2PingPong = values[4]; 
    motor2Speed = values[5]; 
    motor2PingPongNumberOfTurns =values[6]; 
    motor2Direction = values[7];
          if(debug3 == true){
    Serial.println("Variables set!");
    printDebug2();
    }  
      // print each of the stored fields
      
      for(int i=0; i < min(NUMBER_OF_FIELDS, fieldIndex+1); i++)
      {
        Serial.println(values[i]);
        
        values[i] = 0; // set the values to zero, ready for the next message
      }
      
      fieldIndex = 0;  // ready to start over
      Serial.println("parametersProcessed");
      delay(50);
      dataAvailable = false;
    }
  }
  
  if (motor1PingPong == 1){
    runStepper1PingPong2(motor1Speed, motor1PingPongNumberOfTurns);
  }
  else runStepper1(motor1Speed, motor1Direction);

  if (motor2PingPong == 1){
    runStepper2PingPong2(motor2Speed, motor2PingPongNumberOfTurns);
  }
  else runStepper2(motor2Speed, motor2Direction);
 }

void establishContact() {
  while (Serial.available() <= 0) {
  Serial.println("A");   // send a capital A
  delay(300);
  }
}


 
void runStepper1PingPong2(int motorSpeed, int numberOfTurns){
  currentMillis1 = millis();
  
  if(currentMillis1 - previousMillis1 > numberOfTurns*(200/motorSpeed)*1000) {
    // save the last time you blinked the LED 
    previousMillis1 = currentMillis1;   
    motor1LastPingPongDirection = -motor1LastPingPongDirection;
    motorSpeedWithDir1 = motor1LastPingPongDirection*motorSpeed;
    //Serial.println("PingPong1 direction change");
  }
      stepper1.setSpeed(motorSpeedWithDir1);
      stepper1.runSpeed();

}

void runStepper2PingPong2(int motorSpeed, int numberOfTurns){
  currentMillis2 = millis();
  
  if(currentMillis2 - previousMillis2 > numberOfTurns*(200/motorSpeed)*1000) {
    // save the last time you blinked the LED 
    previousMillis2 = currentMillis2;   
   motor2LastPingPongDirection = -motor2LastPingPongDirection;
    motorSpeedWithDir2 = motor2LastPingPongDirection*motorSpeed;
    Serial.println("PingPong2 direction change");
  }
      stepper2.setSpeed(motorSpeedWithDir2);
      stepper2.runSpeed();

}
void runStepper1PingPong(int motorSpeed, int numberOfTurns){
  if(destinationNotReachedStepper1  == true)
  {
  motor1LastPingPongDirection = -motor1LastPingPongDirection;
  int newPossition = motor1LastPingPongDirection*numberOfTurns*2000;
  //Serial.println("pingPong direction changed for motor 1");
  stepper1.moveTo(newPossition);
  }
  stepper1.setSpeed(motorSpeed);
  destinationNotReachedStepper1 = stepper1.runSpeedToPosition();
  //Serial.print("destinationNotReachedStepper1: ");
  //Serial.println(destinationNotReachedStepper1);
}

void runStepper2PingPong(int motorSpeed, int numberOfTurns){
  if(destinationNotReachedStepper2 == true){
  motor2LastPingPongDirection = -motor2LastPingPongDirection;
  int newPossition = motor2LastPingPongDirection*numberOfTurns*2000;
  //Serial.println("pingPong direction changed for motor 2");
  stepper2.moveTo(newPossition);
  }
  stepper2.setSpeed(motorSpeed);
  destinationNotReachedStepper2 = stepper2.runSpeedToPosition();
  
}

void runStepper1(int motorSpeed, int motorDirection){
  
    if(debug2 == true){
    Serial.println("######### Triggered from run stepper 1 ############");
    printDebug();
    }    
    
  if (motorDirection == 0){
    motorSpeed = -motorSpeed;
  }
  
      stepper1.setSpeed(motorSpeed*motorMultiplier);
      stepper1.runSpeed();
      
      if(debug2 == true){
      Serial.print("Run Stepper function for motor 1");
      Serial.print(", at speed: ");
      Serial.println(motorSpeed*motorMultiplier);
      }  
}

void runStepper2(int motorSpeed, int motorDirection){
  
    if(debug2 == true){
    Serial.println("######### Triggered from run stepper 2 ############");
    printDebug();
    }    
  if (motorDirection == 0){
    
    motorSpeed = -motorSpeed;
  }
      stepper2.setSpeed(motorSpeed*motorMultiplier);
      stepper2.runSpeed();
      if(debug2 == true){
      Serial.print("Run Stepper function for motor 2");
      Serial.print(", at speed: ");
      Serial.println(motorSpeed*motorMultiplier);
      }  
}



/*
boolean updateMotor1(){

  //Reading inputs from controls
  motor1Inputval = analogRead(motor1ControlPin);
  delay(5);
  motor1Direction = digitalRead(motor1DirectionControlPin);
  delay(5);
  //Mapping input

  motor1Speed = map(motor1Inputval, 1023, 0, 0.00001, 200);
  
  if(debug == true){
    Serial.println("######### Triggered from updateMotor1 ############");
    printDebug();
  }

  if (motor1Speed != motor1SpeedLast || motor1Direction != motor1DirectionLast){
    motor1SpeedLast = motor1Speed;
    motor1DirectionLast = motor1Direction;
    return true;
  }
  else{
    return false;
  }
}

boolean updateMotor2(){
  //Reading inputs from controls
  motor2Inputval = analogRead(motor2ControlPin);
  delay(5);
  motor2Direction = digitalRead(motor2DirectionControlPin);
  delay(5);

  //Map variables
  motor2Speed = map(motor2Inputval, 1023, 0, 0.00001, 200);


  if(debug == true){
    Serial.println("######## Triggered from updateMotor2 ############");
    printDebug();
  }
  if (motor2Speed != motor2SpeedLast || motor2Direction != motor2DirectionLast){
    motor2SpeedLast = motor2Speed;
    motor2DirectionLast = motor2Direction;

    return true;
  }
  else{
    return false;
  }

}
*/
void printDebug2(){
  Serial.println("######### printDebug Start ############");
  Serial.println("Reading Values. ");
  Serial.print("motor1PingPong: ");
  Serial.println(motor1PingPong);
  Serial.print("motor1Speed: ");
  Serial.println(motor1Speed );
  Serial.print("motor1PingPongNumberOfTurns: ");
  Serial.println(motor1PingPongNumberOfTurns);
  Serial.print("motor1Direction ");
  Serial.println(motor1Direction );
  Serial.print("motor2PingPong: ");
  Serial.println(motor2PingPong);
  Serial.print("motor2Speed: ");
  Serial.println(motor2Speed);
  Serial.print("motor2PingPongNumberOfTurns: ");
  Serial.println(motor2PingPongNumberOfTurns);
  Serial.print("motor2Direction: ");
  Serial.println(motor2Direction);
  Serial.print("stopMotors: ");
  Serial.println(stopMotors);
  Serial.println("######### printDebug Stop ############");
}

void printDebug(){
  Serial.println("######### printDebug Start ############");
  Serial.println("Reading Values. ");
  Serial.print("motor1Inputval: ");
  Serial.println(motor1Inputval);
  Serial.print("Mapped to: ");
  Serial.println(motor1Speed );
  Serial.print("motor2Inputval: ");
  Serial.println(motor2Inputval);
  Serial.print("Mapped to: ");
  Serial.println(motor2Speed );
  Serial.print("motor1Direction: ");
  Serial.println(motor1Direction);
  Serial.print("motor2Direction: ");
  Serial.println(motor2Direction);
  Serial.print("stopMotors: ");
  Serial.println(stopMotors);
  Serial.println("######### printDebug Stop ############");
}

void printMotorUpdatedVariables(int MotorNumber){
  if (MotorNumber == 1){
  Serial.print("motor1Inputval: ");
  Serial.print(motor1Inputval);
  Serial.print(", Mapped to: ");
  Serial.print(motor1Speed );
  Serial.print(" motor1Direction: ");
  Serial.println(motor1Direction);
  }
    if (MotorNumber == 2){
  Serial.print("motor2Inputval: ");
  Serial.print(motor2Inputval);
  Serial.print(", Mapped to: ");
  Serial.print(motor2Speed );
  Serial.print(" motor2Direction: ");
  Serial.println(motor2Direction);
  }


}


//Interrupt function
void stopAllMotors(){
    Serial.println("Stopping motor 1");
  stepper1.setSpeed(0.00001); 
  stepper1.runSpeed();
  Serial.println("Stopping motor 2");
  stepper2.setSpeed(0.00001); 
  stepper2.runSpeed();
  
  /*
  //Input variables for motor 1
  Serial.println("Will motor 1 ping-pong? 1 = yes 0 = no");
  serialRead();
  while(currentResult != true)
  ;
  readMotor1PingPong = inputStringToInt;
  Serial.println("readMotor1PingPong" + readMotor1PingPong);
  //currentResult = false;
  /*
  if ( readMotor1PingPong == 1 ){
  motor1PingPong = true;
  }
  else motor1PingPong = false;
  
  Serial.println("Input speed motor 1, int between 1-300: ");
  while(serialRead() != true)
  motor1Speed = inputStringToInt;
  
  if (motor1PingPong == false){
  Serial.println("Input direction for motor 1, 0 = clockwise 1 = counter clockwise: ");
  while(serialRead() != true)
  motor1Direction = inputStringToInt;
  }
  else {
  Serial.println("Enter number of turns before switching direction: ");
  while(serialRead() != true)
  motor1PingPongNumberOfTurns = inputStringToInt;
  }
  
  
  
  
    //Input variables for motor 2
  Serial.println("Will motor 2 ping-pong? 1 = yes 0 = no");
  
  while(serialRead() != true)
  readMotor2PingPong = inputStringToInt; 
  if ( readMotor2PingPong == 1 ){
  motor2PingPong = true;
  }
  else motor2PingPong = false;
  
  Serial.println("Input speed motor 2, int between 1-300: ");
  while(serialRead() != true)
  motor2Speed = inputStringToInt;
  
  if (motor2PingPong == false){
  Serial.println("Input direction for motor 2, 0 = clockwise 1 = counter clockwise: ");
  while(serialRead() != true)
  motor2Direction = inputStringToInt;
  }
  else {
  Serial.println("Enter number of turns before switching direction: ");
  while(serialRead() != true)
  motor2PingPongNumberOfTurns = inputStringToInt;
  }
  
  */
  while (stopMotors == LOW){
    stopMotors = digitalRead(enableDisableMotormovementsPin);
  }
}


/*
void serialRead() {
  inputString = "";
  while (Serial.available()) {
    
    // get the new byte:
    char inChar = (char)Serial.read(); 
    // add it to the inputString:
    inputString += inChar;
    
    // if the incoming character is a newline, set a flag
    // so the main loop can do something about it:
    if (inChar == '\n') {
      inputStringToInt = inputString.toInt();
      Serial.println(inputString);
     currentResult = true;
    } 
    
}
}
*/
