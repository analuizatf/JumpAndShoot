jmp main		

; Declaração das strings
instructions1: string "Desvie ou atire nos obstaculos"
instructions2: string "Use 'w' para pular"
instructions3: string "Use 's' para atirar"
instructions4: string "Pressione ESPACO para iniciar"
scoreBoard : string "Pontos: "
gameoverStr1: string "GAME OVER"
gameoverStr2: string "Pressione 'r' para"
gameoverStr3: string "retornar ao inicio"
gameoverStr4: string "Pontos: "

; Declaração das variáveis
; Variáveis de caractere
characterHead: var #1
characterBody: var #1
obstacleToJump: var #1
obstacleToShoot: var #1
obstacleToStandStill: var #1
shoot: var #1

; Variáveis de controle do jogo
command: var #1
points: var #1
shotPosition: var #1
jumpCycle: var #1
characterPosition: var #1
obstaclePosition: var #1
randomPosition: var #1

; Variáveis de delay para tempo na ação do usuário
delay1: var #30
delay2: var #60

; Variáveis para impressão de número
numberToPrint: var #1
numberToPrintPosition: var #1

; Variável para guardar posição na tabela rand
IncRand: var #1

; Tabela de números aleatórios entre 1 - 3
Rand : var #30
	static Rand + #0, #3
	static Rand + #1, #2
	static Rand + #2, #2
	static Rand + #3, #3
	static Rand + #4, #3
	static Rand + #5, #2
	static Rand + #6, #1
	static Rand + #7, #2
	static Rand + #8, #1
	static Rand + #9, #3
	static Rand + #10, #2
	static Rand + #11, #1
	static Rand + #12, #3
	static Rand + #13, #3
	static Rand + #14, #2
	static Rand + #15, #1
	static Rand + #16, #2
	static Rand + #17, #3
	static Rand + #18, #1
	static Rand + #19, #2
	static Rand + #20, #1
	static Rand + #20, #2
	static Rand + #21, #3
	static Rand + #22, #2
	static Rand + #23, #2
	static Rand + #24, #1
	static Rand + #25, #1
	static Rand + #26, #3
	static Rand + #27, #2
	static Rand + #28, #3
	static Rand + #29, #2
;--------------------------------------------------------;
;--------------------------------------------------------;

; ------------------------------------------------------ ;
; 					Código principal					 ;
; ------------------------------------------------------ ;
main:
	call initVariables
	call buildStartScreen
	
	; Pula para o loop inicial
	jmp InitialScreen_Loop
	
	InitialScreen_Loop:
		; Espera o usuário digitar algo
		call TypeCommand
		
		; Se a tecla de espaço for digitada, continua a execução e inicia o jogo. Caso contrário, volta para o início do loop e espera outro comando
		load r0, command
		loadn r1, #' '
		cmp r0, r1
			jne InitialScreen_Loop
		
	; Inicia o jogo
	GameInProgress:
		call buildGameScreen
	
		; Loop principal do jogo
		Game_Loop:
			call CheckImpact
			call UpdatePoints
			
			call Update_ShootPosition
			call CheckIfShotHit
			
			call Update_ObstaclePosition
			
			call PrintShoot
			call PrintObstacle			
			
			; Subrotinas para realizar o pulo do personagem
			call Update_CharacterPosition		; Todo ciclo principal do jogo, a funcao Update_CharacterPosition atualiza a posicao do personagem de acordo com a situacao
			call PrintCharacter
			
			call CheckAction_Delay				; Todo ciclo principal do jogo, a funcao CheckAction_Delay atrasa a execucao e le uma tecla do teclado (que é 'w', 'r' ou não)
			
			;-- Verifica posição do personagem. Se estiver no chão, valida e executa caso algum comando tenha sido enviado em CheckAction_Delay --;	
			ExecuteCommand:
				push r0
				push r1
				
				loadn r0, #0
				load r1, jumpCycle
				cmp r0, r1
					ceq ExecuteChosenCommand 
				
				pop r1
				pop r0
			
		jmp Game_Loop
	
	
	GameOver:
		call buildGameOverScreen
		
		GameOver_Loop:
			; Espera que a tecla 'r' seja digitada para retornar à tela inicial
			call TypeCommand
			loadn r0, #'r'
			load r1, command
			cmp r0, r1
				jeq main
			
			jmp GameOver_Loop
	
	halt
