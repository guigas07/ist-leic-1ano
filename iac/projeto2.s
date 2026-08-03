###########################################################################
# Upper bound constants for static memory reservation
###########################################################################
.equ CONST_DIMENSION 4
.equ CONST_BUFFER_SIZE 1024
.equ CONST_MAX_VOCAB_TOKENS 100
.equ CONST_MAX_INPUT_TOKENS 10

###########################################################################
# System call constants
###########################################################################
.equ CONST_SYSCALL_PRINT_INT 1
.equ CONST_SYSCALL_PRINT_STRING 4
.equ CONST_SYSCALL_PRINT_CHAR 11
.equ CONST_SYSCALL_EXIT 10
.equ CONST_SYSCALL_EXIT2 93
.equ CONST_SYSCALL_OPEN 1024
.equ CONST_SYSCALL_CLOSE 57
.equ CONST_SYSCALL_READ 63
.equ CONST_SYSCALL_WRITE 64

###########################################################################
# ASCII character constants
###########################################################################
.equ CONST_CHAR_EOF 0
.equ CONST_CHAR_SPACE 32
.equ CONST_CHAR_NEWLINE 10
.equ CONST_CHAR_HYPHEN 45
.equ CONST_CHAR_ZERO 48

.data
###########################################################################
# Data section with static memory reservations.
# Feel free to add more if needed.
###########################################################################
VOCABULARY_FILENAME:     .string "vocab.txt"
EMBEDDINGS_FILENAME:     .string "embeddings.txt"
INPUT_FILENAME:          .string "input.txt"
     
W_Q_FILENAME:            .string "W_Q.txt"
W_K_FILENAME:            .string "W_K.txt"
W_V_FILENAME:            .string "W_V.txt"

VOCAB_BUFFER:            .zero CONST_BUFFER_SIZE                              # Contents of the vocabulary file
INPUT_BUFFER:            .zero CONST_BUFFER_SIZE                              # Contents of the input file
MATRIX_BUFFER:           .zero CONST_BUFFER_SIZE                              # Contents of a matrix file (used for W_Q, W_K, W_V, and embeddings)

INPUT_INDICES_VECTOR:    .zero (CONST_MAX_INPUT_TOKENS * 4)                   # Vector of input token indices (#inputs x 4 bytes)
SCORES_VECTOR:           .zero (CONST_MAX_INPUT_TOKENS * 4)                   # Vector of scores (#tokens x 4 bytes)

INPUT_TOTAL_TOKENS:      .word 0                                              # Number of tokens in the input
VOCAB_TOTAL_TOKENS:      .word 0                                              # Number of tokens in the vocabulary

VOCAB_EMBEDDINGS_MATRIX: .zero (CONST_MAX_VOCAB_TOKENS * CONST_DIMENSION * 4) # Embedding matrix (#tokens x dimension x 4 bytes)
INPUT_EMBEDDINGS_MATRIX: .zero (CONST_MAX_INPUT_TOKENS * CONST_DIMENSION * 4) # Embedding matrix (#tokens x dimension x 4 bytes)
W_Q_MATRIX:              .zero (CONST_DIMENSION * CONST_DIMENSION * 4)        # W_Q matrix (dimension x dimension x 4 bytes)
W_K_MATRIX:              .zero (CONST_DIMENSION * CONST_DIMENSION * 4)        # W_K matrix (dimension x dimension x 4 bytes)
W_V_MATRIX:              .zero (CONST_DIMENSION * CONST_DIMENSION * 4)        # W_V matrix (dimension x dimension x 4 bytes)
Q_MATRIX:                .zero (CONST_MAX_INPUT_TOKENS * CONST_DIMENSION * 4) # Q matrix (#tokens x dimension x 4 bytes)
K_MATRIX:                .zero (CONST_MAX_INPUT_TOKENS * CONST_DIMENSION * 4) # K matrix (#tokens x dimension x 4 bytes)
V_MATRIX:                .zero (CONST_MAX_INPUT_TOKENS * CONST_DIMENSION * 4) # V matrix (#tokens x dimension x 4 bytes)

