#include <stdint.h>

// Funciones en ensamblador
extern void tea_encrypt_asm(uint32_t v[2], const uint32_t key[4]);
extern void tea_decrypt_asm(uint32_t v[2], const uint32_t key[4]);

// Funciones de impresión
void print_char(char c) {
    volatile char *uart = (volatile char*)0x10000000; // UART en QEMU
    *uart = c;
}

void print_string(const char* str) {
    while (*str) {
        print_char(*str++);
    }
}

void print_hex(uint32_t num) {
    const char hex_chars[] = "0123456789ABCDEF";
    for (int i = 28; i >= 0; i -= 4) {
        print_char(hex_chars[(num >> i) & 0xF]);
    }
}

void print_block(uint32_t v[2]) {
    print_hex(v[0]);
    print_char(' ');
    print_hex(v[1]);
    print_char('\n');
}

// Casos de prueba
void test_single_block() {
    print_string("=== Prueba 1: Bloque unico ===\n");

    uint32_t key[4] = {0x12345678, 0x9ABCDEF0, 0xFEDCBA98, 0x76543210};
    uint32_t v[2]   = {0x484F4C41, 0x31323334}; // "HOLA1234" en ASCII

    print_string("Texto original:\n");
    print_block(v);

    tea_encrypt_asm(v, key);
    print_string("Cifrado:\n");
    print_block(v);

    tea_decrypt_asm(v, key);
    print_string("Descifrado:\n");
    print_block(v);

    print_string("===============================\n\n");
}

void test_multiple_blocks() {
    print_string("=== Prueba 2: Multiples bloques ===\n");

    uint32_t key[4] = {0xA56BABCD, 0x0000FFFF, 0xABCDEF01, 0x12345678};

    uint32_t msg[][2] = {
        {0x4D656E73, 0x616A6520}, // "Mens" "aje "
        {0x64652070, 0x72756562}, // "de p" "rueb"
        {0x61207061, 0x72612054}, // "a pa" "ra T"
        {0x45412000, 0x00000000}  // "EA\0" + padding
    };

    int num_blocks = 4;

    print_string("Texto original:\n");
    for (int i = 0; i < num_blocks; i++) {
        print_block(msg[i]);
    }

    // Cifrar
    for (int i = 0; i < num_blocks; i++) {
        tea_encrypt_asm(msg[i], key);
    }

    print_string("Cifrado:\n");
    for (int i = 0; i < num_blocks; i++) {
        print_block(msg[i]);
    }

    // Descifrar
    for (int i = 0; i < num_blocks; i++) {
        tea_decrypt_asm(msg[i], key);
    }

    print_string("Descifrado:\n");
    for (int i = 0; i < num_blocks; i++) {
        print_block(msg[i]);
    }

    print_string("\n\n");
}

// =====================
// Punto de entrada
// =====================
void main() {
    test_single_block();
    test_multiple_blocks();

    while (1) {
        __asm__ volatile ("nop");
    }
}