;--------------------------------------------------------;
;--------------------------------------------------------;

; ------------------------------------------------------ ;
; 				  Subrotinas Gerais 					 ;
; ------------------------------------------------------ ;
;-- Reseta valores ao retornar à tela inicial --;
initVariables:
	push r0

	; Inicializa ou reseta comando
	initCommand:
		loadn r0, #255					; Inicializa o comando com valor 255
		store command, r0
		
	; Inicializa ou reseta placar
	initScoreBoard:
		loadn r0, #0					; Inicializa o placar com valor 0
		store points, r0				; Salva o placar inicial

	; Inicializa ou reseta posição do tiro
	initShotPosition:
		loadn r0, #0					; Posição do tiro na tela
		store shotPosition, r0

	; Inicializa ou reseta ciclo do pulo
	initJumpCycle:
		loadn r0, #0					; Ciclo do pulo (0 = chão, entre 1 e 3 = MoveUp, 3 a 9 = MoveDown)
		store jumpCycle, r0

	; Inicializa ou reseta posição do personagem na tela
	initCharacterPosition:
		loadn r0, #970					; Posição do personagem na tela (fixa no eixo x e variável no eixo y)
		store characterPosition, r0

	; Inicializa ou reseta posição do obstáculo na tela
	initObstaclePosition:
		loadn r0, #999					; Posição do obstáculo na tela (fixa no eixo y e variável no eixo x)
		store obstaclePosition, r0

	; Inicializa delay1 e delay2
	initDelays:
		loadn r0, #300
		store delay1, r0
		loadn r0, #500
		store delay2, r0
	
	pop r0
	rts  
;--------------------------------------------------------
	
;-- Aguarda um comando do jogador --;
TypeCommand:	
	; Espera que uma tecla seja digitada e salva na variável global "command"				
	push r0
	push r1
	
	loadn r1, #255				; Se não digitar nada vem 255
   
   	TypeCommand_Loop:
		inchar r0				; Le o teclado, se nada for digitado = 255
		cmp r0, r1				; compara r0 com 255
			jeq TypeCommand_Loop	; Fica lendo até que digite uma tecla válida

	store command, r0			; Salva a tecla na variável global "command"

	pop r1
	pop r0
	rts
;--------------------------------------------------------

;-- Verifica o comando recebido e desvia para a rota correta --;
ExecuteChosenCommand:
	push r0
	push r1
	
	load r0, command
	
	; Caso o comando tenha sido de pulo, desvia para a rota de pulo
	loadn r1, #'w'					; Parâmetro para saber se a tecla de pular foi pressionada
	cmp r0, r1
		ceq AdvanceJumpRoute
	
	; Caso o comando tenha sido de tiro, desvia para a rota de tiro
	loadn r1, #'s'					; Parâmetro para saber se a tecla de atirar foi pressionada
	cmp r0, r1
		ceq AdvanceToShootRoute
	
	pop r1
	pop r0
	rts
;--------------------------------------------------------

;-- Delay para verificar a ação --;
CheckAction_Delay:
	push r0
	push r1
	push r2
	push r3
	
	loadn r0, #255
	store command, r0		; Guarda 255 na command pro caso de não apertar nenhuma tecla
	
	load r1, delay1
	loop_delay_1:
		load r2, delay2

		; Bloco de ler o Teclado no meio do delay!!		
		loop_delay_2:
			inchar r3
			cmp r0, r3 
				jeq loop_skip
			store command, r3		; Se apertar uma tecla, guarda na variável command
			
	loop_skip:			
		dec r2
		jnz loop_delay_2
		dec r1
		jnz loop_delay_1
		jmp leave_delay
	
	leave_delay:
		pop r3
		pop r2
		pop r1
		pop r0
		rts
;--------------------------------------------------------

;-- Reseta o ciclo da ação --;
ResetJumpCycle:
	push r0 ; Protege r0 na pilha
	
	loadn r0, #0
	store jumpCycle, r0
	
	pop r0
	rts
;--------------------------------------------------------;
;--------------------------------------------------------;

