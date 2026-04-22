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

'--------------------------------------
' World
groundY = 200
platformX = 80
platformY = 150
platformW = 120
platformH = 10

gravity = 0.4
moveSpeed = 2
jumpStrength = -7

gameOver = 0

ShowIntro

'--------------------------------------
' Intro Screen
Sub ShowIntro
  CLS
  'text x,y,"string",align,font,scl,c,bc
  Text 80,20,"A Micro Platformer",,4,1,RGB(114, 188, 212), 2 'blue
  Text 40,40,"-------------------------",,4,1,RGB(173, 216, 230), 2 'light blue
  Text 50,60,"(04-2026) by SaharaHex",,4,1,RGB(173, 216, 230), 2 'light blue
  Text 20,80,"Mini HexJump",,5,1,RGB(114, 188, 212), 2 'blue
  Text 40,110,"Platformer",,5,1,RGB(114, 188, 212), 2 'blue
  Text 50,140,"(for PicoCalc)",,3,1,RGB(173, 216, 230), 2 'light blue
  TEXT 20, 180, "M for Restart. X for Exit", , 4, , RGB(173, 216, 230), 2
  TEXT 20, 200, "(Working Progress, Testing)", , 4, , RGB(173, 216, 230), 2
  PAUSE 3000
  Do
    k$=Inkey$
  Loop Until k$<>""
End Sub

'--------------------------------------
' Draw UI Border + Controls
Sub DrawInterface
  LINE 10,10,300,10,7,RGB(26, 70, 83)   ' Top
  LINE 10,10,10,250,7,RGB(26, 70, 83)   ' Left
  LINE 300,10,300,250,7,RGB(26, 70, 83) ' Right
  LINE 10,250,306,250,7,RGB(26, 70, 83) ' Bottom
  TEXT 125, 265, "M : Restart", , 7, , RGB(173, 216, 230), 2
  TEXT 125, 275, "X : Exit", , 7, , RGB(173, 216, 230), 2
End Sub

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
End Sub

'--------------------------------------
Sub DrawWorld
  ' Ground
  Line 10, groundY, 300, groundY, 2, RGB(255,255,255)

  ' Platform
  Box platformX, platformY, platformW, platformH, 1, RGB(173,216,230)

  ' Player
  TEXT prevPX, prevPY, " ",,2,,RGB(0, 0, 0), 2 ' Erase position
  Box px, py, 10, 10, 1, RGB(255,255,0)
End Sub

'--------------------------------------
Sub GameLoop
  CLS 0
  ResetGame
  DrawInterface

  Do    
      vx = 0
      k$ = Inkey$

      ' Movement
      If k$ = "a" Or k$ = "A" Then vx = -moveSpeed
      If k$ = "d" Or k$ = "D" Then vx = moveSpeed

      ' Jump
      If (k$ = "w" Or k$ = "W") And onGround = 1 Then
        vy = jumpStrength
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
          TEXT 70, 20, "Eagle Signing Out.", , 4, , RGB(114, 188, 212), 2
          TEXT 110, 40, "Exiting...", , 4, , RGB(173, 216, 230), 2
          Pause 1000
          End
      End Select

      ' Gravity
      vy = vy + gravity

      ' Update position
      prevPX = px
      prevPY = py
      px = px + vx
      py = py + vy

      ' Ground collision
      If py + 10 >= groundY Then
        py = groundY - 10
        vy = 0
        onGround = 1
      EndIf

      ' Platform collision
      If px + 10 > platformX And px < platformX + platformW Then
        If py + 10 >= platformY And py + 10 <= platformY + 5 And vy > 0 Then
          py = platformY - 10
          vy = 0
          onGround = 1
        EndIf
      EndIf

      ' Fall off screen
      If px < 10 OR px > 300 Then
        gameOver = 1
        TEXT 110, 40, "Game Over...", , 4, , RGB(173, 216, 230), 2
      EndIf

    DrawWorld
    Pause 20
  Loop
End Sub

'--------------------------------------
GameLoop