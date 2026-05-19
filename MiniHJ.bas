'--------------------------------------
' Mini HexJump Platformer
' For PicoCalc (05-2026) by SaharaHex
'--------------------------------------
Option Base 1
FONT 2
CLS

'--------------------------------------
' Player state
Dim px, py          ' Position
Dim prevPX, prevPY  ' Previous Position
Dim vx, vy          ' Velocity
Dim onGround        ' Grounded flag
Dim lives           ' Player lives
Dim score           ' Player score
Dim hiscore         ' Your high score
Dim currentLevel    ' Game level
Dim hasMovingE      ' Are there moving Enemies
Dim hasMovingP      ' Are there moving Platforms
Dim hasRain         ' Is level rain mode
Dim hasPatrol       ' Are there moving Enemies Patrols

'--------------------------------------
' World
groundY = 240
Const MAX_LEVELS = 10
Const MAX_PLATFORMS = 5

Dim platX(MAX_PLATFORMS)
Dim platY(MAX_PLATFORMS)
Dim platW(MAX_PLATFORMS)
Dim platH(MAX_PLATFORMS)
' Moving platform
Dim platVX(MAX_PLATFORMS)
Dim platVY(MAX_PLATFORMS)
Dim prevPlatX(MAX_PLATFORMS)
Dim prevPlatY(MAX_PLATFORMS)

Const MAX_ENEMIES = 5

Dim enemyX(MAX_ENEMIES)
Dim enemyY(MAX_ENEMIES)
Dim enemyW(MAX_ENEMIES)
Dim enemyH(MAX_ENEMIES)
' Moving enemies
Dim enemyVX(MAX_ENEMIES)
Dim enemyVY(MAX_ENEMIES)
Dim prevEnemyX(MAX_ENEMIES)
Dim prevEnemyY(MAX_ENEMIES)
Dim patrolLeft(MAX_ENEMIES)
Dim patrolRight(MAX_ENEMIES)

Dim rainX(40)
Dim rainY(40)

' Teleporters
Dim teleX1, teleY1, teleX2, teleY2, teleW, teleH

' Exit goal
Dim exitX, exitY, exitW, exitH

gravity = 0.4
moveSpeed = 2
jumpStrength = -7

lives = 10
score = 0
hiscore = 0
fileName$  = "MiniHJ.txt"
currentLevel = 1
currentLevelText$ = "Get to White Square" ' Level message 

readData
ShowIntro

'--------------------------------------
' Intro Screen
Sub ShowIntro
  CLS
  'text x,y,"string",align,font,scl,c,bc
  Text 80,20,"A Micro Platformer",,4,1,RGB(115, 43, 245), 2 'purple
  Text 10,40,"------------------------------",,4,1,RGB(126, 132, 247), 2 'light purple
  Text 50,60,"(05-2026) by SaharaHex",,4,1,RGB(126, 132, 247), 2 'light purple
  Text 20,80,"Mini HexJump",,5,1,RGB(115, 43, 245), 2 'purple
  Text 40,110,"Platformer",,5,1,RGB(115, 43, 245), 2 'purple
  Text 50,140,"(for PicoCalc)",,3,1,RGB(126, 132, 247), 2 'light purple
  TEXT 20, 180, "M for Restart. X for Exit", , 4, , RGB(126, 132, 247), 2
  TEXT 20, 200, "Controls : to move use", , 4, , RGB(126, 132, 247), 2
  TEXT 20, 220, "R : Jump Left", , 4, , RGB(115, 43, 245), 2
  TEXT 100, 240, "T : Jump Up", , 4, , RGB(115, 43, 245), 2
  TEXT 165, 220, "Y : Jump Right", , 4, , RGB(115, 43, 245), 2
  TEXT 20, 260, "F : Move Left", , 4, , RGB(115, 43, 245), 2
  TEXT 165, 260, "H : Move Right", , 4, , RGB(115, 43, 245), 2
  TEXT 100, 280, "L : Skip level", , 4, , RGB(115, 43, 245), 2
  TEXT 10, 300, "------------------------------", , 4, , RGB(126, 132, 247), 2
  PAUSE 3000
  Do
    k$=Inkey$
  Loop Until k$<>""
END Sub

