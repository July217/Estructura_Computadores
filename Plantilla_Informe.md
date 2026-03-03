# Informe de Laboratorio: Estructura de Computadores

**Nombre del Estudiante:** [Deiby Gonzalez, Julieta Ruiz]  
**Fecha:** [27/02/2026]  
**Asignatura:** Estructura de Computadores
**Enlace del repositorio en GitHub:** [agregar enlace Aquí]  

---

## 1. Análisis del Código Base

### 1.1. Evidencia de Ejecución
Adjunte aquí las capturas de pantalla de la ejecución del `programa_base.asm` utilizando las siguientes herramientas de MARS:
*   **MIPS X-Ray** (Ventana con el Datapath animado).
*   **Instruction Counter** (Contador de instrucciones totales).
*   **Instruction Statistics** (Desglose por tipo de instrucción).

> [Inserte aquí las capturas de pantalla]
![Captura IC](Codigo%20Base/PB.png)
![Captura IC](Codigo%20Base/MIPS.png)
![Captura IC](Codigo%20Base/IC.png)
![Captura IC](Codigo%20Base/IS.png)

### 1.2. Identificación de Riesgos (Hazards)
Completa la siguiente tabla identificando las instrucciones que causan paradas en el pipeline:

| Instrucción Causante | Instrucción Afectada | Tipo de Riesgo (Load-Use, etc.) | Ciclos de Parada |
|----------------------|----------------------|---------------------------------|------------------|
| `lw $t6, 0($t5)`     | `mul $t7, $t6, $t0`  | Load-Use Data Hazard            |      1 Ciclo     |
| `beq $t3, $t2, fin`  | `sll $t4, $t3, 2`    | Control hazard                  | 1 Ciclo (Teorico)|

### 1.2. Estadísticas y Análisis Teórico
Dado que MARS es un simulador funcional, el número de instrucciones ejecutadas será igual en ambas versiones. Sin embargo, en un procesador real, el tiempo de ejecución (ciclos) varía. Completa la siguiente tabla de análisis teórico:

| Métrica | Código Base | Código Optimizado |
|---------|-------------|-------------------|
| Instrucciones Totales (según MARS) |      94      |      94        |
| Stalls (Paradas) por iteración |      3       |        1 (Por el salto de "j")        |
| Total de Stalls (8 iteraciones) |      24       |         8          |
| **Ciclos Totales Estimados** (Inst + Stalls) |      118       |          102        |
| **CPI Estimado** (Ciclos / Inst) |      1.25       |        1.15      |

| Metrica | Codigo Base | Codigo Optimizado |
|---------|-------------|-------------------|
| Instrucciones Totales (8 Iteraciones) | 80 Instrucciones | 80 Instrucciones | 
| Stalls por Iteracion  | 1 stall (en el mul) | 0 stalls |
| Total de Stall (Todo el programa) | 8 ciclos | 0 ciclos
| Ciclos Totales Estimados | 88 Ciclos | 80 Ciclos |
| CPI Estimados (Ciclos / Instruccion) | 1.10 | 1.00 (Ideal)

---

## 2. Optimización Propuesta

### 2.1. Evidencia de Ejecución (Código Optimizado)
Adjunte aquí las capturas de pantalla de la ejecución del `programa_optimizado.asm` utilizando las mismas herramientas que en el punto 1.1:
*   **MIPS X-Ray**.
*   **Instruction Counter**.
*   **Instruction Statistics**.

> [Inserte aquí las capturas de pantalla]

![Captura IC](Codigo%20Optimizado/PO.png)
![Captura IC](Codigo%20Optimizado/MIPS_PO.png)
![Captura IC](Codigo%20Optimizado/IC_PO.png)
![Captura IC](Codigo%20Optimizado/IS_PO.png)

### 2.2. Código Optimizado
Pega aquí el fragmento de tu bucle `loop` reordenado:

```asm
# Pega tu código aquí
# Laboratorio: Estructura de computadores
# Actividad: Optimizacion de pipeline en Procesadores MIPS
# Archivo: programa_optimizado.asm

.data
    vector_x: .word 1, 2, 3, 4, 5, 6, 7, 8      # Arreglo en memoria con 8 enteros
    vector_y: .space 32                         # Espacio reservado de 32 bytes (8 enteros y 4 bytes) para Y
    const_a: .word 3                            # La constante A contiene un valor de 3
    const_b: .word 5                            # La constante B contiene un valor de 5
    tamano: .word 8                             # Tamaño de los vectores (8 elementos)

.text
.globl main

main: 
    # -- Inicio --
    la $s0, vector_x    # Carga el registro $s0 la direccion base del vector_x en memoria
    la $s1, vector_y    # Carga el registro $s1 la direccion base del vector_y en memoria
    lw $t0, const_a     # Carga el valor de const_a (3) desde memoria al registro $t0
    lw $t1, const_b     # Carga el valor de const_b (5) desde memoria al registro $t1
    lw $t2, tamano      # Carga el valor de tamaño (8) desde memori al registrar St2
    li $t3, 0           # Inicia el contador del bucle (indice i) en 0 dentro del registro $t3

loop:
    
    # -- Condicion de salida -- 
    beq	$t3, $t2, fin   # Compara el indice (i) con el tamaño (8) si son iguales, salta a la etiqueta de "fin"

    # -- Calculo de direccion de memoria de X[i] -- 
    sll	$t4, $t3, 2     # Multiplica el indice i por 4 (Desplazamiento de bits a la izquierda) y lo guarda en $t4
    addu $t5, $s0, $t4  # Suma la direccion base de vector_x ($s0) mas el desplazamiento ($t4), guardando en $t5

    # -- Cargo de dato --
    lw $t6, 0($t5)      # Carga en $t6 el valor entero ubicado en la direccion de la memoria contenida en $t5 (X[i])

    # *** Optimizacion Aplicada
    # Se mueve el calculo de la direccion de Y[i] aqui para evitar el "Stall" (Riesgo Load-Use)
    # Esta instruccion es independiente de $t6, por lo que el procesador hace trabajo util mientras esperas a la memoria.
    addu $t9, $s1, $s4  # Suma la direccion base de vector_y ($s1) mas el desplazamiento ($t4), guardando en $t9 la direccion de Y[i]

    # -- Operacion aritmetica --
    mul $t7, $t6, $t0   # Multiplica X[i] ($t6) por la constante A ($t0) y guarda el resultado en $t7
    addu $t8, $t7, $t1  # Suma el resultado anterior ($t7) mas la constante B ($t1) y lo guarda en $t8 (Y[i] calculado)

    # -- Almacenamiento de resultado --
    sw $t8, 0($t9)      # guarda el valor final calculado ($t8) en la direccion de memoria de Y[i] ($t9)

    # -- Incremento y salto --
    addi $t3, $t3, 1    # Suma 1 al indice i ($t3) para pasar a la siguiente iteracion
    j loop              # Salto incondicional al inicio de la etiqueta "loop"

fin:
    # -- Finalizacion del programa --
    li $v0, 10          # Carga el codigo de servicio 10 en $v0 (Codigo para salir del programa en MARS)
    syscall             # Llama al sistema para terminar la ejecución
```

### 2.2. Justificación Técnica de la Mejora
Explica qué instrucción moviste y por qué colocarla entre el `lw` y el `mul` elimina el riesgo de datos:
> [Tu explicación aquí]

---

## 3. Comparativa de Resultados

| Métrica | Código Base | Código Optimizado | Mejora (%) |
|---------|-------------|-------------------|------------|
| Ciclos Totales |      88       |        80           |            |
| Stalls (Paradas) |      8       |        0          |            |
| CPI |      1.1       |        1.0           |            |

---

## 4. Conclusiones
¿Qué impacto tiene la segmentación en el diseño de software de bajo nivel? ¿Es siempre posible eliminar todas las paradas?
> [Tus conclusiones aquí]