.text
main:
    ###########################################################################
    # Read vocabulary
    ###########################################################################
    la a0, VOCABULARY_FILENAME   #endereço do vocab txt
    la a1, VOCAB_BUFFER    #endereço onde guardar o conteudo
    li a2, CONST_BUFFER_SIZE    #tamanho maximo de bytes a ler
    jal read_file
    
    #la a0, VOCAB_BUFFER    #endereço do buffer já preenchido
    #jal print_vocabulary
    
                 
    ###########################################################################
    # Read input
    ###########################################################################
    la a0, INPUT_FILENAME
    la a1, INPUT_BUFFER
    li a2, CONST_BUFFER_SIZE
    jal read_file
    
    #la a0, INPUT_BUFFER
    #jal print_input

    ###########################################################################
    # Read W_Q matrix
    ###########################################################################
    la a0, W_Q_FILENAME
    la a1, MATRIX_BUFFER
    li a2, CONST_BUFFER_SIZE
    jal read_file
                       
    ###########################################################################
    # Parse W_Q matrix from buffer
    ###########################################################################
    la a0, W_Q_MATRIX
    la a1, MATRIX_BUFFER
    jal parse_matrix_buffer

    #la a0, W_Q_MATRIX
    #li a2, CONST_DIMENSION
    #jal print_matrix
    ###########################################################################
    # Read W_K matrix
    ###########################################################################
    la a0, W_K_FILENAME
    la a1, MATRIX_BUFFER
    li a2, CONST_BUFFER_SIZE
    jal read_file

    ###########################################################################
    # Parse W_K matrix from buffer
    ###########################################################################
    la a0, W_K_MATRIX
    la a1, MATRIX_BUFFER
    jal parse_matrix_buffer

    ###########################################################################
    # Read W_V matrix
    ###########################################################################
    la a0, W_V_FILENAME
    la a1, MATRIX_BUFFER
    li a2, CONST_BUFFER_SIZE
    jal read_file

    ###########################################################################
    # Parse W_V matrix from buffer
    ###########################################################################
    la a0, W_V_MATRIX
    la a1, MATRIX_BUFFER
    jal parse_matrix_buffer

    ###########################################################################
    # Read embeddings matrix
    ###########################################################################
    la a0, EMBEDDINGS_FILENAME
    la a1, MATRIX_BUFFER
    li a2, CONST_BUFFER_SIZE
    jal read_file

    ###########################################################################
    # Parse vocabulary embeddings matrix from buffer
    ###########################################################################
    la a0, VOCAB_EMBEDDINGS_MATRIX
    la a1, MATRIX_BUFFER
    jal parse_matrix_buffer

    la t0, VOCAB_TOTAL_TOKENS
    sw a1, 0(t0)

    ###########################################################################
    # Convert input tokens to indices
    ###########################################################################
    la a0, INPUT_INDICES_VECTOR #guardar os indices
    la a2, INPUT_BUFFER     # texto do input
    la a3, VOCAB_BUFFER  #texto do vocab
    jal tokens_to_indices

    la t0, INPUT_TOTAL_TOKENS
    sw a1, 0(t0)
    
    la a0, INPUT_INDICES_VECTOR    

    ###########################################################################
    # Build input embeddings matrix
    ###########################################################################
    la a0, INPUT_EMBEDDINGS_MATRIX
    la a1, VOCAB_EMBEDDINGS_MATRIX
    la a2, INPUT_INDICES_VECTOR

    la t0, INPUT_TOTAL_TOKENS
    lw a3, 0(t0)

    jal build_input_embeddings_matrix

    ###########################################################################
    # Build matrix Q
    ###########################################################################
    la a0, Q_MATRIX
    la a1, INPUT_EMBEDDINGS_MATRIX

    la t0, INPUT_TOTAL_TOKENS
    lw a2, 0(t0)

    li a3, CONST_DIMENSION
    la a4, W_Q_MATRIX
    li a5, CONST_DIMENSION
    li a6, CONST_DIMENSION

    jal matrix_multiply

    ###########################################################################
    # Build matrix K
    ###########################################################################
    la a0, K_MATRIX
    la a1, INPUT_EMBEDDINGS_MATRIX

    la t0, INPUT_TOTAL_TOKENS
    lw a2, 0(t0)

    li a3, CONST_DIMENSION
    la a4, W_K_MATRIX
    li a5, CONST_DIMENSION
    li a6, CONST_DIMENSION

    jal matrix_multiply

    ###########################################################################
    # Build matrix V
    ###########################################################################
    la a0, V_MATRIX
    la a1, INPUT_EMBEDDINGS_MATRIX

    la t0, INPUT_TOTAL_TOKENS
    lw a2, 0(t0)
    
    li a3, CONST_DIMENSION
    la a4, W_V_MATRIX
    li a5, CONST_DIMENSION
    li a6, CONST_DIMENSION

    jal matrix_multiply

    ###########################################################################
    # Compute scores for the last input token
    ###########################################################################
    la a0, SCORES_VECTOR
    la a1, Q_MATRIX
    la a2, K_MATRIX

    la t0, INPUT_TOTAL_TOKENS
    lw a3, 0(t0)

    li a4, CONST_DIMENSION
    addi a5, a3, -1        # target = último token

    jal compute_scores

    ###########################################################################
    # Get the highest score index using argmax
    ###########################################################################
    la a1, SCORES_VECTOR

    la t0, INPUT_TOTAL_TOKENS
    lw a2, 0(t0)

    jal argmax

    mv s8, a1      # índice com maior score

    ###########################################################################
    # Select chosen vector in V using the index from argmax
    ###########################################################################
    la a1, V_MATRIX

    la t0, INPUT_TOTAL_TOKENS
    lw a2, 0(t0)

    li a3, CONST_DIMENSION
    mv a4, s8
    
    jal select_vector_in_matrix  # a0 agora tem o endereço do vetor selecionado em V

    ###########################################################################
    # Pick the next token in the vocabulary with the highest score
    ###########################################################################
    la a1, VOCAB_EMBEDDINGS_MATRIX

    la t0, VOCAB_TOTAL_TOKENS
    lw a2, 0(t0)

    jal decide_next_token  # a0 agora tem o índice do token previsto
    
    mv t1, a0              # t1 = índice previsto
    la t0, VOCAB_BUFFER    # t0 = ponteiro atual no vocabulário

