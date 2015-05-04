import controlP5.*;
import com.dhchoi.CountdownTimer;
import com.dhchoi.CountdownTimerService;
import processing.serial.*;

ControlP5 cp5;

//Serial communications
Serial myPort;
boolean firstContact = false;
String val;
CountdownTimer serialTransmissionTimer;
int timeBetweenSerialTransmissions = 200;
boolean transmissionTimerFinished = true;

//GUI Variables
int windowSizeWidth;
int windowSizeHeight;
int xOffsetLeft = 50;
int xOffsetRight = 50;
int yOffsetTop = 50;
int yOffsetBottom = 50;

//Sliders & Range controllers gui preferences
int sliderHeight = 40;
int sliderHandleSize = 20;
int sliderHorizontalSpacing = 20;
Range motor1Range;
Range motor2Range;
Slider motor1TimeSlider;
Slider motor2TimeSlider;

//Text label
int textLabelRowSpacing = 17;
Textlabel motor1CurrentParametersTextLabel1;
Textlabel motor1CurrentParametersTextLabel2;
Textlabel motor1CurrentParametersTextLabel3;

Textlabel motor2CurrentParametersTextLabel1;
Textlabel motor2CurrentParametersTextLabel2;
Textlabel motor2CurrentParametersTextLabel3;

Textlabel currentMotorStateLabel;
Textlabel pauseMotorLabel;

//Buttons
Toggle motor1ChangeDirectionButton;
boolean motor1ChangeDirectionButtonStatus;
Toggle motor2ChangeDirectionButton;
boolean motor2ChangeDirectionButtonStatus;
Toggle startStopDrawing;
Toggle pauseDrawing;
int buttonHeight = 20;
int startButtonHeight = 100;

//Motor Control Parameters
int motor1MinSpeed;
int motor2MinSpeed;
int motor1MaxSpeed;
int motor2MaxSpeed;
long motor1TimeUntilFinished = 10;
long motor2TimeUntilFinished = 10;
int motor1CurrentSpeed = 0;
int motor2CurrentSpeed = 0;
int motor1CurrentTime = 0;
int motor2CurrentTime = 0;
float motor1LastTimerValue = 0;
float motor2LastTimerValue = 0;
boolean motor1CurrentState;
boolean motor2CurrentState;
int motor1Direction = 0; //0 = counter clockwise, 1 = clockwise
int motor2Direction = 0; //0 = counter clockwise, 1 = clockwise
CountdownTimer motor1CountdownTimer;
CountdownTimer motor2CountdownTimer;
String runMotorsString; //contains speed parameters
String currentValuesFromGuiOrFunction; //contains the parameters the GUI is currently set to.



