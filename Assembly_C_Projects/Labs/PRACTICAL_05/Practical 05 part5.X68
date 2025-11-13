
    ORG    $1000

DAMAGE              EQU 10
POWER_UP_HEALTH     EQU 20

START:                  
    LEA     PLAYER_X, A2  ;PLAYER movement alont X axis
    LEA     ENEMY_POSITION, A3 ; Enemy position
    BRA     GAME_LOOP  ; Branch always to GAME_LOOP
    
    
GAME_LOOP:
    BSR     COUNT_ENEMIES ; goes to Sup routine of count enemies
    MOVE.B  D0,D4       ;reset enemy count at begining of loop
    
    LEA     MSG_GAMELOOP, A1    ; load and draw GAMELOOP Message
    BSR     DRAW
    
   BSR      UPDATE      ; call UPDATE
   BRA      GAME_LOOP   ; call GAME_LOOP
    

UPDATE:
    MOVE.B      PLAYER_HEALTH, D1 ; Move Player Health into D1
    LEA         MSG_HEALTH, A1 ; Load and draw Health Message
    BSR         DRAW
    
    MOVE.B      #3, D0
    TRAP        #15
    
    LEA         CRLF, A1 ; Load and Carriage Return and Line Feed
    BSR         DRAW
    
    CMP         #0, D1    ; Check if Health is 0 
    BLE         GAME_OVER ; Game Over
    
    ADD.L       #1, PLAYER_X  ; Change X position of Player
    
    BSR         COLLISION ; Check for collision with enemies
    BSR         POWER_UPS_CHECK ; Check player location reached power up?
    RTS
    
    
DRAW:
    MOVE.B      #13, D0     ;Display signed number D1.L in decimal in smallest field
    TRAP        #15
    RTS
    
    
COLLISION:
    MOVE.B      #1, D5      ; Loop through Array
    LEA         ENEMY_POSITION, A3 ;Load ENEMY_POSITION Array
    
    
ITERATE:
    CMP         D5, D4          ;Counter for ENEMY_POSITION
    ADD.B       #1, D5          ;Subtract one
    BEQ         GAME_LOOP       ;If 0 go to GAME_LOOP
    BNE         CHECK_ENEMIES   ; If not Check for enemy Collistions
    
    
CHECK_ENEMIES:
    MOVE.L      (A3)+, D2       ;Move enemies position to D2
    MOVE.L      (A2), D3        ;MOVE Player Position to D3
        
    CMP.L       D2, D3          ;Compare Player and Enemy position
    BEQ         REDUCE_HEALTH   ; If equal reduce Health
    BNE         ITERATE         ; Iterate to next enemy
    
    
REDUCE_HEALTH:
    LEA     MSG_COLLISION, A1       ; Load And Draw Collision Message
    BSR     DRAW
    
    SUB.B   #DAMAGE, PLAYER_HEALTH
    
    LEA     MSG_DAMAGE, A1      ; Load and Draw Damage Message
    BSR     DRAW
    
    BRA     GAME_LOOP

END_COLLISION:
    RTS
    
POWER_UPS_CHECK:
    MOVE.B      #1, D6
    LEA         POWER_UPS, A4
    
POWER_UP_IMPLEMENTATION:
    ADD.B #POWER_UPS_HP, PLAYER_HEALTH
    
    
GAME_OVER:
    LEA     MSG_GAMEOVER, A1    ; Load and Draw Game Over! Message
    BSR     DRAW
            


COUNT_ENEMIES:

    MOVE.B     #0, D0               ; Initialize Counter to 0 
    LEA         ENEMY_POSITION, A0  ; Load the Address of the Array into A0
    

COUNT_ENEMIES_LOOP:
    TST.L       (A0)+               ; Test the byte at the address in A0 (Check if 0 ) and increment A0
    BEQ         END_COUNTING        ; If the byte is zero, it's the end of the array
    
    ADD.B       #1, D0             ;Increment the counter
    BRA         COUNT_ENEMIES_LOOP ; Repeat back the loop

END_COUNTING:
    RTS

    SIMHALT

    
PLAYER_X            DC.L    1
PLAYER_HEALTH       DC.B    100
MSG_HEALTH          DC.B    'Health :', 0
MSG_GAMELOOP        DC.B    'Game Loop', 0
MSG_COLLISION       DC.B    'Collision', 0
MSG_GAMEOVER        DC.B    'Game Over!', 0
MSG_DAMAGE          DC.B    'Taking Damage', 0
MSG_POWERUPS        DC.B    'POWER UP, Collected', 0
CRLF                DC.B    $0D, $0A, 0 
ENEMY_POSITION      DC.L    20, 30, 40, 50, 60, 70, 80, 90, 200, 300 ,500, 0 ; Terminate Array with a 0
POWER_UPS           DC.L    10, 55, 220, 0 ; Terminate Array with a 0
        
    END    START        


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