main_find_token_loop:
    beq t1, zero, main_found_token_address

main_skip_token_chars:
    lb t2, 0(t0)
    li t3, CONST_CHAR_NEWLINE
    beq t2, t3, main_next_token
    addi t0, t0, 1
    j main_skip_token_chars

main_next_token:
    addi t0, t0, 1     # passar o newline
    addi t1, t1, -1    # falta menos um token
    j main_find_token_loop

main_found_token_address:
    mv a0, t0
    jal print_predicted_token
    ###########################################################################
    # Terminate program successfully
    ###########################################################################
    li a0, 0
    j exit_with_code                                # Exit with code 0

# Read from a text file into a buffer.
# (in)     a0: filename address (char*)
# (in/out) a1: destination buffer
# (in)     a2: maximum number of bytes to read
# Read from a text file into a buffer.
# (in)     a0: filename address (char*)
# (in/out) a1: destination buffer
# (in)     a2: maximum number of bytes to read
read_file:
    addi sp, sp, -16                
    sw ra, 0(sp)                    # guardar endereço de retorno
    sw a1, 4(sp)                    # guardar endereço do buffer de destino
    sw a2, 8(sp)                    # guardar tamanho máximo de bytes a ler
    
    # Abrir o ficheiro (syscall open)
    # a0 já tem o endereço do nome do ficheiro
    li a1, 0                        
    li a7, CONST_SYSCALL_OPEN
    ecall
    # a0 agora contém o file descriptor (inteiro >= 0) ou -1 se erro
    
    sw a0, 12(sp)                   # guardar o file descriptor na stack para usar depois

    # Ler o conteúdo do ficheiro para o buffer (syscall read)
    lw a0, 12(sp)                   # a0 = file descriptor
    lw a1, 4(sp)                    # a1 = endereço do buffer de destino
    lw a2, 8(sp)                    # a2 = número máximo de bytes a ler
    li a7, CONST_SYSCALL_READ
    ecall
    # a0 agora contém o número de bytes lidos

    # Colocar '\0' (null terminator) no fim do texto lido
    # Isto é necessário para que as funções de parsing saibam onde o conteúdo termina
    lw t0, 4(sp)                    # t0 = endereço do início do buffer
    add t0, t0, a0                  # t0 = endereço do byte após o último byte lido
    sb zero, 0(t0)                  # escrever '\0' nessa posição

    # Fechar o ficheiro (syscall close)
    lw a0, 12(sp)                   # a0 = file descriptor
    li a7, CONST_SYSCALL_CLOSE
    ecall

    lw ra, 0(sp)                    # restaurar endereço de retorno
    addi sp, sp, 16                 # libertar espaço na stack
    ret


# Assumes the matrix is stored in the buffer as space-separated integers.
# Assumes columns are separated by 1 space (' '), and rows by 1 newline ('\n').
# Assumes only signed integers are provided.
# (in/out) a0: address of the matrix to fill (int*)
# (out)    a1: number of rows in the matrix (int)
# (in)     a1: address of the buffer containing the matrix data (char*)
parse_matrix_buffer:
    addi sp, sp, -24              
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)

    mv s0, a0                       # s0 = ponteiro para a matriz de inteiros a preencher
    mv s1, a1                       # s1 = ponteiro para o buffer de texto (avança char a char)
    li s2, 0                        # s2 = contador de linhas da matriz (será devolvido em a1)
    li s3, 0                        # s3 = valor do número que está a ser construído dígito a dígito
    li s4, 1                        # s4 = sinal do número atual: +1 (positivo) ou -1 (negativo)

parse_matrix_loop:
    lb t0, 0(s1)                    # ler o caractere atual do buffer

    beq t0, zero, parse_matrix_done # se for '\0' (EOF), terminar

    li t1, CONST_CHAR_HYPHEN
    beq t0, t1, parse_matrix_negative          # se for '-', o número seguinte é negativo

    li t1, CONST_CHAR_SPACE
    beq t0, t1, parse_matrix_store_number      # se for ' ', terminou um número (separador de colunas)

    li t1, CONST_CHAR_NEWLINE
    beq t0, t1, parse_matrix_store_number_newline  # se for '\n', terminou uma linha

    j parse_matrix_digit            # caso contrário, é um dígito entre '0' e '9'


parse_matrix_digit:
    li t1, CONST_CHAR_ZERO
    sub t2, t0, t1                  # converter ASCII para valor numérico: t2 = char - '0'

    li t3, 10
    mul s3, s3, t3                  # deslocar o número atual uma casa decimal: s3 = s3 * 10
    add s3, s3, t2                  # adicionar o novo dígito: s3 = s3 * 10 + dígito

    addi s1, s1, 1                  # avançar para o próximo caractere
    j parse_matrix_loop


parse_matrix_negative:
    li s4, -1                       # marcar que o próximo número é negativo
    addi s1, s1, 1                  # avançar para o próximo caractere (o primeiro dígito)
    j parse_matrix_loop


