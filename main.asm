.data
    buffer: .space 100  
    newLine: .asciiz "\n"
    inputText: .asciiz "Digite um texto para criptografar: "
    inputEncryption: .asciiz "(0) Cifra de cesar \n(1) OTP \n(2) base64 \nDigite o tipo de criptografia:"
    inputProcess: .asciiz "Encriptar ou decriptar? (0) Encriptar (1) Decriptar:"
    
    inputCesarKey: .asciiz "(Cifra de cesar) Digite a chave: "
    cesarCypherText: .asciiz "(Cifra de cesar) CypherText: "

    inputOtpKey: .asciiz "(OTP) Digite a chave: "
    cesarOtpText: .asciiz "(OTP) CypherText: "

    ASC: .byte    'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/'
    binary: .space 4096  # Space for the binary representation
    first_six: .space 7  # Space for the first 6 characters + null terminator
    length: .word 6  # The length of the binary number

.text
    main:
        # printa o prompt
        li $v0, 4  
        la $a0, inputText 
        syscall

        # lê o texto
        li $v0, 8 
        la $a0, buffer  
        li $a1, 100 
        syscall 

        la $t0,($a0)        # O texto é guardado em $t0
        
        # printa o prompt
        li $v0, 4  
        la $a0, inputEncryption 
        syscall

        # seleciona o metodo de criptografia
        li $v0, 12
        syscall
        move $t1, $v0
        
        # pula uma linha
        li $v0, 4  
        la $a0, newLine 
        syscall
        
        beq $t1, '0', criptografia1
        beq $t1, '1', criptografia2
        beq $t1, '2', criptografia3

        j end

    end: 
        # sai do programa
        li $v0, 10 
        syscall  

    # Cifra de cesar
    criptografia1: 
        # printa e lê a chave
        li $v0, 4
        la $a0, inputCesarKey
        syscall

        li $v0,5
        syscall
        move $t3,$v0 

        # verifica o processo
        li $v0, 4
        la $a0, inputProcess
        syscall

        li $v0,12
        syscall
        move $t1,$v0 

        # pula uma linha
        li $v0, 4  
        la $a0, newLine 
        syscall

        beq $t1, '0', cesarEncrypt
        beq $t1, '1', cesarDecrypt
        
        li $v0, 4
        la $a0, cesarCypherText
        syscall

        j end
        

    # OTP
    criptografia2:
        # printa e lê a chave
        li $v0, 4
        la $a0, inputOtpKey
        syscall

        li $v0,5
        syscall
        move $t3,$v0 

        li $v0, 4
        la $a0, inputProcess
        syscall

        li $v0,12
        syscall
        move $t1,$v0 

        # pula uma linha
        li $v0, 4  
        la $a0, newLine 
        syscall

        # começa a encriptar
        j otpEncrypt


    # BASE64
    criptografia3:
        la $s0, ASC
        la $t1, binary  # Load the address of the binary string

        j convert_string

     # ------------------------------------ Cesar ------------------------------------

    cesarEncrypt:
        lb $t4, 0($t0)
        beq $t4,10,end 	 		# Termina o programa no \n 
        beqz $t4,end  			# Termina o programa no final da string

        li $t5,26   				
        sub $t4,$t4,97
        add $t4, $t4, $t3
        div $t4,$t5
        mfhi $a0
        addi $a0,$a0,97
        j PrintCesarEncryptChar

    PrintCesarEncryptChar:
        # printa o caracter encryptado
        li $v0,11 			
        syscall

        # incrementa o ponteiro para o proximo caractere
        add $t0,$t0,1 		
        j cesarEncrypt

    cesarDecrypt:
        li $t1, 26
        sub $t3, $t1, $t3
        j cesarEncrypt

    # ------------------------------------ OTP ------------------------------------

    otpEncrypt:
        lb $t1, 0($t0)
        beq $t1,10,end 	 		# Termina o programa no \n 
        beqz $t1,end  			# Termina o programa no final da string
        
        xor $t1, $t1, $t3
        addi $t0,$t0,1
        j printOptEncryptChar

    printOptEncryptChar:
        # printa o caracter encryptado
        li $v0,11 	
        move $a0, $t1
        syscall
        j otpEncrypt

    
    # Metodo de pontenciação
    power:
        li $t1, 1

    powerLoop:
        beqz $a1, endPower
        mult $a0, $t1
        mflo $t1

        addi $a1, $a1, -1

        j powerLoop
    
    endPower:
        jr $ra

# ----------- BASE64

    convert_string:
        lb $t2, 0($t0)  # Load the current character
        beqz $t2, end_convert  # If the character is null, end the conversion

        li $t3, 7  # Start with the 7th bit (counting from 0)

    convert_char:
        srlv $t4, $t2, $t3  # Shift the character right by the current bit number
        andi $t4, $t4, 1  # Isolate the last bit

        addiu $t4, $t4, '0'  # Convert the bit to an ASCII character
        sb $t4, 0($t1)  # Store the bit in the binary string

        addiu $t1, $t1, 1  # Move to the next position in the binary string
        addiu $t3, $t3, -1  # Move to the next bit

        bgez $t3, convert_char  # If there are more bits, keep going

        addiu $t0, $t0, 1  # Move to the next character in the string
        j convert_string  # Convert the next character

    end_convert:
        sb $zero, 0($t1)  # Null-terminate the binary string

    encrypt_base64:
        la $t0, binary  # Load the address of the string
        la $t1, first_six  # Load the address of the new string
        li $t2, 6  # The number of characters to copy

    copy_chars:
        lb $t3, 0($t0)  # Load the current character
        sb $t3, 0($t1)  # Store the character in the new string

        addiu $t0, $t0, 1  # Move to the next character in the string
        addiu $t1, $t1, 1  # Move to the next position in the new string
        addiu $t2, $t2, -1  # Decrement the counter

        bnez $t2, copy_chars  # If there are more characters to copy, keep going

        sb $zero, 0($t1)  # Null-terminate the new string

        la $t0, first_six  # Load the address of the new string
        lw $t1, length  # Load the length of the binary number
        li $t2, 0  # Initialize the decimal number to 0

    convert_to_decimal:
        lb $t3, 0($t0)  # Load the current bit
        subu $t3, $t3, '0'  # Convert the bit from ASCII to integer

        li $t4, 2  # The base of the binary number

        move $a0, $t4  # Move the base to $a0
        move $a1, $t1  # Move the exponent to $a1

        jal pow  # Call the pow function
        move $t4, $v0  # Move the result to $t4

        
        mul $t4, $t4, $t3  # Multiply the bit by the base raised to the power of its position
        add $t2, $t2, $t4  # Add the result to the decimal number

        addiu $t0, $t0, 1  # Move to the next bit
        addiu $t1, $t1, -1  # Move to the next position

        bnez $t1, convert_to_decimal  # If there are more bits, keep going

        addu $t1, $s0, $t2  # Calculate the address of the character
        lbu $a0, 0($t1)

        # printa o valor
        li $v0, 11
        syscall

        li $v0, 4  
        la $a0, newLine 
        syscall

        j end

    pow:
        # Arguments:
        #   $a0 - the base
        #   $a1 - the exponent

        # Return value:
        #   $v0 - the result

        li $v0, 1  # Initialize the result to 1

    pow_loop:
        beqz $a1, pow_end  # If the exponent is 0, end the loop
        mul $v0, $v0, $a0  # Multiply the result by the base
        addiu $a1, $a1, -1  # Decrement the exponent
        j pow_loop  # Jump back to the start of the loop

    pow_end:
        jr $ra  # Return to the caller