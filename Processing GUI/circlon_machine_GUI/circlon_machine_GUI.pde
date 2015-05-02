
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



import controlP5.*;

ControlP5 cp5;

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

//Motor Control Parameters
int motor1MinSpeed;
int motor2MinSpeed;
int motor1MaxSpeed;
int motor2MaxSpeed;
int motor1Time = 10;
int motor2Time = 10;
int motor1CurrentSpeed = 0;
int motor2CurrentSpeed = 0;
int motor1CurrentTime = 0;
int motor2CurrentTime = 0;
boolean motor1CurrentState;
boolean motor2CurrentState;
int motor1Direction = 0; //0 = counter clockwise, 1 = clockwise
int motor2Direction = 0; //0 = counter clockwise, 1 = clockwise

void setup() {
  
  //Setup window based on screensize
  size(displayWidth-100, displayHeight-100, P2D);
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
             .setPosition(xOffsetLeft,yOffsetTop)
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
             .setPosition((windowSizeWidth/2+xOffsetRight), yOffsetTop)
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
     .setPosition(xOffsetLeft,yOffsetTop + sliderHeight + sliderHorizontalSpacing)
     .setSize(windowSizeWidth/2-xOffsetLeft-100,sliderHeight)
     .setRange(10,200)
     .setValue(30)
     .setColorForeground(color(153, 0, 51))
     .setColorBackground(color(255, 153, 128))
     .setColorLabel(color(0,0,0))
     ;
  
   motor2TimeSlider = cp5.addSlider("Motor 2 Time")
    .setPosition(windowSizeWidth/2+xOffsetRight,yOffsetTop + sliderHeight + sliderHorizontalSpacing)
    .setSize(windowSizeWidth/2-xOffsetLeft-100,sliderHeight)
    .setRange(10,200)
    .setValue(30)
    .setColorForeground(color(153, 0, 51))
    .setColorBackground(color(255, 153, 128))
    .setColorLabel(color(0,0,0))
    ;


  motor1CurrentParametersTextLabel1 = cp5.addTextlabel("motor1Label1")
                    .setText("Speed: " + motor1CurrentSpeed)
                    .setPosition(xOffsetLeft,yOffsetTop + 2*sliderHeight + 2*sliderHorizontalSpacing)
                    .setColorValue(color(0,0,0))
                    .setFont(createFont("Arial",15))
                    ;
                    
  motor1CurrentParametersTextLabel2 = cp5.addTextlabel("motor1Label2")
                    .setText( "Direction: " + getCurrentDirection(motor1Direction))
                    .setPosition(xOffsetLeft,yOffsetTop + 2*sliderHeight + 2*sliderHorizontalSpacing+textLabelRowSpacing)
                    .setColorValue(color(0,0,0))
                    .setFont(createFont("Arial",15))
                    ;
                    
  motor1CurrentParametersTextLabel3 = cp5.addTextlabel("motor1Label3")
                    .setText( "Time until max or min: " + (motor1Time-motor1CurrentTime) + " seconds.")
                    .setPosition(xOffsetLeft,yOffsetTop + 2*sliderHeight + 2*sliderHorizontalSpacing+2*textLabelRowSpacing)
                    .setColorValue(color(0,0,0))
                    .setFont(createFont("Arial",15))
                    ;                   

  motor2CurrentParametersTextLabel1 = cp5.addTextlabel("motor2Label1")
                    .setText("Speed: " + motor2CurrentSpeed)
                    .setPosition(windowSizeWidth/2+xOffsetRight,yOffsetTop + 2*sliderHeight + 2*sliderHorizontalSpacing)
                    .setColorValue(color(0,0,0))
                    .setFont(createFont("Arial",15))
                    ;
                    
  motor2CurrentParametersTextLabel2 = cp5.addTextlabel("motor2Label2")
                    .setText( "Direction: " + getCurrentDirection(motor2Direction))
                    .setPosition(windowSizeWidth/2+xOffsetRight, yOffsetTop + 2*sliderHeight + 2*sliderHorizontalSpacing+textLabelRowSpacing)
                    .setColorValue(color(0,0,0))
                    .setFont(createFont("Arial",15))
                    ;                  
                    
                    
  motor2CurrentParametersTextLabel3 = cp5.addTextlabel("motor2Label3")
                    .setText( "Time until max or min: " + (motor2Time-motor2CurrentTime) + " seconds.")
                    .setPosition(windowSizeWidth/2+xOffsetRight, yOffsetTop + 2*sliderHeight + 2*sliderHorizontalSpacing+2*textLabelRowSpacing)
                    .setColorValue(color(0,0,0))
                    .setFont(createFont("Arial",15))
                    ;
  noStroke();
  
}

void draw() {
//debug start
motor1CurrentSpeed = motor1MaxSpeed;
motor2CurrentSpeed = motor2MaxSpeed;
//debug end
updateScreen();
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
motor1CurrentParametersTextLabel3.setText( "Time until max or min: " + (motor1Time-motor1CurrentTime) + " seconds.");
motor2CurrentParametersTextLabel1.setText("Speed: " + motor2CurrentSpeed);
motor2CurrentParametersTextLabel2.setText( "Direction: " + getCurrentDirection(motor2Direction));
motor2CurrentParametersTextLabel3.setText( "Time until max or min: " + (motor2Time-motor2CurrentTime) + " seconds.");


}

//Controller events listeners
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




