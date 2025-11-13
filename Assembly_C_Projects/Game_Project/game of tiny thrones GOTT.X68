*------------------------
* NAME - MUNZER ELSARAFANDI
* ID - C00281934
* DATE - 28/02/2025
*------------------------
    ORG    $1000
    
DATA_SECTION:
GOLD          DC.W  50
FOOD          DC.W  50
ARMY          DC.W  10
HAPPINESS     DC.W  80
TURN_COUNT    DC.W  0
RANDOM_SEED   DC.W  1234
DIFFICULTY    DC.W  0     ; 0 = normal mode, 1 = hard mode
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
    BSR    EXIT
    LEA    INPUT_PROMPT_MSG,A1
    MOVE.B #14,D0
    TRAP   #15
    CLR.B  D0                ; Clear D0 to avoid residual values
    MOVE.B #5,D0
    TRAP   #15
    MOVE.B D1,D0
    RTS

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
    
    MOVE.W DIFFICULTY,D1
    CMP.W  #1,D1
    BEQ    HARD_RANDOM
    
NORMAL_RANDOM:
    CMP.W  #90,D0            ; 10% no event (90-99)
    BGE    NO_EVENT
    CMP.W  #70,D0            ; 20% good day (70-89)
    BGE    GOOD_DAY_EVENT
    CMP.W  #50,D0            ; 20% snowy (50-69)
    BGE    SNOWY_EVENT
    CMP.W  #40,D0            ; 10% drought (40-49)
    BGE    DROUGHT_EVENT
    CMP.W  #20,D0            ; 20% bee (20-39)
    BGE    BEE_EVENT
    BRA    NO_EVENT          ; 20% no event (0-19)
    
HARD_RANDOM:
    CMP.W  #90,D0            ; 10% no event (90-99)
    BGE    NO_EVENT
    CMP.W  #70,D0            ; 20% good day (70-89)
    BGE    GOOD_DAY_EVENT
    CMP.W  #50,D0            ; 20% snowy (50-69)
    BGE    SNOWY_EVENT
    CMP.W  #40,D0            ; 10% drought (40-49)
    BGE    DROUGHT_EVENT
    CMP.W  #20,D0            ; 20% bee (20-39)
    BGE    BEE_EVENT
    BRA    NO_EVENT          ; 20% no event (0-19)
    
DROUGHT_EVENT:
    MOVE.W DIFFICULTY,D1
    CMP.W  #1,D1
    BEQ    HARD_DROUGHT
    SUB.W  #10,FOOD
    SUB.W  #5,HAPPINESS
    BRA    DROUGHT_DONE
    
HARD_DROUGHT:
    SUB.W  #15,FOOD
    SUB.W  #10,HAPPINESS
    
DROUGHT_DONE:
    LEA    DROUGHT_MSG,A1
    BSR    PRINT_STRING
    BRA    EVENT_DONE

SNOWY_EVENT:
    MOVE.W DIFFICULTY,D1
    CMP.W  #1,D1
    BEQ    HARD_SNOWY
    SUB.W  #10,HAPPINESS
    MOVE.W ARMY,D0
    CMP.W  #5,D0
    BLT    SKIP_SNOWY_ARMY
    SUB.W  #5,ARMY
    BRA    SNOWY_DONE
    
HARD_SNOWY:
    SUB.W  #15,HAPPINESS
    MOVE.W ARMY,D0
    CMP.W  #8,D0
    BLT    SKIP_SNOWY_ARMY
    SUB.W  #8,ARMY
    
SNOWY_DONE:

SKIP_SNOWY_ARMY:
    LEA    SNOWY_MSG,A1
    BSR    PRINT_STRING
    BRA    EVENT_DONE

GOOD_DAY_EVENT:
    ADD.W  #15,GOLD
    ADD.W  #5,HAPPINESS
    LEA    GOOD_DAY_MSG,A1
    BSR    PRINT_STRING
    BRA    EVENT_DONE

BEE_EVENT:
    ADD.W  #10,GOLD
    ADD.W  #10,HAPPINESS
    ADD.W  #5,ARMY 
    LEA    BEE_ART,A1
    BSR    PRINT_STRING
    BRA    EVENT_DONE

NO_EVENT:
    RTS

EVENT_DONE:
    BSR    CLAMP_ZERO
    RTS
    
