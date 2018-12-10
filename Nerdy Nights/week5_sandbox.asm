; NintendoAge Nerdy Nights Week 5 - Controller

; modified to assemble with ASM6 (and possibly other) assemblers

; away with those .ines directives, this assembler will use a header instead

byte "NES",$1a                          ; basically "NES" plus a terminator
byte $01                                ; 1x16 PRG-ROM block ($c000)
byte $01                                ; 1 CHR-ROM block
byte $00                                ; dontcare
byte $00                                ; dontcare
dsb 8                                   ; 8 bytes padding

;;;;;;;;;;;;;;;

; away with .bank directives
  .org $C000 
RESET:
  SEI          ; disable IRQs
  CLD          ; disable decimal mode
  LDX #$40
  STX $4017    ; disable APU frame IRQ
  LDX #$FF
  TXS          ; Set up stack
  INX          ; now X = 0
  STX $2000    ; disable NMI
  STX $2001    ; disable rendering
  STX $4010    ; disable DMC IRQs

vblankwait1:       ; First wait for vblank to make sure PPU is ready
  BIT $2002
  BPL vblankwait1

clrmem:
  LDA #$00
  STA $0000, x
  STA $0100, x
  STA $0200, x
  STA $0400, x
  STA $0500, x
  STA $0600, x
  STA $0700, x
  LDA #$FE
  STA $0300, x
  INX
  BNE clrmem
   
vblankwait2:      ; Second wait for vblank, PPU is ready after this
  BIT $2002
  BPL vblankwait2


LoadPalettes:
  LDA $2002             ; read PPU status to reset the high/low latch
  LDA #$3F
  STA $2006             ; write the high byte of $3F00 address
  LDA #$00
  STA $2006             ; write the low byte of $3F00 address
  LDX #$00              ; start out at 0
LoadPalettesLoop:
  LDA palette, x        ; load data from address (palette + the value in x)
                          ; 1st time through loop it will load palette+0
                          ; 2nd time through loop it will load palette+1
                          ; 3rd time through loop it will load palette+2
                          ; etc
  STA $2007             ; write to PPU
  INX                   ; X = X + 1
  CPX #$20              ; Compare X to hex $10, decimal 16 - copying 16 bytes = 4 sprites
  BNE LoadPalettesLoop  ; Branch to LoadPalettesLoop if compare was Not Equal to zero
                        ; if compare was equal to 32, keep going down



LoadSprites:
  LDX #$00              ; set x to 0
LoadSpritesLoop:
  LDA sprites, x        ; load data from address (sprites +  x)
  STA $0200, x          ; store into RAM address ($0200 + x)
  INX                   ; X = X + 1
  CPX #$20              ; Compare X to hex $20, decimal 32
  BNE LoadSpritesLoop   ; Branch to LoadSpritesLoop if compare was Not Equal to zero
                        ; if compare was equal to 32, keep going down
              
              

  LDA #%10000000   ; enable NMI, sprites from Pattern Table 1
  STA $2000

  LDA #%00010000   ; enable sprites
  STA $2001

Forever:
  JMP Forever     ;jump back to Forever, infinite loop
  
 

NMI:
  LDA #$00
  STA $2003       ; set the low byte (00) of the RAM address
  LDA #$02
  STA $4014       ; set the high byte (02) of the RAM address, start the transfer


LatchController:
  LDA #$01
  STA $4016
  LDA #$00
  STA $4016       ; tell both the controllers to latch buttons


ReadA: 
  LDA $4016       ; player 1 - A
  AND #%00000001  ; only look at bit 0
ReadB:
  LDA $4016       ; player 1 - A
  AND #%00000001  ; only look at bit 0
ReadSel:
  LDA $4016       ; player 1 - A
  AND #%00000001  ; only look at bit 0
ReadSta:
  LDA $4016       ; player 1 - A
  AND #%00000001  ; only look at bit 0
  ReadD:
  LDA $4016       ; player 1 - A
  AND #%00000001  ; only look at bit 0
  BEQ ReadDDone   ; branch to ReadBDone if button is NOT pressed (0)
                  ; add instructions here to do something when button IS pressed (1)
  LDA $0200      ; load sprite X position
  SEC             ; make sure carry flag is set
  SBC #$01        ; A = A - 1
  STA $0200       ; save sprite X position
  LDA $0204       ; load sprite X position
  SEC             ; make sure carry flag is set
  SBC #$01        ; A = A - 1
  STA $0204       ; save sprite X position
  LDA $0208       ; load sprite X position
  SEC             ; make sure carry flag is set
  SBC #$01        ; A = A - 1
  STA $0208      ; save sprite X position
  LDA $020C       ; load sprite X position
  SEC             ; make sure carry flag is set
  SBC #$01        ; A = A - 1
  STA $020C       ; save sprite X position