'--------------------------------------
' Draw screen border (static)
Sub DrawInterface
  LINE 10,25,300,25,7,RGB(26, 70, 83)   ' Top
  LINE 10,25,10,270,7,RGB(26, 70, 83)   ' Left
  LINE 300,25,300,270,7,RGB(26, 70, 83) ' Right
  LINE 10,270,306,270,7,RGB(26, 70, 83) ' Bottom
  TEXT 11, 285, "R : Jump Left", , 7, , RGB(126, 132, 247), 2
  TEXT 11, 295, "T : Jump Up", , 7, , RGB(126, 132, 247), 2
  TEXT 11, 305, "Y : Jump Right", , 7, , RGB(126, 132, 247), 2
  TEXT 110, 285, "F : Move Left", , 7, , RGB(126, 132, 247), 2
  TEXT 110, 295, "H : Move Right", , 7, , RGB(126, 132, 247), 2
  TEXT 110, 305, "High Score: " + STR$(hiscore), , 7, , RGB(115, 43, 245), 2
  TEXT 210, 285, "M : Restart", , 7, , RGB(126, 132, 247), 2
  TEXT 210, 295, "L : Skip level", , 7, , RGB(126, 132, 247), 2
  TEXT 210, 305, "X : Exit", , 7, , RGB(126, 132, 247), 2
END Sub

