
    ORG    $1000
    
DATA_SECTION:
GOLD          DC.W  50  ; starting gold
FOOD          DC.W  50  ; starting food
ARMY          DC.W  10  ; starting soldiers
HAPPINESS     DC.W  80  ; start at 80 from 100%
TURN_COUNT    DC.W  0   ; track number of turns

RANDOM_SEED   DC.W  0   ; used for random event generation             

* -------------------
* Main Game Loop
* -------------------
START:
    LEA    TITLE_MSG,A1       ; Load title message
    MOVE.B #14, D0
    TRAP #15
    MOVE.B      #1, $2000    ; Initialize the game state to 1 (for example, player alive)
    MOVE.B      $2000, D1    ; Move the game state value into D1
    CMP         #1, D1       ; Compare the game state with 1 (player alive)
    BNE         LOSE_GAME     ; If not equal, jump to END_GAME
    
    BSR    GAME_LOOP       ; Print the title

GAME_LOOP:
    ADD.W #1, TURN_COUNT     ; increment turn counter

    ; Check win condition (50 turns survived)
    MOVE.W TURN_COUNT,D0
    CMP.W  #50,D0
    BEQ    WIN_GAME

    ; Check loss conditions
    MOVE.W HAPPINESS,D0
    CMP.W  #0,D0
    BLE    LOSE_GAME          ; Lose if happiness is 0

    MOVE.W FOOD,D0
    CMP.W  #0,D0
    BLE    LOSE_GAME          ; Lose if no food

    ; Trigger Random Events
    BSR    RANDOM_EVENT

    ; Display choices
    LEA    PROMPT_MSG,A1
    MOVE.B #14, D0 
    TRAP #15 
    BSR    PRINT_STRING

    ; Get player input
    BSR    INPUT
    CMP.B  #'1',D0
    BEQ    EXPAND_KINGDOM
    CMP.B  #'2',D0
    BEQ    COLLECT_TAXES
    CMP.B  #'3',D0
    BEQ    TRAIN_ARMY
    CMP.B  #'4',D0
    BEQ    DECLARE_WAR
    CMP.B  #'5',D0
    BEQ    TRADE_RESOURCES
    CMP.B  #'6',D0
    BEQ    SAVE_EXIT

    BRA    GAME_LOOP          ; Loop back for the next turn
    
INPUT:
    MOVE        #4, D0       ; Load input data into D0 (e.g., read input)
    TRAP        #15          ; Call system trap to process the input
    MOVE.B      D1, $2000    ; Store the processed input into game state memory
    RTS                      ; Return from subroutine

* -------------------
* actions n choices
* -------------------
EXPAND_KINGDOM:
    SUB.W #10, GOLD          ; Expanding costs gold
    SUB.W #5, FOOD           ; Expanding costs food
    ADD.W #5, HAPPINESS      ; People are happy
    BRA    GAME_LOOP

COLLECT_TAXES:
    ADD.W #15, GOLD          ; Gain gold
    SUB.W #10, HAPPINESS     ; People dislike taxes
    BRA    GAME_LOOP

TRAIN_ARMY:
    SUB.W #10, FOOD          ; Training costs food
    ADD.W #5, ARMY           ; More soldiers
    BRA    GAME_LOOP

DECLARE_WAR:
    SUB.W #10, ARMY          ; Lose some soldiers
    ADD.W #20, GOLD          ; Gain war loot
    BRA    GAME_LOOP

TRADE_RESOURCES:
    ADD.W #10, FOOD          ; Gain food
    SUB.W #10, GOLD          ; Spend gold
    ADD.W #5, HAPPINESS      ; People like trade
    BRA    GAME_LOOP

* -------------------
* battle System 
* -------------------

BATTLE_SYSTEM:
    ; Generate enemy army size (random 5-20 soldiers)
    MOVE.W RANDOM_SEED,D0    
    ADD.W  #3, RANDOM_SEED   
    AND.W  #15, D0           ; between 0-15
    ADD.W  #5, D0            ; at least 5 soldiers
    MOVE.W D0, D1            ; D1= enemy army size

    ; compare Player army vs Enemy army
    MOVE.W ARMY,D2           
    CMP.W  D1,D2             
    BGT    BATTLE_WINNER     
    BLE    BATTLE_LOSER      

