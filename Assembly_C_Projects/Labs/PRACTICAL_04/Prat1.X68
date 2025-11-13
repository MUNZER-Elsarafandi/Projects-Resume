
    ORG    $1000
START:                

    ; Move Health to Memory Location $3000
    MOVE.B #100, $3000

    ; Load Memory Address $3000 into
    ; Address Register A1
    LEA    $3000, A1

    ; Hit by NPC
    ; Non Player Character
    SUB.B   #20, (A1)

    ;   Pickup Health Found
    ADD.B   #10, (A1)
    SIMHALT             



    END    START        

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