'--------------------------------------
' Draw level base on value (currentLevel)
Sub LoadLevel(level)
  ' Clear arrays
  For i = 1 To MAX_PLATFORMS
    platW(i) = 0
  Next
  For i = 1 To MAX_ENEMIES
    enemyW(i) = 0
  Next

  Select Case level

    '--------------------------------------
    ' LEVEL 1
    '--------------------------------------
    Case 1
      px = 40 : py = 100

      ' Platforms - Level one
      platX(1) = 80 : platY(1) = 180 : platW(1) = 120 : platH(1) = 10
      platX(2) = 40 : platY(2) = 130 : platW(2) = 80  : platH(2) = 10
      platX(3) = 160: platY(3) = 90  : platW(3) = 100 : platH(3) = 10
      platX(4) = 250: platY(4) = 200 : platW(4) = 35  : platH(4) = 10
      platX(5) = 250: platY(5) = 150 : platW(5) = 35  : platH(5) = 10

      ' Enemies (triangles) - Level one
      enemyX(1) = 120 : enemyY(1) = 210 : enemyW(1) = 10 : enemyH(1) = 10
      enemyX(2) = 60  : enemyY(2) = 160 : enemyW(2) = 10 : enemyH(2) = 10
      enemyX(3) = 200 : enemyY(3) = 130 : enemyW(3) = 10 : enemyH(3) = 10
      enemyX(4) = 250 : enemyY(4) = 180 : enemyW(4) = 10 : enemyH(4) = 10
      enemyX(5) = 149 : enemyY(5) = 100 : enemyW(5) = 10 : enemyH(5) = 10

      ' Movement flags 0 no : 1 yes
      hasMovingE = 0    ' enemies
      hasMovingP = 0    ' platforms
      hasRain = 0       ' rain affect 
      hasPatrol = 0     ' enemies patrol      
      'Level Message
      currentLevelText$ = "Get to White Square"

      ' Exit
      exitX = 230 : exitY = 60 : exitW = 20 : exitH = 20

    '--------------------------------------
    ' LEVEL 2
    '--------------------------------------
    Case 2
      px = 30 : py = 220

      ' Platforms - Level two
      platX(1) = 50 : platY(1) = 200 : platW(1) = 80 : platH(1) = 10
      platX(2) = 150: platY(2) = 160 : platW(2) = 100: platH(2) = 10
      platX(3) = 40 : platY(3) = 120 : platW(3) = 60 : platH(3) = 10
      platX(4) = 200: platY(4) = 90  : platW(4) = 80 : platH(4) = 10
      platX(5) = 120: platY(5) = 100  : platW(5) = 60 : platH(5) = 10

      ' Enemies (triangles) - Level two
      enemyX(1) = 100 : enemyY(1) = 199 : enemyW(1) = 12 : enemyH(1) = 12
      enemyX(2) = 200 : enemyY(2) = 159 : enemyW(2) = 12 : enemyH(2) = 12
      enemyX(3) = 60  : enemyY(3) = 119 : enemyW(3) = 12 : enemyH(3) = 12
      enemyX(4) = 210 : enemyY(4) = 239 : enemyW(4) = 12 : enemyH(4) = 12
      enemyX(5) = 260 : enemyY(5) = 239 : enemyW(5) = 12 : enemyH(5) = 12

      ' Movement flags
      hasMovingE = 0
      hasMovingP = 0
      hasRain = 0
      hasPatrol = 0      
      'Level Message
      currentLevelText$ = "L2: Avoid enemies"

      ' Exit
      exitX = 260 : exitY = 50 : exitW = 20 : exitH = 20

    '--------------------------------------
    ' LEVEL 3 — Moving enemies
    '--------------------------------------
    Case 3
      px = 30 : py = 220

      ' Platforms
      platX(1) = 65 : platY(1) = 200 : platW(1) = 80 : platH(1) = 10
      platX(2) = 150: platY(2) = 160 : platW(2) = 100: platH(2) = 10
      platX(3) = 60 : platY(3) = 120 : platW(3) = 60 : platH(3) = 10
      platX(4) = 200: platY(4) = 200  : platW(4) = 80 : platH(4) = 10
      platX(5) = 21: platY(5) = 168  : platW(5) = 60 : platH(5) = 10

      ' Moving Enemies - Level three
      enemyX(1) = 60  : enemyY(1) = 190 : enemyW(1) = 12 : enemyH(1) = 12 : enemyVX(1) = 1 : enemyVY(1) = 0
      enemyX(2) = 180 : enemyY(2) = 150 : enemyW(2) = 12 : enemyH(2) = 12 : enemyVX(2) = -1 : enemyVY(2) = 0
      enemyX(3) = 100 : enemyY(3) = 110 : enemyW(3) = 12 : enemyH(3) = 12 : enemyVX(3) = 1 : enemyVY(3) = 0

      ' Clear unused enemies
      For i = 4 To MAX_ENEMIES
        enemyW(i) = 0
      Next 

      ' Movement flags
      hasMovingE = 1
      hasMovingP = 0
      hasRain = 0
      hasPatrol = 0      
      'Level Message
      currentLevelText$ = "L3: Moving enemies"

      ' Exit
      exitX = 130 : exitY = 60 : exitW = 20 : exitH = 20

    '--------------------------------------
    ' LEVEL 4 — Exit in the middle
    '--------------------------------------
    Case 4
      px = 30 : py = 100

      ' Platforms (balanced layout around the centre)
      platX(1) = 50  : platY(1) = 200 : platW(1) = 60  : platH(1) = 10
      platX(2) = 180 : platY(2) = 200 : platW(2) = 80  : platH(2) = 10
      platX(3) = 100 : platY(3) = 150 : platW(3) = 100 : platH(3) = 10
      platX(4) = 60  : platY(4) = 100 : platW(4) = 60  : platH(4) = 10
      platX(5) = 180 : platY(5) = 100 : platW(5) = 60  : platH(5) = 10

      ' Enemies (static triangles guarding the centre) - Level four
      enemyX(1) = 110 : enemyY(1) = 190 : enemyW(1) = 12 : enemyH(1) = 12
      enemyX(2) = 190 : enemyY(2) = 190 : enemyW(2) = 12 : enemyH(2) = 12
      enemyX(3) = 140 : enemyY(3) = 140 : enemyW(3) = 12 : enemyH(3) = 12
      enemyX(4) = 90  : enemyY(4) = 90  : enemyW(4) = 12 : enemyH(4) = 12
      enemyX(5) = 210 : enemyY(5) = 90  : enemyW(5) = 12 : enemyH(5) = 12

      ' Movement flags
      hasMovingE = 0
      hasMovingP = 0
      hasRain = 0
      hasPatrol = 0    
      ' Level message
      currentLevelText$ = "L4: Centre exit"

      ' Exit (centre of the map)
      exitX = 140 : exitY = 50 : exitW = 20 : exitH = 20

    '--------------------------------------
    ' LEVEL 5 — Moving Platforms
    '--------------------------------------
    Case 5
      px = 30 : py = 220

      ' Platforms (some static, some moving)
      platX(1) = 40  : platY(1) = 200 : platW(1) = 80 : platH(1) = 10 : platVX(1) = 1 : platVY(1) = 0
      platX(2) = 160 : platY(2) = 200 : platW(2) = 80 : platH(2) = 10 : platVX(2) = -1 : platVY(2) = 0
      platX(3) = 100 : platY(3) = 150 : platW(3) = 100 : platH(3) = 10 : platVX(3) = 0 : platVY(3) = 0  ' static
      platX(4) = 60  : platY(4) = 110 : platW(4) = 60  : platH(4) = 10 : platVX(4) = 1 : platVY(4) = 0
      platX(5) = 180 : platY(5) = 110 : platW(5) = 60  : platH(5) = 10 : platVX(5) = -1 : platVY(5) = 0

      ' Single enemy (triangle) - Level five
      enemyX(1) = 200 : enemyY(1) = 140 : enemyW(1) = 12 : enemyH(1) = 12 : enemyVX(1) = -1 : enemyVY(1) = 0

      ' Clear unused enemies
      For i = 2 To MAX_ENEMIES
        enemyW(i) = 0
      Next      

      ' Movement flags
      hasMovingE = 1
      hasMovingP = 1
      hasRain = 0
      hasPatrol = 0    
      ' Level message
      currentLevelText$ = "L5: Moving platforms"

      ' Exit in the middle-top
      exitX = 140 : exitY = 60 : exitW = 20 : exitH = 20

    '--------------------------------------
    ' LEVEL 6 — Moving Enemy + Moving Platform (H + V)
    '--------------------------------------
    Case 6
      px = 30 : py = 220

      ' Platforms (one static, one moving horizontally + vertically)
      platX(1) = 60  : platY(1) = 200 : platW(1) = 80 : platH(1) = 10 : platVX(1) = 1  : platVY(1) = 0
      platX(2) = 160 : platY(2) = 150 : platW(2) = 80 : platH(2) = 10 : platVX(2) = 0  : platVY(2) = 1
      platX(3) = 100 : platY(3) = 100 : platW(3) = 100 : platH(3) = 10 : platVX(3) = 1 : platVY(3) = 1
      platX(4) = 40  : platY(4) = 60  : platW(4) = 60 : platH(4) = 10 : platVX(4) = 0 : platVY(4) = 0
      platX(5) = 200 : platY(5) = 60  : platW(5) = 60 : platH(5) = 10 : platVX(5) = 0 : platVY(5) = 0

      ' Enemy that moves horizontally + vertically - Level six
      enemyX(1) = 140 : enemyY(1) = 180 : enemyW(1) = 12 : enemyH(1) = 12
      enemyVX(1) = 1
      enemyVY(1) = 1

      ' Clear unused enemies
      For i = 2 To MAX_ENEMIES
        enemyW(i) = 0
      Next

      ' Movement flags
      hasMovingE = 1
      hasMovingP = 1
      hasRain = 0
      hasPatrol = 0  
      ' Level message
      currentLevelText$ = "L6: H+V movement"

      ' Exit in the centre-top
      exitX = 140 : exitY = 40 : exitW = 20 : exitH = 20

    '--------------------------------------
    ' LEVEL 7 — Elevator Platforms
    '--------------------------------------
    Case 7
      px = 30 : py = 220

      ' Elevator platforms (vertical movement)
      platX(1) = 60  : platY(1) = 210 : platW(1) = 80 : platH(1) = 10 : platVX(1) = 0  : platVY(1) = -1
      platX(2) = 160 : platY(2) = 210 : platW(2) = 80 : platH(2) = 10 : platVX(2) = 0  : platVY(2) = -1

      ' Mid level static platform
      platX(3) = 100 : platY(3) = 150 : platW(3) = 100 : platH(3) = 10 : platVX(3) = 0 : platVY(3) = 0

      ' Top elevator platforms (move downward)
      platX(4) = 60  : platY(4) = 90  : platW(4) = 60 : platH(4) = 10 : platVX(4) = 0 : platVY(4) = 1
      platX(5) = 180 : platY(5) = 90  : platW(5) = 60 : platH(5) = 10 : platVX(5) = 0 : platVY(5) = 1

      ' Two enemy riding the middle section - Level seven
      enemyX(1) = 140 : enemyY(1) = 135 : enemyW(1) = 12 : enemyH(1) = 12 : enemyVX(1) = 1: enemyVY(1) = 0
      enemyX(2) = 50 : enemyY(2) = 180 : enemyW(2) = 12 : enemyH(2) = 12 : enemyVX(2) = 1: enemyVY(2) = 0

      ' Clear unused enemies
      For i = 3 To MAX_ENEMIES
        enemyW(i) = 0
      Next

      ' Movement flags
      hasMovingE = 1
      hasMovingP = 1
      hasRain = 0
      hasPatrol = 0
      ' Level message
      currentLevelText$ = "L7: Elevator platforms"

      ' Exit at the top centre
      exitX = 140 : exitY = 40 : exitW = 20 : exitH = 20

    '--------------------------------------
    ' LEVEL 8 — Rain Mode
    '--------------------------------------
    Case 8
      px = 30 : py = 220

      ' Platforms (simple layout)
      platX(1) = 60  : platY(1) = 200 : platW(1) = 80 : platH(1) = 10
      platX(2) = 160 : platY(2) = 160 : platW(2) = 80 : platH(2) = 10
      platX(3) = 100 : platY(3) = 120 : platW(3) = 100 : platH(3) = 10
      platX(4) = 60  : platY(4) = 80  : platW(4) = 60 : platH(4) = 10
      platX(5) = 180 : platY(5) = 80  : platW(5) = 60 : platH(5) = 10

      ' One enemy - Level eight
      enemyX(1) = 140 : enemyY(1) = 150 : enemyW(1) = 12 : enemyH(1) = 12
      enemyVX(1) = 1 : enemyVY(1) = 0

      For i = 2 To MAX_ENEMIES
        enemyW(i) = 0
      Next

      ' Movement flags
      hasMovingE = 1
      hasMovingP = 0
      hasRain = 1
      hasPatrol = 0
      ' Level message
      currentLevelText$ = "L8: Rain Storm"

      exitX = 140 : exitY = 40 : exitW = 20 : exitH = 20

    '--------------------------------------
    ' LEVEL 9 — Enemy Patrol Zones
    '--------------------------------------
    Case 9
      px = 30 : py = 220

      ' Platforms
      platX(1) = 60  : platY(1) = 200 : platW(1) = 80 : platH(1) = 10
      platX(2) = 160 : platY(2) = 160 : platW(2) = 80 : platH(2) = 10
      platX(3) = 100 : platY(3) = 120 : platW(3) = 100 : platH(3) = 10
      platX(4) = 60  : platY(4) = 80  : platW(4) = 60 : platH(4) = 10
      platX(5) = 180 : platY(5) = 80  : platW(5) = 60 : platH(5) = 10

      ' Enemy patrols - Level nine
      enemyX(1) = 80  : enemyY(1) = 190 : enemyW(1) = 12 : enemyH(1) = 12
      enemyVX(1) = 1
      patrolLeft(1) = 60
      patrolRight(1) = 140

      enemyX(2) = 200 : enemyY(2) = 150 : enemyW(2) = 12 : enemyH(2) = 12
      enemyVX(2) = -1
      patrolLeft(2) = 150
      patrolRight(2) = 230

      ' Clear unused enemies
      For i = 3 To MAX_ENEMIES
        enemyW(i) = 0
      Next

      ' Movement flags
      hasMovingE = 1
      hasMovingP = 0
      hasRain = 0
      hasPatrol = 1
      ' Level message
      currentLevelText$ = "L9: Patrol Zones"

      exitX = 140 : exitY = 40 : exitW = 20 : exitH = 20

    '--------------------------------------
    ' LEVEL 10 — Teleporters
    '--------------------------------------
    Case 10
      px = 30 : py = 220

      ' Platforms
      platX(1) = 200  : platY(1) = 200 : platW(1) = 40 : platH(1) = 10
      platX(2) = 160 : platY(2) = 160 : platW(2) = 80 : platH(2) = 10
      platX(3) = 60  : platY(3) = 140 : platW(3) = 100 : platH(3) = 10
      platX(4) = 170 : platY(4) = 70 : platW(4) = 50 : platH(4) = 10
      platX(5) = 235 : platY(5) = 90 : platW(5) = 60 : platH(5) = 10

      ' Enemy patrols & teleport - Level ten
      enemyX(1) = 200  : enemyY(1) = 185 : enemyW(1) = 12 : enemyH(1) = 12
      enemyVX(1) = 1
      patrolLeft(1) = 150
      patrolRight(1) = 230

      enemyX(2) = 200 : enemyY(2) = 225 : enemyW(2) = 12 : enemyH(2) = 12
      enemyVX(2) = -1
      patrolLeft(2) = 150
      patrolRight(2) = 270

      enemyX(3) = 140 : enemyY(3) = 75 : enemyW(3) = 12 : enemyH(3) = 12
      enemyVX(3) = -1
      patrolLeft(3) = 50
      patrolRight(3) = 150

      enemyX(4) = 60 : enemyY(4) = 125 : enemyW(4) = 12 : enemyH(4) = 12
      enemyVX(4) = -1
      patrolLeft(4) = 40
      patrolRight(4) = 140

      ' Clear unused enemies
      For i = 5 To MAX_ENEMIES
        enemyW(i) = 0
      Next

      ' Teleporters (two linked pads)
      teleX1 = 25  : teleY1 = 100 : teleW = 20 : teleH = 10
      teleX2 = 275 : teleY2 = 50

      ' Movement flags
      hasMovingE = 1
      hasMovingP = 0
      hasRain = 0
      hasPatrol = 1
      ' Level message
      currentLevelText$ = "L10: Teleporters"

      exitX = 140 : exitY = 40 : exitW = 20 : exitH = 20

  End Select