ReadDDone:        ; handling this button is done
ReadU:
  LDA $4016       ; player 1 - R
  AND #%00000001  ; only look at bit 0
  BEQ ReadUDone   ; branch to ReadADone if button is NOT pressed (0)
                  ; add instructions here to do something when button IS pressed (1)
  LDA $0200
  CLC             ; make sure the carry flag is clear
  ADC #$01        ; A = A + 1
  STA $0200
  LDA $0204
  CLC             ; make sure the carry flag is clear
  ADC #$01        ; A = A + 1
  STA $0204
  LDA $0208
  CLC             ; make sure the carry flag is clear
  ADC #$01        ; A = A + 1
  STA $0208
  LDA $020C
  CLC             ; make sure the carry flag is clear
  ADC #$01        ; A = A + 1
  STA $020C ; load sprite X position
ReadUDone:


  ReadL: 
  LDA $4016       ; player 1 - B
  AND #%00000001  ; only look at bit 0
  BEQ ReadLDone   ; branch to ReadBDone if button is NOT pressed (0)
                  ; add instructions here to do something when button IS pressed (1)
  LDA $0203       ; load sprite X position
  SEC             ; make sure carry flag is set
  SBC #$01        ; A = A - 1
  STA $0203       ; save sprite X position
  LDA $0207       ; load sprite X position
  SEC             ; make sure carry flag is set
  SBC #$01        ; A = A - 1
  STA $0207       ; save sprite X position
  LDA $020B       ; load sprite X position
  SEC             ; make sure carry flag is set
  SBC #$01        ; A = A - 1
  STA $020B      ; save sprite X position
  LDA $020F       ; load sprite X position
  SEC             ; make sure carry flag is set
  SBC #$01        ; A = A - 1
  STA $020F       ; save sprite X position
ReadLDone:        ; handling this button is done
  
  ReadR:  
  LDA $4016       ; player 1 - R
  AND #%00000001  ; only look at bit 0
  BEQ ReadRDone   ; branch to ReadADone if button is NOT pressed (0)
                  ; add instructions here to do something when button IS pressed (1)
  LDA $0203
  CLC             ; make sure the carry flag is clear
  ADC #$01        ; A = A + 1
  STA $0203
  LDA $0207
  CLC             ; make sure the carry flag is clear
  ADC #$01        ; A = A + 1
  STA $0207
  LDA $020B
  CLC             ; make sure the carry flag is clear
  ADC #$01        ; A = A + 1
  STA $020B
  LDA $020F
  CLC             ; make sure the carry flag is clear
  ADC #$01        ; A = A + 1
  STA $020F ; load sprite X position

ReadRDone:        ; handling this button is done
  




  
  RTI             ; return from interrupt
 
;;;;;;;;;;;;;;  
  
  
  

  .org $E000
palette:
  .db $0F,$31,$32,$33,$34,$35,$36,$37,$38,$39,$3A,$3B,$3C,$3D,$3E,$0F
  .db $0F,$1C,$15,$14,$31,$02,$38,$3C,$0F,$1C,$15,$14,$31,$02,$38,$3C

sprites:
     ;vert tile attr horiz
  .db $80, $32, $00, $80   ;sprite 0
  .db $80, $33, $00, $88   ;sprite 1
  .db $88, $34, $00, $80   ;sprite 2
  .db $88, $35, $00, $88   ;sprite 3

  .org $FFFA     ;first of the three vectors starts here
  .dw NMI        ;when an NMI happens (once per frame if enabled) the 
                   ;processor will jump to the label NMI:
  .dw RESET      ;when the processor first turns on or is reset, it will jump
                   ;to the label RESET:
  .dw 0          ;external interrupt IRQ is not used in this tutorial
  
  
;;;;;;;;;;;;;;  

  .incbin "mario.chr"   ;includes 8KB graphics file from SMB1