void setup() {
  
  //Create serial communications port
  println(Serial.list());
  String portName = Serial.list()[1];
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil('\n');
  
  //Setup window based on screensize
  size(displayWidth-100, displayHeight-100);
  //Set background clour to white.
  background(255, 255, 255);
  windowSizeWidth = displayWidth-100;
  windowSizeHeight = displayHeight-100;
  
  //create a p5 controller object
  cp5 = new ControlP5(this);
  
  //Create slider for motor one speed control
  motor1Range = cp5.addRange("Motor 1 Speed")
               // disable broadcasting since setRange and setRangeValues will trigger an event
             .setBroadcast(false) 
             .setPosition(xOffsetLeft,yOffsetTop+buttonHeight+sliderHorizontalSpacing)
             .setSize(windowSizeWidth/2-xOffsetLeft-100, sliderHeight)
             .setHandleSize(sliderHandleSize)
             .setRange(600,2500)
             .setRangeValues(600,800)
             // after the initialization we turn broadcast back on again
             .setBroadcast(true)
             .setColorForeground(color(153, 0, 51))
             .setColorBackground(color(255, 153, 128))
             .setColorLabel(color(0,0,0))
             ; 
  //Create slider for motor two speed control
  motor2Range = cp5.addRange("Motor 2 Speed")
               // disable broadcasting since setRange and setRangeValues will trigger an event
             .setBroadcast(false) 
             .setPosition((windowSizeWidth/2+xOffsetRight), yOffsetTop+buttonHeight+sliderHorizontalSpacing)
             .setSize((windowSizeWidth/2-xOffsetRight-100), sliderHeight)
             .setHandleSize(sliderHandleSize)
             .setRange(600,2500)
             .setRangeValues(600,800)
             // after the initialization we turn broadcast back on again
             .setBroadcast(true)
             .setColorForeground(color(153, 0, 51))
             .setColorBackground(color(255, 153, 128))
             .setColorLabel(color(0,0,0))
             ;
             
  motor1TimeSlider = cp5.addSlider("Motor 1 Time")
     .setPosition(xOffsetLeft,yOffsetTop + sliderHeight + sliderHorizontalSpacing+buttonHeight+sliderHorizontalSpacing)
     .setSize(windowSizeWidth/2-xOffsetLeft-100,sliderHeight)
     .setRange(10,200)
     .setValue(30)
     .setColorForeground(color(153, 0, 51))
     .setColorBackground(color(255, 153, 128))
     .setColorLabel(color(0,0,0))
     ;
  
   motor2TimeSlider = cp5.addSlider("Motor 2 Time")
    .setPosition(windowSizeWidth/2+xOffsetRight,yOffsetTop + sliderHeight + sliderHorizontalSpacing+buttonHeight+sliderHorizontalSpacing)
    .setSize(windowSizeWidth/2-xOffsetLeft-100,sliderHeight)
    .setRange(10,200)
    .setValue(30)
    .setColorForeground(color(153, 0, 51))
    .setColorBackground(color(255, 153, 128))
    .setColorLabel(color(0,0,0))
    ;


  motor1CurrentParametersTextLabel1 = cp5.addTextlabel("motor1Label1")
                    .setText("Speed: " + motor1CurrentSpeed)
                    .setPosition(xOffsetLeft,yOffsetTop + 2*sliderHeight + 2*sliderHorizontalSpacing+buttonHeight+sliderHorizontalSpacing)
                    .setColorValue(color(0,0,0))
                    .setFont(createFont("Arial",15))
                    ;
                    
  motor1CurrentParametersTextLabel2 = cp5.addTextlabel("motor1Label2")
                    .setText( "Direction: " + getCurrentDirection(motor1Direction))
                    .setPosition(xOffsetLeft,yOffsetTop + 2*sliderHeight + 2*sliderHorizontalSpacing+textLabelRowSpacing+buttonHeight+sliderHorizontalSpacing)
                    .setColorValue(color(0,0,0))
                    .setFont(createFont("Arial",15))
                    ;
                    
  motor1CurrentParametersTextLabel3 = cp5.addTextlabel("motor1Label3")
                    .setText( "Time until max or min: " + motor1TimeUntilFinished + " seconds.")
                    .setPosition(xOffsetLeft,yOffsetTop + 2*sliderHeight + 2*sliderHorizontalSpacing+2*textLabelRowSpacing+buttonHeight+sliderHorizontalSpacing)
                    .setColorValue(color(0,0,0))
                    .setFont(createFont("Arial",15))
                    ;                   

  motor2CurrentParametersTextLabel1 = cp5.addTextlabel("motor2Label1")
                    .setText("Speed: " + motor2CurrentSpeed)
                    .setPosition(windowSizeWidth/2+xOffsetRight,yOffsetTop + 2*sliderHeight + 2*sliderHorizontalSpacing+buttonHeight+sliderHorizontalSpacing)
                    .setColorValue(color(0,0,0))
                    .setFont(createFont("Arial",15))
                    ;
                    
  motor2CurrentParametersTextLabel2 = cp5.addTextlabel("motor2Label2")
                    .setText( "Direction: " + getCurrentDirection(motor2Direction))
                    .setPosition(windowSizeWidth/2+xOffsetRight, yOffsetTop + 2*sliderHeight + 2*sliderHorizontalSpacing+textLabelRowSpacing+buttonHeight+sliderHorizontalSpacing)
                    .setColorValue(color(0,0,0))
                    .setFont(createFont("Arial",15))
                    ;                  
                    
                    
  motor2CurrentParametersTextLabel3 = cp5.addTextlabel("motor2Label3")
                    .setText( "Time until max or min: " + motor1TimeUntilFinished + " seconds.")
                    .setPosition(windowSizeWidth/2+xOffsetRight, yOffsetTop + 2*sliderHeight + 2*sliderHorizontalSpacing+2*textLabelRowSpacing+buttonHeight+sliderHorizontalSpacing)
                    .setColorValue(color(0,0,0))
                    .setFont(createFont("Arial",15))
                    ;


//Toggle Switches
//Motor Direction
   motor1ChangeDirectionButton = cp5.addToggle("Click to change direction of motor 1")
     .setPosition(xOffsetLeft,yOffsetTop)
     .setSize(windowSizeWidth/2-xOffsetLeft-100,buttonHeight)
     .setValue(0)
     .setColorForeground(color(153, 0, 51))
     .setColorBackground(color(255, 153, 128))
     .setColorActive(color(153, 0, 51)) 
     .setColorLabel(color(0,0,0))
     ;

   motor2ChangeDirectionButton = cp5.addToggle("Click to change direction of motor 2")
     .setPosition(windowSizeWidth/2+xOffsetRight,yOffsetTop)
     .setSize(windowSizeWidth/2-xOffsetLeft-100,buttonHeight)
     .setValue(0)
     .setColorForeground(color(153, 0, 51))
    .setColorBackground(color(255, 153, 128))
    .setColorActive(color(153, 0, 51)) 
    .setColorLabel(color(0,0,0))
     ;
//Motors on or off     
   startStopDrawing = cp5.addToggle("Start/Stop motors")
     .setPosition(windowSizeWidth/2+xOffsetRight,yOffsetTop + 2*sliderHeight + 3*sliderHorizontalSpacing+3*textLabelRowSpacing+buttonHeight+sliderHorizontalSpacing)
     .setSize(windowSizeWidth/2-xOffsetLeft-100,startButtonHeight)
     .setValue(0)
     .setColorForeground(color(153, 0, 51))
    .setColorBackground(color(255, 153, 128))
    .setColorActive(color(153, 0, 51)) 
    .setColorLabel(color(0,0,0))
    .setLabelVisible(false)
     ;
   pauseDrawing = cp5.addToggle("Reset Timers")
     .setPosition(xOffsetRight,yOffsetTop + 2*sliderHeight + 3*sliderHorizontalSpacing+3*textLabelRowSpacing+buttonHeight+sliderHorizontalSpacing)
     .setSize(windowSizeWidth/2-xOffsetLeft-100,startButtonHeight)
     .setValue(0)
     .setColorForeground(color(153, 0, 51))
    .setColorBackground(color(255, 153, 128))
    .setColorActive(color(153, 0, 51)) 
    .setColorLabel(color(0,0,0))
    .setLabelVisible(false)
     ;
     
  
  currentMotorStateLabel = cp5.addTextlabel("currentMotorStateLabel")
    .setText( "Start")
    .setPosition(windowSizeWidth/2+xOffsetRight, yOffsetTop + 2*sliderHeight + 3*sliderHorizontalSpacing+3*textLabelRowSpacing+buttonHeight+sliderHorizontalSpacing+startButtonHeight)
    .setColorValue(color(0,0,0))
    .setFont(createFont("Arial",25))
                    ;

  pauseMotorLabel = cp5.addTextlabel("resetTimers")
    .setText( "Reset Timers")
    .setPosition(xOffsetRight, yOffsetTop + 2*sliderHeight + 3*sliderHorizontalSpacing+3*textLabelRowSpacing+buttonHeight+sliderHorizontalSpacing+startButtonHeight)
    .setColorValue(color(0,0,0))
    .setFont(createFont("Arial",25))
                    ;


//Create timers

motor1CountdownTimer = CountdownTimerService.getNewCountdownTimer(this).configure(100, (int)(motor1TimeSlider.getValue()*1000));
motor2CountdownTimer = CountdownTimerService.getNewCountdownTimer(this).configure(100, (int)(motor2TimeSlider.getValue()*1000));
serialTransmissionTimer = CountdownTimerService.getNewCountdownTimer(this).configure(100, timeBetweenSerialTransmissions);
  noStroke();


}