END Sub

'--------------------------------------
Sub ResetGame
  px = 40
  py = 100
  prevPX = 0
  prevPY = 0
  vx = 0
  vy = 0
  onGround = 0
  gameOver = 0

  LoadLevel currentLevel

  For i = 1 To 40
    rainX(i) = Rnd * 275 + 20     ' inside left/right border
    rainY(i) = Rnd * 200 + 40     ' inside top border
  Next
END Sub

'--------------------------------------
Sub DrawWorld
  ' Ground
  Line 20, groundY, 296, groundY, 2, RGB(255,255,255)

  ' Platform
  For i = 1 To MAX_PLATFORMS
      If hasMovingP = 1 Then
        Box prevPlatX(i), prevPlatY(i), platW(i), platH(i), 1, RGB(0,0,0)
      EndIf  
      If platW(i) > 0 Then
          Box platX(i), platY(i), platW(i), platH(i), 1, RGB(173,216,230)
      EndIf
  Next
  
  ' Enemies (triangles)
  For i = 1 To MAX_ENEMIES
      If enemyW(i) > 0 Then
          if hasMovingE = 1 Then
            ' Erase old triangle
            Line prevEnemyX(i), prevEnemyY(i), prevEnemyX(i)+enemyW(i), prevEnemyY(i), 1, RGB(0,0,0)
            Line prevEnemyX(i)+enemyW(i), prevEnemyY(i), prevEnemyX(i)+enemyW(i)/2, prevEnemyY(i)-enemyH(i), 1, RGB(0,0,0)
            Line prevEnemyX(i)+enemyW(i)/2, prevEnemyY(i)-enemyH(i), prevEnemyX(i), prevEnemyY(i), 1, RGB(0,0,0)
          EndIf

          ' Draw triangle enemy
          x1 = enemyX(i)
          y1 = enemyY(i)
          x2 = enemyX(i) + enemyW(i)
          y2 = enemyY(i)
          x3 = enemyX(i) + enemyW(i)/2
          y3 = enemyY(i) - enemyH(i)

          Line x1, y1, x2, y2, 1, RGB(255,0,0)
          Line x2, y2, x3, y3, 1, RGB(255,0,0)
          Line x3, y3, x1, y1, 1, RGB(255,0,0)
      EndIf
  Next

  ' Exit goal (white box)
  Box exitX, exitY, exitW, exitH, 1, RGB(255,255,255)

  TEXT 21, 255, currentLevelText$, , 7, , RGB(126, 132, 247), 2

  If hasRain = 1 Then
    For i = 1 To 40

      ' Erase old drop
      Line rainX(i), rainY(i)-6, rainX(i), rainY(i), 1, RGB(0,0,0)

      ' Draw new drop (only if inside borders)
      If rainY(i) >= 40 And rainY(i) <= groundY - 5 Then
        Line rainX(i), rainY(i), rainX(i), rainY(i)+5, 1, RGB(100,100,255)
      EndIf

    Next
  EndIf

  ' Teleporters
  If hasPatrol = 1 Then
    Box teleX1, teleY1, teleW, teleH, 1, RGB(255,0,255)   ' Pink pad
    Box teleX2, teleY2, teleW, teleH, 1, RGB(0,255,255)   ' Cyan pad
  EndIf

  ' Player
  TEXT prevPX, prevPY, " ",,2,,RGB(0, 0, 0), 2 ' Erase position
  Box px, py, 10, 10, 1, RGB(255,255,0)

