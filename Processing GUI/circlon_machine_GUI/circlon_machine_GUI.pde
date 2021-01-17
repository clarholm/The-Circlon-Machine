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
int yOffsetTop = 50;
int yOffsetBottom = 50;
int secondRowX=250;

//Sliders & Range controllers gui preferences
int sliderHeight = 40;
int sliderHandleSize = 20;
int sliderHorizontalSpacing = 20;
Range motor1Range;
Range motor2Range;
Range motor3Range;
Range motor4Range;
Slider motor1TimeSlider;
Slider motor2TimeSlider;
Slider motor3TimeSlider;
Slider motor4TimeSlider;

//Text label
int textLabelRowSpacing = 17;
Textlabel motor1CurrentParametersTextLabel1;
Textlabel motor1CurrentParametersTextLabel2;
Textlabel motor1CurrentParametersTextLabel3;

Textlabel motor2CurrentParametersTextLabel1;
Textlabel motor2CurrentParametersTextLabel2;
Textlabel motor2CurrentParametersTextLabel3;

Textlabel motor3CurrentParametersTextLabel1;
Textlabel motor3CurrentParametersTextLabel2;
Textlabel motor3CurrentParametersTextLabel3;

Textlabel motor4CurrentParametersTextLabel1;
Textlabel motor4CurrentParametersTextLabel2;
Textlabel motor4CurrentParametersTextLabel3;

Textlabel currentMotorStateLabel;
Textlabel pauseMotorLabel;

//Buttons
Toggle motor1ChangeDirectionButton;
boolean motor1ChangeDirectionButtonStatus;
Toggle motor2ChangeDirectionButton;
boolean motor2ChangeDirectionButtonStatus;
Toggle motor3ChangeDirectionButton;
boolean motor3ChangeDirectionButtonStatus;
Toggle motor4ChangeDirectionButton;
boolean motor4ChangeDirectionButtonStatus;
Toggle startStopDrawing;
Toggle pauseDrawing;
int buttonHeight = 20;
int startButtonHeight = 100;

//Motor Control Parameters
int motor1MinSpeed = 0;
int motor2MinSpeed = 0;
int motor3MinSpeed = 0;
int motor4MinSpeed = 0;
int motor1MaxSpeed = 0;
int motor2MaxSpeed = 0;
int motor3MaxSpeed = 0;
int motor4MaxSpeed = 0;
long motor1TimeUntilFinished = 10;
long motor2TimeUntilFinished = 10;
long motor3TimeUntilFinished = 10;
long motor4TimeUntilFinished = 10;
float motor1CurrentSpeed = 0;
float motor2CurrentSpeed = 0;
float motor3CurrentSpeed = 0;
float motor4CurrentSpeed = 0;
int motor1CurrentTime = 0;
int motor2CurrentTime = 0;
int motor3CurrentTime = 0;
int motor4CurrentTime = 0;
float motor1LastTimerValue = 0;
float motor2LastTimerValue = 0;
float motor3LastTimerValue = 0;
float motor4LastTimerValue = 0;
boolean motor1CurrentState;
boolean motor2CurrentState;
boolean motor3CurrentState;
boolean motor4CurrentState;
int motor1Direction = 0; //0 = counter clockwise, 1 = clockwise
int motor2Direction = 0; //0 = counter clockwise, 1 = clockwise
int motor3Direction = 0; //0 = counter clockwise, 1 = clockwise
int motor4Direction = 0; //0 = counter clockwise, 1 = clockwise
CountdownTimer motor1CountdownTimer;
CountdownTimer motor2CountdownTimer;
CountdownTimer motor3CountdownTimer;
CountdownTimer motor4CountdownTimer;
String runMotorsString; //contains speed parameters
String currentValuesFromGuiOrFunction; //contains the parameters the GUI is currently set to.

