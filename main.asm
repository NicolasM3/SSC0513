.data
    buffer: .space 100  
    newLine: .asciiz "\n"
    inputText: .asciiz "Digite um texto para criptografar: "
    inputEncryption: .asciiz "(0) Cifra de cesar \n(1) OTP \nDigite o tipo de criptografia:"
    inputProcess: .asciiz "Encriptar ou decriptar? (0) Encriptar (1) Decriptar:"
    
    inputCesarKey: .asciiz "(Cifra de cesar) Digite a chave: "
    cesarCypherText: .asciiz "(Cifra de cesar) CypherText: "

    inputOtpKey: .asciiz "(OTP) Digite a chave: "
    cesarOtpText: .asciiz "(OTP) CypherText: "

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


    # 3
    criptografia3:
        
        

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