parse_matrix_store_number:
    # Chegou a um espaço: guardar o número atual na matriz
    mul t2, s3, s4                  # aplicar o sinal: t2 = valor * sinal (+1 ou -1)
    sw t2, 0(s0)                    # guardar o inteiro na posição atual da matriz
    addi s0, s0, 4                  # avançar o ponteiro da matriz (4 bytes por inteiro)
    li s3, 0                        # reset do número atual para o próximo
    li s4, 1                        # reset do sinal para positivo
    addi s1, s1, 1                  # avançar para o próximo caractere
    j parse_matrix_loop


parse_matrix_store_number_newline:
    # Chegou a um newline: guardar o número atual e incrementar o contador de linhas
    mul t2, s3, s4                  # aplicar o sinal: t2 = valor * sinal
    sw t2, 0(s0)                    # guardar o inteiro na posição atual da matriz
    addi s0, s0, 4                  # avançar o ponteiro da matriz
    addi s2, s2, 1                  # incrementar o contador de linhas
    li s3, 0                        # reset do número atual
    li s4, 1                        # reset do sinal para positivo
    addi s1, s1, 1                  # avançar para o próximo caractere
    j parse_matrix_loop


parse_matrix_done:
    mv a1, s2            

    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 24
    ret


# Converts the input tokens into their corresponding indices in the vocabulary.
# (in/out) a0: address of input indices vector to fill (int*)
# (out)    a1: size of input indices vector (number of tokens in input)
# (in)     a2: address to input buffer
# (in)     a3: address to vocabulary buffer
tokens_to_indices:
    addi sp, sp, -20                
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)

    mv s0, a0                       # s0 = ponteiro para o vetor de índices a preencher
    mv s1, a2                       # s1 = ponteiro para o buffer de input (palavra atual do input)
    mv s2, a3                       # s2 = ponteiro para o início do vocabulário (fixo)
    li s3, 0                        # s3 = contador de tokens encontrados (será devolvido em a1)

tokens_input_loop:
    lb t0, 0(s1)                    # ler o primeiro char da palavra atual do input
    beq t0, zero, tokens_end        # se for '\0', chegou ao fim do input

    mv t1, s2                       # t1 = ponteiro para a palavra atual do vocab (recomeça do início do vocab)
    li t2, 0                        # t2 = índice da palavra atual no vocab (começa em 0)

tokens_vocab_loop:
    # Comparar a palavra do input com a palavra atual do vocabulário
    mv t3, s1                       # t3 = ponteiro para o char atual da palavra do input
    mv t4, t1                       # t4 = ponteiro para o char atual da palavra do vocab

tokens_compare_loop:
    lb t5, 0(t3)                    # ler char atual da palavra do input
    lb t6, 0(t4)                    # ler char atual da palavra do vocab
    li t0, CONST_CHAR_NEWLINE

    beq t5, t0, tokens_input_word_end       # se input chegou ao '\n', a palavra do input terminou
    bne t5, t6, tokens_go_next_vocab_word   # se os chars são diferentes, esta palavra do vocab não é a correta

    addi t3, t3, 1                  # avançar para o próximo char do input
    addi t4, t4, 1                  # avançar para o próximo char do vocab
    j tokens_compare_loop           # continuar a comparar char a char

tokens_input_word_end:
    # A palavra do input terminou (chegou ao '\n')
    # Verificar se a palavra do vocab também terminou (caso contrário, são palavras diferentes, ex: "cat" vs "cats")
    bne t6, t0, tokens_go_next_vocab_word   # se o vocab ainda não chegou ao '\n', as palavras são diferentes

    # As duas palavras terminaram ao mesmo tempo: são iguais!
    sw t2, 0(s0)                    # guardar o índice do vocab no vetor de índices
    addi s0, s0, 4                  # avançar o ponteiro do vetor de índices
    addi s3, s3, 1                  # incrementar o contador de tokens encontrados
    addi s1, t3, 1                  # avançar s1 para a próxima palavra do input (passar o '\n')
    j tokens_input_loop             # processar a próxima palavra do input

tokens_go_next_vocab_word:
    # A palavra do vocab atual não corresponde: avançar até ao próximo '\n' do vocab
    lb t5, 0(t1)                    # ler char atual do vocab
    li t0, CONST_CHAR_NEWLINE
    beq t5, t0, tokens_next_vocab_word_found    # se chegou ao '\n', encontrou o fim desta palavra
    addi t1, t1, 1                  # senão, avançar um char no vocab
    j tokens_go_next_vocab_word

tokens_next_vocab_word_found:
    addi t1, t1, 1                  # avançar para passar o '\n' e ficar no início da próxima palavra
    addi t2, t2, 1                  # incrementar o índice do vocab
    j tokens_vocab_loop             # tentar comparar a palavra do input com a próxima palavra do vocab

tokens_end:
    mv a1, s3 

    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    addi sp, sp, 20
    ret


# (in/out) a0: address of the output matrix to fill (int*)
# (in)     a1: address of the vocabulary embeddings matrix (int*)
# (in)     a2: address of the input indices array (int*)
# (in)     a3: number of tokens in the input (int)
build_input_embeddings_matrix:
    addi sp, sp, -24                
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)

    mv s0, a0                       # s0 = ponteiro para a matriz de embeddings do input a preencher
    mv s1, a1                       # s1 = ponteiro para a matriz de embeddings do vocabulário
    mv s2, a2                       # s2 = ponteiro para o vetor de índices do input
    mv s3, a3                       # s3 = número total de tokens no input
    li s4, 0                        # s4 = índice do token atual (i = 0, 1, ..., s3-1)