BATTLE_WINNER:
    ADD.W #20, GOLD          ; gain gold as war loot
    ADD.W #10, FOOD          ; gain food from conquest
    LEA    BATTLE_WIN,A1
    BSR    PRINT_STRING
    RTS

BATTLE_LOSER:
    SUB.W #5, ARMY           ; Lose some soldiers
    SUB.W #10, HAPPINESS     ; People are unhappy after losing
    LEA    BATTLE_LOSE,A1
    BSR    PRINT_STRING
    RTS



* -------------------
* random events system
* -------------------
RANDOM_EVENT:
    MOVE.W RANDOM_SEED,D0
    ADD.W #1, RANDOM_SEED       ; change the seed each turn
    AND.W #3, D0                ; generates a number 0-3

    CMP.W #0,D0
    BEQ    EVENT_PLAGUE

    CMP.W #1,D0
    BEQ    EVENT_DROUGHT

    CMP.W #2,D0
    BEQ    EVENT_INVASION

    RTS                          ; return if no event

EVENT_PLAGUE:
    SUB.W #10, HAPPINESS         ; plague reduces happiness
    SUB.W #5, FOOD               ; some food is lost
    LEA    EVENT_MSG,A0
    BSR    PRINT_STRING
    RTS

EVENT_DROUGHT:
    SUB.W #15, FOOD              ; major food loss
    LEA    EVENT_MSG,A0
    BSR    PRINT_STRING
    RTS

EVENT_INVASION:
    SUB.W #5, ARMY               ; Army takes casualties
    SUB.W #10, GOLD              ; loot stolen
    LEA    EVENT_MSG,A0
    BSR    PRINT_STRING
    RTS

* -------------------
* save n exit feature
* -------------------
SAVE_EXIT:
    TRAP    #15                  ; placeholder for saving 
    BRA     EXIT

; -------------------
; win n lose Conditions
; -------------------
WIN_GAME:
    LEA    WIN_MSG,A1
    MOVE.B      #14, D0      ; Set the message length (14 characters)
    TRAP        #15          ; Call system trap to display the message
    BSR    PRINT_STRING
    BRA    EXIT

LOSE_GAME:
    LEA    LOSE_MSG,A1
    MOVE.B      #14, D0      ; Set the message length (14 characters)
    TRAP        #15          ; Call system trap to display the message
    BSR    PRINT_STRING
    BRA    EXIT

; -------------------
; utility functions
; -------------------

PRINT_STRING:
    MOVE.B  (A0)+,D0          ; load character
    CMP     #0, D0
    BEQ     DONE_PRINT        ; if null, stop printing
    ADD.L   #1, A0
    TRAP    #15               ; print character
    BRA     PRINT_STRING
DONE_PRINT:
    RTS
    

EXIT:
    TRAP    #15               ; exit program
    
    SIMHALT             ; halt simulator

* -------------------
* data section / msgs
* -------------------

PROMPT_MSG    DC.B  '1. Expand Kingdom',10,13
              DC.B  '2. Collect Taxes',10,13
              DC.B  '3. Train Army',10,13
              DC.B  '4. Declare War',10,13
              DC.B  '5. Trade Resources',10,13
              DC.B  '6. Save & Exit',10,13
              DC.B  'Choose an action: ',0

TITLE_MSG     DC.B  'Tiny Throne: Strategy RPG',10,13,0

*----------------- 
* win lose msgs
*-----------------

WIN_MSG       DC.B  'Your kingdom thrives! Victory!',10,13,0
LOSE_MSG      DC.B  'Your kingdom has collapsed. Game Over.',10,13,0
BATTLE_WIN    DC.B  'You won the battle! Gained resources.',10,13,0
BATTLE_LOSE   DC.B  'You lost the battle! Lost soldiers.',10,13,0
EVENT_MSG     DC.B  'A random event has occurred!',10,13,0







* Core Game Loop – Player chooses actions each turn   - (tick)
* Resource Management – Gold, food, army, happiness   - (tick)
* Random Events – Plagues, droughts, invasions        - (tick)
* Trade System  – Exchange gold for food              - (tick)
* Battle System - Declaring war and                   - (tick)
* Basic Win/Loss Conditions – 50 turns to win, 0 food/happiness to lose   - (tick)
* Save & Exit Feature (Placeholder).                  - (tick)



    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
