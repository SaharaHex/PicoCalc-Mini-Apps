'--------------------------------------
' Mini HexJump Platformer (Working Progress)
' For PicoCalc (04-2026) by SaharaHex
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
Dim currentLevel    ' Game level
Dim hasMovingE      ' Are there moving Enemies

'--------------------------------------
' World
groundY = 240
Const MAX_PLATFORMS = 5

Dim platX(MAX_PLATFORMS)
Dim platY(MAX_PLATFORMS)
Dim platW(MAX_PLATFORMS)
Dim platH(MAX_PLATFORMS)

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

' Exit goal
Dim exitX, exitY, exitW, exitH

gravity = 0.4
moveSpeed = 2
jumpStrength = -7

lives = 9
score = 0
currentLevel = 1
currentLevelText$ = "Get to White Square" ' Level message 

ShowIntro

'--------------------------------------
' Intro Screen
Sub ShowIntro
  CLS
  'text x,y,"string",align,font,scl,c,bc
  Text 80,20,"A Micro Platformer",,4,1,RGB(115, 43, 245), 2 'purple
  Text 40,40,"-------------------------",,4,1,RGB(126, 132, 247), 2 'light purple
  Text 50,60,"(05-2026) by SaharaHex",,4,1,RGB(126, 132, 247), 2 'light purple
  Text 20,80,"Mini HexJump",,5,1,RGB(115, 43, 245), 2 'purple
  Text 40,110,"Platformer",,5,1,RGB(115, 43, 245), 2 'purple
  Text 50,140,"(for PicoCalc)",,3,1,RGB(126, 132, 247), 2 'light purple
  TEXT 20, 180, "M for Restart. X for Exit", , 4, , RGB(126, 132, 247), 2
  TEXT 20, 200, "(Working Progress, Testing)", , 4, , RGB(126, 132, 247), 2
  PAUSE 3000
  Do
    k$=Inkey$
  Loop Until k$<>""
END SUB

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
  TEXT 210, 285, "M : Restart", , 7, , RGB(126, 132, 247), 2
  TEXT 210, 295, "X : Exit", , 7, , RGB(126, 132, 247), 2
END SUB

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

      'Moving enemies 0 for no 1 for yes
      hasMovingE = 0
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

      'Moving enemies 0 for no 1 for yes
      hasMovingE = 0
      'Level Message
      currentLevelText$ = "Avoid the Triangles"

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

      ' Moving enemies
      enemyX(1) = 60  : enemyY(1) = 190 : enemyW(1) = 12 : enemyH(1) = 12 : enemyVX(1) = 1 : enemyVY(1) = 0
      enemyX(2) = 180 : enemyY(2) = 150 : enemyW(2) = 12 : enemyH(2) = 12 : enemyVX(2) = -1 : enemyVY(2) = 0
      enemyX(3) = 100 : enemyY(3) = 110 : enemyW(3) = 12 : enemyH(3) = 12 : enemyVX(3) = 1 : enemyVY(3) = 0

      'Moving enemies 0 for no 1 for yes
      hasMovingE = 1
      'Level Message
      currentLevelText$ = "Moving Enemies"

      ' Exit
      exitX = 130 : exitY = 60 : exitW = 20 : exitH = 20

  End Select
END SUB

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
END SUB

'--------------------------------------
Sub DrawWorld
  ' Ground
  Line 20, groundY, 296, groundY, 2, RGB(255,255,255)

  ' Platform
  For i = 1 To MAX_PLATFORMS
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

  ' Player
  TEXT prevPX, prevPY, " ",,2,,RGB(0, 0, 0), 2 ' Erase position
  Box px, py, 10, 10, 1, RGB(255,255,0)

END SUB

'--------------------------------------
' Draw the score
SUB DrawScore
  TEXT 10, 10, "Score: " + STR$(score), , 1, , RGB(115, 43, 245), 2
  TEXT 230, 10, "Lives: " + STR$(lives), , 1, , RGB(115, 43, 245), 2
END SUB

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
END SUB

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
      Pause 3000
      CLS 0
      DrawInterface

      currentLevel = currentLevel + 1

      If currentLevel > 3 Then
        CLS
        TEXT 20, 100, "----------------------------", , 4, , RGB(115, 43, 245), 2
        TEXT 20, 120, ">> You Completed HexJump! <<", , 4, , RGB(114,188,212), 2
        TEXT 90, 150, "Score: " + STR$(score), , 2, , RGB(115, 43, 245), 2
        TEXT 20, 170, "----------------------------", , 4, , RGB(115, 43, 245), 2
        Pause 3000
        lives = 9
        score = 0
        currentLevel = 1
        ShowIntro
        GameLoop
        End
      EndIf

      ResetGame
    EndIf
  EndIf
END SUB

'--------------------------------------
' Moving enemies
Sub UpdateEnemies(level)
  
  Select Case level
  '--------------------------------------
  ' LEVEL 3
  '--------------------------------------
  Case 3
    For i = 1 To MAX_ENEMIES
      If enemyW(i) > 0 Then
        ' Save previous position BEFORE movement
        prevEnemyX(i) = enemyX(i)
        prevEnemyY(i) = enemyY(i)

        ' Apply movement
        enemyX(i) = enemyX(i) + enemyVX(i)
        enemyY(i) = enemyY(i) + enemyVY(i)

        ' Bounce horizontally
        If enemyX(i) < 20 Or enemyX(i) + enemyW(i) > 296 Then
          enemyVX(i) = -enemyVX(i)
        EndIf

        ' Bounce vertically (optional)
        If enemyY(i) < 40 Or enemyY(i) > groundY - 5 Then
          enemyVY(i) = -enemyVY(i)
        EndIf

      EndIf
    Next    
  
  End Select
END SUB

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

      ' Restart / Exit
      Select Case k$
        Case "m", "M"
          ShowIntro
          GameLoop
          Exit Sub
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
      UpdateEnemies currentLevel

      ' Update game state
      DrawScore

      If lives = 0 Then
        gameOver = 1
        lives = 9
        score = 0
        currentLevel = 1
        TEXT 165, 250, "Game Over...", , 4, , RGB(255,0,0), 2
        Pause 3000
        ShowIntro
        GameLoop
      EndIf

    DrawWorld
    Pause 20
  Loop
END SUB

'--------------------------------------
GameLoop