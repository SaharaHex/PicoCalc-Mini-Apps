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

' Exit goal
Dim exitX, exitY, exitW, exitH

gravity = 0.4
moveSpeed = 2
jumpStrength = -7

ShowIntro

'--------------------------------------
' Intro Screen
Sub ShowIntro
  CLS
  'text x,y,"string",align,font,scl,c,bc
  Text 80,20,"A Micro Platformer",,4,1,RGB(115, 43, 245), 2 'purple
  Text 40,40,"-------------------------",,4,1,RGB(126, 132, 247), 2 'light purple
  Text 50,60,"(04-2026) by SaharaHex",,4,1,RGB(126, 132, 247), 2 'light purple
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
Sub ResetGame
  px = 40
  py = 100
  prevPX = 0
  prevPY = 0
  vx = 0
  vy = 0
  onGround = 0
  gameOver = 0
  lives = 9
  score = 0

  ' Platforms - Level one
  platX(1) = 80 : platY(1) = 180 : platW(1) = 120 : platH(1) = 10
  platX(2) = 40 : platY(2) = 130 : platW(2) = 80  : platH(2) = 10
  platX(3) = 160: platY(3) = 90  : platW(3) = 100 : platH(3) = 10
  platX(4) = 250: platY(4) = 200 : platW(4) = 35 : platH(4) = 10
  platX(5) = 250: platY(5) = 150 : platW(5) = 35 : platH(5) = 10

  ' Enemies (triangles) - Level one
  enemyX(1) = 120 : enemyY(1) = 210 : enemyW(1) = 10 : enemyH(1) = 10
  enemyX(2) = 60  : enemyY(2) = 160 : enemyW(2) = 10 : enemyH(2) = 10
  enemyX(3) = 200 : enemyY(3) = 130 : enemyW(3) = 10 : enemyH(3) = 10
  enemyX(4) = 250 : enemyY(4) = 180 : enemyW(4) = 10 : enemyH(4) = 10
  enemyX(5) = 150 : enemyY(5) = 100 : enemyW(5) = 10 : enemyH(5) = 10

  ' Exit  - Level one
  exitX = 230 : exitY = 60 : exitW = 20 : exitH = 20
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

  TEXT 21, 255, "Get to White Square", , 7, , RGB(126, 132, 247), 2

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
      CLS
      score = score + 100
      TEXT 80, 120, "LEVEL COMPLETE!", , 4, , RGB(114,188,212), 2
      TEXT 80, 150, "Score: " + STR$(score), , 2, , RGB(115, 43, 245), 2
      Pause 3000
      ShowIntro
      GameLoop
      End
    EndIf
  EndIf
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

      ' Update game state
      DrawScore

      If lives = 0 Then
        gameOver = 1
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