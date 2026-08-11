
; CANYON RUNNER 
; 
; Endless runner game written in pure Assembly
;
; Author:    Jahanzaib Ashraf Mir (Cybersecurity | Hacker | Developer)

; Email:     jahanzaibashraf1318@gmail.com
; GitHub:    https://github.com/jahanzaibmir
; LinkedIn:  https://linkedin.com/in/Jahanzaib-Ashraf-Mir
; Instagram: https://instagram.com/jahanzaibmir_
; Youtube:   https://youtube.com/jahanzaibmir
; X:         https://x.com/Jahanzaib1318
; 
; CONTROLS:
;   Jump:      [SPACE] or [UP]
;   Duck:      [DOWN]
;   Restart:   [SPACE] or [R] (Post-Game)
;   Quit:      [ESC]
;
; BUILD COMMANDS:
;   nasm -f win64 runner.asm -o runner.obj
;   gcc runner.obj -o runner.exe -lkernel32 -luser32 -lgdi32 -mwindows -nostartfiles -e start
;

default rel

extern GetModuleHandleA
extern ExitProcess
extern RegisterClassExA
extern CreateWindowExA
extern ShowWindow
extern UpdateWindow
extern GetMessageA
extern TranslateMessage
extern DispatchMessageA
extern DefWindowProcA
extern PostQuitMessage
extern DestroyWindow
extern SetTimer
extern KillTimer
extern InvalidateRect
extern BeginPaint
extern EndPaint
extern GetClientRect
extern GetDC
extern ReleaseDC
extern GetTickCount
extern LoadCursorA
extern SetCursor

extern CreateCompatibleDC
extern CreateCompatibleBitmap
extern SelectObject
extern DeleteDC
extern DeleteObject
extern CreateSolidBrush
extern CreatePen
extern GetStockObject
extern Rectangle
extern Ellipse
extern Polygon
extern MoveToEx
extern LineTo
extern FillRect
extern SetTextColor
extern SetBkMode
extern TextOutA
extern CreateFontA
extern BitBlt

extern CreateFileA
extern ReadFile
extern WriteFile
extern CloseHandle

%define WIN_W_REQ        940
%define WIN_H_REQ        620
%define MAX_OBST         6
%define OBST_STRIDE      20

%define GRAVITY_FP       91
%define JUMP_V_FP        2465
%define BASE_SPEED_FP    384
%define MAX_SPEED_FP     1536

%define PLAYER_X         130
%define PLAYER_W         40
%define PLAYER_H_STAND   56
%define PLAYER_H_DUCK    30
%define GROUND_MARGIN    90

%define OVERHEAD_BOTTOM  40
%define OVERHEAD_H       28

%define TIMER_ID         1
%define TIMER_MS         16

%define VK_SPACE         0x20
%define VK_UP            0x26
%define VK_DOWN          0x28
%define VK_ESCAPE        0x1B
%define VK_R             0x52

%define WM_CREATE        0x0001
%define WM_DESTROY       0x0002
%define WM_SIZE          0x0005
%define WM_SETCURSOR     0x0020
%define WM_KEYDOWN       0x0100
%define WM_KEYUP         0x0101
%define WM_TIMER         0x0113
%define WM_PAINT         0x000F
%define WM_ERASEBKGND    0x0014
%define WM_CLOSE         0x0010

%define GST_START        0
%define GST_PLAYING      1
%define GST_GAMEOVER     2
%define GST_COUNTDOWN    3

%define OT_BLOCK         0
%define OT_SPIKE         1
%define OT_OVERHEAD      2

%define COL_SKY_TOP      0x00FACE87
%define COL_SKY_MID      0x00FFE0B0
%define COL_SKY_LOW      0x00DCF8FF
%define COL_MOUNTAIN     0x00A08C78
%define COL_GROUND       0x00283750
%define COL_DASH         0x0096C8E6
%define COL_PLAYER       0x003C50E6
%define COL_PLAYER_DUCK  0x003746C8
%define COL_BLOCK        0x00645A5A
%define COL_SPIKE        0x002828B4
%define COL_OVERHEAD     0x00C86E96
%define COL_DIM          0x001E1414
%define COL_TEXT         0x00FFFFFF
%define COL_TITLE        0x0078E6FF

section .data
    className       db "CanyonRunnerWndClass",0
    winTitle        db "Canyon Runner, By Jahanzaib Ashraf Mir in Assembly",0
    fontNameHud     db "Consolas",0
    highScoreFile   db "highscore.dat",0

    titleText       db "CANYON RUNNER",0
    titleLen        equ $-titleText-1
    instrText1      db "PRESS SPACE TO START",0
    instrLen1       equ $-instrText1-1
    instrText2      db "UP/SPACE JUMP   DOWN DUCK   ESC QUIT",0
    instrLen2       equ $-instrText2-1
    
    jumpInstr       db "UP / SPACE : JUMP",0
    jumpInstrLen    equ $-jumpInstr-1
    crouchInstr     db "DOWN : CROUCH",0
    crouchInstrLen  equ $-crouchInstr-1
    quitInstr       db "ESC : QUIT",0
    quitInstrLen    equ $-quitInstr-1
    
    text_3          db "3",0
    text_2          db "2",0
    text_1          db "1",0

    gameOverText    db "GAME OVER",0
    gameOverLen     equ $-gameOverText-1
    restartText     db "PRESS SPACE OR R TO RESTART",0
    restartLen      equ $-restartText-1
    scoreLabel      db "SCORE ",0
    scoreLabelLen   equ $-scoreLabel-1
    highLabel       db "HIGH ",0
    highLabelLen    equ $-highLabel-1
    finalScoreLabel db "FINAL SCORE ",0
    finalScoreLabelLen equ $-finalScoreLabel-1
    newHighText     db "NEW HIGH SCORE!",0
    newHighLen      equ $-newHighText-1