build_input_embeddings_loop:
    beq s4, s3, build_input_embeddings_done # se i == número de tokens, terminar

    lw t0, 0(s2)                    # t0 = índice do token atual no vocabulário

    li t1, CONST_DIMENSION          # t1 = número de colunas (4)
    mul t2, t0, t1                  # t2 = índice do token * 4 (deslocamento em inteiros)
    slli t2, t2, 2                  # t2 = deslocamento em bytes (multiplicar por 4)
    add t3, s1, t2                  # t3 = endereço da linha correta na matriz de embeddings do vocab

    li t4, 0                        # t4 = contador de colunas copiadas (j = 0)

build_input_embeddings_col_loop:
    beq t4, t1, build_input_embeddings_next_token   # se j == 4 (CONST_DIMENSION), passou as 4 colunas

    lw t5, 0(t3)                    # ler o valor da coluna j do embedding do vocab
    sw t5, 0(s0)                    # guardar esse valor na linha correspondente da matriz de input

    addi t3, t3, 4                  # avançar para a próxima coluna do vocab
    addi s0, s0, 4                  # avançar para a próxima posição da matriz de output
    addi t4, t4, 1                  # j++
    j build_input_embeddings_col_loop

build_input_embeddings_next_token:
    addi s2, s2, 4                  # avançar o ponteiro do vetor de índices para o próximo token
    addi s4, s4, 1                  # i++
    j build_input_embeddings_loop

build_input_embeddings_done:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 24
    ret


# (in/out) a0: address of the output matrix to fill (int*)
# (in)     a1: address of the first matrix (int*) — matriz A
# (in)     a2: #rows of the first matrix (int)
# (in)     a3: #columns of the first matrix (int)
# (in)     a4: address of the second matrix (int*) — matriz B
# (in)     a5: #rows of the second matrix (int)
# (in)     a6: #columns of the second matrix (int)
# Calcula C = A x B, onde C tem dimensão a2 x a6
matrix_multiply:
    addi sp, sp, -36                
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)
    sw s7, 32(sp)

    mv s0, a0                       # s0 = ponteiro para a matriz C (resultado)
    mv s1, a1                       # s1 = ponteiro para a matriz A
    mv s2, a2                       # s2 = número de linhas de A (e de C)
    mv s3, a3                       # s3 = número de colunas de A (= número de linhas de B)
    mv s4, a4                       # s4 = ponteiro para a matriz B
    mv s5, a6                       # s5 = número de colunas de B (e de C)
    li s6, 0                        # s6 = i (índice da linha atual de A e C)

matrix_multiply_row_loop:
    beq s6, s2, matrix_multiply_done    # se i == linhas de A, terminar

    li s7, 0                        # s7 = j (índice da coluna atual de B e C)

matrix_multiply_col_loop:
    beq s7, s5, matrix_multiply_next_row    # se j == colunas de B, passar à próxima linha i

    li t0, 0                        # t0 = soma acumulada para C[i][j] (começa em 0)
    li t1, 0                        # t1 = k (índice interior para o produto interno)

matrix_multiply_inner_loop:
    beq t1, s3, matrix_multiply_store  # se k == colunas de A, terminou o produto interno

    # Calcular endereço de A[i][k] = base_A + (i * cols_A + k) * 4
    mul t2, s6, s3                  # t2 = i * cols_A
    add t2, t2, t1                  # t2 = i * cols_A + k
    slli t2, t2, 2                  # t2 = offset em bytes
    add t3, s1, t2                  # t3 = endereço de A[i][k]
    lw t4, 0(t3)                    # t4 = valor de A[i][k]

    # Calcular endereço de B[k][j] = base_B + (k * cols_B + j) * 4
    mul t2, t1, s5                  # t2 = k * cols_B
    add t2, t2, s7                  # t2 = k * cols_B + j
    slli t2, t2, 2                  # t2 = offset em bytes
    add t3, s4, t2                  # t3 = endereço de B[k][j]
    lw t5, 0(t3)                    # t5 = valor de B[k][j]

    mul t6, t4, t5                  # t6 = A[i][k] * B[k][j]
    add t0, t0, t6                  # acumular na soma: soma += A[i][k] * B[k][j]

    addi t1, t1, 1                  # k++
    j matrix_multiply_inner_loop

matrix_multiply_store:
    # Calcular endereço de C[i][j] = base_C + (i * cols_B + j) * 4
    mul t2, s6, s5                  # t2 = i * cols_B
    add t2, t2, s7                  # t2 = i * cols_B + j
    slli t2, t2, 2                  # t2 = offset em bytes
    add t3, s0, t2                  # t3 = endereço de C[i][j]
    sw t0, 0(t3)                    # guardar a soma calculada em C[i][j]

    addi s7, s7, 1                  # j++
    j matrix_multiply_col_loop

matrix_multiply_next_row:
    addi s6, s6, 1                  # i++
    j matrix_multiply_row_loop

matrix_multiply_done:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    lw s7, 32(sp)
    addi sp, sp, 36
    ret


