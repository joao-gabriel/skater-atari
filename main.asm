	processor 6502
	include includes/vcs.h
	include includes/macro.h

	org $F000


Start
	
	CLEAN_START

; Variables	
SkaterVerticalVelocity = $80
SkaterVerticalPos = $81
SkaterVerticalDelay = $82
SkaterBitmapBuffer = $83
SkaterLineBeingDraw = $84
SkaterBitmapLocation = $85 ; it takes 2 bytes

; Constants
GroundVerticalPos = 74

	
	; Set background color to light blue
	lda #$9C
	sta COLUBK

	lda #0
	sta SkaterVerticalDelay

	lda #GroundVerticalPos-1
	sta SkaterVerticalPos

	lda #-5
	sta SkaterVerticalVelocity

FrameLoop

	VERTICAL_SYNC
	
	lda #43
	sta TIM64T
	
	; Skater bitmap location
  lda #<SkaterStanding
  sta SkaterBitmapLocation
  lda #>SkaterStanding
  sta SkaterBitmapLocation + 1
	
	
	lda SkaterVerticalVelocity
	adc SkaterVerticalPos
	sta SkaterVerticalPos
	
	lda #65
	adc SkaterVerticalDelay
	cmp #$ff
	bvc DontAdjustVerticalVelocity
	
	lda SkaterVerticalVelocity
	adc #1
	sta SkaterVerticalVelocity
	
DontAdjustVerticalVelocity

	sta SkaterVerticalDelay

	; Check if Skater is touching the ground
	lda SkaterVerticalPos
	cmp #GroundVerticalPos
	bcc DontResetJump

	; Reset Jump
	lda #0
	sta SkaterVerticalDelay

	lda #GroundVerticalPos-1
	sta SkaterVerticalPos

	lda #-5
	sta SkaterVerticalVelocity

DontResetJump
	

WaitForVblankEnd
	lda INTIM
	bne WaitForVblankEnd
	lda #0
	sta WSYNC
	sta HMOVE
	sta VBLANK

	ldy #0
ScanlineLoop
	sta WSYNC

	lda SkaterBitmapBuffer
	sta GRP0

  lda #0
  sta SkaterBitmapBuffer

	cpy SkaterVerticalPos
	bne SkipSkaterDrawBegin
	
	lda #15
	sta SkaterLineBeingDraw	
	
	lda #%00111100

SkipSkaterDrawBegin

  tya
  tax
	ldy SkaterLineBeingDraw

	beq FinishDraw		
	lda ColorSkaterStanding,Y
	sta COLUP0

  lda (SkaterBitmapLocation),Y
	sta SkaterBitmapBuffer
	dec SkaterLineBeingDraw
FinishDraw

  txa
  tay
	
	sta WSYNC
	iny
	cpy #96
	bne ScanlineLoop
	
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

	include data/skater.bit
	
	org $FFFC
	.word Start
	.word Start
