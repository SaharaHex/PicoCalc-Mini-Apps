'--------------------------------------
' Inspired by Missile Command on Atari 
' Character Sprite Edition for PicoCalc (11-2025) by SaharaHex
'--------------------------------------
Option Base 1
FONT 2
CLS

'--------------------------------------
' Game variables
Dim cityAlive(7)
Dim cityX(7)                            ' X positions of cities
Dim cityHitRadius                       ' Missile must be within city radius to count as a hit
Dim missileX(10), missileY(10)          ' Current missile positions
Dim missilePrevY(10), missileActive(10) ' Previous Y positions and active flags
Dim explosionPrevX, explosionPrevY
Dim explosionX(5), explosionY(5)        ' Explosion positions
Dim explosionR(5), explosionPrevR(5)    ' Explosion radius and previous radius
Dim explosionActive(5)                  ' Explosion active flags
Dim explosionPrevPX(41), explosionPrevPY(41) 'Explosion variables
Dim score
Dim hiscore                             ' Your high score
Dim pointsPerHit                        ' Points per Hit
Dim barColors(17)                       ' Side score indicator
  barColors(1) = RGB(26, 70, 83)
  barColors(2) = RGB(26, 70, 83)
  barColors(3) = RGB(26, 70, 83)
  barColors(4) = RGB(26, 70, 83)
  barColors(5) = RGB(114, 188, 212)
  barColors(6) = RGB(114, 188, 212)
  barColors(7) = RGB(114, 188, 212)
  barColors(8) = RGB(114, 188, 212)
  barColors(9) = RGB(173, 216, 230)
  barColors(10) = RGB(173, 216, 230)
  barColors(11) = RGB(173, 216, 230)
  barColors(12) = RGB(173, 216, 230)
  barColors(13) = RGB(255, 255, 255)
  barColors(14) = RGB(255, 255, 255)
  barColors(15) = RGB(255, 255, 255)
  barColors(16) = RGB(255, 255, 0)

cityX(1) = 40: cityX(2) = 80: cityX(3) = 120: cityX(4) = 160: cityX(5) = 200: cityX(6) = 240: cityX(7) = 280
cityY = 225                             ' Y position of cities near bottom
cityHitRadius = 6                       ' Missile must be within 6 pixels horizontally of the city to count as a hit
missileSpeed = 2                        ' Speed of falling missiles
explosionMaxR = 20                      ' Max radius before explosion disappears
explosionPrevX = 20
explosionPrevY = 20
score = 0
hiscore = 0
fileName$  = "MiniMC.txt"

' Sprite characters from custom font
missileChar = 33
explosionChar = 34
cityChar = 35

readData
show_intro

Sub show_intro
  CLS
  'text x,y,"string",align,font,scl,c,bc
  Text 80,20,"Inspired by Atari",,4,1,RGB(114, 188, 212), 2 'blue
  Text 40,40,"Character Sprite Edition",,4,1,RGB(173, 216, 230), 2 'light blue
  Text 50,60,"(11-2025) by SaharaHex",,4,1,RGB(173, 216, 230), 2 'light blue
  Text 20,80,"Mini Missile",,5,1,RGB(114, 188, 212), 2 'blue
  Text 80,110,"Command",,5,1,RGB(114, 188, 212), 2 'blue
  Text 50,140,"(for PicoCalc)",,3,1,RGB(173, 216, 230), 2 'light blue
  TEXT 20, 180, "M for Restart. X for Exit", , 4, , RGB(173, 216, 230), 2
  TEXT 20, 200, "Controls : to fire Missiles", , 4, , RGB(173, 216, 230), 2
  TEXT 20, 220, "Use the numbers : ", , 4, , RGB(173, 216, 230), 2
  TEXT 30, 240, "1, 2, 3 for top of screen", , 4, , RGB(173, 216, 230), 2
  TEXT 30, 260, "4, 5, 6 for middle of screen", , 4, , RGB(173, 216, 230), 2
  TEXT 30, 280, "7, 8, 9 for bottom of screen", , 4, , RGB(173, 216, 230), 2
  TEXT 30, 300, "0       for random fire", , 4, , RGB(173, 216, 230), 2
  PAUSE 3000
  Do
    k$=Inkey$
  Loop Until k$<>""
