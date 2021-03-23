names: ; cx: shift  |  si: skip
    xor dx, dx
@1:
    mov ax, cx ; shift
    mul dl
    mov di, ax ; point

    add di, si; skip

    mov ax, dx

    call draw_dig
    call draw_char

    inc dx    
    cmp dx, 16
    jl @1
    ret