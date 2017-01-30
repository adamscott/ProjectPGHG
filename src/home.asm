INCLUDE "src/header.asm"
INCLUDE "src/game.asm"

SECTION "main_code", ROM0
main::
    nop
    jr init

init::
    di

    ; sets the stack pointer
    ld sp, STACK_POINTER

    ; Copy vblank routine to hram
    copy_mem rom_vblank, vblank, rom_vblank_end - rom_vblank
    
    ; sets IF to 0
    ld a, 0
    ld [IFL], a

    ; sets the vblank interrupt
    ld a, IE_VBlank
    ld [IE], a

    ; sets the timer overflow interrupt
    ld b, IE_TimerOverflow
    ld a, [IE]
    or b
    ld [IE], a

    ei

    ld a, GAMESTATE_TITLE
    ld [GAMESTATE], a

main_loop::
    halt
    nop
    
    ; vblank_check
    ld a, [GAMEBOY_STATUS]
    and GAMEBOY_STATUS_VBLANK
    jr Z, main_loop ; halt if not coming from a vblank
    xor GAMEBOY_STATUS_VBLANK
    ld [GAMEBOY_STATUS], a ; remove the vblank status
    ; vblank_check end

    ; starting the game loop
    call game_loop

    ; main_loop ends. Let's start again.
    jr main_loop
