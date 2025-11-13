
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

START:
    ; Player Health 100
    MOVE.W #$64, D0
    ; Player points
    CLR.W D1
    ; Player X Position
    MOVE.W #$10, D2
    ; Player Y Position
    MOVE.W #$20, D3

    ; Boss Health 100
    MOVE.W #$64, D4
    ; Boss X Position
    MOVE.W #$50, D5; 
    ; Boss Y Position
    MOVE.W #$60, D6
    
    
PLAYER_ATTACK:
; Player ATTACK

    ; Boss take 10 damage
    SUB.W #$A, (D4)
    ; Player gain 5 points
    ADD.W #$5, (D1)
    ; see Boss Died ? or not yet
    CMP.W #0, D4
    
    ; if Boss dead Player wins
    BLE   PLAYER_WINS
BOSS_ATTACK:
;Boss ATTACK
    ; Player take 6 damage
    SUB.W #$6, (D0)
    
    ; Check player health
    CMP.W 0, D0
    
    ; if Player dead Boss wins
    BLE BOSS_WINS
    
PLAYER_WINS:
    ; Display "Player Wins!"
    MOVE.W #$1, D7
    BRA GAME_END
    
BOSS_WINS:
    ; Display "Boss Wins!"
    MOVE.W #$1, D7
    BRA GAME_END
GAME_END:
    STOP    #$2700

    SIMHALT            
* Put variables and constants here

    END    START       
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