section .bss
    wc              resb 80
    msg             resb 48
    ps              resb 72
    clientRect      resb 16

    hInst           resq 1
    hWnd            resq 1
    hdcMem          resq 1
    hbmMem          resq 1
    hbmOld          resq 1
    gClientW        resd 1
    gClientH        resd 1

    brushSky1       resq 1
    brushSky2       resq 1
    brushSky3       resq 1
    brushMountain   resq 1
    brushGround     resq 1
    brushDash       resq 1
    brushPlayer     resq 1
    brushPlayerDuck resq 1
    brushBlock      resq 1
    brushSpike      resq 1
    brushOverhead   resq 1
    brushDim        resq 1
    fontHud         resq 1
    fontTitle       resq 1

    brushSkin       resq 1
    brushShirt      resq 1
    brushPants      resq 1
    brushCrate      resq 1
    brushRock       resq 1
    brushBird       resq 1
    penBlack        resq 1

    gState          resd 1
    frameCount      resd 1
    countdownTimer  resd 1

    airY            resd 1
    velY            resd 1
    isJumping       resd 1
    isDucking       resd 1

    speedFp         resd 1
    scrollFp        resd 1
    scoreAccumFp    resd 1
    score           resd 1
    highScore       resd 1

    distSinceSpawnFp resd 1
    nextSpawnGapFp   resd 1
    rngState        resd 1

    obstacles       resd (MAX_OBST*5)

    scoreStrBuf     resb 16
    hsStrBuf        resb 16
    bytesIo         resd 1

section .text
global start

itoa_u32:
    push rbx
    push rsi
    sub rsp, 40
    lea rbx, [rsp+12]
    mov rsi, rbx

    mov ecx, 10
    test eax, eax
    jnz .digits
    dec rsi
    mov byte [rsi], '0'
    jmp .copy
.digits:
    test eax, eax
    jz .copy
    xor edx, edx
    div ecx
    add dl, '0'
    dec rsi
    mov [rsi], dl
    jmp .digits

.copy:
    mov r8, rdi
    mov ecx, 0
.copyloop:
    cmp rsi, rbx
    jge .copydone
    mov al, [rsi]
    mov [rdi], al
    inc rsi
    inc rdi
    inc ecx
    jmp .copyloop
.copydone:
    mov byte [rdi], 0

    add rsp, 40
    pop rsi
    pop rbx
    ret

rng_next:
    mov eax, [rngState]
    mov ecx, eax
    shl ecx, 13
    xor eax, ecx
    mov ecx, eax
    shr ecx, 17
    xor eax, ecx
    mov ecx, eax
    shl ecx, 5
    xor eax, ecx
    mov [rngState], eax
    ret

rng_range:
    push rcx
    call rng_next
    pop rcx
    xor edx, edx
    div ecx
    mov eax, edx
    ret

get_obstacle_rect:
    mov eax, [gClientH]
    sub eax, GROUND_MARGIN
    mov r8d, [rsi+4]
    mov ecx, [rsi+12]
    cmp r8d, OT_OVERHEAD
    je .overhead
    mov edx, [rsi+16]
    mov ebx, eax
    sub ebx, edx
    jmp .setx
.overhead:
    mov edx, OVERHEAD_H
    mov ebx, eax
    sub ebx, OVERHEAD_BOTTOM
    sub ebx, OVERHEAD_H
.setx:
    mov eax, [rsi+8]
    sar eax, 8
    ret

save_highscore:
    push rbx
    push rsi
    push rdi
    sub rsp, 0x50
    lea rcx, [highScoreFile]
    mov edx, 0x40000000
    xor r8d, r8d
    xor r9d, r9d
    mov qword [rsp+0x20], 2
    mov qword [rsp+0x28], 0x80
    mov qword [rsp+0x30], 0
    call CreateFileA
    cmp rax, -1
    je .fail
    mov rbx, rax
    mov rcx, rbx
    lea rdx, [highScore]
    mov r8d, 4
    lea r9, [bytesIo]
    mov qword [rsp+0x20], 0
    call WriteFile
    mov rcx, rbx
    call CloseHandle
.fail:
    add rsp, 0x50
    pop rdi
    pop rsi
    pop rbx
    ret

load_highscore:
    push rbx
    sub rsp, 0x40
    mov dword [highScore], 0
    lea rcx, [highScoreFile]
    mov edx, 0x80000000
    mov r8d, 1
    xor r9d, r9d
    mov qword [rsp+0x20], 3
    mov qword [rsp+0x28], 0x80
    mov qword [rsp+0x30], 0
    call CreateFileA
    cmp rax, -1
    je .fail
    mov rbx, rax
    mov rcx, rbx
    lea rdx, [highScore]
    mov r8d, 4
    lea r9, [bytesIo]
    mov qword [rsp+0x20], 0
    call ReadFile
    mov rcx, rbx
    call CloseHandle