//FadingFunctionVariables
int fadingFunctionId = 0;
boolean motor1FunctionIsCurrentlyIncreasingSpeed = true;
boolean motor2FunctionIsCurrentlyIncreasingSpeed = true;
boolean motor3FunctionIsCurrentlyIncreasingSpeed = true;
boolean motor4FunctionIsCurrentlyIncreasingSpeed = true;
boolean motor1timerFinished = false;
boolean motor2timerFinished = false;
boolean motor3timerFinished = false;
boolean motor4timerFinished = false;

void setup() {
  
  //Create serial communications port
 println(Serial.list());
 String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil('\n');
  
  //Setup window based on screensize
  size(1800, 1000);
  //size(displayWidth-100, displayHeight-100);
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
             .setRange(10,2500)
             .setRangeValues(10,800)
             // after the initialization we turn broadcast back on again
             .setBroadcast(true)
             .setColorForeground(color(153, 0, 51))
             .setColorBackground(color(255, 153, 128))
             .setColorLabel(color(0,0,0))
             .setNumberOfTickMarks(2500-600)
             .showTickMarks(false) 
             .snapToTickMarks(true)
             ; 
  //Create slider for motor two speed control
  motor2Range = cp5.addRange("Motor 2 Speed")
               // disable broadcasting since setRange and setRangeValues will trigger an event
             .setBroadcast(false) 
             .setPosition((windowSizeWidth/2+xOffsetRight), yOffsetTop+buttonHeight+sliderHorizontalSpacing)
             .setSize((windowSizeWidth/2-xOffsetRight-100), sliderHeight)
             .setHandleSize(sliderHandleSize)
             .setRange(10,2500)
             .setRangeValues(600,800)
             // after the initialization we turn broadcast back on again
             .setBroadcast(true)
             .setColorForeground(color(153, 0, 51))
             .setColorBackground(color(255, 153, 128))
             .setColorLabel(color(0,0,0))
             .setNumberOfTickMarks(2500-600)
             .showTickMarks(false) 
             .snapToTickMarks(true)
             ;
 motor3Range = cp5.addRange("Motor 3 Speed")
               // disable broadcasting since setRange and setRangeValues will trigger an event
             .setBroadcast(false) 
             .setPosition(xOffsetLeft,yOffsetTop+buttonHeight+sliderHorizontalSpacing+secondRowX)
             .setSize(windowSizeWidth/2-xOffsetLeft-100, sliderHeight)
             .setHandleSize(sliderHandleSize)
             .setRange(10,2500)
             .setRangeValues(10,800)
             // after the initialization we turn broadcast back on again
             .setBroadcast(true)
             .setColorForeground(color(0, 0, 51))
             .setColorBackground(color(255, 153, 128))
             .setColorLabel(color(0,0,0))
             .setNumberOfTickMarks(2500-600)
             .showTickMarks(false) 
             .snapToTickMarks(true)
             ; 
  motor4Range = cp5.addRange("Motor 4 Speed")
               // disable broadcasting since setRange and setRangeValues will trigger an event
             .setBroadcast(false) 
             .setPosition((windowSizeWidth/2+xOffsetRight), yOffsetTop+buttonHeight+sliderHorizontalSpacing+secondRowX)
             .setSize((windowSizeWidth/2-xOffsetRight-100), sliderHeight)
             .setHandleSize(sliderHandleSize)
             .setRange(10,2500)
             .setRangeValues(600,800)
             // after the initialization we turn broadcast back on again
             .setBroadcast(true)
             .setColorForeground(color(153, 0, 51))
             .setColorBackground(color(255, 153, 128))
             .setColorLabel(color(0,0,0))
             .setNumberOfTickMarks(2500-600)
             .showTickMarks(false) 
             .snapToTickMarks(true)
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
    ;
 motor3TimeSlider = cp5.addSlider("Motor 3 Time")
     .setPosition(xOffsetLeft,yOffsetTop + sliderHeight + sliderHorizontalSpacing+buttonHeight+sliderHorizontalSpacing+secondRowX)
     .setSize(windowSizeWidth/2-xOffsetLeft-100,sliderHeight)
     .setRange(1,200)
     .setValue(30)
     .setColorForeground(color(153, 0, 51))
     .setColorBackground(color(255, 153, 128))
     .setColorLabel(color(0,0,0))
      .setNumberOfTickMarks(200-1)
      .showTickMarks(false) 
      .snapToTickMarks(true)
     ;
   motor4TimeSlider = cp5.addSlider("Motor 4 Time")
    .setPosition(windowSizeWidth/2+xOffsetRight,yOffsetTop + sliderHeight + sliderHorizontalSpacing+buttonHeight+sliderHorizontalSpacing+secondRowX)
    .setSize(windowSizeWidth/2-xOffsetLeft-100,sliderHeight)
    .setRange(1,200)
    .setValue(30)
    .setColorForeground(color(153, 0, 51))
    .setColorBackground(color(255, 153, 128))
    .setColorLabel(color(0,0,0))
     .setNumberOfTickMarks(200-1)
      .showTickMarks(false) 
      .snapToTickMarks(true)
    ;

  motor1CurrentParametersTextLabel1 = cp5.addTextlabel("motor1Label1")
                    .setText("Speed: " + motor1CurrentSpeed)
                    .setPosition(xOffsetLeft,yOffsetTop + 2*sliderHeight + 2*sliderHorizontalSpacing+buttonHeight + sliderHorizontalSpacing)
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
                    .setText( "Time until max or min: " + motor2TimeUntilFinished + " seconds.")
                    .setPosition(windowSizeWidth/2+xOffsetRight, yOffsetTop + 2*sliderHeight + 2*sliderHorizontalSpacing+2*textLabelRowSpacing+buttonHeight+sliderHorizontalSpacing)
                    .setColorValue(color(0,0,0))
                    .setFont(createFont("Arial",15))
                    ;

  motor3CurrentParametersTextLabel1 = cp5.addTextlabel("motor3Label1")
                    .setText("Speed: " + motor3CurrentSpeed)
                    .setPosition(xOffsetLeft,yOffsetTop + 2*sliderHeight + 2*sliderHorizontalSpacing+2*buttonHeight+2*sliderHorizontalSpacing+secondRowX)
                    .setColorValue(color(0,0,0))
                    .setFont(createFont("Arial",15))
                    ;
                    
  motor3CurrentParametersTextLabel2 = cp5.addTextlabel("motor3Label2")
                    .setText( "Direction: " + getCurrentDirection(motor3Direction))
                    .setPosition(xOffsetLeft,yOffsetTop + 2*sliderHeight + 2*sliderHorizontalSpacing+textLabelRowSpacing+buttonHeight+sliderHorizontalSpacing+secondRowX)
                    .setColorValue(color(0,0,0))
                    .setFont(createFont("Arial",15))
                    ;
                    
  motor3CurrentParametersTextLabel3 = cp5.addTextlabel("motor3Label3")
                    .setText( "Time until max or min: " + motor3TimeUntilFinished + " seconds.")
                    .setPosition(xOffsetLeft,yOffsetTop + 2*sliderHeight + 2*sliderHorizontalSpacing+2*textLabelRowSpacing+buttonHeight+sliderHorizontalSpacing+secondRowX)
                    .setColorValue(color(0,0,0))
                    .setFont(createFont("Arial",15))
                    ;
  motor4CurrentParametersTextLabel1 = cp5.addTextlabel("motor2Label1")
                    .setText("Speed: " + motor2CurrentSpeed)
                    .setPosition(windowSizeWidth/2+xOffsetRight,yOffsetTop + 2*sliderHeight + 2*sliderHorizontalSpacing+buttonHeight+sliderHorizontalSpacing+secondRowX)
                    .setColorValue(color(0,0,0))
                    .setFont(createFont("Arial",15))
                    ;
                    
  motor4CurrentParametersTextLabel2 = cp5.addTextlabel("motor4Label2")
                    .setText( "Direction: " + getCurrentDirection(motor4Direction))
                    .setPosition(windowSizeWidth/2+xOffsetRight, yOffsetTop + 2*sliderHeight + 2*sliderHorizontalSpacing+textLabelRowSpacing+buttonHeight+sliderHorizontalSpacing+secondRowX)
                    .setColorValue(color(0,0,0))
                    .setFont(createFont("Arial",15))
                    ;                  
                    
                    
  motor4CurrentParametersTextLabel3 = cp5.addTextlabel("motor4Label3")
                    .setText( "Time until max or min: " + motor4TimeUntilFinished + " seconds.")
                    .setPosition(windowSizeWidth/2+xOffsetRight, yOffsetTop + 2*sliderHeight + 2*sliderHorizontalSpacing+2*textLabelRowSpacing+buttonHeight+sliderHorizontalSpacing+secondRowX)
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

   motor3ChangeDirectionButton = cp5.addToggle("Click to change direction of motor 3")
     .setPosition(xOffsetLeft,yOffsetTop+secondRowX)
     .setSize(windowSizeWidth/2-xOffsetLeft-100,buttonHeight)
     .setValue(0)
     .setColorForeground(color(153, 0, 51))
     .setColorBackground(color(255, 153, 128))
     .setColorActive(color(153, 0, 51)) 
     .setColorLabel(color(0,0,0))
     ;

   motor4ChangeDirectionButton = cp5.addToggle("Click to change direction of motor 4")
     .setPosition(windowSizeWidth/2+xOffsetRight,yOffsetTop+secondRowX)
     .setSize(windowSizeWidth/2-xOffsetLeft-100,buttonHeight)
     .setValue(0)
     .setColorForeground(color(153, 0, 51))
    .setColorBackground(color(255, 153, 128))
    .setColorActive(color(153, 0, 51)) 
    .setColorLabel(color(0,0,0))
     ;
//Motors on or off     
   startStopDrawing = cp5.addToggle("Start/Stop motors")
     .setPosition(windowSizeWidth/2+xOffsetRight,yOffsetTop + 2*sliderHeight + 3*sliderHorizontalSpacing+3*textLabelRowSpacing+buttonHeight+sliderHorizontalSpacing+secondRowX)
     .setSize(windowSizeWidth/2-xOffsetLeft-100,startButtonHeight)
     .setValue(0)
     .setColorForeground(color(153, 0, 51))
    .setColorBackground(color(255, 153, 128))
    .setColorActive(color(153, 0, 51)) 
    .setColorLabel(color(0,0,0))
    .setLabelVisible(false)
     ;
   pauseDrawing = cp5.addToggle("Reset Timers")
     .setPosition(xOffsetRight,yOffsetTop + 2*sliderHeight + 3*sliderHorizontalSpacing+3*textLabelRowSpacing+buttonHeight+sliderHorizontalSpacing+secondRowX)
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
    .setPosition(windowSizeWidth/2+xOffsetRight, yOffsetTop + 2*sliderHeight + 3*sliderHorizontalSpacing+3*textLabelRowSpacing+buttonHeight+sliderHorizontalSpacing+startButtonHeight+secondRowX)
    .setColorValue(color(0,0,0))
    .setFont(createFont("Arial",25))
                    ;

  pauseMotorLabel = cp5.addTextlabel("resetTimers")
    .setText( "Reset Timers")
    .setPosition(xOffsetRight, yOffsetTop + 2*sliderHeight + 3*sliderHorizontalSpacing+3*textLabelRowSpacing+buttonHeight+sliderHorizontalSpacing+startButtonHeight+secondRowX)
    .setColorValue(color(0,0,0))
    .setFont(createFont("Arial",25))
                    ;


//Create timers

motor1CountdownTimer = CountdownTimerService.getNewCountdownTimer(this).configure(100, (int)(motor1TimeSlider.getValue()*1000));
motor2CountdownTimer = CountdownTimerService.getNewCountdownTimer(this).configure(100, (int)(motor2TimeSlider.getValue()*1000));
motor3CountdownTimer = CountdownTimerService.getNewCountdownTimer(this).configure(100, (int)(motor3TimeSlider.getValue()*1000));
motor4CountdownTimer = CountdownTimerService.getNewCountdownTimer(this).configure(100, (int)(motor4TimeSlider.getValue()*1000));
serialTransmissionTimer = CountdownTimerService.getNewCountdownTimer(this).configure(100, timeBetweenSerialTransmissions);
  noStroke();


}

