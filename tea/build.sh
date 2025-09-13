#!/bin/bash

# Build script for TEA project (C + Assembly)
echo "Building TEA project..."

# Compile C source (main.c) to object file
riscv64-unknown-elf-gcc \
    -march=rv32im \
    -mabi=ilp32 \
    -nostdlib \
    -ffreestanding \
    -g3 \
    -gdwarf-4 \
    -c \
    main.c \
    -o main.o

if [ $? -ne 0 ]; then
    echo "C compilation failed"
    exit 1
fi

# Compile startup assembly to object file
riscv64-unknown-elf-gcc \
    -march=rv32im \
    -mabi=ilp32 \
    -nostdlib \
    -ffreestanding \
    -g3 \
    -gdwarf-4 \
    -c \
    startup.s \
    -o startup.o

if [ $? -ne 0 ]; then
    echo "Startup assembly compilation failed"
    exit 1
fi

# Compile TEA assembly source to object file
riscv64-unknown-elf-gcc \
    -march=rv32im \
    -mabi=ilp32 \
    -nostdlib \
    -ffreestanding \
    -g3 \
    -gdwarf-4 \
    -c \
    tea_asm.s \
    -o tea_asm.o

if [ $? -ne 0 ]; then
    echo "TEA assembly compilation failed"
    exit 1
fi

# Link object files together into final ELF
riscv64-unknown-elf-gcc \
    -march=rv32im \
    -mabi=ilp32 \
    -nostdlib \
    -ffreestanding \
    -g3 \
    -gdwarf-4 \
    startup.o \
    main.o \
    tea_asm.o \
    -T linker.ld \
    -o tea.elf

if [ $? -eq 0 ]; then
    echo "Build successful: tea.elf created"
    echo "Object files: main.o, tea_asm.o, startup.o"
else
    echo "Linking failed"
    exit 1
fi