End Sub

'--------------------------------------
' Draw screen border (static)
SUB DrawBorder
  LINE 10,10,300,10,7,RGB(26, 70, 83)   ' Top
  LINE 10,10,10,250,7,RGB(26, 70, 83)   ' Left
  LINE 300,10,300,250,7,RGB(26, 70, 83) ' Right
  LINE 10,250,306,250,7,RGB(26, 70, 83) ' Bottom
  TEXT 65, 260, "Top", , 2, , RGB(173, 216, 230), 2
  BOX 2, 260, 20, 20, 2, RGB(26, 70, 83) 'dark blue 
  TEXT 11, 265, "1", , 7, , RGB(173, 216, 230), 2
  BOX 2, 280, 20, 20, 2, RGB(26, 70, 83)
  TEXT 11, 285, "4", , 7, , RGB(173, 216, 230), 2
  BOX 2, 300, 20, 20, 2, RGB(26, 70, 83)
  TEXT 11, 305, "7", , 7, , RGB(173, 216, 230), 2
  TEXT 65, 280, "Middle", , 2, , RGB(173, 216, 230), 2
  BOX 22, 260, 20, 20, 2, RGB(26, 70, 83)
  TEXT 31, 265, "2", , 7, , RGB(173, 216, 230), 2
  BOX 22, 280, 20, 20, 2, RGB(26, 70, 83)
  TEXT 31, 285, "5", , 7, , RGB(173, 216, 230), 2
  BOX 22, 300, 20, 20, 2, RGB(26, 70, 83)
  TEXT 31, 305, "8", , 7, , RGB(173, 216, 230), 2
  TEXT 65, 300, "Bottom", , 2, , RGB(173, 216, 230), 2
  BOX 42, 260, 20, 20, 2, RGB(26, 70, 83)
  TEXT 51, 265, "3", , 7, , RGB(173, 216, 230), 2
  BOX 42, 280, 20, 20, 2, RGB(26, 70, 83)
  TEXT 51, 285, "6", , 7, , RGB(173, 216, 230), 2
  BOX 42, 300, 20, 20, 2, RGB(26, 70, 83)
  TEXT 51, 305, "9", , 7, , RGB(173, 216, 230), 2
  TEXT 125, 265, "M : Restart", , 7, , RGB(173, 216, 230), 2
  TEXT 125, 275, "X : Exit", , 7, , RGB(173, 216, 230), 2
END SUB

'--------------------------------------
' Draw the score
SUB DrawScore
  TEXT 200, 260, "Score: " + STR$(score), , 2, , RGB(255, 255, 255), 2
  TEXT 200, 285, "High Score: " + STR$(hiscore), , 7, , RGB(173, 216, 230), 2

  TEXT 200, 295, "City destroyed!", , 7, , RGB(114, 188, 212), 2
  xStart = 200
  spacing = 15
  xPos = xStart
  FOR i = 1 TO 7
    IF cityAlive(i) = 0 THEN
      TEXT xPos, 305, STR$(i), , 7, , RGB(114, 188, 212), 2
      xPos = xPos + spacing
    END IF
  NEXT
  ' Side score indicator, from score 20 to 170
  FOR i = 1 TO 16
    IF score >= i * 10 THEN
      y1 = 10 + (i - 1) * 15
      y2 = y1 + 10
      LINE 310, y1, 310, y2, 1, barColors(i)
    END IF
  NEXT      
END SUB

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
' Setting level difficulty based on points
SUB SetDifficulty
  IF score < 100 THEN
    missileSpeed = 2
    explosionMaxR = 20
    pointsPerHit = 10
  ELSEIF score < 150 THEN
    missileSpeed = 3
    explosionMaxR = 15
    pointsPerHit = 10
  ELSEIF score < 200 THEN
    missileSpeed = 4
    explosionMaxR = 12
    pointsPerHit = 15
  ELSEIF score < 250 THEN
    missileSpeed = 5
    explosionMaxR = 10
    pointsPerHit = 15
  ELSE  
    missileSpeed = 6
    explosionMaxR = 8
    pointsPerHit = 15
  END IF
