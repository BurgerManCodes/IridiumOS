bits 64

global load_tss

load_tss:
    str ax
    mov ax, 0x48
    ltr ax
    retq