.fail:
    add rsp, 0x40
    pop rbx
    ret

reset_game:
    push rbx
    mov dword [score], 0
    mov dword [scoreAccumFp], 0
    mov dword [speedFp], BASE_SPEED_FP
    mov dword [scrollFp], 0
    mov dword [airY], 0
    mov dword [velY], 0
    mov dword [isJumping], 0
    mov dword [isDucking], 0
    mov dword [frameCount], 0
    mov dword [distSinceSpawnFp], 0
    mov ecx, 200
    call rng_range
    add eax, 250
    shl eax, 8
    mov [nextSpawnGapFp], eax

    xor ebx, ebx
.clearloop:
    cmp ebx, MAX_OBST
    jge .cleardone
    mov eax, ebx
    imul eax, OBST_STRIDE
    lea rdx, [rel obstacles]
    mov dword [rdx + rax], 0
    inc ebx
    jmp .clearloop
.cleardone:
    pop rbx
    ret

spawn_obstacle:
    push rbx
    push rsi
    push rdi
    xor ebx, ebx
.find:
    cmp ebx, MAX_OBST
    jge .none
    mov eax, ebx
    imul eax, OBST_STRIDE
    lea rsi, [rel obstacles]
    add rsi, rax
    cmp dword [rsi], 0
    je .found
    inc ebx
    jmp .find
.found:
    mov dword [rsi], 1
    mov ecx, 10
    call rng_range
    mov edi, eax
    cmp edi, 2
    jl .isoverhead
    cmp edi, 6
    jl .isspike
    mov dword [rsi+4], OT_BLOCK
    mov ecx, 20
    call rng_range
    add eax, 30
    mov [rsi+12], eax
    mov ecx, 30
    call rng_range
    add eax, 30
    mov [rsi+16], eax
    jmp .setpos
.isspike:
    mov dword [rsi+4], OT_SPIKE
    mov ecx, 14
    call rng_range
    add eax, 26
    mov [rsi+12], eax
    mov ecx, 26
    call rng_range
    add eax, 34
    mov [rsi+16], eax
    jmp .setpos
.isoverhead:
    mov dword [rsi+4], OT_OVERHEAD
    mov ecx, 30
    call rng_range
    add eax, 50
    mov [rsi+12], eax
    mov dword [rsi+16], OVERHEAD_H
.setpos:
    mov eax, [gClientW]
    add eax, 40
    shl eax, 8
    mov [rsi+8], eax
.none:
    pop rdi
    pop rsi
    pop rbx
    ret

update_game:
    push rbx
    push rsi
    push rdi
    push r12
    sub rsp, 0x18

    inc dword [frameCount]

    cmp dword [isJumping], 0
    je .noair
    mov eax, [velY]
    sub eax, GRAVITY_FP
    mov [velY], eax
    add [airY], eax
    cmp dword [airY], 0
    jg .noair
    mov dword [airY], 0
    mov dword [velY], 0
    mov dword [isJumping], 0
.noair:

    mov eax, [score]
    xor edx, edx
    mov ecx, 10
    div ecx
    imul eax, eax, 4
    add eax, BASE_SPEED_FP
    cmp eax, MAX_SPEED_FP
    jle .speedok
    mov eax, MAX_SPEED_FP
.speedok:
    mov [speedFp], eax

    mov eax, [speedFp]
    add [scrollFp], eax

    mov eax, [speedFp]
    add [distSinceSpawnFp], eax
    mov eax, [distSinceSpawnFp]
    cmp eax, [nextSpawnGapFp]
    jl .nospawn
    mov dword [distSinceSpawnFp], 0
    call spawn_obstacle
    mov ecx, 200
    call rng_range
    add eax, 300
    shl eax, 8
    mov [nextSpawnGapFp], eax
.nospawn:

    xor ebx, ebx
.moveloop:
    cmp ebx, MAX_OBST
    jge .movedone
    mov eax, ebx
    imul eax, OBST_STRIDE
    lea rsi, [rel obstacles]
    add rsi, rax
    cmp dword [rsi], 0
    je .movenext
    mov eax, [speedFp]
    sub [rsi+8], eax
    mov eax, [rsi+8]
    sar eax, 8
    add eax, [rsi+12]
    cmp eax, 0
    jge .movenext
    mov dword [rsi], 0
.movenext:
    inc ebx
    jmp .moveloop
.movedone:

    mov eax, [gClientH]
    sub eax, GROUND_MARGIN

    mov ecx, PLAYER_H_STAND
    cmp dword [isDucking], 0
    je .useStdH
    cmp dword [airY], 0
    jne .useStdH
    mov ecx, PLAYER_H_DUCK
.useStdH:
    mov edx, eax
    sub edx, ecx
    mov eax, [airY]
    sar eax, 8
    sub edx, eax

    push rdx
    push rcx

    xor r12d, r12d