EXPAND_KINGDOM:
    BSR    EXIT
    MOVE.W DIFFICULTY,D1
    CMP.W  #1,D1
    BEQ    HARD_EXPAND
    MOVE.W GOLD,D0
    CMP.W  #20,D0            ; Normal
    BLT    INSUFFICIENT
    SUB.W  #20,GOLD
    BRA    EXPAND_DONE
HARD_EXPAND:
    MOVE.W GOLD,D0
    CMP.W  #30,D0            ; Hard
    BLT    INSUFFICIENT
    SUB.W  #30,GOLD
EXPAND_DONE:
    ADD.W  #10,FOOD
    ADD.W  #5,HAPPINESS
    ADD.W  #1,TURN_COUNT ; add new turn each time gameloop excutig again
    BSR    RANDOM_EVENT
    BSR    CLAMP_ZERO
    LEA    EXPAND_MSG,A1
    BSR    PRINT_STRING
    BRA    GAME_LOOP

COLLECT_TAXES:
    BSR    EXIT
    ADD.W  #15,GOLD
    MOVE.W DIFFICULTY,D1
    CMP.W  #1,D1
    BEQ    HARD_TAX
    SUB.W  #10,HAPPINESS     ; Normal
    BRA    TAX_DONE
HARD_TAX:
    SUB.W  #15,HAPPINESS     ; Hard
TAX_DONE:
    ADD.W  #1,TURN_COUNT ; add new turn each time gameloop excutig again
    BSR    RANDOM_EVENT
    BSR    CLAMP_ZERO
    LEA    TAX_MSG,A1
    BSR    PRINT_STRING
    BRA    GAME_LOOP

TRAIN_ARMY:
    BSR    EXIT
    MOVE.W DIFFICULTY,D1
    CMP.W  #1,D1
    BEQ    HARD_TRAIN
    MOVE.W GOLD,D0
    CMP.W  #10,D0            ; Normal
    BLT    INSUFFICIENT
    MOVE.W FOOD,D0
    CMP.W  #5,D0
    BLT    INSUFFICIENT
    SUB.W  #10,GOLD
    SUB.W  #5,FOOD
    BRA    TRAIN_DONE
HARD_TRAIN:
    MOVE.W GOLD,D0
    CMP.W  #15,D0            ; Hard
    BLT    INSUFFICIENT
    MOVE.W FOOD,D0
    CMP.W  #8,D0
    BLT    INSUFFICIENT
    SUB.W  #15,GOLD
    SUB.W  #8,FOOD
TRAIN_DONE:
    ADD.W  #5,ARMY
    ADD.W  #1,TURN_COUNT ; add new turn each time gameloop excutig again
    BSR    RANDOM_EVENT
    BSR    CLAMP_ZERO
    LEA    TRAIN_MSG,A1
    BSR    PRINT_STRING
    BRA    GAME_LOOP

DECLARE_WAR:
    BSR    EXIT
    MOVE.W DIFFICULTY,D1
    CMP.W  #1,D1
    BEQ    HARD_WAR
    MOVE.W ARMY,D0
    CMP.W  #10,D0            ; Normal
    BLT    INSUFFICIENT
    SUB.W  #10,ARMY
    MOVE.W RANDOM_SEED,D0
    MULU   #17,D0
    ADD.W  #11,D0
    DIVU   #100,D0
    SWAP   D0
    MOVE.W D0,RANDOM_SEED
    CMP.W  #50,D0            ; Normal: 50% win
    BGE    WAR_WIN
    BRA    WAR_LOSE
HARD_WAR:
    MOVE.W ARMY,D0
    CMP.W  #15,D0            ; Hard
    BLT    INSUFFICIENT
    SUB.W  #15,ARMY
    MOVE.W RANDOM_SEED,D0
    MULU   #17,D0
    ADD.W  #11,D0
    DIVU   #100,D0
    SWAP   D0
    MOVE.W D0,RANDOM_SEED
    CMP.W  #60,D0            ; Hard: 40% win
    BGE    WAR_WIN
    
WAR_LOSE: ;randon lose takes 10 happiness

    BSR    EXIT
    MOVE.W DIFFICULTY,D1
    CMP.W  #1,D1
    BEQ    HARD_WAR_LOSE
    SUB.W  #10,HAPPINESS     ; Normal
    MOVE.W ARMY,D0
    CMP.W  #15,D0
    BLT    SKIP_ARMY_LOSS
    SUB.W  #15,ARMY
    BRA    WAR_LOSE_DONE
