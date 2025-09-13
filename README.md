# Proyecto Individual: Cifrado TEA en RISC-V con QEMU

Este proyecto implementa el **algoritmo de cifrado TEA (Tiny Encryption Algorithm)** en ensamblador RISC-V de 32 bits, ejecutado sobre un entorno bare-metal con **QEMU y GDB**.  
Se utiliza como base el entorno de desarrollo proporcionado en el curso (rvqemu), y se integra código en C y ensamblador.

---

## 1. Descripción del proyecto

El objetivo del proyecto es:
- Implementar el cifrado y descifrado TEA en ensamblador RISC-V.
- Integrar funciones en C y ensamblador.
- Ejecutar y depurar el programa en un entorno bare-metal (sin sistema operativo).
- Demostrar el correcto funcionamiento con casos de prueba:
  - **Caso 1:** Bloque único de 64 bits (`"HOLA1234"`).
  - **Caso 2:** Mensaje de varias palabras (`"Mensaje de prueba para TEA"`), dividido en bloques de 64 bits con padding.

---

## 2. Requerimientos de software

- **Docker** (para el contenedor de desarrollo `rvqemu`).
- **QEMU** (incluido en el contenedor).
- **Toolchain RISC-V** (`riscv64-unknown-elf-gcc`, `gdb-multiarch`).
- Sistema compatible: Linux o WSL recomendado.

---

## 3. Estructura del proyecto


```
.
├── build.sh # Script de compilación
├── run-qemu.sh # Script de ejecución en QEMU
├── main.c # Programa principal en C
├── tea_asm.s # Implementación de TEA en ensamblador RISC-V
├── startup.s # Código de arranque (bare-metal)
├── linker.ld # Script de ligadura
└── example.elf # Binario resultante
```

## Compilación y ejecución

### Paso 1: Construir el contenedor
```bash
chmod +x run.sh
./run.sh
```

### Paso 2: Elegir y compilar el programa
```bash

# Para el ejemplo de C + ensamblador
cd /home/rvqemu-dev/workspace/examples/tea
./build.sh
```

### Paso 3: Ejecutar con QEMU y depurar
```bash
# En una terminal: iniciar QEMU con servidor GDB
./run-qemu.sh

# En otra terminal: conectar GDB
docker exec -it rvqemu /bin/bash
cd /home/rvqemu-dev/workspace/examples/tea
gdb-multiarch tea.elf
```


---

## 4. Implementación técnica

### Bloques de datos
- **Bloque de entrada/salida:** `uint32_t v[2]` → 64 bits (2 palabras de 32 bits).
- **Clave:** `uint32_t key[4]` → 128 bits (4 palabras de 32 bits).

### Convención de llamadas RISC-V
- `a0` → puntero a bloque `v`.
- `a1` → puntero a clave `key`.
- `s0..s6` → registros persistentes (v0, v1, k0..k3, delta).
- `t0..t3` → registros temporales (sum, contador, cálculos intermedios).
- La pila se utiliza para guardar `ra` y `s*` durante la ejecución.

### Funciones implementadas
```c
extern void tea_encrypt_asm(uint32_t v[2], const uint32_t key[4]);
extern void tea_decrypt_asm(uint32_t v[2], const uint32_t key[4]);

Comandos de gdb en `simple_debug.gdb`:
```gdb
target remote :1234
break _start
break main
break sum_to_n
layout asm
layout regs
continue
step
step
info registers
continue
step
info registers
monitor quit
quit
```

## Convenciones de llamada RISC-V

- `a0`: Primer parámetro de entrada y valor de retorno
- `a1-a7`: Parámetros adicionales
- `s0-s11`: Registros salvados (preserved)
- `t0-t6`: Registros temporales
- `ra`: Dirección de retorno
- `sp`: Puntero de pila

La función assembly respeta estas convenciones:
1. Guarda registros que modifica en la pila
2. Recibe parámetro en `a0`
3. Devuelve resultado en `a0`
4. Restaura registros antes de retornar


## Pruebas de funcionamiento:

Cifrando y decifrando una cadena de caracteres en la Prueba 1, y múltiples cadenas en Prueba 2

<img width="1458" height="471" alt="test1" src="https://github.com/user-attachments/assets/1e21807b-ce7b-4922-8d69-dd6f6cde020c" />

<img width="1453" height="555" alt="image" src="https://github.com/user-attachments/assets/4d3fa279-51bc-433d-a2a0-26c6cc0f0452" />



##  Breve discusión de resultados

Las pruebas realizadas muestran que la implementación en ensamblador del algoritmo TEA funciona correctamente:

- En el **caso 1 (bloque único “HOLA1234”)**, el bloque cifrado produce una salida distinta al texto original, y el descifrado retorna exactamente el mismo valor inicial, confirmando la correcta aplicación del algoritmo.  
- En el **caso 2 (mensaje largo dividido en bloques)**, cada bloque de 64 bits se cifra de forma independiente, produciendo valores cifrados diferentes. Tras aplicar el descifrado, todos los bloques recuperan su contenido original, incluyendo el bloque final con padding.  
- El sistema respeta el modelo de memoria y la convención de llamadas de RISC-V: los punteros `a0` y `a1` permiten acceder a `v[2]` y `key[4]`, mientras que los registros y la pila garantizan la correcta preservación del contexto.  

Esto valida que la integración C ↔ ensamblador ↔ QEMU se realizó de manera exitosa.