void draw() {
  
  
//debug start
motor1CurrentSpeed = motor1MaxSpeed;
motor2CurrentSpeed = motor2MaxSpeed;
//debug end
checkToggleValues();
updateScreen();
//runMotors();


}

void serialEvent( Serial myPort) {
//put the incoming data into a String - 
//the '\n' is our end delimiter indicating the end of a complete packet
val = myPort.readStringUntil('\n');
//make sure our data isn't empty before continuing
if (val != null) {
  //trim whitespace and formatting characters (like carriage return)
  val = trim(val);
  println(val);

  //look for our 'A' string to start the handshake
  //if it's there, clear the buffer, and send a request for data
  if (firstContact == false) {
    if (val.equals("A")) {
      myPort.clear();
      firstContact = true;
      myPort.write("A");
      println("contact");
    }
  }
  else { //if we've already established contact, keep getting and parsing data
    println(val);
    if (val.equals("parametersProcessed")) {
      myPort.clear();
      runMotors();                   //send next motor parameters

    }

    }
  }
}




void runMotors()
{
currentValuesFromGuiOrFunction = ((int)motor1CurrentSpeed+","+(int)motor1Direction+","+(int)motor2CurrentSpeed+","+(int)motor2Direction); 
if (runMotorsString != currentValuesFromGuiOrFunction){
  println("RunMotorsCurrent: " + runMotorsString);
  println("RunMotorsRead:    " + ((int)motor1CurrentSpeed+","+(int)motor1Direction+","+(int)motor2CurrentSpeed+","+(int)motor2Direction));
  if (motor1CurrentState == true && motor2CurrentState == true){
runMotorsString = ((int)motor1CurrentSpeed+","+(int)motor1Direction+","+(int)motor2CurrentSpeed+","+(int)motor2Direction);
println("Before sending run motors command motorcurrentState = true");
if (transmissionTimerFinished == true){
myPort.write(runMotorsString);
transmissionTimerFinished = false;
serialTransmissionTimer.start();
}
println(runMotorsString);
println("After sending run motors command motorcurrentState = true"); 
}

else if (motor1CurrentState == false && motor2CurrentState == false){
runMotorsString = "0,0,0,0";
println("Before sending run motors command motorcurrentState = false");
myPort.write(runMotorsString);
println(runMotorsString);
println("After sending run motors command motorcurrentState = false");
}
}
  
}