HARD_WAR_LOSE:
    SUB.W  #15,HAPPINESS     ; Hard
    MOVE.W ARMY,D0
    CMP.W  #20,D0
    BLT    SKIP_ARMY_LOSS
    SUB.W  #20,ARMY
WAR_LOSE_DONE: 

SKIP_ARMY_LOSS:
    ADD.W  #1,TURN_COUNT ; add new turn each time gameloop excutig again
    BSR    RANDOM_EVENT
    BSR    CLAMP_ZERO
    LEA    BATTLE_LOSE,A1
    BSR    PRINT_STRING
    BRA    GAME_LOOP

WAR_WIN:  ;random win gives 20 gold , 5 happiness
    BSR    EXIT
    ADD.W  #20,GOLD
    ADD.W  #5,HAPPINESS
    SUB.W  #5,ARMY           ; Same in both modes
    ADD.W  #1,TURN_COUNT ; add new turn each time gameloop excutig again
    BSR    RANDOM_EVENT
    BSR    CLAMP_ZERO
    LEA    BATTLE_WIN,A1
    BSR    PRINT_STRING
    BRA    GAME_LOOP

TRADE_RESOURCES: ;trading res takes food but adds gold
    BSR    EXIT
    MOVE.W DIFFICULTY,D1
    CMP.W  #1,D1
    BEQ    HARD_TRADE
    MOVE.W FOOD,D0
    CMP.W  #15,D0            ; Normal
    BLT    INSUFFICIENT
    SUB.W  #15,FOOD
    BRA    TRADE_DONE
HARD_TRADE:
    MOVE.W FOOD,D0
    CMP.W  #20,D0            ; Hard
    BLT    INSUFFICIENT
    SUB.W  #20,FOOD
TRADE_DONE:
    ADD.W  #20,GOLD
    ADD.W  #1,TURN_COUNT
    BSR    RANDOM_EVENT ; random events will pops up randomly
    BSR    CLAMP_ZERO
    LEA    TRADE_MSG,A1
    BSR    PRINT_STRING
    BRA    GAME_LOOP

INSUFFICIENT: ; you can't trade or declare war
    BSR    EXIT
    LEA    INSUFFICIENT_MSG,A1
    BSR    PRINT_STRING
    BRA    GAME_LOOP

SAVE_EXIT: ;saving game and exit it
    LEA    EXIT_MSG,A1
    BSR    PRINT_STRING
    BRA    EXIT

WIN_GAME:
    LEA    WIN_MSG,A1
    BSR    PRINT_STRING
    
    LEA    CONTINUE_PROMPT,A1 ; New prompt for continue or exit
    BSR    PRINT_STRING
    BSR    GET_INPUT ; Get player's choice
    
    CMP.B  #'1',D0 ; '1' to continue
    BEQ    CONTINUE_GAME
    CMP.B  #'2',D0  ; '2' to exit
    BEQ    EXIT_GAME
    
    LEA    INVALID_MSG,A1 ; Invalid choice loops back
    BSR    PRINT_STRING
    BRA    WIN_GAME  ; Re-prompt on invalid input
    

CONTINUE_GAME:  ; Increase difficulty and reset turn count
    MOVE.W #0,TURN_COUNT   ; Reset turn count to 0
    MOVE.W #1,DIFFICULTY     ; Switch to hard mode
    LEA    CONTINUE_MSG,A1
    BSR    PRINT_STRING
    BRA    GAME_LOOP

EXIT_GAME:
    LEA    EXIT_MSG,A1
    BSR    PRINT_STRING
    BRA    EXIT

LOSE_GAME:
    LEA    LOSE_MSG,A1
    BSR    PRINT_STRING
    BRA    EXIT

EXIT:
    MOVEM.L D0/A1,-(A7)
    MOVE    #14,D0
    LEA     CRLF,A1
    TRAP    #15
    MOVEM.L (A7)+,D0/A1
    LEA     LINE_BREAKS,A1
    BSR    PRINT_STRING
    RTS

CLAMP_ZERO:
    MOVE.W GOLD,D0
    CMP.W  #0,D0
    BGE    CHECK_FOOD
    MOVE.W #0,GOLD
CHECK_FOOD:
    MOVE.W FOOD,D0
    CMP.W  #0,D0
    BGE    CHECK_ARMY
    MOVE.W #0,FOOD