; ------------------------------------------------------ ;
;         Subrotinas de controle do personagem 			 ;
; ------------------------------------------------------ ;
;-- Atualiza a posição do personagem na tela --;
Update_CharacterPosition:
	push r0 ; Protege r0 na pilha
	push r1
	
	load r0, jumpCycle
	
	; Caso o ciclo do pulo esteja em 1, 2, 3 ou 4, o personagem sobe na tela
	loadn r1, #1
	cmp r0, r1
		ceq MoveUp
	loadn r1, #2
	cmp r0, r1
		ceq MoveUp
	loadn r1, #3
	cmp r0, r1
		ceq MoveUp
	loadn r1, #4
	cmp r0, r1
		ceq MoveUp
	
	; Caso o ciclo do pulo esteja em 5, 6, 7 ou 8, o personagem desce na tela
	loadn r1, #5
	cmp r0, r1
		ceq MoveDown
	loadn r1, #6
	cmp r0, r1
		ceq MoveDown
	loadn r1, #7
	cmp r0, r1
		ceq MoveDown
	loadn r1, #8
	cmp r0, r1
		ceq MoveDown
	
	; Reloading o ciclo caso tenha sido alterado
	 load r0, jumpCycle
	
	; Caso o personagem esteja no chão, finaliza o ciclo do pulo
	loadn r1, #0
	cmp r0, r1
		cne AdvanceJumpRoute	; Caso esteja no ar, o ciclo do pulo deve continuar sendo incrementado
		
	loadn r1, #9	; Até que o ciclo chegue em 9, então se torna 0 novamente (personagem está no chão novamente)
	cmp r0, r1
		ceq ResetJumpCycle

	pop r1	
	pop r0
	rts
;--------------------------------------------------------

;-- Incrementa o ciclo do pulo --;
AdvanceJumpRoute:
	push r0 ; Protege r0 na pilha
	
	load r0, jumpCycle
	inc r0
	store jumpCycle, r0
	
	pop r0
	rts
;--------------------------------------------------------
	
;-- Sobe a posição do personagem --;
MoveUp:
	push r0
	push r1
	
	call EraseCharacter
	
	load r0, characterPosition
	loadn r1, #40
	sub r0, r0, r1
	store characterPosition, r0
	
	pop r1
	pop r0
	rts 
;--------------------------------------------------------
	
;-- Desce a posição do personagem --;
MoveDown:
	push r0
	push r1
	
	call EraseCharacter
	
	load r0, characterPosition
	loadn r1, #40
	add r0, r0, r1
	store characterPosition, r0
	
	pop r1
	pop r0
	rts
;--------------------------------------------------------
;--------------------------------------------------------;
;--------------------------------------------------------;

; ------------------------------------------------------ ;
;         Subrotinas de controle do obstáculo 			 ;
; ------------------------------------------------------ ;

;-- Reseta a posição do obstáculo --;
Reset_Obstacle:
	push r0
	push r1
	push r2
	
	loadn r0, #999
	store obstaclePosition, r0
	
	call Generate_RandomPosition
	
	loadn r1, #1
	load r2, randomPosition
	cmp r2,r1
	ceq Change_Position1
	
	loadn r1, #2
	cmp r2,r1
	ceq Change_Position2
	
	pop r2
	pop r1
	pop r0
	rts
;--------------------------------------------------------

;-- Gera uma posição "aleatória" para o novo obstáculo surgir --;
Generate_RandomPosition :
	push r3
	push r4
	push r5

	; Sorteia um número aleatório entre 1 - 3
	loadn r3, #Rand 			; declara ponteiro para tabela rand na memória!
	load r4, IncRand			; Pega Incremento da tabela Rand
	add r3, r3, r4				; Soma Incremento ao início da tabela Rand

	loadi r5, r3 				; busca número randômico da memória em R2
	store randomPosition, r5
	
	inc r4
	loadn r3, #30
	cmp r4, r3					; Compara com o Final da Tabela e reinicia em 0
	jne Reset_Vector
		loadn r4, #0			; Reiniciar a Tabela Rand em 0
  	
  	Reset_Vector:
		store IncRand, r4		; Salva incremento ++

	pop r5
	pop r4
	pop r3
	rts
;--------------------------------------------------------

;-- Altera a posição do obstáculo para uma linha --;
Change_Position1:
	push r3
	push r4
	
	load r3, obstaclePosition
	loadn r4,#40
	sub r3,r3,r4
	store obstaclePosition, r3
	
	pop r4
	pop r3
	rts
;--------------------------------------------------------

;-- Altera a posição do obstáculo para 2 linhas --;
Change_Position2:
	push r3
	push r4
	
	load r3, obstaclePosition
	loadn r4,#80
	sub r3,r3,r4
	store obstaclePosition, r3
		
	pop r4
	pop r3
	rts