.colloop:
    cmp r12d, MAX_OBST
    jge .colldone

    mov eax, r12d
    imul eax, OBST_STRIDE
    lea rsi, [rel obstacles]
    add rsi, rax
    cmp dword [rsi], 0
    je .collnext

    call get_obstacle_rect
    mov r8d,  eax
    mov r9d,  ebx
    mov r10d, ecx
    mov r11d, edx

    mov ecx, [rsp]
    mov edx, [rsp+8]

    mov eax, PLAYER_X + PLAYER_W
    cmp eax, r8d
    jle .collnext

    mov eax, r8d
    add eax, r10d
    cmp eax, PLAYER_X
    jle .collnext

    mov eax, edx
    add eax, ecx
    cmp eax, r9d
    jle .collnext

    mov eax, r9d
    add eax, r11d
    cmp eax, edx
    jle .collnext

    add rsp, 16
    mov dword [gState], GST_GAMEOVER
    mov eax, [score]
    cmp eax, [highScore]
    jle .nohigh_col
    mov [highScore], eax
    call save_highscore
.nohigh_col:
    add rsp, 0x18
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

.collnext:
    inc r12d
    jmp .colloop

.colldone:
    add rsp, 16

    mov eax, [speedFp]
    add [scoreAccumFp], eax
    mov eax, [scoreAccumFp]
    mov ecx, eax
    sar ecx, 8
    add [score], ecx
    and dword [scoreAccumFp], 0xFF

    add rsp, 0x18
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

draw_game:
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    sub rsp, 0x70

    mov r15, rcx

    mov eax, [gClientH]
    xor edx, edx
    mov ecx, 3
    div ecx

    sub rsp, 0x30
    mov rcx, r15
    lea rdx, [clientRect]
    mov r8, [brushSky1]
    mov r13d, eax
    mov [clientRect+12], eax
    call FillRect

    mov ecx, [clientRect+12]
    mov [clientRect+4], ecx
    mov ecx, r13d
    shl ecx, 1
    mov [clientRect+12], ecx
    mov rcx, r15
    lea rdx, [clientRect]
    mov r8, [brushSky2]
    call FillRect

    mov ecx, [clientRect+12]
    mov [clientRect+4], ecx
    mov ecx, [gClientH]
    mov [clientRect+12], ecx
    mov rcx, r15
    lea rdx, [clientRect]
    mov r8, [brushSky3]
    call FillRect

    mov dword [clientRect+4], 0
    add rsp, 0x30

    sub rsp, 0x30
    mov eax, [gClientH]
    sub eax, GROUND_MARGIN
    mov r13d, eax
    mov rcx, r15
    lea rdx, [clientRect]
    mov r8, [brushGround]
    mov [clientRect+4], r13d
    mov eax, [gClientH]
    mov [clientRect+12], eax
    call FillRect
    mov dword [clientRect+4], 0
    add rsp, 0x30

    sub rsp, 0x30
    mov eax, [scrollFp]
    sar eax, 8
    mov ecx, 80
    xor edx, edx
    div ecx
    mov esi, edx
    neg esi
    mov edi, [gClientW]
    mov r12d, [gClientH]
    sub r12d, GROUND_MARGIN
    add r12d, 12
.dashloop:
    cmp esi, edi
    jge .dashdone
    mov r9d, esi
    add r9d, 56
    mov rcx, r15
    mov edx, esi
    mov r8d, r12d
    mov eax, r12d
    add eax, 6
    mov [rsp+0x20], rax
    call Rectangle
    add esi, 80
    jmp .dashloop
.dashdone:
    add rsp, 0x30

    sub rsp, 0x30
    mov eax, [gClientH]
    sub eax, GROUND_MARGIN

    mov edi, PLAYER_H_STAND
    cmp dword [isDucking], 0
    je .drawStdH
    cmp dword [airY], 0
    jne .drawStdH
    mov edi, PLAYER_H_DUCK
.drawStdH:
    mov ecx, [airY]
    sar ecx, 8
    mov esi, eax
    sub esi, edi
    sub esi, ecx

    mov rcx, r15
    mov rdx, [penBlack]
    call SelectObject
    mov r13, rax

    mov rcx, r15
    mov rdx, [brushSkin]
    call SelectObject
    mov r14, rax

    cmp edi, PLAYER_H_DUCK
    jne .drawStandPlayer

    mov rcx, r15
    mov edx, PLAYER_X + 13
    mov r8d, esi
    mov r9d, PLAYER_X + 27
    mov eax, esi
    add eax, 14
    mov [rsp+0x20], rax
    call Ellipse

    mov rcx, r15
    mov rdx, [brushShirt]
    call SelectObject

    mov rcx, r15
    mov edx, PLAYER_X + 4
    mov r8d, esi
    add r8d, 14
    mov r9d, PLAYER_X + 36
    mov eax, esi
    add eax, 30
    mov [rsp+0x20], rax
    call Rectangle

    jmp .playerDrawDone