CHECK_ARMY:
    MOVE.W ARMY,D0
    CMP.W  #0,D0
    BGE    CHECK_HAPPINESS
    MOVE.W #0,ARMY
CHECK_HAPPINESS:
    MOVE.W HAPPINESS,D0
    CMP.W  #0,D0
    BGE    CLAMP_DONE
    MOVE.W #0,HAPPINESS
CLAMP_DONE:
    RTS

    SIMHALT

* -------------------
* Data Section
* -------------------
CRLF:         DC.B   $0D,$0A,0
TITLE_MSG     DC.B  '************************************************************'
              DC.B  $0D,$0A
              DC.B '                             |~~[   ]     ' , $0D, $0A
              DC.B '                             |            ' , $0D, $0A
              DC.B '                            |-|           ' , $0D, $0A
              DC.B '                            |-|           ' , $0D, $0A
              DC.B '                            |-|           ' , $0D, $0A
              DC.B '                          []---[]         ' , $0D, $0A
              DC.B '                        _/  ___  \_       ' , $0D, $0A
              DC.B '                       |    ===    |      ' , $0D, $0A
              DC.B '                       |  _[===]_  |      ' , $0D, $0A
              DC.B '                       |  |=====|  |      ' , $0D, $0A
              DC.B '                       |   || ||   |      ' , $0D, $0A
              DC.B '     [][][]=======[][][]=====[]=====[][][]=======[][][]' , $0D, $0A
              DC.B '     [][][]       [][][]     ||     [][][]       [][][]' , $0D, $0A
              DC.B '     [][][]       [][][]     ||     [][][]       [][][]' , $0D, $0A
              DC.B '     []  []       []  []    /  \    []  []       []  []' , $0D, $0A
              DC.B '     []  []       []  []    \__/    []  []       []  []' , $0D, $0A
              DC.B '     []  []       []  []            []  []       []  []' , $0D, $0A
              DC.B  $0D,$0A
              DC.B  '                 Game Of Tiny Thrones: Strategy RPG',10,13,0
              DC.B  $0D,$0A
              DC.B  $0D,$0A
              DC.B  '************************************************************'
              DC.B  $0D,$0A,0
              
LINE_BREAKS   DC.B  '************************',10,13,0
PROMPT_MSG    DC.B  'Actions: 1) Expand   2)Tax   3)Train  4)War   5)Trade   6)Exit',10,13,0
INPUT_PROMPT_MSG DC.B 'Enter your choice (1-6): ',10,13,0
WIN_MSG       DC.B  $0D,$0A
              DC.B '              |~~[   ]                       |~~[   ]' ,$0D,$0A
              DC.B '              |              |~~[   ]        |' ,$0D,$0A
              DC.B '             [-]             |              [-]' ,$0D,$0A
              DC.B '             |-|            |-|             |-|' ,$0D,$0A
              DC.B '             |-|            |-|             |-|' ,$0D,$0A
              DC.B '             |-|            |-|             |-|' ,$0D,$0A
              DC.B '             |-|          []---[]           |-|' ,$0D,$0A 
              DC.B '          __/   \________/  ___  \_________/   \___' ,$0D,$0A
              DC.B '         /|       |    |    ===     |    |        |\' ,$0D,$0A
              DC.B '        / | [] [] |    |  _[===]_   |    |  [] [] | \' ,$0D,$0A
              DC.B '       /  |  ||   |    |  |=====|   |    |    ||  |  \' ,$0D,$0A
              DC.B '      /  /|  ||   |    |   || ||    |    |    ||  |   \' ,$0D,$0A
              DC.B '     [][][]==__===[][][]=====[]=====[][][]===__==[][][]' ,$0D,$0A
              DC.B '     [][][] /__\  [][][]\    ||    /[][][]  /__\ [][][]' ,$0D,$0A
              DC.B '     [][][]_\__/_ [][][] \   ||   / [][][]__\__/_[][][]' ,$0D,$0A
              DC.B '     []  []  \/   []  []  \_/  \_/  []  []   \/  []  []' ,$0D,$0A
              DC.B '     []  []       []  []    \__/    []  []       []  []' ,$0D,$0A
              DC.B '     []  []       []  []            []  []       []  []' ,$0D,$0A
              DC.B '               Your kingdom thrives! Victory!          ',10,13,0
              DC.B  $0D,$0A
              
