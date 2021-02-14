// Bounce.pde
// -*- mode: C++ -*-
//
// Make a single stepper bounce from one limit to another
//
// Copyright (C) 2012 Mike McCauley
// $Id: Random.pde,v 1.1 2011/01/05 01:51:01 mikem Exp mikem $

#include <AccelStepper.h>
#define EN_PIN 8
#define DIR_PIN_M1 0
#define STEP_PIN_M1 1
#define DIR_PIN_M2 2
#define STEP_PIN_M2 3
#define DIR_PIN_M3 4
#define STEP_PIN_M3 5
#define DIR_PIN_M4 6
#define STEP_PIN_M4 7
// Define a stepper and the pins it will use
AccelStepper stepper1 = AccelStepper(stepper1.DRIVER, STEP_PIN_M1, DIR_PIN_M1);
AccelStepper stepper2 = AccelStepper(stepper2.DRIVER, STEP_PIN_M2, DIR_PIN_M2);
AccelStepper stepper3 = AccelStepper(stepper3.DRIVER, STEP_PIN_M3, DIR_PIN_M3);

void setup()
{  
  // Change these to suit your stepper if you want
  stepper1.setMaxSpeed(1000);
  stepper1.setSpeed(5);
  stepper2.setMaxSpeed(1000);
  stepper2.setSpeed(100);
  stepper3.setMaxSpeed(1000);
  stepper3.setSpeed(250);

}

void loop()
{

    stepper1.runSpeed();
    stepper2.runSpeed();
    stepper3.runSpeed();

}
