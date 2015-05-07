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
boolean arduinoHasProcessedSentParameters = true;

//GUI Variables
int windowSizeWidth;
int windowSizeHeight;
int xOffsetLeft = 50;
int xOffsetRight = 50;
int yOffsetTop = 50+167;
int yOffsetBottom = 50;
boolean advancedGui = false;
PImage headline;

//Sliders & Range controllers gui preferences
int sliderHeight = 40;
int sliderHandleSize = 20;
int sliderHorizontalSpacing = 20;
Range motor1Range;
Range motor2Range;
Slider motor1TimeSlider;
Slider motor2TimeSlider;
Slider motor1SpeedSlider;
Slider motor2SpeedSlider;

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
Toggle advancedModeToggleSwitch;
int buttonHeight = 20;
int startButtonHeight = 100;
int advancedModeToggleSwitchWidth = 60;
int advancedModeToggleSwitchHeight = 20;

//Motor Control Parameters
int motor1MinSpeed = 0;
int motor2MinSpeed = 0;
int motor1MaxSpeed = 0;
int motor2MaxSpeed = 0;
long motor1TimeUntilFinished = 10;
long motor2TimeUntilFinished = 10;
float motor1CurrentSpeed = 0;
float motor2CurrentSpeed = 0;
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

//FadingFunctionVariables
int fadingFunctionId = 0;
boolean motor1FunctionIsCurrentlyIncreasingSpeed = true;
boolean motor2FunctionIsCurrentlyIncreasingSpeed = true;
boolean motor1timerFinished = false;
boolean motor2timerFinished = false;

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
  
  headline = loadImage("circlon-gui-bgnd.jpg");
  
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
             .setNumberOfTickMarks(2500-600)
             .showTickMarks(false) 
             .snapToTickMarks(true)
             .setVisible(false) 
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
             .setNumberOfTickMarks(2500-600)
             .showTickMarks(false) 
             .snapToTickMarks(true)
             .setVisible(false) 
             ;
             
//speed sliders for basic mode

      motor1SpeedSlider = cp5.addSlider("Motor 1 Speed")
      .setPosition(xOffsetLeft,yOffsetTop+buttonHeight+sliderHorizontalSpacing)
      .setSize(windowSizeWidth/2-xOffsetLeft-100, sliderHeight)
     .setRange(200,2500)
     .setValue(200)
     .setColorForeground(color(153, 0, 51))
     .setColorBackground(color(255, 153, 128))
     .setColorLabel(color(0,0,0))
     .setVisible(true) 
     ;
     
      motor2SpeedSlider = cp5.addSlider("Motor 2 Speed")
     .setPosition((windowSizeWidth/2+xOffsetRight), yOffsetTop+buttonHeight+sliderHorizontalSpacing)
     .setSize((windowSizeWidth/2-xOffsetRight-100), sliderHeight)
     .setRange(200,2500)
     .setValue(200)
     .setColorForeground(color(153, 0, 51))
     .setColorBackground(color(255, 153, 128))
     .setColorLabel(color(0,0,0))
     .setVisible(true) 
     ;
             
  motor1TimeSlider = cp5.addSlider("Motor 1 Time")
     .setPosition(xOffsetLeft,yOffsetTop + sliderHeight + sliderHorizontalSpacing+buttonHeight+sliderHorizontalSpacing)
     .setSize(windowSizeWidth/2-xOffsetLeft-100,sliderHeight)
     .setRange(1,200)
     .setValue(30)
     .setColorForeground(color(153, 0, 51))
     .setColorBackground(color(255, 153, 128))
     .setColorLabel(color(0,0,0))
      .setNumberOfTickMarks(200-1)
      .showTickMarks(false) 
      .snapToTickMarks(true)
      .setVisible(false) 
     ;
  
   motor2TimeSlider = cp5.addSlider("Motor 2 Time")
    .setPosition(windowSizeWidth/2+xOffsetRight,yOffsetTop + sliderHeight + sliderHorizontalSpacing+buttonHeight+sliderHorizontalSpacing)
    .setSize(windowSizeWidth/2-xOffsetLeft-100,sliderHeight)
    .setRange(1,200)
    .setValue(30)
    .setColorForeground(color(153, 0, 51))
    .setColorBackground(color(255, 153, 128))
    .setColorLabel(color(0,0,0))
     .setNumberOfTickMarks(200-1)
      .showTickMarks(false) 
      .snapToTickMarks(true)
      .setVisible(false) 
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
    .setVisible(false);
     ;
     
    advancedModeToggleSwitch = cp5.addToggle("Advanced Mode")
     .setPosition(windowSizeWidth-xOffsetLeft-advancedModeToggleSwitchWidth,windowSizeHeight-yOffsetBottom-advancedModeToggleSwitchHeight)
     .setSize(advancedModeToggleSwitchWidth,advancedModeToggleSwitchHeight)
     .setValue(0)
     .setColorForeground(color(153, 0, 51))
    .setColorBackground(color(255, 153, 128))
    .setColorActive(color(153, 0, 51)) 
    .setColorLabel(color(0,0,0))
    .setMode(ControlP5.SWITCH)
    .setLabelVisible(true)
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
  