;--------------------------------------------------------

;-- Atualiza posição do obstáculo na tela --;
Update_ObstaclePosition:	
	push r0
	push r1
	
	load r0, obstaclePosition
	loadn r1 , #1
	
	outchar r1, r0
	dec r0
	store obstaclePosition, r0

	loadn r1, #960 				; Posição do obstáculo no chão
	cmp r0, r1
		ceq Reset_Obstacle
		
	loadn r1, #920 				; Posição do obstáculo na frente do personagem
	cmp r0, r1
		ceq Reset_Obstacle
		
	loadn r1, #880				; Posição do obstáculo acima do personagem
	cmp r0, r1
		ceq Reset_Obstacle
	
	pop r1
	pop r0
	rts
;--------------------------------------------------------

;-- Verifica se houve colisão entre personagem e obstáculo --;
CheckImpact:
	push r0
	push r1
	push r2

	load r0, obstaclePosition
	load r1, characterPosition
	
	; Compara a posição inferior do personagem com a do obstáculo. Se igual, finaliza o jogo
	cmp r0, r1 
		jeq GameOver
	
	; Muda o valor de r1 para o segundo caractere do personagem
	loadn r2,#40
	sub r1,r1,r2
	
	; Compara a posição superior do personagem com a do obstáculo. Se igual, finaliza o jogo
	cmp r0, r1 
		jeq GameOver
	
	pop r2
	pop r1
	pop r0
	rts
;--------------------------------------------------------

;-- Verifica se houve colisão entre personagem e obstáculo --;
CheckIfShotHit:
	push r0
	push r1
	push r2

	load r0, shotPosition
	load r1, obstaclePosition
	
	cmp r0, r1
		ceq ShotHit
		
	pop r2
	pop r1
	pop r0
	rts
;--------------------------------------------------------

;-- Checa se obstáculo chegou ao final da tela --;
CheckObstacle_End:
	push r0
	push r1
	
	load r0, obstaclePosition
	
	loadn r1, #970
	cmp r1, r0
		ceq IncPoints
	
	loadn r1, #930
	cmp r1, r0
		ceq IncPoints
		
	loadn r1, #890
	cmp r1, r0
		ceq IncPoints
	
	pop r1
	pop r0
	rts
;--------------------------------------------------------;
;--------------------------------------------------------;

; ------------------------------------------------------ ;
;            Subrotinas de controle do tiro 			 ;
; ------------------------------------------------------ ;

;-- Ciclo de tiro --;
AdvanceToShootRoute:
	push r0
	
	loadn r0, #930
	store shotPosition, r0
	
	pop r0
	rts
;--------------------------------------------------------

;-- Atualiza posição do tiro na tela --;
Reset_ShootPosition:
	push r3
	
	loadn r3, #0
	store shotPosition, r3
	
	pop r3
	rts
;--------------------------------------------------------

;-- Atualiza posição do tiro na tela --;
Update_ShootPosition:
	push r0
	push r1
	push r2
	
	loadn r0, #0
	load r1, shotPosition
	
	cmp r1, r0
		jeq Update_ShootPosition_end

	loadn r0, #1
	outchar r0, r1
	inc r1
	store shotPosition, r1
	
	loadn r0, #960
	cmp r1, r0
		ceg Reset_ShootPosition
	
	Update_ShootPosition_end:
	pop r2
	pop r1
	pop r0
	rts
;--------------------------------------------------------

;-- Reseta a posição do obstáculo --;
ShotHit:
	push r0
	push r1
	push r2
	call IncPoints
	call IncPoints
	
	; Apaga o obstáculo
	loadn r1, #1
	load r2, obstaclePosition
	outchar r1, r2
	
	call Reset_Obstacle
	call Reset_ShootPosition
	
	pop r2
	pop r1
	pop r0
	rts
;--------------------------------------------------------;
;--------------------------------------------------------;

; ------------------------------------------------------ ;
;            Subrotinas de controle do placar 			 ;
; ------------------------------------------------------ ;
;-- Aumenta a pontuação --;
IncPoints:
	push r2
	push r3
	
	; Incrementa o placar
	load r2, points
	inc r2
	store points, r2
	
	; Reduz o delay1 para diminuir o tempo disponível para o jogador realizar uma ação
	load r3, delay1
	dec r3
	dec r3
	dec r3
	dec r3
	dec r3
	dec r3
	dec r3
	dec r3
	dec r3
	dec r3
	dec r3

	store delay1, r3
	
	; Reduz o delay2 para diminuir o tempo disponível para o jogador realizar uma ação
	load r3, delay2
	dec r3
	dec r3
	dec r3
	dec r3
	
	store delay2, r3
	
	pop r3
	pop r2
	rts