END Sub

'--------------------------------------
' Draw the score
SUB DrawScore
  TEXT 10, 10, "Score: " + STR$(score) + " ", , 1, , RGB(115, 43, 245), 2
  TEXT 230, 10, "Lives: " + STR$(lives) + " ", , 1, , RGB(115, 43, 245), 2
END Sub

'--------------------------------------
' Platform collision logic 
Sub CheckPlatformCollision
  For i = 1 To MAX_PLATFORMS
    If platW(i) > 0 Then
      ' Horizontal overlap
      If px + 10 > platX(i) And px < platX(i) + platW(i) Then
        ' Vertical collision (landing on top)
        If py + 10 >= platY(i) And py + 10 <= platY(i) + 5 And vy > 0 Then
          py = platY(i) - 10
          vy = 0
          onGround = 1
        EndIf
      EndIf
    EndIf
  Next
END Sub

'--------------------------------------
' Enemy collision logic 
Sub CheckEnemyCollision
  For i = 1 To MAX_ENEMIES
    If enemyW(i) > 0 Then

      ' Simple bounding-box collision
      If px + 10 > enemyX(i) And px < enemyX(i) + enemyW(i) Then
        If py + 10 > enemyY(i) - enemyH(i) And py < enemyY(i) Then

          ' Player hit enemy
          lives = lives - 1
          score = score - 5

          ' Knockback effect
          vy = -4
          vx = -vx

          ' Sound effect on enemy hit 
          PlayHitSound

          ' Flash effect
          Box px, py, 10, 10, 1, RGB(255,0,0)
          Pause 80

          Exit Sub
        EndIf
      EndIf

    EndIf
  Next