LOSE_MSG      DC.B  $0D,$0A
              DC.B '               |~~[  # ]    # ## ##          ## #  ##    |~~    ' ,$0D,$0A
              DC.B '              |         #  #   |#~~        ###    # |   ' ,$0D,$0A
              DC.B '             [-      #  ## ###    |         #   **#   [-    ' ,$0D,$0A
              DC.B '             |    #    ###*  ###    |-#|    ##  ##  * ###    |-|    ' ,$0D,$0A
              DC.B '             |      ## #*#     |-    #        # # |-|   ' ,$0D,$0A
              DC.B '             |  ###  #  ##      |         ##      |###-|    ' ,$0D,$0A
              DC.B '             |  #  #*#      []---#        ####     *|-|#    ' ,$0D,$0A
              DC.B '          __/  # \______    __      * ##   # #_/   \    ' ,$0D,$0A
              DC.B '         /|  # #  #  ##|    |    =      #     |   ##  | ' ,$0D,$0A
              DC.B '        / | []   ## |    |  _[=_     ##     | [**] # |  ' ,$0D,$0A
              DC.B '       /  |  ||#   |    |  |==       ####    | ||  ##|  ' ,$0D,$0A
              DC.B '      /  /|  ||   *   ###  |   ||  ###         | *||  | ' ,$0D,$0A
              DC.B '     [][][]==__===[] []===#==[]==##=#[]**#*# []===__=[] ' ,$0D,$0A
              DC.B '     [] [**] /__\  [] [] \    ||   / []## [] */_###\ **[]' ,$0D,$0A
              DC.B '     []    \**__/_ [] []  \   || ## /  []    \__/_ ******' ,$0D,$0A
              DC.B '     [] []  \/   [] []   \**_/  \_/  [] []  \/          ' ,$0D,$0A
              DC.B '     []          [] []    \ /    [] []        []     ' ,$0D,$0A
              DC.B '     [] []       []          __    [] []             ' ,$0D,$0A
              DC.B '           Your kingdom has collapsed. Game Over.    ',10,13,0
              DC.B  $0D,$0A 
 
              
              
CONTINUE_PROMPT DC.B $0D,$0A,'YOU WON! Do you wish to continue? but with harder difficulty! (1 = Yes, 2 = No): ',10,13,0
CONTINUE_MSG  DC.B  $0D,$0A
              DC.B '             Game continues with increased difficulty!',10,13,0
              DC.B  $0D,$0A
BATTLE_WIN    DC.B  ' You won the battle!',10,13,0
BATTLE_LOSE   DC.B  ' You lost the battle!',10,13,0
DROUGHT_MSG   DC.B  $0D,$0A,' **** A drought strikes! Food and happiness decrease. ****',10,13,0
SNOWY_MSG     DC.B  $0D,$0A,' **** Snowy weather hits! Happiness and army suffer. ****',10,13,0  ; Fixed typo ($0AA to $0A)
GOOD_DAY_MSG  DC.B  $0D,$0A,' **** A good day brings extra fortune! ****',10,13,0
 
BEE_ART       DC.B  $0D,$0A
              DC.B '(> (___)' ,$0D,$0A
              DC.B ' \(o^-^o)' ,$0D,$0A
              DC.B ' (")O O(")' ,$0D,$0A
 DC.B ' **** A friendly bee visits! Buzz buzz! ****',10,13,0

EXPAND_MSG    DC.B  'Kingdom expanded!',10,13,0
TAX_MSG       DC.B  'Taxes collected!',10,13,0
TRAIN_MSG     DC.B  'Army trained!',10,13,0
TRADE_MSG     DC.B  'Resources traded!',10,13,0
EXIT_MSG      DC.B  'Game saved. Goodbye!',10,13,0
INVALID_MSG   DC.B  'Invalid choice! Try again.',10,13,0
INSUFFICIENT_MSG DC.B ' Insufficient resources!',10,13,0
TURN_LABEL    DC.B  $0D,$0A,'Turn:',0
GOLD_LABEL    DC.B  $0D,$0A,'Gold:',0
FOOD_LABEL    DC.B  $0D,$0A,'Food:',0
ARMY_LABEL    DC.B  $0D,$0A,'Army:',0
HAPPINESS_LABEL DC.B $0D,$0A,'Happiness:',0

    END    START

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