void draw() {
  
  
//debug start
//motor1CurrentSpeed = motor1MaxSpeed;
//motor2CurrentSpeed = motor2MaxSpeed;
//debug end
updateValuesFromRangeSliders();
checkToggleValues();
updateScreen();
//runMotors();


}

void updateValuesFromRangeSliders(){


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

if (motor1CurrentState == true && motor2CurrentState == true && motor3CurrentState == true && motor4CurrentState == true){
calculateNextSpeedBasedOnFadingFunction();
//currentValuesFromGuiOrFunction = ((int)motor1CurrentSpeed+","+(int)motor1Direction+","+(int)motor2CurrentSpeed+","+(int)motor2Direction,"+(int)motor3CurrentSpeed+","+(int)motor3Direction,"+(int)motor4CurrentSpeed+","+(int)motor4Direction); 
}


else if (motor1CurrentState == false && motor2CurrentState == false){
currentValuesFromGuiOrFunction = "0,0,0,0,0,0,0,0";
}
sendMotorParametersOverSerial();  
}

void calculateNextSpeedBasedOnFadingFunction(){
    motor1MinSpeed = (int)motor1Range.getLowValue();
    motor1MaxSpeed = (int)motor1Range.getHighValue();
    motor2MinSpeed = (int)motor2Range.getLowValue();
    motor2MaxSpeed = (int)motor2Range.getHighValue();
    motor3MinSpeed = (int)motor3Range.getLowValue();
    motor3MaxSpeed = (int)motor3Range.getHighValue();
    motor4MinSpeed = (int)motor4Range.getLowValue();
    motor4MaxSpeed = (int)motor4Range.getHighValue();
  int motor1NumberOfSpeedStepsBetweenMaxAndMin = (motor1MaxSpeed-motor1MinSpeed)*10000;
  //println("motor1NumberOfSpeedStepsBetweenMaxAndMin: " + motor1NumberOfSpeedStepsBetweenMaxAndMin);
  int motor2NumberOfSpeedStepsBetweenMaxAndMin = (motor2MaxSpeed-motor2MinSpeed)*10000;
  int motor3NumberOfSpeedStepsBetweenMaxAndMin = (motor3MaxSpeed-motor3MinSpeed)*10000;
  int motor4NumberOfSpeedStepsBetweenMaxAndMin = (motor4MaxSpeed-motor4MinSpeed)*10000;
  long motor1MilliSecondsToTraverseTheSpeedSteps = motor1CountdownTimer.getTimerDuration();
  long motor2MilliSecondsToTraverseTheSpeedSteps = motor2CountdownTimer.getTimerDuration();
  long motor3MilliSecondsToTraverseTheSpeedSteps = motor3CountdownTimer.getTimerDuration();
  long motor4MilliSecondsToTraverseTheSpeedSteps = motor4CountdownTimer.getTimerDuration();
  float motor1StepsPerMilliSecond = motor1NumberOfSpeedStepsBetweenMaxAndMin/motor1MilliSecondsToTraverseTheSpeedSteps;
  float motor2StepsPerMilliSecond = motor2NumberOfSpeedStepsBetweenMaxAndMin/motor2MilliSecondsToTraverseTheSpeedSteps;
  float motor3StepsPerMilliSecond = motor3NumberOfSpeedStepsBetweenMaxAndMin/motor3MilliSecondsToTraverseTheSpeedSteps;
  float motor4StepsPerMilliSecond = motor4NumberOfSpeedStepsBetweenMaxAndMin/motor4MilliSecondsToTraverseTheSpeedSteps;
  
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
      
      if (motor3timerFinished == true ){
       // println("motor2timerFinished == true");
      motor3FunctionIsCurrentlyIncreasingSpeed = !motor3FunctionIsCurrentlyIncreasingSpeed;
      motor3timerFinished = false;
      motor3CountdownTimer.start();
      }
      else {
      if (motor3FunctionIsCurrentlyIncreasingSpeed == true){
        motor3CurrentSpeed = (float)motor3MinSpeed+((motor3StepsPerMilliSecond*(motor3CountdownTimer.getTimerDuration() - motor3CountdownTimer.getTimeLeftUntilFinish()))/10000);
      }
      if (motor3FunctionIsCurrentlyIncreasingSpeed == false){
        motor3CurrentSpeed = (float)motor3MaxSpeed-((motor3StepsPerMilliSecond*(motor3CountdownTimer.getTimerDuration() - motor3CountdownTimer.getTimeLeftUntilFinish()))/10000);
      }
      }
      
      if (motor4timerFinished == true ){
       // println("motor2timerFinished == true");
      motor4FunctionIsCurrentlyIncreasingSpeed = !motor4FunctionIsCurrentlyIncreasingSpeed;
      motor4timerFinished = false;
      motor4CountdownTimer.start();
      }
      else {
      if (motor4FunctionIsCurrentlyIncreasingSpeed == true){
        motor4CurrentSpeed = (float)motor4MinSpeed+((motor4StepsPerMilliSecond*(motor4CountdownTimer.getTimerDuration() - motor4CountdownTimer.getTimeLeftUntilFinish()))/10000);
      }
      if (motor4FunctionIsCurrentlyIncreasingSpeed == false){
        motor4CurrentSpeed = (float)motor4MaxSpeed-((motor4StepsPerMilliSecond*(motor4CountdownTimer.getTimerDuration() - motor4CountdownTimer.getTimeLeftUntilFinish()))/10000);
      }
      }
      
      currentValuesFromGuiOrFunction = (int)motor1CurrentSpeed + "," + (int)motor1Direction+"," + (int)motor2CurrentSpeed + "," + (int)motor2Direction + (int)motor3CurrentSpeed + "," + (int)motor3Direction+"," + (int)motor4CurrentSpeed + "," + (int)motor4Direction;
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
  motor3CurrentParametersTextLabel1.draw(this);
  motor3CurrentParametersTextLabel2.draw(this);
  motor3CurrentParametersTextLabel3.draw(this);
  motor4CurrentParametersTextLabel1.draw(this);
  motor4CurrentParametersTextLabel2.draw(this);
  motor4CurrentParametersTextLabel3.draw(this);
}