End Sub

'--------------------------------------
' Has player reach exit 
Sub CheckExitCollision
  If px + 10 > exitX And px < exitX + exitW Then
    If py + 10 > exitY And py < exitY + exitH Then

      score = score + 100

      CLS   
      TEXT 20, 120, ">>     Level Complete!    <<", , 4, , RGB(114,188,212), 2
      TEXT 90, 150, "Score: " + STR$(score), , 2, , RGB(115, 43, 245), 2
      PlayLevelUpSound
      Pause 3000
      CLS 0
      DrawInterface

      currentLevel = currentLevel + 1

      If currentLevel > MAX_LEVELS Then
        CLS
        If score > hiscore Then ' Check if you beat your high score
          hiscore = score
          saveData
        EndIf        
        TEXT 20, 100, "----------------------------", , 4, , RGB(115, 43, 245), 2
        TEXT 20, 120, ">> You Completed HexJump! <<", , 4, , RGB(114,188,212), 2
        TEXT 90, 150, "Score: " + STR$(score), , 2, , RGB(115, 43, 245), 2
        TEXT 20, 170, "----------------------------", , 4, , RGB(115, 43, 245), 2
        Pause 3000
        lives = 10
        score = 0
        currentLevel = 1
        readData
        ShowIntro
        GameLoop
        End
      EndIf

      ResetGame
    EndIf
  EndIf

  ' Teleporter logic
  If hasPatrol = 1 Then
    ' Teleporter 1 → Teleporter 2 (one-way)
    If px + 10 > teleX1 And px < teleX1 + teleW Then
      If py + 10 > teleY1 And py < teleY1 + teleH Then
        px = teleX2
        py = teleY2 - 15
        PlayLevelUpSound
      EndIf
    EndIf
  EndIf