void updateScreen(){
 background(255, 255, 255);
 setCurrentVariablesInLabelText();
  motor1CurrentParametersTextLabel1.draw(this);
  motor1CurrentParametersTextLabel2.draw(this);
  motor1CurrentParametersTextLabel3.draw(this);
  motor2CurrentParametersTextLabel1.draw(this);
  motor2CurrentParametersTextLabel2.draw(this);
  motor2CurrentParametersTextLabel3.draw(this);
}

void setCurrentVariablesInLabelText(){
motor1CurrentParametersTextLabel1.setText("Speed: " + motor1CurrentSpeed);
motor1CurrentParametersTextLabel2.setText( "Direction: " + getCurrentDirection(motor1Direction));
motor1CurrentParametersTextLabel3.setText( "Time until max or min: " + motor1TimeUntilFinished/1000 + " seconds.");
motor2CurrentParametersTextLabel1.setText("Speed: " + motor2CurrentSpeed);
motor2CurrentParametersTextLabel2.setText( "Direction: " + getCurrentDirection(motor2Direction));
motor2CurrentParametersTextLabel3.setText( "Time until max or min: " + motor2TimeUntilFinished/1000 + " seconds.");
}



void checkToggleValues(){
if (motor1ChangeDirectionButton.getState()  == false){
  motor1Direction = 1;
}
else motor1Direction = 0;


if (motor2ChangeDirectionButton.getState()  == false){
  motor2Direction = 1;
}
else motor2Direction = 0;


if (startStopDrawing.getState()  == true){
  motor1CurrentState = true;
  motor2CurrentState = true;
  
  currentMotorStateLabel.setText("Press to Stop");
  if (motor1LastTimerValue != motor1TimeSlider.getValue()){
    motor1LastTimerValue = motor1TimeSlider.getValue();
  motor1CountdownTimer.reset();
  motor1CountdownTimer.configure(100, (int)(motor1TimeSlider.getValue()*1000)).start();
  }

  if (motor2LastTimerValue != motor2TimeSlider.getValue()){
      motor2LastTimerValue = motor2TimeSlider.getValue();
      motor2CountdownTimer.reset();
      motor2CountdownTimer.configure(100, (int)(motor2TimeSlider.getValue()*1000)).start();
  }
}
else {
  motor1CurrentState = false;
  motor2CurrentState = false;
  currentMotorStateLabel.setText("Press to Start");
  motor1LastTimerValue =0;
  motor2LastTimerValue =0;
  motor1CountdownTimer.reset();
  motor2CountdownTimer.reset();
}
}



