//Circlon Machine by Jens Clarholm, all code is Public Domain.

// Requires the AFMotor library (https://github.com/adafruit/Adafruit-Motor-Shield-library)
// And AccelStepper with AFMotor support (https://github.com/adafruit/AccelStepper)
// Public domain!
//
// Notes on the Circlon macine. The motor speed and direction is set via the serial port.
// Open up a serial connection and send in variables separaded with commas, or use with the processing GUI.
//
// - First parameter is the speed for motor1, usually I use from 600-2500
// - Second parameter is the direction for motor 1, 0 is counter clockwise and 1 is clockwise.
// - Third parameter is the speed for motor2, usually I use from 600-2500
// - Forth parameter is the direction for motor 2, 0 is counter clockwise and 1 is clockwise.

//
//e.g    800,0,1200,1
//  That would tell the first motor to run with a constant
//  speed of 800 in the direction 0 wich is counter clock wise. The second motor
//  would also run with a constant speed of 1200 and clockwise.

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
int motor1Direction = HIGH;
int motor2Direction = HIGH;
long motor1Speed = 0.0000001;
long motor2Speed = 0.0000001;
boolean debug = false;
boolean debug2 = false;
boolean debug3 = false;
float motorMultiplier = 0.1;
String inputString = "";         // a string to hold incoming data
int inputStringToInt = 0;

//Variables for reading from serialport
const int NUMBER_OF_FIELDS = 4; // how many comma separated fields we expect
int fieldIndex = 0;            // the current field being received
int values[NUMBER_OF_FIELDS];   // array holding values for all the fields
boolean dataAvailable = false;

void setup()
{
  Serial.begin(9600);           // set up Serial library at 9600 bps
  while (!Serial) {
    ; // wait for serial port to connect. Needed for Leonardo only
  }

  establishContact();
  // reserve 200 bytes for the inputString:
  inputString.reserve(200);
  stepper1.setMaxSpeed(400);
  stepper2.setMaxSpeed(400);
  pinMode(enableDisableMotormovementsPin, INPUT_PULLUP);

}

void loop()
{
  //check if motors are enabled.
  stopMotors = digitalRead(enableDisableMotormovementsPin);
  if (stopMotors == LOW) {
    stopAllMotors();
  }

 runStepper1(motor1Speed, motor1Direction);
 runStepper2(motor2Speed, motor2Direction);
}

void checkSerialForData(){
 //check if there is serial data to parse
  checkSerialForData();
  if (Serial.available() > 0)
  {
    dataAvailable = true;
    if (debug3 == true)
    {
      Serial.println("data available triggered and debug mode 3 active");
    }
  }

  while (dataAvailable == true)
  {
    char ch = Serial.read();
    if (ch >= '0' && ch <= '9') // is this an ascii digit between 0 and 9?
    {
      // yes, accumulate the value if the fieldIndex is within range
      // additional fields are not stored
      if (fieldIndex < NUMBER_OF_FIELDS) {
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
      motor1Speed = values[0];
      motor1Direction = values[1];
      motor2Speed = values[2];
      motor2Direction = values[3];
      if (debug3 == true) {
        Serial.println("Variables set!");
        printDebug2();
      }
      // print each of the stored fields

      for (int i = 0; i < min(NUMBER_OF_FIELDS, fieldIndex + 1); i++)
      {
        Serial.println(values[i]);

        values[i] = 0; // set the values to zero, ready for the next message
      }

      fieldIndex = 0;  // ready to start over
      Serial.println("parametersProcessed");
      //delay(50);
      dataAvailable = false;
    }
  }
}


void establishContact() {
  while (Serial.available() <= 0) {
    Serial.println("A");   // send a capital A
    delay(300);
  }
}



void runStepper1(int motorSpeed, int motorDirection) {

  if (debug2 == true) {
    Serial.println("######### Triggered from run stepper 1 ############");
    
  }

  if (motorDirection == 0) {
    motorSpeed = -motorSpeed;
  }

  stepper1.setSpeed(motorSpeed * motorMultiplier);
  stepper1.runSpeed();

  if (debug2 == true) {
    Serial.print("Run Stepper function for motor 1");
    Serial.print(", at speed: ");
    Serial.println(motorSpeed * motorMultiplier);
  }
}

void runStepper2(int motorSpeed, int motorDirection) {

  if (debug2 == true) {
    Serial.println("######### Triggered from run stepper 2 ############");
  }
  if (motorDirection == 0) {

    motorSpeed = -motorSpeed;
  }
  stepper2.setSpeed(motorSpeed * motorMultiplier);
  stepper2.runSpeed();
  if (debug2 == true) {
    Serial.print("Run Stepper function for motor 2");
    Serial.print(", at speed: ");
    Serial.println(motorSpeed * motorMultiplier);
  }
}

void printDebug2() {
  Serial.println("######### printDebug Start ############");
  Serial.println("Reading Values. ");
  Serial.print("motor1Speed: ");
  Serial.println(motor1Speed );
  Serial.print("motor1Direction ");
  Serial.println(motor1Direction );
  Serial.print("motor2Speed: ");
  Serial.println(motor2Speed);
  Serial.print("motor2Direction: ");
  Serial.println(motor2Direction);
  Serial.print("stopMotors: ");
  Serial.println(stopMotors);
  Serial.println("######### printDebug Stop ############");
}

/*
void printMotorUpdatedVariables(int MotorNumber) {
  if (MotorNumber == 1) {
    Serial.print("motor1Inputval: ");
    Serial.print(motor1Inputval);
    Serial.print(", Mapped to: ");
    Serial.print(motor1Speed );
    Serial.print(" motor1Direction: ");
    Serial.println(motor1Direction);
  }
  if (MotorNumber == 2) {
    Serial.print("motor2Inputval: ");
    Serial.print(motor2Inputval);
    Serial.print(", Mapped to: ");
    Serial.print(motor2Speed );
    Serial.print(" motor2Direction: ");
    Serial.println(motor2Direction);
  }


}

*/
//Interrupt function
void stopAllMotors() {
  Serial.println("Stopping motor 1");
  stepper1.setSpeed(0.00001);
  stepper1.runSpeed();
  Serial.println("Stopping motor 2");
  stepper2.setSpeed(0.00001);
  stepper2.runSpeed();

  while (stopMotors == LOW) {
    stopMotors = digitalRead(enableDisableMotormovementsPin);
  }
}