END Sub

'--------------------------------------
' Moving enemies
Sub UpdateEnemies(movingE)
  
  If movingE = 1 THEN
    For i = 1 To MAX_ENEMIES
      If enemyW(i) > 0 Then
        ' Save previous position BEFORE movement
        prevEnemyX(i) = enemyX(i)
        prevEnemyY(i) = enemyY(i)

        ' Apply movement
        enemyX(i) = enemyX(i) + enemyVX(i)
        enemyY(i) = enemyY(i) + enemyVY(i)

        ' Patrol zone logic
        If hasPatrol = 1 Then
          If enemyX(i) <= patrolLeft(i) Then enemyVX(i) = Abs(enemyVX(i))
          If enemyX(i) >= patrolRight(i) Then enemyVX(i) = -Abs(enemyVX(i))
        Else
          ' Default bounce if no patrol zone set
          If enemyX(i) < 20 Or enemyX(i) + enemyW(i) > 296 Then
            enemyVX(i) = -enemyVX(i)
          EndIf
        EndIf

        ' Bounce vertically (optional)
        If enemyY(i) < 45 Or enemyY(i) > groundY - 5 Then
          enemyVY(i) = -enemyVY(i)
        EndIf

      EndIf
    Next    
  EndIf  

END Sub

'--------------------------------------
' Moving platforms
Sub UpdatePlatforms(movingP)

  If movingP = 1 THEN
      For i = 1 To MAX_PLATFORMS
        If platW(i) > 0 Then

          ' Save previous position
          prevPlatX(i) = platX(i)
          prevPlatY(i) = platY(i)

          ' Apply movement
          platX(i) = platX(i) + platVX(i)
          platY(i) = platY(i) + platVY(i)

          ' Bounce horizontally
          If platX(i) < 20 Or platX(i) + platW(i) > 296 Then
            platVX(i) = -platVX(i)
          EndIf

          ' Bounce vertically (optional)
          If platY(i) < 40 Or platY(i) > groundY - 20 Then
            platVY(i) = -platVY(i)
          EndIf

        EndIf
      Next
  EndIf

End Sub

