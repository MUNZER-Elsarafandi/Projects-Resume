    ORG $1000  ; Start of the program

BUFFER  DS.B 80  ; Reserve 80 bytes for input buffer

START:
    ; Task 1: Display string (A1),
    LEA MESSAGE, A1
    MOVE.B #14, D0   
    TRAP #15         ;

    ; Task 2: Display string at (A1)
    LEA MESSAGE, A1
    MOVE.B #14, D0
    TRAP #15         

    ; Task 3: Read string from keyboard and store in (A1)
    LEA BUFFER, A1
    MOVE.W #80, D1   
    TRAP #3

    ; Display the entered string
    LEA BUFFER, A1
    MOVE.B #14, D0
    TRAP #15

    ; Task 4: Display signed number in D1.L
    MOVE.L #1234, D1
    TRAP #4

    ; Task 5: Read number from keyboard into D1.L
    TRAP #5

    ; Task 6: Read single character into D1.B
    TRAP #6

    ; Task 7: Check if keyboard input is pending
    TRAP #7

    ; Task 8: Read pending key using Task 5
    TRAP #5

    ; Task 9: Get system time
    TRAP #9

    ; Task 10: Display "HI HI HI!"
    LEA MSGH, A1
    MOVE.B #14, D0
    TRAP #15         ; Print message

    ; End program
    TRAP #10         ; Terminates the program

MESSAGE DC.B 'Hello, World!',13,10, 0  
MSGH    DC.B 'HI HI HI!',13,10, 0      

    END START

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