.drawStandPlayer:
    mov rcx, r15
    mov rdx, [brushSkin]
    call SelectObject

    mov rcx, r15
    mov edx, PLAYER_X + 12
    mov r8d, esi
    mov r9d, PLAYER_X + 28
    mov eax, esi
    add eax, 16
    mov [rsp+0x20], rax
    call Ellipse

    mov rcx, r15
    mov rdx, [brushShirt]
    call SelectObject

    mov rcx, r15
    mov edx, PLAYER_X + 12
    mov r8d, esi
    add r8d, 16
    mov r9d, PLAYER_X + 28
    mov eax, esi
    add eax, 36
    mov [rsp+0x20], rax
    call Rectangle

    mov rcx, r15
    mov rdx, [brushSkin]
    call SelectObject

    mov rcx, r15
    mov edx, PLAYER_X
    mov r8d, esi
    add r8d, 18
    mov r9d, PLAYER_X + 12
    mov eax, esi
    add eax, 34
    mov [rsp+0x20], rax
    call Rectangle

    mov rcx, r15
    mov edx, PLAYER_X + 28
    mov r8d, esi
    add r8d, 18
    mov r9d, PLAYER_X + 40
    mov eax, esi
    add eax, 34
    mov [rsp+0x20], rax
    call Rectangle

    mov rcx, r15
    mov rdx, [brushPants]
    call SelectObject

    mov rcx, r15
    mov edx, PLAYER_X + 12
    mov r8d, esi
    add r8d, 36
    mov r9d, PLAYER_X + 21
    mov eax, esi
    add eax, 56
    mov [rsp+0x20], rax
    call Rectangle

    mov rcx, r15
    mov edx, PLAYER_X + 19
    mov r8d, esi
    add r8d, 36
    mov r9d, PLAYER_X + 28
    mov eax, esi
    add eax, 56
    mov [rsp+0x20], rax
    call Rectangle

.playerDrawDone:
    mov rcx, r15
    mov rdx, r14
    call SelectObject

    mov rcx, r15
    mov rdx, r13
    call SelectObject
    add rsp, 0x30

    sub rsp, 0x50
    mov rcx, r15
    mov rdx, [penBlack]
    call SelectObject
    mov r13, rax

    xor r12d, r12d
.obstdrawloop:
    cmp r12d, MAX_OBST
    jge .obstdrawdone
    mov eax, r12d
    imul eax, OBST_STRIDE
    lea rsi, [rel obstacles]
    add rsi, rax
    cmp dword [rsi], 0
    je .obstdrawnext

    call get_obstacle_rect
    
    mov [rsp+0x28], eax
    mov [rsp+0x30], ebx
    mov [rsp+0x38], ecx
    mov [rsp+0x40], edx

    mov eax, [rsi+4]
    cmp eax, OT_BLOCK
    je .ob_block
    cmp eax, OT_SPIKE
    je .ob_spike
    
    mov rdx, [brushBird]
    jmp .ob_draw_sel
.ob_block:
    mov rdx, [brushCrate]
    jmp .ob_draw_sel
.ob_spike:
    mov rdx, [brushRock]
.ob_draw_sel:
    mov rcx, r15
    call SelectObject

    mov rcx, r15
    mov edx, [rsp+0x28]
    mov r8d, [rsp+0x30]
    
    mov eax, [rsp+0x28]
    add eax, [rsp+0x38]
    mov r9d, eax
    
    mov eax, [rsp+0x30]
    add eax, [rsp+0x40]
    mov [rsp+0x20], rax

    mov eax, [rsi+4]
    cmp eax, OT_OVERHEAD
    je .ob_call_ellipse
    cmp eax, OT_SPIKE
    je .ob_call_ellipse
    call Rectangle
    jmp .obstdrawnext
.ob_call_ellipse:
    call Ellipse

.obstdrawnext:
    inc r12d
    jmp .obstdrawloop
.obstdrawdone:
    mov rcx, r15
    mov rdx, r13
    call SelectObject
    add rsp, 0x50

    sub rsp, 0x30

    mov rcx, r15
    mov rdx, [fontTitle]
    call SelectObject

    mov rcx, r15
    call SetBkMode.wrap

    mov rcx, r15
    mov edx, 0x00000000
    call SetTextColor

    mov eax, [gState]
    cmp eax, GST_PLAYING
    je .draw_hud
    
    cmp eax, GST_COUNTDOWN
    jne .check_start_state
    
    mov rcx, r15
    mov edx, 250
    mov r8d, 250
    lea r9, [jumpInstr]
    mov rax, jumpInstrLen
    mov [rsp+0x20], rax
    call TextOutA
    
    mov rcx, r15
    mov edx, 300
    mov r8d, 320
    lea r9, [crouchInstr]
    mov rax, crouchInstrLen
    mov [rsp+0x20], rax
    call TextOutA
    
    mov rcx, r15
    mov edx, 350
    mov r8d, 390
    lea r9, [quitInstr]
    mov rax, quitInstrLen
    mov [rsp+0x20], rax
    call TextOutA
    
    mov eax, [countdownTimer]
    cmp eax, 62
    jle .count_3
    cmp eax, 124
    jle .count_2
    jmp .count_1
    
.count_3:
    lea r9, [text_3]
    jmp .count_draw
.count_2:
    lea r9, [text_2]
    jmp .count_draw
.count_1:
    lea r9, [text_1]
.count_draw:
    mov rax, 1
    mov [rsp+0x20], rax
    mov rcx, r15
    mov edx, 460
    mov r8d, 100
    call TextOutA
    jmp .hud_done

.check_start_state:
    cmp eax, GST_START
    jne .check_gameover_state

    mov rcx, r15
    mov edx, 300
    mov r8d, 150
    lea r9, [titleText]
    mov rax, titleLen
    mov [rsp+0x20], rax
    call TextOutA

    mov rcx, r15
    mov edx, 300
    mov r8d, 250
    lea r9, [instrText1]
    mov rax, instrLen1
    mov [rsp+0x20], rax
    call TextOutA

    mov rcx, r15
    mov edx, 250
    mov r8d, 300
    lea r9, [instrText2]
    mov rax, instrLen2
    mov [rsp+0x20], rax
    call TextOutA
    jmp .hud_done

