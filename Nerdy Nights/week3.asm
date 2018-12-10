; NintendoAge Nerdy Nights Week 3 - Background

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


  LDA #%10000000   ;intensify blues
  STA $2001

Forever:
  JMP Forever     ;jump back to Forever, infinite loop



NMI:
  RTI

IRQ:
  RTI

;;;;;;;;;;;;;;

; vector declarations

  .org $FFFA     ;first of the three vectors starts here
  .dw NMI        ;when an NMI happens (once per frame if enabled) the
                   ;processor will jump to the label NMI:
  .dw RESET      ;when the processor first turns on or is reset, it will jump
                   ;to the label RESET:
  .dw IRQ          ;external interrupt IRQ (just rti for now)


;;;;;;;;;;;;;;

  .incbin "mario.chr"   ;includes 8KB graphics file from SMB1