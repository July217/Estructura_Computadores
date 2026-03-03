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