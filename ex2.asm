LIST        P=16F877
INCLUDE     <P16F877.INC>

; -----------------------
; RAM VARIABLES
; -----------------------
TENS        EQU 0x20      ; BCD tens digit (0–9)
UNITS       EQU 0x21      ; BCD units digit (0–9)
OLD_PA2     EQU 0x22      ; Previous RA2 state
TEMP        EQU 0x23      ; Temporary storage

        ORG 0x0000
        GOTO MAIN

MAIN:
    ; -------- Bank 1 --------
    BSF     STATUS, RP0
    BCF     STATUS, RP1

    MOVLW   0xFF
    MOVWF   TRISA          ; PORTA input

    CLRF    TRISD          ; PORTD output

    ; -------- Bank 0 --------
    BCF     STATUS, RP0

    CLRF    TENS
    CLRF    UNITS
    CLRF    PORTD

    ; Read initial RA2 state
    MOVF    PORTA, W
    ANDLW   0b00000100
    MOVWF   OLD_PA2

; =========================
; MAIN LOOP
; =========================
LOOP:
    ; Read RA2
    MOVF    PORTA, W
    ANDLW   0b00000100
    MOVWF   TEMP

    ; Check if changed
    XORWF   OLD_PA2, W
    BTFSC   STATUS, Z
    GOTO    LOOP            ; no change

    ; Store new state
    MOVF    TEMP, W
    MOVWF   OLD_PA2

    ; -----------------------
    ; BCD INCREMENT
    ; -----------------------
    INCF    UNITS, F

    MOVLW   d'10'
    SUBWF   UNITS, W
    BTFSS   STATUS, Z
    GOTO    UPDATE_PORTD

    CLRF    UNITS
    INCF    TENS, F

    MOVLW   d'10'
    SUBWF   TENS, W
    BTFSS   STATUS, Z
    GOTO    UPDATE_PORTD

    CLRF    TENS

; -----------------------
; PACK BCD → PORTD
; -----------------------
UPDATE_PORTD:
    SWAPF   TENS, W        ; TENS << 4
    ANDLW   0xF0
    MOVWF   PORTD

    MOVF    UNITS, W
    IORWF   PORTD, F

    GOTO    LOOP

    END
