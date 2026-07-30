# You can change these values to test your solution.
.data
ARRAY: .word -6 -1 6 1
SIZE:  .word 4

.text
main:
  la a1, ARRAY        # a1 = pointer to array
  lw a2, SIZE         # a2 = number of elements in the array
  jal ra, argmax      # call argmax function
exit:
  li a7, 10           # exit syscall code
  ecall               # terminate the program

# ==========================================================================
# FUNCTION: argmax
#   Takes an array of integers and returns the index of the largest element.
#   If there are multiple elements with the same maximum value, 
#   it should return the smallest index among them.
# Arguments:
#   a1 = pointer to int array
#   a2 = array length
# Returns:
#   a0 = status code
#   a1 = index of the largest element
# ===========================================================================
argmax:
  # TODO: Implement the argmax function here
  # verificar se o tamanho é menor que  1
  li t0, 1
  blt a2, t0, argmax_invalid_size
  
  lw t0, 0(a1)    # t0 é igual ao primeiro elemento a[0], vai ser o maior elemento
  
  li t1, 0    # indice do maior elemento
  li t2, 1    # indice do elemento atual
  
  addi t3, a1, 4    # endereço do elemento atual, andar de 4 em 4 bytes
  
comparison:
    bge t2, a2, success    # quando o indice é maior ou igual ao tamanho, ja acabou
    
    lw t4, 0(t3)    # valor do elemento atual
 
    bgt t4, t0, update    # se o elemento atual for maior do que o elemento maior, trocamos

next:
  # avançar para o próximo elemento
  addi t2, t2, 1    # aumentar o indice
  addi t3, t3, 4    # aumentar o offset de 4 em 4 bytes
  j comparison

update:
  mv t0, t4    # valor maximo passa a ser o valor atual
  mv t1, t2    # o indice do maximo para a ser o atual
  j next

success:    # caso esteja tudo bem 
    li a0, 0
    mv a1, t1  
    j argmax_end
  
argmax_invalid_size:
    li a0, 50
    j argmax_end

argmax_end:
  jr ra               # return to the caller
