byte "NES",$1a                          ; basically "NES" plus a terminator
byte $01                                ; 1x16 PRG-ROM block ($c000)
byte $01                                ; 1 CHR-ROM block
byte $00                                ; dontcare
byte $00                                ; dontcare
dsb 8                                   ; 8 bytes padding

;;;;;;;;;;;;;;;;var
;cardnum equ $00
;cardsui equ $01
;seed equ $02

;;;;;;;;;;;;;;;;init
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
  STA $0300, x
  STA $0400, x
  STA $0500, x
  STA $0600, x
  STA $0700, x
  LDA #$FE
  STA $0200, x    ;move all sprites off screen
  INX
  BNE clrmem
   
vblankwait2:      ; Second wait for vblank, PPU is ready after this
  BIT $2002
  BPL vblankwait2
  
;;;;;;;;;;;program

;prng

;prng:
;seed = a
;ldx #1
;lda seed+0
;asl
;rol seed+1
;bcc :+
;eor #$2D
;dex
;bne :--
;sta seed+0
;sta cardnum
;cmp #0
;rts

ldPalettes:
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
  LDX #$00              ; start at 0
LoadSpritesLoop:
  LDA sprites, x        ; load data from address (sprites +  x)
  STA $0200, x          ; store into RAM address ($0200 + x)
  INX                   ; X = X + 1
  CPX #$10              ; Compare X to hex $10, decimal 16
  BNE LoadSpritesLoop   ; Branch to LoadSpritesLoop if compare was Not Equal to zero
                        ; if compare was equal to 16, keep going down
             
              
              
  LDA #%10010000   ; enable NMI, sprites from Pattern Table 0, background from Pattern Table 1
  STA $2000

  LDA #%00011110   ; enable sprites, enable background, no clipping on left side
  STA $2001

Forever:
  JMP Forever     ;jump back to Forever, infinite loop
  
 

NMI:
  LDA #$00
  STA $2003       ; set the low byte (00) of the RAM address
  LDA #$02
  STA $4014       ; set the high byte (02) of the RAM address, start the transfer
;;;;;;;;;;;
	.org $E000
palette:
  .db $0F,$06,$27,$26,$0F,$2D,$20,$15,$0F,$2D,$20,$15
  .db $0F,$2D,$20,$15,$0F,$2D,$20,$15,$0F,$2D,$20,$15

sprites:
     ;vert tile attr horiz
  .db $80, $00, $00, $80   ;sprite 0
  .db $81, $01, $00, $80   ;sprite 1
  .db $82, $00, %01000000, $80   ;sprite 2
  .db $80, $01, $00, $81   ;sprite 3
  .db $81, $00, $00, $81   ;sprite 4
  .db $82, $00, $00, $81   ;sprite 5
  .db $80, $01, %10000000, $82   ;sprite 6
  .db $81, $01, $00, $82   ;sprite 7
  .db $82, $00, %11000000, $82   ;sprite 8
  
.incbin "cards.chr"
;.incbin "cards.nam"