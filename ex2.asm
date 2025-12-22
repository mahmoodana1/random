LIST        P=16F877
INCLUDE     <P16F877.INC>

TENS        EQU 0x20      ; BCD tens digit (09)
UNITS       EQU 0x21      ; BCD units digit (09)
TEMP        EQU 0x23      ; Temporary storage

        ORG 0x0000
        GOTO MAIN

MAIN:
    
    ;Bank 1 - Configure I/O
    BSF     STATUS, RP0
    BCF     STATUS, RP1
    MOVLW   0xFF           ; PORTA = input
    MOVWF   TRISA
    CLRF    TRISD          ; PORTD = output
    MOVLW   0x04
    MOVWF   PORTA
    
    ;Bank 0 - Initialize variables
    BCF     STATUS, RP0
    CLRF    TENS
    CLRF    UNITS
    CLRF    PORTD
    BSF     PORTA, RA2

LOOP:
    ; Read RA2 current state
    MOVF    PORTA, W
    ANDLW   0b00000100     ; isolate RA2 bit
    MOVWF   TEMP
    
    ; Check if RA2 is HIGH (switch ON) or LOW (switch OFF)
    BTFSS   TEMP, 2        ; Test bit 2
    GOTO    COUNT_DOWN     ; If bit 2 = 0 ? count down
    
    ; RA2 is HIGH ? COUNT UP
    INCF    UNITS, F       ; units++
    MOVLW   10
    SUBWF   UNITS, W       ; compare UNITS with 10
    BTFSS   STATUS, Z
    GOTO    UPDATE_PORTD   ; if not 10 ? continue
    
    ; Units rolled over to 10
    CLRF    UNITS
    INCF    TENS, F
    MOVLW   10
    SUBWF   TENS, W
    BTFSS   STATUS, Z
    GOTO    UPDATE_PORTD
    
    ; Tens also rolled over ? reset to 00
    CLRF    TENS
    GOTO    UPDATE_PORTD
    
COUNT_DOWN:
    ; RA2 is LOW ? COUNT DOWN
    DECF    UNITS, F       ; units--
    BTFSS   STATUS, Z      ; Check if UNITS became 0xFF (underflow)
    GOTO    UPDATE_PORTD   ; if not underflow ? continue
    
    ; Units underflowed (went below 0)
    MOVLW   9
    MOVWF   UNITS          ; set to 9
    DECF    TENS, F        ; tens--
    BTFSS   STATUS, Z      ; Check if TENS became 0xFF
    GOTO    UPDATE_PORTD
    
    ; Tens also underflowed ? reset to 99
    MOVLW   9
    MOVWF   TENS
    MOVLW   9
    MOVWF   UNITS

; -------------------------------
; UPDATE PORTD WITH PACKED BCD
; -------------------------------
UPDATE_PORTD:
    ; PORTD = (TENS << 4) | UNITS
    MOVF    TENS, W
    SWAPF   TENS, W        ; swap nibbles = shift left 4 bits
    ANDLW   0xF0           ; keep only upper nibble
    MOVWF   PORTD
    
    MOVF    UNITS, W
    IORWF   PORTD, F       ; combine UNITS in lower nibble
    
    GOTO LOOP

    END