# (in/out) a0: address of the output scores vector to fill (int*)
# (in)     a1: address of Q matrix (int*)
# (in)     a2: address of K matrix (int*)
# (in)     a3: #rows of Q and K (int)
# (in)     a4: #columns of Q and K (int)
# (in)     a5: target token index for which we want to compute the score (int)
# Para cada j de 0 a n-1, calcula score(j) = Q[target] · K[j] e guarda no vetor de scores
compute_scores:
    addi sp, sp, -36                
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)
    sw s7, 32(sp)

    mv s0, a0                       # s0 = ponteiro para o vetor de scores a preencher
    mv s1, a1                       # s1 = ponteiro para a matriz Q
    mv s2, a2                       # s2 = ponteiro para a matriz K
    mv s3, a3                       # s3 = número de linhas (tokens) em Q e K
    mv s4, a4                       # s4 = número de colunas (dimensão dos vetores)
    mv s5, a5                       # s5 = índice do token alvo (last token)

    # Calcular o endereço fixo de Q[target]: é a linha target da matriz Q
    mul t0, s5, s4                  # t0 = target * cols (deslocamento em inteiros)
    slli t0, t0, 2                  # t0 = offset em bytes
    add s6, s1, t0                  # s6 = endereço de Q[target] — fixo para todo o loop

    li s7, 0                        # s7 = j (índice da linha atual de K, começa em 0)

compute_scores_loop:
    beq s7, s3, compute_scores_done # se j == número de tokens, terminar

    # Calcular o endereço de K[j]: avança j linhas na matriz K
    mul t0, s7, s4                  # t0 = j * cols (deslocamento em inteiros)
    slli t0, t0, 2                  # t0 = offset em bytes
    add t1, s2, t0                  # t1 = endereço de K[j]

    # Chamar dot para calcular Q[target] · K[j]
    mv a1, s6                       # a1 = endereço de Q[target] (fixo)
    mv a2, t1                       # a2 = endereço de K[j]
    mv a3, s4                       # a3 = dimensão dos vetores
    jal dot
    # resultado devolvido em a1

    slli a1, a1, 1                  # multiplicar o score por 2
    sw a1, 0(s0)                    # guardar o score no vetor de scores

    addi s0, s0, 4                  # avançar o ponteiro do vetor de scores
    addi s7, s7, 1                  # j++
    j compute_scores_loop

compute_scores_done:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    lw s7, 32(sp)
    addi sp, sp, 36
    ret


# (out) a0: address of the selected vector (int*)
# (in)  a1: address of matrix (int*)
# (in)  a2: #rows (int)
# (in)  a3: #cols (int)
# (in)  a4: target row
# Devolve o endereço da linha target_row na matriz
select_vector_in_matrix:
    # endereço = base_matrix + (target_row * cols) * 4
    mul t0, a4, a3                  # t0 = target_row * cols (deslocamento em inteiros)
    slli t0, t0, 2                  # t0 = offset em bytes
    add a0, a1, t0                  # a0 = endereço da linha target_row
    ret


# (out) a0: index of the predicted token in the vocabulary (int)
# (in)  a0: address of target vector (int*)
# (in)  a1: vocabulary embeddings address (int*)
# (in)  a2: number of tokens in vocabulary (int)
# Compara o vetor alvo com todos os embeddings do vocabulário usando produto interno
# e devolve o índice do embedding mais semelhante (maior produto interno)
decide_next_token:
    addi sp, sp, -32            
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)

    mv s0, a0                       # s0 = endereço do vetor alvo (fixo durante todo o loop)
    mv s1, a1                       # s1 = endereço do início da matriz de embeddings do vocab
    mv s2, a2                       # s2 = número de tokens no vocabulário
    li s3, 0                        # s3 = índice do token atual (i = 0, 1, ..., s2-1)
    li s4, 0                        # s4 = melhor índice encontrado até agora
    li s5, 0                        # s5 = melhor score (produto interno) encontrado até agora
    mv s6, s1                       # s6 = ponteiro para o embedding atual (avança a cada iteração)

decide_next_token_loop:
    beq s3, s2, decide_next_token_done  # se i == número de tokens, terminar

    # Calcular produto interno entre o vetor alvo e o embedding atual do vocab
    mv a1, s0                       # a1 = vetor alvo
    mv a2, s6                       # a2 = embedding atual do vocab
    li a3, CONST_DIMENSION          # a3 = dimensão dos vetores (4)
    jal dot
    # resultado do produto interno devolvido em a1

    # Atualizar o melhor score se for o primeiro token ou se o score for maior
    beq s3, zero, decide_next_token_update  # primeiro token: atualizar sempre
    bgt a1, s5, decide_next_token_update    # score maior que o melhor até agora: atualizar
    j decide_next_token_next                # caso contrário, não atualizar

decide_next_token_update:
    mv s5, a1                       # atualizar o melhor score
    mv s4, s3                       # atualizar o melhor índice

decide_next_token_next:
    addi s6, s6, 16                 # avançar para o próximo embedding (4 inteiros * 4 bytes = 16 bytes)
    addi s3, s3, 1                  # i++
    j decide_next_token_loop

decide_next_token_done:
    mv a0, s4                      

    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    addi sp, sp, 32
    ret