END SUB

'--------------------------------------
' Initialize missiles with random X positions
SUB InitMissiles
  FOR i = 1 TO 10
    missileX(i) = 20 + RND * 260
    missileY(i) = 20
    missilePrevY(i) = 20
    missileActive(i) = 1
  NEXT
END SUB

'--------------------------------------
' Respawn inactive missiles
SUB RespawnMissiles
  FOR i = 1 TO 10
    IF missileActive(i) = 0 THEN
      missileX(i) = 20 + RND * 260
      missileY(i) = 20
      missilePrevY(i) = 20
      missileActive(i) = 1
    END IF
  NEXT
END SUB

'--------------------------------------
' Draw cities using character sprite
SUB DrawCities
  FOR i = 1 TO 7
    IF cityAlive(i) = 1 THEN
      TEXT cityX(i), cityY, CHR$(cityChar),,2,,RGB(green), 2
    ELSE
      TEXT cityX(i), cityY, " ",,2,,RGB(0, 0, 0), 2
    END IF
  NEXT
END SUB

'--------------------------------------
' Draw missiles and erase previous position
SUB DrawMissiles
  FOR i = 1 TO 10
    IF missileActive(i) = 1 THEN
      IF missileX(i) >= 10 AND missileX(i) <= 280 AND missileY(i) >= 10 AND missileY(i) <= 250 THEN
        TEXT missileX(i), missileY(i), CHR$(missileChar),,2,,RGB(255, 0, 0), 2
      END IF
      missilePrevY(i) = missileY(i)
    ELSE
      TEXT missileX(i), missileY(i), " ",,2,,RGB(0, 0, 0), 2 ' Erase old
    END IF
  NEXT
END SUB

'--------------------------------------
' Update missile positions and deactivate if they reach city level
SUB UpdateMissiles
  FOR i = 1 TO 10
    IF missileActive(i) = 1 THEN
      missileY(i) = missileY(i) + missileSpeed
      IF missileY(i) >= cityY THEN
        missileActive(i) = 0
        FOR c = 1 TO 7  'If a missile is close enough to a city and marks it destroyed
          IF ABS(missileX(i) - cityX(c)) < cityHitRadius AND cityAlive(c) = 1 THEN
            cityAlive(c) = 0
          END IF
        NEXT
      END IF
      TEXT missileX(i), missileY(i), " ", , 2, , RGB(0, 0, 0), 2 ' Erase old
    END IF
  NEXT
END SUB

'--------------------------------------
' Launch a new explosion at given coordinates
SUB LaunchExplosion(x, y)
  FOR i = 1 TO 5
    IF explosionActive(i) = 0 THEN
      explosionX(i) = x
      explosionY(i) = y
      explosionR(i) = 1
      explosionPrevR(i) = 0
      explosionActive(i) = 1
      EXIT SUB
    END IF
  NEXT
END SUB

'--------------------------------------
' Expand explosion radius and deactivate when max reached
SUB UpdateExplosions
  FOR i = 1 TO 5
    IF explosionActive(i) = 1 THEN
      ' Erase previous ring
      FOR p = 0 TO 7
        index = (i - 1) * 8 + p + 1
        px = explosionPrevPX(index)
        py = explosionPrevPY(index)
        TEXT px, py, " ",,2,,RGB(0, 0, 0), 2
      NEXT

      ' Expand radius
      explosionR(i) = explosionR(i) + 2

      ' Draw new ring and store positions
      FOR angle = 0 TO 315 STEP 45
        p = angle / 45
        index = (i - 1) * 8 + p
        px = explosionX(i) + COS(angle) * explosionR(i)
        py = explosionY(i) + SIN(angle) * explosionR(i)
        TEXT px, py, "*",,2,,RGB(255, 255, 0), 2
        IF index >= 1 AND index <= 41 THEN
          explosionPrevPX(index) = px
          explosionPrevPY(index) = py
        END IF
      NEXT

      ' Deactivate if max radius reached
      IF explosionR(i) > explosionMaxR THEN
        explosionActive(i) = 0
      END IF
    END IF
  NEXT
