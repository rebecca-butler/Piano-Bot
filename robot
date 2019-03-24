const int SIZE = 64, yAngle = -20, BARRIER = 10, SKIP = 5;
          keyC = 15, keyD = 4, keyE = -4, keyF = -16,
          keyG = -28, keyA = -37, keyB = -50;
// The value of each ‘key’ constant is its corresponding motor encoder count.
const float LENGTH = 1.85, RADIUS = 5.5;

int distance()
{
   int colorNumber = 0;
   while(!getButtonPress(buttonEnter))
   {
      // The user sets the number of coloured notes
      displayBigTextLine(5, "Number of notes");
      displayBigTextLine(7, "     < %d >", colorNumber);
      wait1Msec(150);
      if ((colorNumber > 0) && (colorNumber <= SIZE) && 
      getButtonPress(buttonLeft))
         colorNumber--;
      else if ((colorNumber >= 0) && (colorNumber < SIZE) && 
      getButtonPress(buttonRight))
         colorNumber++;
      // The following allows the user to set higher values conveniently by 
         incrementing by a larger number
      else if ((colorNumber >= SKIP) && (colorNumber <= SIZE) && 
      getButtonPress(buttonDown))
         colorNumber -= SKIP;
      else if ((colorNumber >= 0) && (colorNumber <= (SIZE-SKIP)) && 
      getButtonPress(buttonUp))
         colorNumber += SKIP;
   }
   return colorNumber;
}

void readColor(int numColor, int *colorCount)
{
   nMotorEncoder[motorA] = 0;
   nMotorEncoder[motorD] = 0;
   wait1Msec(50);
   // The following sets the maximum encoder count with the user’s input value
   while (nMotorEncoder[motorA] < (numColor * LENGTH * 360 / RADIUS / PI))
   {
      displayBigTextLine(7, "Let's read!");
      for (int colorIndex = 0; colorIndex < numColor; colorIndex++)
      {
         // The robot will begin reading before the first colour note
         while (nMotorEncoder[motorA] < ((colorIndex + 1) * LENGTH * 360 / RADIUS 
         / PI))
         {
            // The robot will stop moving when there’s an obstacle in front of it
            if (SensorValue[S3] > BARRIER)
               motor[motorA] = motor[motorD] = 5;
            else
               motor[motorA] = motor[motorD] = 0;
         }
         displayBigTextLine(9, "%d", SensorValue[S1]);
         colorCount[colorIndex] = SensorValue[S1];
      }
   }
   motor[motorA] = motor[motorD] = 0;
}

void checkPhone()
{
   eraseDisplay();
   // If phone is not placed, the display asks the user to place the phone.
   while (!SensorValue[S2])
   {
      displayBigTextLine(7, "Please place");
      displayBigTextLine(9, "your phone.");
   }
   eraseDisplay();
}

void armY()
{
   // The arm moves down to hit the phone
   wait1Msec(200);
   while (nMotorEncoder[motorC] > yAngle)
      motor[motorC] = -20;
   motor[motorC] = 0;
   wait1Msec(300);
   // The arm moves back up to its original position
   while (nMotorEncoder[motorC] < 0)
      motor[motorC] = 20;
   motor[motorC] = 0;
}

void arm(int musicKey)
{
   // The musicKey corresponds to the motor encoder count for a specific musical 
      note relative to the initial position of the arm.
   // The motor will rotate from its current motor encoder count in the direction 
      to the motor encoder count of the next note.
   if (nMotorEncoder[motorB] > musicKey)
   {
      while (nMotorEncoder[motorB] > musicKey)
         motor[motorB] = -50;
   }
   else
   {
      while (nMotorEncoder[motorB] < musicKey)
         motor[motorB] = 50;
   }
   motor[motorB] = 0;
   armY();
}

int musicPlay(int numColor, int *colorCount)
{
   time1[T1] = 0;
   for (int colorDis = 0; colorDis < numColor; colorDis++)
   {
      // Each colour detected corresponds to their own motor encoder count, and 
         runs the function arm() above.
      displayBigTextLine(7, "Now playing!");
      if (colorCount[colorDis] == 2)
         arm(keyC);
      else if (colorCount[colorDis] == 4)
         arm(keyD);
      else if (colorCount[colorDis] == 5)
         arm(keyE);
      else if (colorCount[colorDis] == 6)
         arm(keyF);
      else if (colorCount[colorDis] == 7)
         arm(keyG);
      else if (colorCount[colorDis] == 1)
         arm(keyA);
      else if (colorCount[colorDis] == 3)
         arm(keyB);
      else
         wait1Msec(500);
	wait1Msec(100);
	checkPhone();
   }
   // Records the duration of song when it has completed.
   return time1[T1];
}

void resetPosition()
{
   // The arm returns to its original position, where the motor encoder count is 
      0 after the song is played.
   if (nMotorEncoder[motorB] > 0)
   {
      while (nMotorEncoder[motorB] > 0)
         motor[motorB] = -10;
   }
   else
   {
      while (nMotorEncoder[motorB] < 0)
         motor[motorB] = 10;
   }
   motor[motorB] = 0;
}

bool playAgain()
{
   displayBigTextLine(7, "Do you want");
   displayBigTextLine(9, "to play again?");
   displayBigTextLine(11, "< Yes      No >");+
   while (!getButtonPress(buttonRight))
   {
      if (getButtonPress(buttonLeft))
         return true;
   }
   return false;
}

task main()
{
   SensorType[S1] = sensorEV3_Color;
   wait1Msec(50);
   SensorMode[S1] = modeEV3Color_Color;
   SensorType[S2] = sensorEV3_Touch;
   SensorType[S3] = sensorEV3_Ultrasonic;
   bool toPlay = true;
   int numColor = 0, timePlay = 0;

   while (toPlay)
   {
      numColor = distance();

      int colorCount[SIZE];
      for (int index = 0; index < SIZE; index++)
         colorCount[index] = 0;

      readColor(numColor, colorCount);

      displayBigTextLine(7, "Score read!");
      displayBigTextLine(9, "Let's play!");
      wait1Msec(2000);

      checkPhone();

      displayBigTextLine(7, "Now playing!");
      wait1Msec(1000);

      nMotorEncoder[motorB] = 0;
      nMotorEncoder[motorC] = 0;

      timePlay = musicPlay(numColor, colorCount);

      resetPosition();

      displayBigTextLine(7, "Song's over!");
      displayBigTextLine(9, "Song is:");
      displayBigTextLine(11, "%.1f seconds", timePlay/1000);
      wait1Msec(3000);

      toPlay = playAgain();

      eraseDisplay();
   }

   eraseDisplay();
   displayBigTextLine(7, "Shutting Down");
   wait1Msec(3000);
}
