	processor 6502
	include includes/vcs.h
	include includes/macro.h

	org $F000


Start
	
	CLEAN_START

; Variables	
DinoVerticalVelocity = $80
DinoVerticalPos = $81
DinoVerticalDelay = $82
DinoBitmapBuffer = $83
DinoLineBeingDraw = $84
DinoBitmapLocation = $85 ; it takes 2 bytes
VarButtonLock = $87;
DinoAnimateSpriteBitmap = $88
DinoAnimateSpriteDelay = $89

; Constants
GroundVerticalPos = 65
DinoAnimateSpriteFramesDelay = 8
	
	; Set background color to light blue
	lda #$9C
	sta COLUBK

	lda #$C2
	sta COLUP0
	
	lda #$E2
	sta COLUPF

	lda #0
	sta DinoVerticalDelay
	sta VarButtonLock

	lda #GroundVerticalPos
	sta DinoVerticalPos
	
	lda #DinoAnimateSpriteFramesDelay
	sta DinoAnimateSpriteDelay

	lda #0
	sta DinoVerticalVelocity

FrameLoop

	VERTICAL_SYNC
	
	lda #43
	sta TIM64T
	
	lda #$00
	sta PF0
	sta PF1
	sta PF2
	
	jsr AnimateDinoSprite
	jsr HandleDinoJump
	
	sta WSYNC
	SLEEP 30
	sta RESP0

WaitForVblankEnd
	lda INTIM
	bne WaitForVblankEnd
	lda #0
	sta WSYNC
	sta VBLANK

	ldy #0

ScanlineLoop
	sta WSYNC

	lda DinoBitmapBuffer
	sta GRP0

  lda #0
  sta DinoBitmapBuffer

	cpy DinoVerticalPos
	bne SkipDinoDrawBegin
	
	lda #14
	sta DinoLineBeingDraw	

SkipDinoDrawBegin

  tya
  tax
	ldy DinoLineBeingDraw
	beq FinishDraw

  lda (DinoBitmapLocation),Y
	sta DinoBitmapBuffer
	dec DinoLineBeingDraw
	
FinishDraw

	sta WSYNC

  txa
  tay
	iny
	cpy #80
	bne ScanlineLoop
	
	lda #0
	sta GRP0
	
	lda #$FF
	sta PF0
	sta PF1
	sta PF2
	
	ldy #20
GroundScanlineLoop
	sta WSYNC
	dey 
	bne GroundScanlineLoop

	; Overscan
	lda #2
	sta WSYNC
	sta HMOVE
	sta VBLANK
	ldx #30
OverScanWait
	sta WSYNC
	dex
	bne OverScanWait
	
	jmp FrameLoop

	include dino.asm
	include data/bitmaps.asm
	
	org $FFFC
	.word Start
	.word Start