END SUB

'--------------------------------------
' Draw explosions and erase previous radius
SUB DrawExplosions
  FOR i = 1 TO 5
    IF explosionActive(i) = 1 THEN
      IF explosionX(i) >= 38 AND explosionX(i) <= 267 AND explosionY(i) >= 37 AND explosionY(i) <= 190 THEN
        TEXT explosionPrevX, explosionPrevY, " ",,2,,RGB(0, 0, 0), 2 ' Erase old
        TEXT explosionX(i), explosionY(i), CHR$(explosionChar),,2,,RGB(255, 255, 0), 2
        explosionPrevR(i) = explosionR(i)
        explosionPrevX = explosionX(i)
        explosionPrevY = explosionY(i)
      END IF
    END IF
  NEXT
END SUB

'--------------------------------------
' Check if any missiles are within explosion radius
SUB CheckCollisions
  FOR m = 1 TO 10
    IF missileActive(m) = 1 THEN
      FOR e = 1 TO 5
        IF explosionActive(e) = 1 THEN
          dx = missileX(m) - explosionX(e)
          dy = missileY(m) - explosionY(e)
          dist = SQR(dx*dx + dy*dy)
          IF dist <= explosionR(e) THEN
            missileActive(m) = 0
            score = score + pointsPerHit
          END IF
        END IF
      NEXT
    END IF
  NEXT
END SUB

'--------------------------------------
' Main game loop
SUB GameLoop
  CLS 0
  FOR i = 1 TO 7
    cityAlive(i) = 1
  NEXT
  score = 0 'Reset

  DrawBorder
  DrawCities
  InitMissiles

  DO
    ' Update game state
    SetDifficulty
    UpdateMissiles
    UpdateExplosions
    CheckCollisions
    RespawnMissiles

    ' Draw updated elements
    DrawMissiles
    DrawExplosions
    DrawScore

    aliveCount = 0
    FOR i = 1 TO 7
      IF cityAlive(i) = 1 THEN aliveCount = aliveCount + 1
    NEXT

    IF aliveCount = 0 THEN
      TEXT 100, 120, "GAME OVER", , 4, , RGB(255, 0, 0), 2
      TEXT 60, 140, "Final Score: " + STR$(score), , 2, , RGB(255, 255, 255), 2
      If score > hiscore Then ' Check if you beat your high score
        hiscore = score
        saveData
      EndIf
      PAUSE 6000
      readData
      show_intro
      GameLoop
      EXIT SUB
    END IF
    
    ' Handle input
    tecla$ = INKEY$
    SELECT CASE tecla$
      CASE "1" TO "9"
        zone = VAL(tecla$)
        col = ((zone - 1) MOD 3)
        row = INT((zone - 1) / 3)
        xMin = 38 + col * 76
        xMax = xMin + 76
        yMin = 37 + row * 51
        yMax = yMin + 51
        xRand = xMin + RND * (xMax - xMin)
        yRand = yMin + RND * (yMax - yMin)
        LaunchExplosion xRand, yRand
      CASE "0"
        LaunchExplosion 38 + RND * 229, 37 + RND * 153  ' Full random fallback
      CASE "M", "m"
        readData
        show_intro
        GameLoop
        EXIT SUB
      CASE "X", "x"
        CLS
        TEXT 70, 20, "Eagle Signing Out.", , 4, , RGB(114, 188, 212), 2
        TEXT 110, 40, "Exiting...", , 4, , RGB(173, 216, 230), 2
        PAUSE 1000
        EXIT SUB      
    END SELECT

    PAUSE 30
  LOOP
END SUB

'--------------------------------------
GameLoop