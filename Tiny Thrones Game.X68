    ORG    $1000
    
DATA_SECTION:
GOLD          DC.W  50
FOOD          DC.W  50
ARMY          DC.W  10
HAPPINESS     DC.W  80
TURN_COUNT    DC.W  0
RANDOM_SEED   DC.W  1234
STATS_BUFFER  DS.B  80

* -------------------
* Main Game Loop
* -------------------
START:
    LEA    TITLE_MSG,A1
    MOVE.B #14,D0
    TRAP   #15
    MOVE.B #1,$2000
    
GAME_LOOP:
    ADD.W  #1,TURN_COUNT
    BSR    DISPLAY_STATS
    
    MOVE.W TURN_COUNT,D0
    CMP.W  #50,D0
    BEQ    WIN_GAME
    
    MOVE.W HAPPINESS,D0
    CMP.W  #0,D0
    BLE    LOSE_GAME
    
    MOVE.W FOOD,D0
    CMP.W  #0,D0
    BLE    LOSE_GAME
    
    MOVE.W GOLD,D0
    CMP.W  #0,D0
    BLE    LOSE_GAME
    
    BSR    RANDOM_EVENT
    
    LEA    PROMPT_MSG,A1
    BSR    PRINT_STRING
    BSR    GET_INPUT
    
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
    
    LEA    INVALID_MSG,A1
    BSR    PRINT_STRING
    BRA    GAME_LOOP

* -------------------
* Subroutines
* -------------------
GET_INPUT:
    LEA    INPUT_PROMPT_MSG,A1    ; Load the address of the input prompt message
    MOVE.B #14,D0                 ; Task 14: Display null-terminated string
    TRAP   #15                    ; Display the prompt
    MOVE.B #5,D0                  ; Task 5: Read a single character into D1.B
    TRAP   #15                    ; Wait for user input, result in D1.B
    MOVE.B D1,D0                  ; Move the input character to D0 for comparison
    RTS                           ; Return to caller

PRINT_STRING:
    MOVE.B #14,D0
    TRAP   #15
    RTS

DISPLAY_STATS:
    LEA    STATS_BUFFER,A1
    LEA    TURN_LABEL,A2
    BSR    COPY_STRING
    MOVE.W TURN_COUNT,D0
    BSR    NUM_TO_STRING
    
    MOVE.B #' ',(A1)+
    LEA    GOLD_LABEL,A2
    BSR    COPY_STRING
    MOVE.W GOLD,D0
    BSR    NUM_TO_STRING
    
    MOVE.B #' ',(A1)+
    LEA    FOOD_LABEL,A2
    BSR    COPY_STRING
    MOVE.W FOOD,D0
    BSR    NUM_TO_STRING
    
    MOVE.B #' ',(A1)+
    LEA    ARMY_LABEL,A2
    BSR    COPY_STRING
    MOVE.W ARMY,D0
    BSR    NUM_TO_STRING
    
    MOVE.B #' ',(A1)+
    LEA    HAPPINESS_LABEL,A2
    BSR    COPY_STRING
    MOVE.W HAPPINESS,D0
    BSR    NUM_TO_STRING
    
    MOVE.B #10,(A1)+
    MOVE.B #13,(A1)+
    MOVE.B #0,(A1)
    LEA    STATS_BUFFER,A1
    BSR    PRINT_STRING
    RTS

COPY_STRING:
    MOVE.B (A2)+,D1
    BEQ    COPY_DONE
    MOVE.B D1,(A1)+
    BRA    COPY_STRING
COPY_DONE:
    RTS

NUM_TO_STRING:
    CLR.L  D1
    CLR.L  D2
    MOVE.W D0,D1
    BEQ    ZERO_CASE
    
CONVERT_LOOP:
    DIVU   #10,D1
    SWAP   D1
    ADD.B  #'0',D1
    MOVE.B D1,-(SP)
    CLR.W  D1
    SWAP   D1
    ADDQ   #1,D2
    TST.W  D1
    BNE    CONVERT_LOOP
    
POP_DIGITS:
    MOVE.B (SP)+,(A1)+
    SUBQ   #1,D2
    BNE    POP_DIGITS
    RTS

ZERO_CASE:
    MOVE.B #'0',(A1)+
    RTS

RANDOM_EVENT:
    MOVE.W RANDOM_SEED,D0
    MULU   #13,D0
    ADD.W  #7,D0
    DIVU   #100,D0
    SWAP   D0
    MOVE.W D0,RANDOM_SEED
    
    CMP.W  #60,D0
    BGE    NO_EVENT
    
    CMP.W  #40,D0
    BGE    GOOD_DAY_EVENT
    
    CMP.W  #20,D0
    BGE    SNOWY_EVENT
    
DROUGHT_EVENT:
    SUB.W  #10,FOOD
    SUB.W  #5,HAPPINESS
    LEA    DROUGHT_MSG,A1
    BSR    PRINT_STRING
    BRA    EVENT_DONE

SNOWY_EVENT:
    SUB.W  #10,HAPPINESS
    SUB.W  #5,ARMY
    LEA    SNOWY_MSG,A1
    BSR    PRINT_STRING
    BRA    EVENT_DONE