#############################################################################################################
# Dot product and argmax helper functions.
#############################################################################################################

# (in)  a1: address of first vector (int*)
# (in)  a2: address of second vector (int*)
# (in)  a3: length of the vectors (int)
# (out) a0: status code (0 for success, non-zero for error)
# (out) a1: dot product result (int)
dot:
    addi sp, sp, -4
    sw ra, 0(sp)                                    # Save return address on the stack
    # Initialize the result and the loop index.
    mv t0, zero                                     # t0 will hold the result (dot product)
    mv t1, zero                                     # t1 will be our loop index
    # Let's see first if SIZE < 1, and jump to dot_end if that's the case.
    slti t2, a3, 1                                  # t2 = (SIZE < 1)
    beq t2, zero, dot_loop                          # If SIZE >= 1, we can proceed to the loop
    li a0, 50                                       # Set a0 to 50 to indicate an error (invalid size)
    j dot_end                                       # If SIZE < 1, jump to dot_end
dot_loop:
    beq t1, a3, dot_end_loop                        # If t1 == SIZE, we are done
    lw t2, 0(a1)                                    # Load A[t1] into t2
    lw t3, 0(a2)                                    # Load B[t1] into t3
    mul t4, t2, t3                                  # t4 = A[t1] * B[t1]
    # Check if the multiplication of A[t1] and B[t1] overflows
    mulh t5, t2, t3                                 # t5 = high 32 bits of A[t1] * B[t1] (signed)
    srai t6, t4, 31                                 # t6 = sign extension of low 32 bits (0 or -1)
    bne t5, t6, overflow                            # Overflow if high bits != sign extension of low bits
    mv t6, t0                                       # Store the current result in t6 for overflow checking
    add t0, t0, t4                                  # t0 += A[t1] * B[t1]
    # Check if the previous addition caused an overflow
    # Careful: adding negative numbers will correctly result in a negative number, so we need to check for overflow in both directions.
    bgt t6, zero, check_positive_overflow           # If previous result was positive, check for positive overflow
    blt t6, zero, check_negative_overflow           # If previous result was negative, check for negative overflow
    j dot_continue_loop
check_positive_overflow:
    blt t4, zero, dot_continue_loop                 # If we added a negative number, we can't have a positive overflow
    blt t0, zero, overflow                          # If t0 < 0 after adding a positive number, we have an overflow
    j dot_continue_loop
check_negative_overflow:
    bgt t4, zero, dot_continue_loop                 # If we added a positive number, we can't have a negative overflow
    bgt t0, zero, overflow                          # If t0 > 0 after adding a negative number, we have an overflow
    j dot_continue_loop
dot_continue_loop:
    addi a1, a1, 4                                  # Move to the next element in A
    addi a2, a2, 4                                  # Move to the next element in B
    addi t1, t1, 1                                  # t1++
    j dot_loop                                      # Repeat the loop
dot_end_loop:
    li a0, 0                                        # Set a0 to 0 to indicate success
    mv a1, t0                                       # Move the result into a1 for return
    j dot_end                                       # Jump to the end of the function
overflow:
    li a0, 200                                      # Set a0 to 200 to indicate an overflow error
    j dot_end                                       # Jump to the end of the function
dot_end:
    lw ra, 0(sp)                                    # Restore return address
    addi sp, sp, 4                                  # Deallocate stack space
    ret                                             # Return to the caller

# (in)  a1: pointer to int array
# (in)  a2: array length
# (out) a0: status code
# (out) a1: index of the largest element
argmax:
    # Get the index of the maximum value in A, which is of size SIZE.
    # The result will be stored in a0.
    # If here's a draw, return the smallest index among the maximum values.
    addi sp, sp, -4
    sw ra, 0(sp)                                    # Save return address on the stack
    # Initialize the max value and the index of the max value.
    lw t0, 0(a1)                                    # t0 will hold the max value
    mv t1, zero                                     # t1 will hold the index of the max value
    mv t2, zero                                     # t2 will be our loop index
    # Error checking first: if SIZE < 1, we should return 50 to indicate an error.
    slti t3, a2, 1                                  # t3 = (SIZE < 1)
    beq t3, zero, argmax_loop                       # if SIZE >= 1, we can proceed to the loop
    li a0, 50                                       # set a0 to 50 to indicate an error (invalid size)
    j argmax_end                                    # if SIZE < 1, jump to argmax_end
argmax_loop:
    # The actual loop logic.
    beq t2, a2, argmax_end_loop                     # if t2 == SIZE, we are done
    lw t3, 0(a1)                                    # load A[t2] into t3
    ble t3, t0, argmax_next                         # if A[t2] <= max_value, skip to next
    mv t0, t3                                       # max_value = A[t2]
    mv t1, t2                                       # index_of_max = t2
argmax_next:
    addi a1, a1, 4                                  # move to the next element in A
    addi t2, t2, 1                                  # t2++
    j argmax_loop                                   # repeat the loop
argmax_end_loop:
    mv a1, t1                                       # move the index of the max value into a1 for return
    li a0, 0                                        # set a0 to 0 to indicate success
argmax_end:
    lw ra, 0(sp)                                    # Restore return address
    addi sp, sp, 4                                  # Deallocate stack space
    ret                                             # return to the caller

