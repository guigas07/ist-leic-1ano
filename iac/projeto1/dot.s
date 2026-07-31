# You can change these values to test your solution.
.data
A:    .word 1, 2, 1, 1
B:    .word 1, 1, 3, 3
SIZE: .word 4

.text
main:
  la a1, A          # a1 = pointer to array A
  la a2, B          # a2 = pointer to array B
  lw a3, SIZE       # a3 = number of elements in each array
  jal ra, dot       # call dot function
exit:
  li a7, 10         # exit syscall code
  ecall             # terminate the program


# ==========================================================================
# FUNCTION: dot
#   This function computes the dot product of two integer arrays.
# Arguments:
#   a1 = pointer to first array
#   a2 = pointer to second array
#   a3 = array length
# Returns:
#   a0 = status code
#   a1 = dot product result
# ===========================================================================
dot:

  li t0, 1
  blt a3, t0, exit_out_of_bounds     # verificacao len > 1
     
  li t0, 0        # inicia contador
  li t1, 0        # inicia indice

loop_dot:
  beq t1, a3, loop_end
  lw t2, 0(a1)        # num indice i array A
  lw t3, 0(a2)        # num indice i array B
  
  check_overflow_mult:
    mulh t4, t2, t3                 # dá nos o sinal da mult mulh(10*10) = 000...0, mulh(10*(-10)) = 111...1
    mul t2, t2, t3                  # t2 *= t3
    mv t6, t2                       # t6 = t2
    srai t6, t6, 31                 # o bit mais significativo que nos diz o sinal passa a ser tudo. ex 0101010... -> 00000000
    bne t4, t6, overflow_error      # caso a extensao nao seja igual ao sinal, existiu overflow (precisou de mais de 32 bits)
  
  check_overflow_add:
    mv t3, t0       
    srai t3, t3, 31               # extender o sinal em ambas as parcelas
    srai t5, t2, 31
    add t0, t0, t2                # fazer a soma, caso exista overflow nao utilizamos o resultado
    bne t3, t5, continua          # se o sinal de a != sinal de b, impossivel haver overflow
    mv t5, t0
    srai t5, t5, 31               # voltar a fazer a extensao ao resultado da soma caso os sinais sejam iguais
    bne t3, t5, overflow_error    # sinal diferente = overflow
  
  continua:
     
    addi a1, a1, 4  # adiciona 4 bits para ir para o proximo inteiro
    addi a2, a2, 4
    addi t1, t1, 1
    
    j loop_dot


loop_end:
  li a0, 0
  mv a1, t0
  j dot_end

overflow_error:
  li a0, 200
  j dot_end

exit_out_of_bounds:
  li a0, 50       
  j dot_end

dot_end:
  jr ra               # return to the caller