GOOD_DAY_EVENT:
    ADD.W  #15,GOLD
    ADD.W  #5,HAPPINESS
    LEA    GOOD_DAY_MSG,A1
    BSR    PRINT_STRING
    BRA    EVENT_DONE

NO_EVENT:
    RTS

EVENT_DONE:
    RTS

EXPAND_KINGDOM:
    MOVE.W GOLD,D0
    CMP.W  #20,D0
    BLT    INSUFFICIENT
    SUB.W  #20,GOLD
    ADD.W  #10,FOOD
    ADD.W  #5,HAPPINESS
    LEA    EXPAND_MSG,A1
    BSR    PRINT_STRING
    BRA    GAME_LOOP

COLLECT_TAXES:
    ADD.W  #15,GOLD
    SUB.W  #10,HAPPINESS
    LEA    TAX_MSG,A1
    BSR    PRINT_STRING
    BRA    GAME_LOOP

TRAIN_ARMY:
    MOVE.W GOLD,D0
    CMP.W  #10,D0
    BLT    INSUFFICIENT
    MOVE.W FOOD,D0
    CMP.W  #5,D0
    BLT    INSUFFICIENT
    SUB.W  #10,GOLD
    SUB.W  #5,FOOD
    ADD.W  #5,ARMY
    LEA    TRAIN_MSG,A1
    BSR    PRINT_STRING
    BRA    GAME_LOOP

DECLARE_WAR:
    MOVE.W ARMY,D0
    CMP.W  #10,D0             ; Check if enough army
    BLT    INSUFFICIENT
    SUB.W  #10,ARMY
    MOVE.W RANDOM_SEED,D0
    MULU   #17,D0             ; Generate new random value
    ADD.W  #11,D0             ; Add offset for variation
    DIVU   #100,D0
    SWAP   D0                 ; Use remainder
    MOVE.W D0,RANDOM_SEED     ; Update seed
    CMP.W  #50,D0             ; 50% chance (0-49 lose, 50-99 win)
    BGE    WAR_WIN
WAR_LOSE:
    SUB.W  #10,HAPPINESS
    LEA    BATTLE_LOSE,A1
    BSR    PRINT_STRING
    BRA    GAME_LOOP
WAR_WIN:
    ADD.W  #20,GOLD
    ADD.W  #5,HAPPINESS
    LEA    BATTLE_WIN,A1
    BSR    PRINT_STRING
    BRA    GAME_LOOP

TRADE_RESOURCES:
    MOVE.W FOOD,D0
    CMP.W  #15,D0
    BLT    INSUFFICIENT
    SUB.W  #15,FOOD
    ADD.W  #20,GOLD
    LEA    TRADE_MSG,A1
    BSR    PRINT_STRING
    BRA    GAME_LOOP

INSUFFICIENT:
    LEA    INSUFFICIENT_MSG,A1
    BSR    PRINT_STRING
    BRA    GAME_LOOP

SAVE_EXIT:
    LEA    EXIT_MSG,A1
    BSR    PRINT_STRING
    BRA    EXIT

WIN_GAME:
    LEA    WIN_MSG,A1
    BSR    PRINT_STRING
    BRA    EXIT

LOSE_GAME:
    LEA    LOSE_MSG,A1
    BSR    PRINT_STRING
    BRA    EXIT

EXIT:
    SIMHALT

* -------------------
* Data Section
* -------------------
TITLE_MSG     DC.B  'Tiny Throne: Strategy RPG',10,13,0
PROMPT_MSG    DC.B  'Actions: 1) Expand   2)Tax   3)Train  4)War   5)Trade   6)Exit',10,13,0
INPUT_PROMPT_MSG DC.B 'Enter your choice (1-6): ',0
WIN_MSG       DC.B  'Your kingdom thrives! Victory!',10,13,0
LOSE_MSG      DC.B  'Your kingdom has collapsed. Game Over.',10,13,0
BATTLE_WIN    DC.B  'You won the battle!',10,13,0
BATTLE_LOSE   DC.B  'You lost the battle!',10,13,0
DROUGHT_MSG   DC.B  'A drought strikes! Food and happiness decrease.',10,13,0
SNOWY_MSG     DC.B  'Snowy weather hits! Happiness and army suffer.',10,13,0
GOOD_DAY_MSG  DC.B  'A good day brings extra fortune!',10,13,0
EXPAND_MSG    DC.B  'Kingdom expanded!',10,13,0
TAX_MSG       DC.B  'Taxes collected!',10,13,0
TRAIN_MSG     DC.B  'Army trained!',10,13,0
TRADE_MSG     DC.B  'Resources traded!',10,13,0
EXIT_MSG      DC.B  'Game saved. Goodbye!',10,13,0
INVALID_MSG   DC.B  'Invalid choice! Try again.',10,13,0
INSUFFICIENT_MSG DC.B 'Insufficient resources!',10,13,0
TURN_LABEL    DC.B  'Turn:',0
GOLD_LABEL    DC.B  'Gold:',0
FOOD_LABEL    DC.B  'Food:',0
ARMY_LABEL    DC.B  'Army:',0
HAPPINESS_LABEL DC.B 'Happiness:',0

    END    START
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