.check_gameover_state:
    cmp eax, GST_GAMEOVER
    jne .hud_done

    mov rcx, r15
    mov edx, 350
    mov r8d, 200
    lea r9, [gameOverText]
    mov rax, gameOverLen
    mov [rsp+0x20], rax
    call TextOutA

    mov rcx, r15
    mov edx, 280
    mov r8d, 280
    lea r9, [restartText]
    mov rax, restartLen
    mov [rsp+0x20], rax
    call TextOutA

    mov rcx, r15
    mov edx, 320
    mov r8d, 240
    lea r9, [finalScoreLabel]
    mov rax, finalScoreLabelLen
    mov [rsp+0x20], rax
    call TextOutA

    lea rdi, [scoreStrBuf]
    mov eax, [score]
    call itoa_u32
    mov r13d, ecx

    mov rcx, r15
    mov edx, 470
    mov r8d, 240
    lea r9, [scoreStrBuf]
    mov [rsp+0x20], r13
    call TextOutA

    mov eax, [score]
    cmp eax, [highScore]
    jne .not_new_high
    cmp eax, 0
    je .not_new_high

    mov rcx, r15
    mov edx, 320
    mov r8d, 320
    lea r9, [newHighText]
    mov rax, newHighLen
    mov [rsp+0x20], rax
    call TextOutA
.not_new_high:
    jmp .hud_done

.draw_hud:
    mov rcx, r15
    mov rdx, [fontHud]
    call SelectObject

    mov rcx, r15
    call SetBkMode.wrap

    mov rcx, r15
    mov edx, 10
    mov r8d, 10
    lea r9, [scoreLabel]
    mov rax, scoreLabelLen
    mov [rsp+0x20], rax
    call TextOutA

    lea rdi, [scoreStrBuf]
    mov eax, [score]
    call itoa_u32
    mov r13d, ecx

    mov rcx, r15
    mov edx, 60
    mov r8d, 10
    lea r9, [scoreStrBuf]
    mov [rsp+0x20], r13
    call TextOutA

    mov rcx, r15
    mov edx, 200
    mov r8d, 10
    lea r9, [highLabel]
    mov rax, highLabelLen
    mov [rsp+0x20], rax
    call TextOutA

    lea rdi, [hsStrBuf]
    mov eax, [highScore]
    call itoa_u32
    mov r13d, ecx

    mov rcx, r15
    mov edx, 250
    mov r8d, 10
    lea r9, [hsStrBuf]
    mov [rsp+0x20], r13
    call TextOutA

.hud_done:
    add rsp, 0x30

    add rsp, 0x70
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

SetBkMode.wrap:
    sub rsp, 0x28
    mov rcx, r15
    mov edx, 1
    call SetBkMode
    add rsp, 0x28
    ret

WndProc:
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    sub rsp, 0x90

    mov r12, rcx
    mov r13d, edx
    mov r14, r8
    mov r15, r9

    cmp r13d, WM_CREATE
    jne .notCreate

    mov [hWnd], r12
    call load_highscore

    call GetTickCount
    mov [rngState], eax
    test eax, eax
    jnz .rngok
    mov dword [rngState], 0xDEADBEEF
.rngok:

    mov ecx, COL_SKY_TOP
    call CreateSolidBrush
    mov [brushSky1], rax

    mov ecx, COL_SKY_MID
    call CreateSolidBrush
    mov [brushSky2], rax

    mov ecx, COL_SKY_LOW
    call CreateSolidBrush
    mov [brushSky3], rax

    mov ecx, COL_MOUNTAIN
    call CreateSolidBrush
    mov [brushMountain], rax

    mov ecx, COL_GROUND
    call CreateSolidBrush
    mov [brushGround], rax

    mov ecx, COL_DASH
    call CreateSolidBrush
    mov [brushDash], rax

    mov ecx, COL_PLAYER
    call CreateSolidBrush
    mov [brushPlayer], rax

    mov ecx, COL_PLAYER_DUCK
    call CreateSolidBrush
    mov [brushPlayerDuck], rax

    mov ecx, COL_BLOCK
    call CreateSolidBrush
    mov [brushBlock], rax

    mov ecx, COL_SPIKE
    call CreateSolidBrush
    mov [brushSpike], rax

    mov ecx, COL_OVERHEAD
    call CreateSolidBrush
    mov [brushOverhead], rax

    mov ecx, COL_DIM
    call CreateSolidBrush
    mov [brushDim], rax

    mov ecx, 0x00FCD9A4
    call CreateSolidBrush
    mov [brushSkin], rax

    mov ecx, 0x00E61E1E
    call CreateSolidBrush
    mov [brushShirt], rax

    mov ecx, 0x00001E96
    call CreateSolidBrush
    mov [brushPants], rax

    mov ecx, 0x008C5A2B
    call CreateSolidBrush
    mov [brushCrate], rax

    mov ecx, 0x00808080
    call CreateSolidBrush
    mov [brushRock], rax

    mov ecx, 0x00D0D0D0
    call CreateSolidBrush
    mov [brushBird], rax

    mov ecx, 0
    xor edx, edx
    mov r8d, 2
    call CreatePen
    mov [penBlack], rax

    mov ecx, 22
    xor edx, edx
    xor r8d, r8d
    xor r9d, r9d
    mov qword [rsp+0x20], 700
    mov qword [rsp+0x28], 0
    mov qword [rsp+0x30], 0
    mov qword [rsp+0x38], 0
    mov qword [rsp+0x40], 0
    mov qword [rsp+0x48], 0
    mov qword [rsp+0x50], 0
    mov qword [rsp+0x58], 5
    mov qword [rsp+0x60], 0x31
    lea rax, [fontNameHud]
    mov [rsp+0x68], rax
    call CreateFontA
    mov [fontHud], rax

    mov ecx, 48
    xor edx, edx
    xor r8d, r8d
    xor r9d, r9d
    mov qword [rsp+0x20], 900
    mov qword [rsp+0x28], 0
    mov qword [rsp+0x30], 0
    mov qword [rsp+0x38], 0
    mov qword [rsp+0x40], 0
    mov qword [rsp+0x48], 0
    mov qword [rsp+0x50], 0
    mov qword [rsp+0x58], 5
    mov qword [rsp+0x60], 0x31
    lea rax, [fontNameHud]
    mov [rsp+0x68], rax
    call CreateFontA
    mov [fontTitle], rax

    mov rcx, r12
    lea rdx, [clientRect]
    call GetClientRect
    mov eax, [clientRect+8]
    mov [gClientW], eax
    mov eax, [clientRect+12]
    mov [gClientH], eax

    mov rcx, r12
    call GetDC
    mov rbx, rax

    mov rcx, rax
    call CreateCompatibleDC
    mov [hdcMem], rax

    mov rcx, rbx
    mov edx, [gClientW]
    mov r8d, [gClientH]
    call CreateCompatibleBitmap
    mov [hbmMem], rax

    mov rcx, [hdcMem]
    mov rdx, [hbmMem]
    call SelectObject
    mov [hbmOld], rax

    mov rcx, r12
    mov rdx, rbx
    call ReleaseDC

    mov rcx, r12
    mov rdx, TIMER_ID
    mov r8d, TIMER_MS
    xor r9d, r9d
    call SetTimer

    mov dword [gState], GST_START
    xor eax, eax
    jmp .done