image(headline, windowSizeWidth/2-300, 20);
//debug start
//motor1CurrentSpeed = motor1MaxSpeed;
//motor2CurrentSpeed = motor2MaxSpeed;
//debug end
updateValuesFromRangeSliders();
checkToggleValues();
updateScreen();
//runMotors();


}

void updateGuiAtModeChange(){
if (advancedGui == true){
  motor1Range.setVisible(true);
  motor2Range.setVisible(true);
  motor1TimeSlider.setVisible(true);
  motor2TimeSlider.setVisible(true);
  motor1SpeedSlider.setVisible(false);
  motor1SpeedSlider.setVisible(false);
  
  //textlables
  motor1CurrentParametersTextLabel1.setText("Speed: " + motor1CurrentSpeed).setLabelVisible(true) ;
  motor1CurrentParametersTextLabel2.setText( "Direction: " + getCurrentDirection(motor1Direction).setLabelVisible(true);                 
  motor1CurrentParametersTextLabel3.setText( "Time until max or min: " + motor1TimeUntilFinished + " seconds.").setLabelVisible(true) ;                   
  motor2CurrentParametersTextLabel1.setText("Speed: " + motor2CurrentSpeed).setLabelVisible(true) ;          
  motor2CurrentParametersTextLabel2.setText( "Direction: " + getCurrentDirection(motor2Direction).setLabelVisible(true) ;                 
  motor2CurrentParametersTextLabel3.setText( "Time until max or min: " + motor1TimeUntilFinished + " seconds.").setLabelVisible(true) ;


}
else {
  motor1Range.setVisible(false);
  motor2Range.setVisible(false);
  motor1TimeSlider.setVisible(false);
  motor2TimeSlider.setVisible(false);
  motor1SpeedSlider.setVisible(true);
  motor1SpeedSlider.setVisible(true);
  //textlables
  motor1CurrentParametersTextLabel1.setText("Speed: " + motor1CurrentSpeed).setLabelVisible(true) ;
  motor1CurrentParametersTextLabel2.setText( "Direction: " + getCurrentDirection(motor1Direction).setLabelVisible(true);                 
  motor1CurrentParametersTextLabel3.setText( "Time until max or min: " + motor1TimeUntilFinished + " seconds.").setLabelVisible(false) ;                   
  motor2CurrentParametersTextLabel1.setText("Speed: " + motor2CurrentSpeed).setLabelVisible(true) ;          
  motor2CurrentParametersTextLabel2.setText( "Direction: " + getCurrentDirection(motor2Direction).setLabelVisible(true) ;                 
  motor2CurrentParametersTextLabel3.setText( "Time until max or min: " + motor1TimeUntilFinished + " seconds.").setLabelVisible(false) ;

}

}


void serialEvent( Serial myPort) {
    try {
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
      arduinoHasProcessedSentParameters = true; 
      serialTransmissionTimer.start();
    }
  }
  else { //if we've already established contact, keep getting and parsing data
    println("Received serial data from Arduino: " +val);
    if (val.equals("parametersProcessed")) {
     arduinoHasProcessedSentParameters = true; 
    }
    myPort.clear();
    }
  }
    }
       catch (Exception e) {
    println("Initialization exception");
//    decide what to do here
  }
 }
 


void sendMotorParametersOverSerial(){
//println("in send function, transmissionTimerFinished = "+transmissionTimerFinished+ " arduinoHasProcessedSentParameters: " +arduinoHasProcessedSentParameters );
if (transmissionTimerFinished == true && arduinoHasProcessedSentParameters == true){
println("Just before sending function =" + currentValuesFromGuiOrFunction);
myPort.write(currentValuesFromGuiOrFunction);
arduinoHasProcessedSentParameters = true;
transmissionTimerFinished = false;
serialTransmissionTimer.start();
}
}


void getMotorParametersFromGui(){

if (motor1CurrentState == true && motor2CurrentState == true){
calculateNextSpeedBasedOnFadingFunction();
//currentValuesFromGuiOrFunction = ((int)motor1CurrentSpeed+","+(int)motor1Direction+","+(int)motor2CurrentSpeed+","+(int)motor2Direction); 
}


else if (motor1CurrentState == false && motor2CurrentState == false){
currentValuesFromGuiOrFunction = "0,0,0,0";
}
sendMotorParametersOverSerial();  
}

void calculateNextSpeedBasedOnFadingFunction(){
    motor1MinSpeed = (int)motor1Range.getLowValue();
    motor1MaxSpeed = (int)motor1Range.getHighValue();
    motor2MinSpeed = (int)motor2Range.getLowValue();
    motor2MaxSpeed = (int)motor2Range.getHighValue();
  int motor1NumberOfSpeedStepsBetweenMaxAndMin = (motor1MaxSpeed-motor1MinSpeed)*10000;
  //println("motor1NumberOfSpeedStepsBetweenMaxAndMin: " + motor1NumberOfSpeedStepsBetweenMaxAndMin);
  int motor2NumberOfSpeedStepsBetweenMaxAndMin = (motor2MaxSpeed-motor2MinSpeed)*10000;
  long motor1MilliSecondsToTraverseTheSpeedSteps = motor1CountdownTimer.getTimerDuration();
  long motor2MilliSecondsToTraverseTheSpeedSteps = motor2CountdownTimer.getTimerDuration();
  float motor1StepsPerMilliSecond = motor1NumberOfSpeedStepsBetweenMaxAndMin/motor1MilliSecondsToTraverseTheSpeedSteps;
  float motor2StepsPerMilliSecond = motor2NumberOfSpeedStepsBetweenMaxAndMin/motor2MilliSecondsToTraverseTheSpeedSteps;
 switch (fadingFunctionId) {
    case 0:
        /*
        println("case 0 started, motor1FunctionIsCurrentlyIncreasingSpeed= " + motor1FunctionIsCurrentlyIncreasingSpeed);
        println("motor1StepsPerMilliSecond= " + motor1StepsPerMilliSecond);
        println("motor1CountdownTimer.getTimerDuration()= " + motor1CountdownTimer.getTimerDuration());
        println("motor1NumberOfSpeedStepsBetweenMaxAndMin= " + motor1NumberOfSpeedStepsBetweenMaxAndMin);
        println("(motor1StepsPerMilliSecond*((int)motor1CountdownTimer.getTimerDuration() - (int)motor1CountdownTimer.getTimeLeftUntilFinish()) "+((long)motor1StepsPerMilliSecond*(motor1CountdownTimer.getTimerDuration() - motor1CountdownTimer.getTimeLeftUntilFinish())));
        */
      if (motor1timerFinished == true ){
       // println("motor1timerFinished == true");
      motor1FunctionIsCurrentlyIncreasingSpeed = !motor1FunctionIsCurrentlyIncreasingSpeed;
      motor1timerFinished = false;
      motor1CountdownTimer.start();
      }

      else {

       // println("motorspeed should change, motor1FunctionIsCurrentlyIncreasingSpeed= " + motor1FunctionIsCurrentlyIncreasingSpeed);
      if (motor1FunctionIsCurrentlyIncreasingSpeed == true){
        
      motor1CurrentSpeed = (float)motor1MinSpeed+((motor1StepsPerMilliSecond*(motor1CountdownTimer.getTimerDuration() - motor1CountdownTimer.getTimeLeftUntilFinish()))/10000);
      }
      if (motor1FunctionIsCurrentlyIncreasingSpeed == false){
        motor1CurrentSpeed = (float)motor1MaxSpeed-((motor1StepsPerMilliSecond*(motor1CountdownTimer.getTimerDuration() - motor1CountdownTimer.getTimeLeftUntilFinish()))/10000);
      }
      }
      
      if (motor2timerFinished == true ){
       // println("motor2timerFinished == true");
      motor2FunctionIsCurrentlyIncreasingSpeed = !motor2FunctionIsCurrentlyIncreasingSpeed;
      motor2timerFinished = false;
      motor2CountdownTimer.start();
      }
      else {
      if (motor2FunctionIsCurrentlyIncreasingSpeed == true){
        motor2CurrentSpeed = (float)motor2MinSpeed+((motor2StepsPerMilliSecond*(motor2CountdownTimer.getTimerDuration() - motor2CountdownTimer.getTimeLeftUntilFinish()))/10000);
      }
      if (motor2FunctionIsCurrentlyIncreasingSpeed == false){
        motor2CurrentSpeed = (float)motor2MaxSpeed-((motor2StepsPerMilliSecond*(motor2CountdownTimer.getTimerDuration() - motor2CountdownTimer.getTimeLeftUntilFinish()))/10000);
      }
      }
      
      currentValuesFromGuiOrFunction = (int)motor1CurrentSpeed + "," + (int)motor1Direction+"," + (int)motor2CurrentSpeed + "," + (int)motor2Direction;
      //println("currentValuesFromGuiOrFunction: " + currentValuesFromGuiOrFunction);
      sendMotorParametersOverSerial();
      break;
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


if (advancedModeToggleSwitch.getState() == true{
advancedGui = true;
updateGuiAtModeChange();
else {
advancedGui = false;
updateGuiAtModeChange();
}



}
if (startStopDrawing.getState()  == true){
  motor1CurrentState = true;
  motor2CurrentState = true;
  getMotorParametersFromGui();
  
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
else if(startStopDrawing.getState()  == false){
  motor1CurrentState = false;
  motor2CurrentState = false;
  currentMotorStateLabel.setText("Press to Start");
  getMotorParametersFromGui();
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
    case 2:

      break;
    }
}

void onFinishEvent(int timerId) {
  // finalize any changes when the timer finishes
  switch (timerId) {
    case 0:
    motor1timerFinished = true;
    motor1CountdownTimer.reset();
      motor1LastTimerValue =0;
      
      break;
    case 1:
    motor2CountdownTimer.reset();
       motor2LastTimerValue =0;
       motor2timerFinished = true;

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




