#!/bin/bash

# Run QEMU with GDB server for TEA project
echo "Starting QEMU with GDB server on port 1234..."
echo "In another terminal, run: gdb-multiarch tea.elf"
echo "Then in GDB: target remote :1234"
echo ""
echo "Useful GDB commands for this project:"
echo "  break _start          - break at program start"
echo "  break tea_encrypt_asm - break at encryption function"
echo "  break tea_decrypt_asm - break at decryption function"
echo "  info registers        - show register values"
echo "  step / next           - step through code"

qemu-system-riscv32 \
    -machine virt \
    -nographic \
    -bios none \
    -kernel tea.elf \
    -S \
    -gdb tcp::1234