;--------------------------------------------------------

;-- Atualiza o placar --;
UpdatePoints:
	; Verifica se não houve colisão com o obstáculo e atualiza o placar
	call CheckObstacle_End
	call PrintScoreBoard
	
	rts	
;--------------------------------------------------------;
;--------------------------------------------------------;

; ------------------------------------------------------ ;
; 		     Subrotinas de impressão na tela			 ;
; ------------------------------------------------------ ;
static obstacleToJump, #21
static obstacleToShoot, #8
static obstacleToStandStill, #'<'

static shoot, #45

static characterHead, #29	
static characterBody, #9

; ********** Telas ********* ;
;-- Limpa a tela --;
ClearScreen:
	push r0
	push r1
	
	loadn r0, #1200		; Número de posições na tela
	loadn r1, #1		; Caractere em branco (O caractere de espaço está imprimindo um ponto, por isso este foi escolhido)
	
	   ClearScreen_Loop:
		dec r0
		outchar r1, r0
		jnz ClearScreen_Loop
 
	pop r1
	pop r0
	rts	
;--------------------------------------------------------

;-- Cria tela inicial --;
buildStartScreen:
	push r0
	push r1
	
	call ClearScreen
	loadn r0, #284					; Posição da primeira linha de instruções
	loadn r1, #instructions1		; Salva o valor da string no registrador 1
	call PrintStr
	loadn r0, #446					; Posição da segunda linha de instruções
	loadn r1, #instructions2		; Salva o valor da string no registrador 1
	call PrintStr
	loadn r0, #486					; Posição da terceira linha de instruções
	loadn r1, #instructions3		; Salva o valor da string no registrador 1
	call PrintStr
	loadn r0, #644					; Posição da quarta linha de instruções
	loadn r1, #instructions4		; Salva o valor da string no registrador 1
	call PrintStr
	
	pop r1
	pop r0
	rts
;--------------------------------------------------------

;-- Cria a tela do jogo em progresso --;
buildGameScreen:
	push r0
	push r1
	
	call ClearScreen				; Limpa a tela do jogo
		
	; Imprime o placar
	loadn r0, #43					; Posição do placar
	loadn r1, #scoreBoard			
	call PrintStr
	
	; Imprime as intruções
	loadn r0, #288					; Posição da primeira linha de instruções
	loadn r1, #instructions1
	call PrintStr
	
	; Imprime o chão
	call printGround
	
	pop r1
	pop r0
	rts
;--------------------------------------------------------

;-- Cria a tela do fim do jogo --;
buildGameOverScreen:
	push r0
	push r1
	push r2
	
	call ClearScreen
	loadn r0, #374
	loadn r2, #256
	loadn r1, #gameoverStr1
	call PrintStr
	loadn r1, #gameoverStr2			
	loadn r0, #530							
	call PrintStr			
	loadn r1, #gameoverStr3			
	loadn r0, #570					
	call PrintStr
	
	
	loadn r1, #gameoverStr4			
	loadn r0, #43			
	loadn r2, #0		
	call PrintStr
	
	load r0, points
	store numberToPrint, r0
	loadn r0, #51
	store numberToPrintPosition, r0
	call PrintNumber
	
	pop r2
	pop r1
	pop r0
	rts
;--------------------------------------------------------
;--------------------------------------------------------

; ********** Objetos ********* ;
;-- Imprime um número --;
PrintNumber:
	push r0
	push r1
	push r2
	push r3
	push r4
	push r5
	
	loadn r0, #10
	loadn r1, #48
	load r2, numberToPrint
	load r3, numberToPrintPosition
	
	div r4, r2, r0	; Divide o numero por 10 para imprimir a dezena
	
	add r5, r4, r1	; Soma 48 ao numero pra dar o Cod.  ASCII do numero
	outchar r5, r3
	
	inc r3			; Incrementa a posicao na tela
	
	mul r4, r4, r0	; Multiplica a dezena por 10
	sub r4, r2, r4	; Pra subtrair do numero e pegar o resto
	
	add r5, r4, r1	; Soma 48 ao numero pra dar o Cod.  ASCII do numero
	outchar r5, r3
	
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0

	rts
