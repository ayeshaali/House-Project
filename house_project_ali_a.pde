/* Program: My House Project
 Author: Ayesha Ali
 Date: 10/28/16 */

import processing.serial.*;
import cc.arduino.*;
Arduino arduino;

//balloon coordinates
int ballX =0;
int ballY = 400;

//cloud coordinates
float cloudX = 650;
float deltaC = 0;

//light sensor for windows
float light;
float lightDelta;

//snow array
float p =0;
float[] snowX = new float[500];
float[] snowY = new float[500];
float[] xMove = new float[500];
float[] yMove = new float[500];

//sun and moon
float slider;
float sunX = 0;
float sunY;
float moonX = 0;
float moonY;
float alpha = 0;

//stars' random location and width
float starX[] = new float[100];
float starY[] = new float[100];
float starW[] = new float[100];

//ufo coordinates
float ufoX = 20;
int deltaX= 0;

void setup() {
  colorMode(RGB);
  size(700, 600);
  //random star formation
  for (int i = 0; i<50; i++) {
    starX[i] = random(0, width);
    starY[i] = random(0, height);
    starW[i] = random(1, 6);
  } 
  //random snow formation
  for (int i = 0; i < 500; i++) {
    snowX[i] = random(width);
    snowY[i] = random(height);
    yMove[i] = random(1, 3);
  }
  //arduino pinmodes
  println(Arduino.list());
  arduino = new Arduino(this, Arduino.list()[2], 57600);
  arduino.pinMode(12, Arduino.INPUT);
  arduino.pinMode(2, Arduino.INPUT);
}

void draw() {
  sky();
  sunAndMoon();
  snow();
  ufo();
  balloon();
  cloud();
  ground();
  house();
  snow();
  picture();
}

//---------------------------------------------------------------------------------------------------------
//alphabetical order

void balloon() {
  //string
  stroke(0, 0, 0);
  strokeWeight(3);
  line(ballX, ballY, ballX, ballY+80);

  //balloon
  strokeWeight(0);
  fill(255, 0, 0);
  ellipse(ballX, ballY, 50, 60);
  
  //non-linear movement
  if (ballX<800)
    ballX+=2;
  if (ballY>50)
    ballY--;
}

void cloud() {
  //microphone used to stimulate wind
  deltaC = arduino.analogRead(2)/5;
  cloudX= cloudX - deltaC;

  //cloud
  fill(255);
  ellipse(cloudX-40, 90, 70, 70);
  ellipse(cloudX+40, 90, 70, 70);
  ellipse(cloudX, 70, 100, 100);
}

void ground() {
  fill(113, 200, 55);
  rect(0, 400, 800, 250);
}

void house() {
  //brown rect
  fill(120, 68, 33);
  rect(100, 300, 250, 300);

  //roof
  fill(170, 0, 0);
  triangle(80, 300, 225, 125, 370, 300);

  //windows
  light = arduino.analogRead(1)/4;
  lightDelta = 125 - light;
  light=125+lightDelta;
  fill(light, light, light);
  stroke(0, 0, 255);
  strokeWeight(5);
  rect(135, 350, 75, 75);
  rect(240, 350, 75, 75);

  //door
  fill(31, 96, 51);
  stroke(0);
  strokeWeight(1);
  rect(185, 470, 80, 150);

  //knob
  fill(240, 201, 41);
  ellipse(200, 535, 15, 15);

  //window panes
  strokeWeight(3);
  line(173, 350, 173, 425);
  line(135, 387, 210, 387);
  line(277, 350, 277, 425);
  line(240, 387, 312, 387);

  //tree
  strokeWeight(1);
  fill(111, 75, 7);
  rect(500, 250, 50, 400);
  fill(0, 255, 102);
  ellipse(525, 250, 200, 200);
  
  //fence
  for (int i = 80; i<370; i+=20) {
    fill(90, 80, 7);
    rect(i, 530, 20, 70);
  }
}

void picture() {
  fill(255);
  rect(137, 353, 35, 32);
  
  //scales and moves a small image of the house
  scale(0.060);
  translate(2250, 5770);
  house();
}

void sky() {
  fill(51, 199, 250);
  rect(0, 0, 800, 400);
}

void snow() {
  p++; //controls how often it snows
  noStroke();
  if (p>500 && p<1000) {
    fill(255);
    for (int i = 0; i < 500; i++) {
      //formation of snowflake and movement across the screen
      ellipse(snowX[i], snowY[i], 6, 6);
      snowX[i] +=xMove[i];
      snowY[i] +=yMove[i];

      //since snow doesn't fall straight down, by adding this you can make the snow drift
      snowX[i] += random(-5, 1);

      //once the snowflakes hit the bottom they'll return back to the top
      if (snowY[i] > height) {
        snowY[i] = 0;
      }
      if (snowX[i] < 0) {
        snowX[i] = width;
      }
    }
  }
  else if (p>2000)
    p=0; //once p reaches 2000, p resets so that it can snow again
 
}

void sunAndMoon() {
  //changing from day to night
  if  (sunX>670 && sunX<1369) {
    //(slider+1) increases opacity of black rectangle behind the sky to turn to night
    fill(0, 0, 0, alpha+=(slider+1)); 
    rect(0, 0, 800, 400);
  } else if (moonX>667 || sunX>0 && sunX<150) {
    //(slider+30) decreases opacity of black rectangle behind the sky to turn to day
    fill(0, 0, 0, alpha-=(slider+30));
    rect(0, 0, 800, 400);
  } else
    alpha=0;

  //creation of sun and animation speed
  //slider here in both the moon and sun changes the speed of their movements
  slider = arduino.analogRead(3)/100;
  sunX += 1+slider;
  sunY = 390-300*sin(sunX/210);
  fill(240, 201, 41);
  noStroke();
  ellipse(sunX, sunY, 100, 100);

  //star formation during the night
  if (moonX>0 && moonX<650) {
    for (int i = 0; i<100; i++) {
      fill(255);
      ellipse(starX[i], starY[i], starW[i], starW[i]);
    }
  }

  //moon formation
  if (sunX>700) {
    fill(225);
    moonX += 1+slider;
    moonY = 390-300*sin(moonX/210);
    ellipse(moonX, moonY, 100, 100);
  } else {
    moonX= 0;
    moonY =200;
  }

  //causes sun to go back to the beginning when moon passes off screen
  if (moonX>700) {
    sunX = 0;
    sunY= 200;
  }
}

void ufo() {
  //ufo
  if (arduino.digitalRead(12)==arduino.HIGH) { // Button is pressed
    if (arduino.digitalRead(2)==arduino.HIGH) { //  Switch is ON -->
      deltaX = 1; //changes direction
    } else
      deltaX = -1; //changes direction
    ufoX = ufoX+deltaX; 
  }

  fill(150);
  ellipse(ufoX+20, 90, 30, 40);
  fill(100, 0, 50);
  ellipse(ufoX+20, 100, 70, 20);
}