'--------------------------------------
' Rain update
Sub UpdateRain
  For i = 1 To 40
    ' Move drop downward
    rainY(i) = rainY(i) + 6

    ' If drop reaches ground line, erase and reset
    If rainY(i) >= groundY - 5 Then
      Line rainX(i), rainY(i)-6, rainX(i), rainY(i)+5, 1, RGB(0,0,0)
      rainX(i) = Rnd * 275 + 20
      rainY(i) = 40
    EndIf

  Next
End Sub

'--------------------------------------
' Simple sounds
Sub PlayHitSound
  Play Tone 600, 20: Pause 50
  Play Tone 300, 30: Pause 50
  Play Tone 0, 0    ' Stop sound
End Sub

Sub PlayLevelUpSound
  Play tone 350,400: Pause 200
  Play tone 0,0: Pause 50
  Play tone 400,350: Pause 200
  Play tone 0,0: Pause 50
  Play tone 350,400: Pause 200
  Play Tone 0,0     ' Stop sound
End Sub

Sub PlayGameOverSound
  For f=600 To 300 Step -50
    Play tone f,f: Pause 200
  Next
  Play Tone 0,0     ' Stop sound
End Sub

'--------------------------------------
' Read high score data
Sub readData
  If MM.Info(exists file fileName$) Then
    Open fileName$ For input As #1
    Line Input #1,line$
    Close #1
    hiscore = Val(line$)
  EndIf
End Sub

'--------------------------------------
' Save high score data
Sub saveData
  Open fileName$ For output As #1
  Print #1, hiscore
  Close #1
End Sub

'--------------------------------------
' Main game loop
Sub GameLoop
  CLS 0
  ResetGame
  DrawInterface

  Do
      vx = 0
      k$ = Inkey$

      ' Movement
      If k$ = "f" OR k$ = "F" Then vx = -moveSpeed 
      If k$ = "h" OR k$ = "H" Then vx = moveSpeed 

      ' Straight jump
      If (k$ = "t" OR k$ = "T") AND onGround = 1 Then
        vy = jumpStrength
        onGround = 0
      EndIf

      ' Angled jump LEFT (R key)
      If (k$ = "r" OR k$ = "R") AND onGround = 1 Then
        vy = jumpStrength
        vx = -moveSpeed * 7   ' stronger push left
        onGround = 0
      EndIf

      ' Angled jump RIGHT (Y key)
      If (k$ = "y" OR k$ = "Y") AND onGround = 1 Then
        vy = jumpStrength
        vx = moveSpeed * 7   ' stronger push right
        onGround = 0
      EndIf      

      ' Restart / Skip level / Exit
      Select Case k$
        Case "m", "M"
          ShowIntro
          GameLoop
          Exit Sub
        Case "l", "L"
          currentLevel = currentLevel + 1
          If currentLevel > MAX_LEVELS Then currentLevel = 1
          PlayLevelUpSound
          TEXT 95, 10, "Skipping Level..", , 1, , RGB(255, 60, 237), 2 'pink
          Pause 1000
          CLS 0
          lives = 10
          score = 0
          DrawInterface
          ResetGame
          Continue Do
        Case "x", "X"
          CLS
          TEXT 70, 20, "Eagle Signing Out.", , 4, , RGB(115, 43, 245), 2
          TEXT 110, 40, "Exiting...", , 4, , RGB(126, 132, 247), 2
          Pause 1000
          End
      End Select

      ' Gravity
      vy = vy + gravity

      ' Update position
      prevPX = px
      prevPY = py
      py = py + vy
      px = px + vx

      ' Keep player inside UI border
      If px < 21 Then px = 21
      If px > 288 Then px = 288
      If py < 36 Then py = 36

      ' Ground collision
      If py + 10 >= groundY Then
        py = groundY - 10
        vy = 0
        onGround = 1
      EndIf

      ' Platform & Exit collision
      CheckPlatformCollision
      CheckEnemyCollision
      CheckExitCollision
      UpdateEnemies hasMovingE
      UpdatePlatforms hasMovingP
      If hasRain = 1 Then UpdateRain

      ' Update game state
      DrawScore

      If lives = 0 Then
        If score > hiscore Then ' Check if you beat your high score
          hiscore = score
          saveData
        EndIf       
        gameOver = 1
        lives = 10
        score = 0
        currentLevel = 1
        TEXT 165, 250, "Game Over...", , 4, , RGB(255,0,0), 2
        PlayGameOverSound       
        Pause 3000
        readData
        ShowIntro
        GameLoop
      EndIf

    DrawWorld
    Pause 20
  Loop
END Sub

'--------------------------------------
GameLoop