.notCreate:
    cmp r13d, WM_DESTROY
    jne .notDestroy

    mov rcx, r12
    mov rdx, TIMER_ID
    call KillTimer

    mov rcx, [hdcMem]
    mov rdx, [hbmOld]
    call SelectObject
    mov rcx, [hbmMem]
    call DeleteObject
    mov rcx, [hdcMem]
    call DeleteDC

    mov rcx, [brushSky1]
    call DeleteObject
    mov rcx, [brushSky2]
    call DeleteObject
    mov rcx, [brushSky3]
    call DeleteObject
    mov rcx, [brushMountain]
    call DeleteObject
    mov rcx, [brushGround]
    call DeleteObject
    mov rcx, [brushDash]
    call DeleteObject
    mov rcx, [brushPlayer]
    call DeleteObject
    mov rcx, [brushPlayerDuck]
    call DeleteObject
    mov rcx, [brushBlock]
    call DeleteObject
    mov rcx, [brushSpike]
    call DeleteObject
    mov rcx, [brushOverhead]
    call DeleteObject
    mov rcx, [brushDim]
    call DeleteObject
    mov rcx, [fontHud]
    call DeleteObject
    mov rcx, [fontTitle]
    call DeleteObject
    
    mov rcx, [brushSkin]
    call DeleteObject
    mov rcx, [brushShirt]
    call DeleteObject
    mov rcx, [brushPants]
    call DeleteObject
    mov rcx, [brushCrate]
    call DeleteObject
    mov rcx, [brushRock]
    call DeleteObject
    mov rcx, [brushBird]
    call DeleteObject
    mov rcx, [penBlack]
    call DeleteObject

    xor ecx, ecx
    call PostQuitMessage
    xor eax, eax
    jmp .done

.notDestroy:
    cmp r13d, WM_CLOSE
    jne .notClose
    mov rcx, r12
    call DestroyWindow
    xor eax, eax
    jmp .done

.notClose:
    cmp r13d, WM_SETCURSOR
    jne .notSetCursor
    xor ecx, ecx
    call SetCursor
    xor eax, eax
    jmp .done

.notSetCursor:
    cmp r13d, WM_ERASEBKGND
    jne .notErase
    mov eax, 1
    jmp .done

.notErase:
    cmp r13d, WM_SIZE
    jne .notSize

    mov rcx, r12
    lea rdx, [clientRect]
    call GetClientRect
    mov eax, [clientRect+8]
    mov [gClientW], eax
    mov eax, [clientRect+12]
    mov [gClientH], eax

    cmp qword [hdcMem], 0
    je .size_done

    mov rcx, [hdcMem]
    mov rdx, [hbmOld]
    call SelectObject
    mov rcx, [hbmMem]
    call DeleteObject

    mov rcx, r12
    call GetDC
    mov rbx, rax

    mov rcx, rbx
    mov edx, [gClientW]
    mov r8d, [gClientH]
    call CreateCompatibleBitmap
    mov [hbmMem], rax

    mov rcx, [hdcMem]
    mov rdx, [hbmMem]
    call SelectObject
    mov [hbmOld], rax

    mov rcx, r12
    mov rdx, rbx
    call ReleaseDC

.size_done:
    mov rcx, r12
    xor rdx, rdx
    xor r8d, r8d
    call InvalidateRect
    xor eax, eax
    jmp .done