//Timer configurations
void onTickEvent(int timerId, long timeLeftUntilFinish) {
  // change the radius of the circle based on which timer it was hooked up to
  switch (timerId) {
    case 0:
      motor1TimeUntilFinished = timeLeftUntilFinish;
      break;
    case 1:
     motor2TimeUntilFinished = timeLeftUntilFinish;
      break;
    }
}

void onFinishEvent(int timerId) {
  // finalize any changes when the timer finishes
  switch (timerId) {
    case 0:
    motor1CountdownTimer.reset();
      motor1LastTimerValue =0;
      motor1CountdownTimer.start();
      break;
    case 1:
    motor2CountdownTimer.reset();
       motor2LastTimerValue =0;
      motor2CountdownTimer.start();
      break;
    case 2:
    serialTransmissionTimer.reset();
    transmissionTimerFinished = true;
    break;
    
  }

//  println("[timerId:" + timerId + "] finished");
}

//Controller Events Listeners
void controlEvent(ControlEvent theControlEvent) {
  if(theControlEvent.isFrom(motor1Range)) {
    // min and max values are stored in an array.
    // access this array with controller().arrayValue().
    // min is at index 0, max is at index 1.
    motor1MinSpeed = int(theControlEvent.getController().getArrayValue(0));
    motor1MaxSpeed = int(theControlEvent.getController().getArrayValue(1));
    //Debug
  }
   if(theControlEvent.isFrom(motor2Range)) {
    // min and max values are stored in an array.
    // access this array with controller().arrayValue().
    // min is at index 0, max is at index 1.
    motor2MinSpeed = int(theControlEvent.getController().getArrayValue(0));
    motor2MaxSpeed = int(theControlEvent.getController().getArrayValue(1));
    //Debug
  }

}



String getCurrentDirection(int currentDirectionInt){
  if (currentDirectionInt==0){
     return "Counter Clockwise";
      }
  else if (currentDirectionInt == 1){
    return "Clockwise";
}
  else return "Confusion is present, direction unknown";
}