void setCurrentVariablesInLabelText(){
motor1CurrentParametersTextLabel1.setText("Speed: " + motor1CurrentSpeed);
motor1CurrentParametersTextLabel2.setText( "Direction: " + getCurrentDirection(motor1Direction));
motor1CurrentParametersTextLabel3.setText( "Time until max or min: " + motor1TimeUntilFinished/1000 + " seconds.");
motor2CurrentParametersTextLabel1.setText("Speed: " + motor2CurrentSpeed);
motor2CurrentParametersTextLabel2.setText( "Direction: " + getCurrentDirection(motor2Direction));
motor2CurrentParametersTextLabel3.setText( "Time until max or min: " + motor2TimeUntilFinished/1000 + " seconds.");
motor3CurrentParametersTextLabel1.setText("Speed: " + motor3CurrentSpeed);
motor3CurrentParametersTextLabel2.setText( "Direction: " + getCurrentDirection(motor3Direction));
motor3CurrentParametersTextLabel3.setText( "Time until max or min: " + motor3TimeUntilFinished/1000 + " seconds.");
motor4CurrentParametersTextLabel1.setText("Speed: " + motor4CurrentSpeed);
motor4CurrentParametersTextLabel2.setText( "Direction: " + getCurrentDirection(motor4Direction));
motor4CurrentParametersTextLabel3.setText( "Time until max or min: " + motor4TimeUntilFinished/1000 + " seconds.");
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

if (motor3ChangeDirectionButton.getState()  == false){
  motor3Direction = 1;
}
else motor3Direction = 0;


if (motor4ChangeDirectionButton.getState()  == false){
  motor4Direction = 1;
}
else motor4Direction = 0;


if (startStopDrawing.getState()  == true){
  motor1CurrentState = true;
  motor2CurrentState = true;
  motor3CurrentState = true;
  motor4CurrentState = true;
  getMotorParametersFromGui();
  
  currentMotorStateLabel.setText("Press to Stop");
  
  if (motor1LastTimerValue != motor1TimeSlider.getValue()){
  motor1LastTimerValue = motor1TimeSlider.getValue();
  motor1CountdownTimer.reset(CountdownTimer.StopBehavior.STOP_AFTER_INTERVAL);
  motor1CountdownTimer.configure(100, (int)(motor1TimeSlider.getValue()*1000)).start();
  
  }

  if (motor2LastTimerValue != motor2TimeSlider.getValue()){
      motor2LastTimerValue = motor2TimeSlider.getValue();
      motor2CountdownTimer.reset(CountdownTimer.StopBehavior.STOP_AFTER_INTERVAL);
      motor2CountdownTimer.configure(100, (int)(motor2TimeSlider.getValue()*1000)).start();
       
  }
  if (motor3LastTimerValue != motor3TimeSlider.getValue()){
      motor3LastTimerValue = motor3TimeSlider.getValue();
      motor3CountdownTimer.reset(CountdownTimer.StopBehavior.STOP_AFTER_INTERVAL);
      motor3CountdownTimer.configure(100, (int)(motor3TimeSlider.getValue()*1000)).start();
       
  }
  if (motor4LastTimerValue != motor4TimeSlider.getValue()){
      motor4LastTimerValue = motor4TimeSlider.getValue();
      motor4CountdownTimer.reset(CountdownTimer.StopBehavior.STOP_AFTER_INTERVAL);
      motor4CountdownTimer.configure(100, (int)(motor4TimeSlider.getValue()*1000)).start();
       
  }
}
else if(startStopDrawing.getState()  == false){
  motor1CurrentState = false;
  motor2CurrentState = false;
  motor3CurrentState = false;
  motor4CurrentState = false;
  currentMotorStateLabel.setText("Press to Start");
  getMotorParametersFromGui();
  motor1LastTimerValue =0;
  motor2LastTimerValue =0;
  motor3LastTimerValue =0;
  motor4LastTimerValue =0;
  motor1CountdownTimer.reset(CountdownTimer.StopBehavior.STOP_AFTER_INTERVAL);
  motor2CountdownTimer.reset(CountdownTimer.StopBehavior.STOP_AFTER_INTERVAL);
  motor3CountdownTimer.reset(CountdownTimer.StopBehavior.STOP_AFTER_INTERVAL);
  motor4CountdownTimer.reset(CountdownTimer.StopBehavior.STOP_AFTER_INTERVAL);
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
    motor1CountdownTimer.reset(CountdownTimer.StopBehavior.STOP_AFTER_INTERVAL);
      motor1LastTimerValue =0;
      
      break;
    case 1:
    motor2CountdownTimer.reset(CountdownTimer.StopBehavior.STOP_AFTER_INTERVAL);
       motor2LastTimerValue =0;
       motor2timerFinished = true;

      break;
    case 2:
    serialTransmissionTimer.reset(CountdownTimer.StopBehavior.STOP_AFTER_INTERVAL);
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
