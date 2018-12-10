;;header
  byte "NES",$1A
  byte $01
  byte $01
  byte $00
  byte $00
  dsb 8
;;variables
buttons equ $00

;;PRG
  .org $C000

vblank:
  BIT $2002
  BPL vblank
  RTS

LatchController:
  LDA #$01
  STA $4016
  LDA #$00
  STA $4016
  RTS
ReadController:
  LDA #$01
  STA $4016
  LDA #$00
  STA $4016
  LDX #$08
  RTS
ReadControllerLoop:
  LDA $4016
  LSR A           ; Rotate all bits to the right, thus dropping the carry flag
  ROL buttons     ; Rotate bits back to the right. Currently unsure why buttons is being called
  DEX
  BNE ReadControllerLoop
  RTS
  
RESET:
  SEI
  CLD
  LDX #$40
  STX $4017
  LDX #$FF
  TXS
  INX
  STX $2000
  STX $2001
  STX $4010
	
 JSR vblank
    
  
clrmem:
  LDA #$00
  STA $0000, x
  STA $0100, x
  STA $0200, X
  STA $0400, x
  STA $0500, x
  STA $0600, x
  STA $0700, x
  LDA #$FE
  STA $0300, x
  INX
  BNE clrmem
    
  JSR vblank
  
ldPal:
  LDA $2002
  LDA #$3F
  STA $2006
  LDA #$00
  STA $2006
  LDX #$00
ldPalLoop:
  LDA palette, x
  STA $2007
  INX
  CPX #$20
  BNE ldPalLoop
	
ldSprites:
  LDX #$00
ldSpritesLoop:
  LDA sprites, x
  STA $0200, x
  INX
  CPX #$40
  BNE ldSpritesLoop
	
  LDA #%10000000	;enable NMI, Patern Table 0
  STA $2000
	
  LDA #%10010000	;enable sprites
  STA $2001	
  
JSR LatchController  
  
ReadA: 
  JSR ReadController	; player 1 - A
  LDA buttons
  AND #%00000001  ; only look at bit 0
  BEQ ReadADone   ; branch to ReadADone if button is NOT pressed (0)
  				; add instructions here to do something when button IS pressed (1)
  LDA $0203
  CLC
  ADC #$01  ; load sprite X position
  STA $0203       ; save sprite X position
ReadADone:        ; handling this button is done
  
RTI
;;chr rom
  .org $E000
palette:
  .db $0F,$06,$27,$26,$0F,$2D,$20,$15,$0F,$2D,$20,$15,$0F,$2D,$20,$15
  .db $0F,$06,$27,$26,$0F,$2D,$20,$15,$0F,$2D,$20,$15,$0F,$2D,$20,$15
  
sprites:
	;vert tile attr horiz
  .db $80, $00, $00, $80  
  .db $88, $02, $00, $80   
  .db $90, $03, $00, $80   
  .db $80, $01, $00, $88   
  .db $88, $04, $00, $88  
  .db $90, $01, $00, $88   
  .db $80, $05, $00, $90   
  .db $88, $01, $00, $90   
  .db $90, $09, $00, $90
  .db $80, $12, $00, $98
  .db $88, $08, $00, $98
  .db $90, $13, $00, $98
  .db $98, $01, $00, $80
  .db $98, $01, $00, $88
  .db $98, $01, $00, $90
  .db $98, $01, $00, $98
  
Forever:
  JMP Forever
	
NMI:
  LDA #$00
  STA $2003
  LDA #$02
  STA $4014
	
  RTI
  

 
  .org $FFFA
  
  .dw NMI		;when NMI happens
  
  .dw RESET	;when processor resets
  
  .dw 0 		
  
  .incbin "cards.chr"