.notSize:
    cmp r13d, WM_KEYDOWN
    jne .notKeyDown

    cmp r14, VK_ESCAPE
    jne .notEsc
    mov rcx, r12
    call DestroyWindow
    jmp .done
.notEsc:
    mov eax, [gState]
    cmp eax, GST_START
    jne .notStart
    cmp r14, VK_SPACE
    jne .keyDone
    call reset_game
    mov dword [countdownTimer], 0
    mov dword [gState], GST_COUNTDOWN
    jmp .keyDone
.notStart:
    cmp eax, GST_GAMEOVER
    jne .notGameOver
    cmp r14, VK_SPACE
    je .doRestart
    cmp r14, VK_R
    jne .keyDone
.doRestart:
    call reset_game
    mov dword [countdownTimer], 0
    mov dword [gState], GST_COUNTDOWN
    jmp .keyDone
.notGameOver:
    cmp r14, VK_SPACE
    je .doJump
    cmp r14, VK_UP
    jne .notJump
.doJump:
    cmp dword [isJumping], 0
    jne .keyDone
    cmp dword [airY], 0
    jne .keyDone
    mov dword [isJumping], 1
    mov dword [velY], JUMP_V_FP
    jmp .keyDone
.notJump:
    cmp r14, VK_DOWN
    jne .keyDone
    mov dword [isDucking], 1
.keyDone:
    xor eax, eax
    jmp .done

.notKeyDown:
    cmp r13d, WM_KEYUP
    jne .notKeyUp
    cmp r14, VK_DOWN
    jne .keyupDone
    mov dword [isDucking], 0
.keyupDone:
    xor eax, eax
    jmp .done

.notKeyUp:
    cmp r13d, WM_TIMER
    jne .notTimer
    cmp r14, TIMER_ID
    jne .notTimer

    cmp dword [gState], GST_PLAYING
    je .timerUpdate
    
    cmp dword [gState], GST_COUNTDOWN
    jne .timerNoUpdate
    
    inc dword [countdownTimer]
    mov eax, [countdownTimer]
    cmp eax, 187
    jl .timerNoUpdate
    mov dword [gState], GST_PLAYING
    
.timerUpdate:
    call update_game
    
.timerNoUpdate:
    mov rcx, r12
    xor rdx, rdx
    xor r8d, r8d
    call InvalidateRect
    xor eax, eax
    jmp .done

.notTimer:
    cmp r13d, WM_PAINT
    jne .notPaint

    mov rcx, r12
    lea rdx, [ps]
    call BeginPaint
    mov rbx, rax

    mov rcx, [hdcMem]
    call draw_game

    mov rcx, rbx
    xor edx, edx
    xor r8d, r8d
    mov r9d, [gClientW]
    mov eax, [gClientH]
    mov [rsp+0x20], rax
    mov rax, [hdcMem]
    mov [rsp+0x28], rax
    xor eax, eax
    mov [rsp+0x30], rax
    mov [rsp+0x38], rax
    mov dword [rsp+0x40], 0x00CC0020
    call BitBlt

    mov rcx, r12
    lea rdx, [ps]
    call EndPaint
    xor eax, eax
    jmp .done

.notPaint:
    mov rcx, r12
    mov rdx, r13
    mov r8, r14
    mov r9, r15
    call DefWindowProcA
    jmp .done

.done:
    add rsp, 0x90
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

start:
    sub rsp, 0x68

    xor ecx, ecx
    call GetModuleHandleA
    mov [hInst], rax

    mov dword [wc],    80
    mov dword [wc+4],  3
    lea rax, [WndProc]
    mov [wc+8],  rax
    mov dword [wc+16], 0
    mov dword [wc+20], 0
    mov rax, [hInst]
    mov [wc+24], rax
    mov qword [wc+32], 0
    mov qword [wc+40], 0
    mov qword [wc+48], 0
    mov qword [wc+56], 0
    lea rax, [className]
    mov [wc+64], rax
    mov qword [wc+72], 0

    lea rcx, [wc]
    call RegisterClassExA
    test eax, eax
    jz .exit

    xor ecx, ecx
    lea rdx, [className]
    lea r8,  [winTitle]
    mov r9d, 0x00CF0000
    mov qword [rsp+0x20], 100
    mov qword [rsp+0x28], 80
    mov qword [rsp+0x30], WIN_W_REQ
    mov qword [rsp+0x38], WIN_H_REQ
    mov qword [rsp+0x40], 0
    mov qword [rsp+0x48], 0
    mov rax, [hInst]
    mov [rsp+0x50], rax
    mov qword [rsp+0x58], 0
    call CreateWindowExA
    test rax, rax
    jz .exit
    mov [hWnd], rax

    mov rcx, [hWnd]
    mov edx, 1
    call ShowWindow
    mov rcx, [hWnd]
    call UpdateWindow

.msgloop:
    lea rcx, [msg]
    xor rdx, rdx
    xor r8d, r8d
    xor r9d, r9d
    call GetMessageA
    test eax, eax
    jle .exitloop

    lea rcx, [msg]
    call TranslateMessage
    lea rcx, [msg]
    call DispatchMessageA
    jmp .msgloop

.exitloop:
    mov eax, [msg+8]

.exit:
    mov ecx, eax
    call ExitProcess