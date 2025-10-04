INCLUDE "include/hardware.inc"

SECTION "TILES", ROM0
picture_tiles: INCBIN "gfx/picture_tiles.bin"
picture_tilesEnd:
SECTION "MAP", ROM0
picture_map: INCBIN "gfx/picture_map.bin"
picture_mapEnd:


;==============================================================
; Header
;==============================================================
SECTION "Header", ROM0[$100]
    nop
    jp $0150

    NINTENDO_LOGO
    
	ds $150 - @, 0 ; Make room for the header

; Initialization
SECTION "main", ROM0[$0150]
	jr EntryPoint

EntryPoint:

    ; Do not turn the LCD off outside of VBlank
.WaitVBlank:
    ld a, [rLY]
    cp 144
    jp c, .WaitVBlank

    ; Turn the LCD off
    xor a
    ld [rLCDC], a

    ; Init sound
    ld a, AUDENA_OFF     ; disable sounds
    ld [rAUDENA], a

    ; During the first (blank) frame, initialize display registers
    ld a, %11111100
    ld [rBGP], a
    ld a, %11100100 ; Object Palette 0 Data
    ld [rOBP0], a   ; Object Palette 0 Data
    ld a, %11010000 ; Object Palette 1 Data
    ld [rOBP1], a   ; Object Palette 1 Data

ClearVRAM:
    ld hl, _VRAM ; DEF _VRAM        EQU $8000 ; $8000->$9FFF
    ld bc, $2000 ; (8192 = 8 KiB)
.ClearVram
    xor a
    ld [hl+],a    
    dec bc
    ld a, b
    or a, c
    jp nz, .ClearVram

ClearOAM:
    ; OAM
    xor a
    ld b, 160
    ld hl, _OAMRAM
.ClearOam:
    ld [hli], a
    dec b
    jp nz, .ClearOam


    ; Load Picture tiles at $8800
    ; @param hl: source
    ; @param de: destination
    ; @param bc: length
    ; @param  a: VRAM BANK
    ld hl, picture_tiles
    ld de, $8800
    ld bc, picture_tilesEnd-picture_tiles
    xor a
    call Memcopy

    ; Load Map at $9800
    ; @param hl: source
    ; @param de: destination
    ; @param bc: length
    ; @param  a: VRAM BANK
    ld hl, picture_map
    ld de, $9800
    ld bc, picture_mapEnd-picture_map
    xor a
    call Memcopy

    ; Turn the LCD on
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_BG8800
    ld [rLCDC], a

; Main LOOP
main_loop:
    ld a, [rLY]
    cp 144
    jr c, main_loop    
    jr main_loop ;* End of Main loop

Memcopy:
    push hl
    push bc
    push de
; Waits for VRAM access before copying data.
; @param hl: source
; @param de: destination
; @param bc: length
; @param  a: VRAM BANK

    ; Change to VRAM BANK @param a
    ldh [rVBK], a             ; change VRAM BANK0

    ; exit if bc == 0
    ld a, b
    add a, c
    cp a, 0
    jr z, .end

.VramCopy:
    dec bc
    inc b
    inc c
.loop:
    ldh a, [rSTAT]
    and STATF_BUSY
    jr nz, .loop

    ld a, [hli]
    ld [de], a
    inc de
    dec c
    jr nz, .loop
    dec b
    jr nz, .loop

.end
    pop de   
    pop bc
    pop hl
    ret
