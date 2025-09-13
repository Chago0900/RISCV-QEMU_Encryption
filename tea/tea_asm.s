.section .text

# void tea_encrypt_asm(uint32_t v[2], const uint32_t key[4])

.globl tea_encrypt_asm
tea_encrypt_asm:
    # Guardar registros
    addi sp, sp, -32
    sw ra, 28(sp)
    sw s0, 24(sp)
    sw s1, 20(sp)
    sw s2, 16(sp)
    sw s3, 12(sp)
    sw s4, 8(sp)
    sw s5, 4(sp)
    sw s6, 0(sp)

    # Cargar v0, v1
    lw s0, 0(a0)    # v0
    lw s1, 4(a0)    # v1

    # Cargar claves k0 a k3
    lw s2, 0(a1)    # k0
    lw s3, 4(a1)    # k1
    lw s4, 8(a1)    # k2
    lw s5, 12(a1)   # k3

    # Constante DELTA
    li s6, 0x9e3779b9

    li t0, 0        # sum = 0
    li t1, 32       # contador de rondas

encrypt_loop:
    add t0, t0, s6                      # sum += DELTA

    sll t2, s1, 4                       # (v1 << 4)
    add t2, t2, s2                      # + k0
    add t3, s1, t0                      # v1 + sum
    xor t2, t2, t3
    srl t3, s1, 5                       # (v1 >> 5)
    add t3, t3, s3                      # + k1
    xor t2, t2, t3
    add s0, s0, t2                      # v0 += ...

    sll t2, s0, 4                       # (v0 << 4)
    add t2, t2, s4                      # + k2
    add t3, s0, t0                      # v0 + sum
    xor t2, t2, t3
    srl t3, s0, 5                       # (v0 >> 5)
    add t3, t3, s5                      # + k3
    xor t2, t2, t3
    add s1, s1, t2                    

    addi t1, t1, -1
    bnez t1, encrypt_loop

    # Guardar resultados en memoria
    sw s0, 0(a0)
    sw s1, 4(a0)

    # Restaurar y retornar
    lw ra, 28(sp)
    lw s0, 24(sp)
    lw s1, 20(sp)
    lw s2, 16(sp)
    lw s3, 12(sp)
    lw s4, 8(sp)
    lw s5, 4(sp)
    lw s6, 0(sp)
    addi sp, sp, 32
    ret

# void tea_decrypt_asm(uint32_t v[2], const uint32_t key[4])

.globl tea_decrypt_asm
tea_decrypt_asm:
    # Guardar registros
    addi sp, sp, -32
    sw ra, 28(sp)
    sw s0, 24(sp)
    sw s1, 20(sp)
    sw s2, 16(sp)
    sw s3, 12(sp)
    sw s4, 8(sp)
    sw s5, 4(sp)
    sw s6, 0(sp)

    # Cargar v0, v1
    lw s0, 0(a0)    # v0
    lw s1, 4(a0)    # v1
    # Cargar claves
    lw s2, 0(a1)    # k0
    lw s3, 4(a1)    # k1
    lw s4, 8(a1)    # k2
    lw s5, 12(a1)   # k3

    # DELTA
    li s6, 0x9e3779b9
    li t1, 32
    mul t0, s6, t1     # sum = DELTA * 32
decrypt_loop:
    sll t2, s0, 4
    add t2, t2, s4
    add t3, s0, t0
    xor t2, t2, t3
    srl t3, s0, 5
    add t3, t3, s5
    xor t2, t2, t3
    sub s1, s1, t2          # v1 -= ...

    sll t2, s1, 4
    add t2, t2, s2
    add t3, s1, t0
    xor t2, t2, t3
    srl t3, s1, 5
    add t3, t3, s3
    xor t2, t2, t3
    sub s0, s0, t2          # v0 -= ...

    sub t0, t0, s6          # sum -= DELTA
    addi t1, t1, -1
    bnez t1, decrypt_loop

    # Guardar resultados
    sw s0, 0(a0)
    sw s1, 4(a0)

    # Restaurar y retornar
    lw ra, 28(sp)
    lw s0, 24(sp)
    lw s1, 20(sp)
    lw s2, 16(sp)
    lw s3, 12(sp)
    lw s4, 8(sp)
    lw s5, 4(sp)
    lw s6, 0(sp)
    addi sp, sp, 32
    ret
