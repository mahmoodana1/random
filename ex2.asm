LIST        P=16F877
INCLUDE     <P16F877.INC>

TENS        EQU 0x20      ; BCD tens digit (0–9)
UNITS       EQU 0x21      ; BCD units digit (0–9)
OLD_PA2     EQU 0x22      ; Store previous PA2 state

        ORG 0x0000
        GOTO MAIN

MAIN:
    
    ;Bank 1
    BSF     STATUS, RP0
    BCF     STATUS, RP1

    MOVLW   0xFF           ; PORTA = input
    MOVWF   TRISA

    CLRF    TRISD          ; PORTD = output

    ;Bank 0
    BCF     STATUS, RP0

    CLRF    TENS
    CLRF    UNITS
    CLRF    PORTD

    MOVF    PORTA, W
    ANDLW   0b00000100     ; isolate RA2 bit
    MOVWF   OLD_PA2

LOOP:

    ; Read RA2
    MOVF    PORTA, W
    ANDLW   0b00000100
    MOVWF   0x23            ; TEMP

    ; Compare with old value
    XORWF   OLD_PA2, W
    BTFSC   STATUS, Z
    GOTO    LOOP            ; No change → keep waiting

    ; PA2 changed → store new state
    MOVF    0x23, W
    MOVWF   OLD_PA2

    ; -----------------------
    ; PERFORM BCD INCREMENT
    ; -----------------------

    INCF    UNITS, F        ; units++

    MOVLW   10
    SUBWF   UNITS, W        ; compare UNITS with 10
    BTFSS   STATUS, Z
    GOTO    UPDATE_PORTD    ; if not 10 → continue

    ; Units rolled over
    CLRF    UNITS
    INCF    TENS, F

    MOVLW   10
    SUBWF   TENS, W
    BTFSS   STATUS, Z
    GOTO    UPDATE_PORTD

    ; Tens also rolled over → reset to 00
    CLRF    TENS

; -------------------------------
; UPDATE PORTD WITH PACKED BCD
; -------------------------------
UPDATE_PORTD:

    ; PORTD = (TENS << 4) | UNITS

    MOVF    TENS, W
    SWAPF   TENS, W         ; swap high/low nibble = shift left 4 bits
    ANDLW   0xF0            ; keep only upper nibble
    MOVWF   PORTD

    MOVF    UNITS, W
    IORWF   PORTD, F        ; combine with units

    GOTO LOOP

    END