;--------------------------------------------------------

;-- Imprime uma string --;
PrintStr:
	push r0	; protege o r0 na pilha para preservar seu valor
	push r1	; protege o r1 na pilha para preservar seu valor
	push r2	; protege o r1 na pilha para preservar seu valor
	push r3	; protege o r3 na pilha para ser usado na subrotina
	push r4	; protege o r4 na pilha para ser usado na subrotina
	
	loadn r3, #'\0'	; Critério de parada

   PrintStr_Loop:	
		loadi r4, r1
		cmp r4, r3			; If (Char == \0)  vai Embora
		jeq Leave_PrintStr
		add r4, r2, r4		; Soma a Cor
		outchar r4, r0		; Imprime o caractere na tela
		inc r0				; Incrementa a posicao na tela
		inc r1				; Incrementa o ponteiro da String
		jmp PrintStr_Loop
	
   Leave_PrintStr:
	; Resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r4					
	pop r3
	pop r2
	pop r1
	pop r0
	rts
;--------------------------------------------------------

PrintScoreBoard:
	push r0
	
	load r0, points
	store numberToPrint, r0
	loadn r0, #51
	store numberToPrintPosition, r0
	call PrintNumber
	
	pop r0
	rts
;--------------------------------------------------------

;-- Imprime o chão --;
printGround:
	push r0
	push r1
	push r2

	loadn r0, #45
	loadn r1, #1000
	loadn r2, #1040

	printGroundLoop:
		outchar r0, r1
		inc r1
		cmp r1, r2
		jne printGroundLoop

	pop r2
	pop r1
	pop r0
	rts  
;--------------------------------------------------------

;-- Imprime o obstáculo --;
PrintObstacle:
	push r0
	push r1
	push r2
	
	load r0, obstaclePosition
	
	; Se estiver na linha 24 (chão)
	loadn r1, #960
	cmp r0, r1
	jeg PrintObstacleToJump
	
	; Se estiver na linha 23 (cabeça do personagem)
	loadn r1, #920
	cmp r0, r1
	jeg PrintObstacleToShoot
	
	; Se estiver na linha 22 (acima do personagem)
	loadn r1, #880
	cmp r0, r1
	jeg PrintObstacleToStandStill
		
	PrintObstacleToJump:
		load r2, obstacleToJump
		jmp Leave_PrintObstacle
	
	PrintObstacleToShoot:
		load r2, obstacleToShoot
		jmp Leave_PrintObstacle
		
	PrintObstacleToStandStill:
		load r2, obstacleToStandStill
		jmp Leave_PrintObstacle
	
	Leave_PrintObstacle:
	outchar r2, r0
	
	pop r2
	pop r1
	pop r0
	rts
;--------------------------------------------------------

;-- Imprime o tiro --;
PrintShoot:
	push r0
	push r1
	push r2
	
	loadn r0, #0
	load r1, shotPosition
	
	cmp r0, r1
		jeq PrintShoot_rts
	
	loadn r0, #960
	cmp r1, r0
		jeg PrintShoot_rts
	
	load r2, shoot
	outchar r2, r1
	
	PrintShoot_rts:
	pop r2
	pop r1
	pop r0
	rts
;--------------------------------------------------------
	
;-- Apaga o personagem --;
EraseCharacter:
	push r0
	push r1
	push r2
	
	loadn r1, #1
	load r2, characterPosition
	outchar r1, r2
	
	loadn r0, #40
	sub r2, r2, r0
	outchar r1, r2 
	add r2, r2, r0
	
	pop r2
	pop r1
	pop r0
	rts
;--------------------------------------------------------

;-- Imprime o personagem --;
PrintCharacter:
	call EraseCharacter	
	
	push r0
	push r1
	push r2
	
	load r0, characterBody	; Guardando a string do corpo do personagem no registrador r1
	load r1, characterPosition
	outchar r0, r1 ; Printa o corpo do character
	
	load r0, characterHead	; Guardando a string da cabeça do personagem no registrador r1
	loadn r2, #40
	sub r1, r1, r2
	outchar r0, r1 ; Printa a cabeca  do character
	add r1, r1, r2
	
	pop r2
	pop r1
	pop r0			
	rts
;--------------------------------------------------------