# You can change these values to test your solution.
.data
ARRAY: .word -6 -1 6 1
SIZE:  .word 4
INDEX: .word 2

.text
main:
  la a1, ARRAY      # a1 = pointer to array
  lw a2, SIZE       # a2 = array length
  lw a3, INDEX      # a3 = element index
  jal ra, select    # call select function
exit:
  li a7, 10         # exit syscall code
  ecall             # terminate the program

# ==========================================================================
# FUNCTION: select
#   This function selects an element from an integer array.
# Arguments:
#   a1 = pointer to int array
#   a2 = array length
#   a3 = element index
# Returns:
#   a0 = status code
#   a1 = value of the selected element
# ===========================================================================
select:
  # TODO: Implement the select function here

  # verificar se o tamanho e menor que  1
  li t0, 1
  blt a2, t0, select_invalid_size
  
  # verificar se o indice e menor que 0
  blt a3, zero, select_invalid_index
  
  # verificar se o indice e maior ou igual ao tamanho
  bge a3, a2, select_invalid_index
  
  # shift left, calcular o indice do elemento
  slli t0, a3, 2 # t0 = indice * 4
  # calcular o endereço do elemento
  add t0, a1, t0 # t0 = a1 + indice
  
  # ir buscar o valor certo de a1 no indice certo
  lw a1, 0(t0)
  
  # caso esteja tudo bem
  li a0, 0
  j select_end
  
 select_invalid_size:
     li a0, 50
     j select_end
 
 select_invalid_index:
     li a0, 100
     j select_end

select_end:
  jr ra               # return to the caller