exit_with_code:
    li a7, CONST_SYSCALL_EXIT2
    ecall

#############################################################################################################
# Helper functions for printing and debugging.
#############################################################################################################

.data
PRINT_HEADER_VOCABULARY:    .string "=== Vocabulary ==="
PRINT_HEADER_INPUT:         .string "=== Input ==="
PRINT_HEADER_INPUT_INDICES: .string "=== Input Indices ==="
PRINT_HEADER_MATRIX:        .string "=== Matrix ==="
PRINT_HEADER_SCORES:        .string "=== Scores ==="
PRINT_HEADER_NEXT_TOKEN:    .string "=== Decision ==="
PRINT_VECTOR_LB:            .string "[ "
PRINT_VECTOR_RB:            .string "]"

.text
# Prints a null-terminated string followed by a newline.
# (in) a0: buffer to print (char*)
println:
    li a7, CONST_SYSCALL_PRINT_STRING
    ecall
    li a0, CONST_CHAR_NEWLINE
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    ret

# Prints the vocabulary buffer.
# (in) a0: address of the vocabulary buffer (char*)
print_vocabulary:
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)
    mv s0, a0
    la a0, PRINT_HEADER_VOCABULARY
    jal println
    mv a0, s0
    jal println
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    ret

# Prints the input buffer as a string.
# (in) a0: address of the input buffer (char*)
print_input:
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)
    mv s0, a0
    la a0, PRINT_HEADER_INPUT
    jal println
    mv a0, s0
    jal println
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    ret

# Prints the input indices vector.
# (in) a0: address of the input indices vector (int*)
# (in) a1: size of the input indices vector (int)
print_indices:
    addi sp, sp, -12
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    mv s0, a0
    mv s1, a1
    la a0, PRINT_HEADER_INPUT_INDICES
    jal println
    mv a0, s0
    mv a1, s1
    jal print_vector
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    addi sp, sp, 12
    ret

print_scores:
    addi sp, sp, -4
    sw ra, 0(sp)
    la a0, PRINT_HEADER_SCORES
    jal println
    la a0, SCORES_VECTOR
    lw a1, INPUT_TOTAL_TOKENS
    jal print_vector
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

# a0: address of matrix to print (int*)
# a1: number of rows
# a2: number of columns
print_matrix:
    addi sp, sp, -24
    sw ra, 0(sp)                                    # return address
    sw s0, 4(sp)                                    # matrix pointer
    sw s1, 8(sp)                                    # row index
    sw s2, 12(sp)                                   # col index
    sw s3, 16(sp)                                   # number of rows
    sw s4, 20(sp)                                   # number of columns
    mv s0, a0                                       # s0 = pointer to matrix
    mv s3, a1                                       # s3 = number of rows
    mv s4, a2                                       # s4 = number of columns
    li s1, 0                                        # s1 = current row index
    la a0, PRINT_HEADER_MATRIX
    jal println
print_matrix_row_loop:
    beq s1, s3, print_matrix_done
    li s2, 0
print_matrix_col_loop:
    beq s2, s4, print_matrix_next_row
    lw a0, 0(s0)
    li a7, CONST_SYSCALL_PRINT_INT
    ecall
    addi s0, s0, 4
    addi s2, s2, 1
    li a0, CONST_CHAR_SPACE
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    j print_matrix_col_loop
print_matrix_next_row:
    li a0, CONST_CHAR_NEWLINE
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    addi s1, s1, 1
    j print_matrix_row_loop
print_matrix_done:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 24
    ret

# a0: address of vector to print (int*)
# a1: number of elements (int)
print_vector:
    addi sp, sp, -8
    sw s0, 0(sp)
    sw s1, 4(sp)
    mv s0, a0                                       # s0 = pointer to vector
    mv s1, a1                                       # s1 = number of elements
    la a0, PRINT_VECTOR_LB                          # Print "[ "
    li a7, CONST_SYSCALL_PRINT_STRING
    ecall
print_vector_loop:
    beq s1, zero, print_vector_done
    lw a0, 0(s0)
    li a7, CONST_SYSCALL_PRINT_INT
    ecall
    li a0, CONST_CHAR_SPACE
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    addi s0, s0, 4
    addi s1, s1, -1
    j print_vector_loop
print_vector_done:
    la a0, PRINT_VECTOR_RB                          # Print "]"
    li a7, CONST_SYSCALL_PRINT_STRING
    ecall
    li a0, CONST_CHAR_NEWLINE
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    lw s0, 0(sp)
    lw s1, 4(sp)
    addi sp, sp, 8
    ret

# (in) a0: address of the predicted token (char*)
print_predicted_token:
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)
    mv s0, a0
    la a0, PRINT_HEADER_NEXT_TOKEN
    jal println
    # s0 = start of target token, print it char by char until newline or null
print_predicted_token_char:
    lb t0, 0(s0)
    beq t0, zero, print_predicted_token_nl          # null terminator
    li t1, CONST_CHAR_NEWLINE
    beq t0, t1, print_predicted_token_nl            # newline terminator
    mv a0, t0
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    addi s0, s0, 1
    j print_predicted_token_char
print_predicted_token_nl:
    li a0, CONST_CHAR_NEWLINE
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    ret

