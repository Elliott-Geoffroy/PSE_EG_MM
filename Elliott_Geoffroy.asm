.data
grille: .byte 81
varcol: .word 23
varco2: .word 23


.text

# Effectue un retour a la ligne a l'ecran
# Registres utilises : $v0, $a0
newLine:
	li		$v0, 11
	li		$a0, 10
	syscall
	jr $ra
	

# Ouverture d'un fichier. 
#	$a0 nom du fichier, 
#	$a1 le flag d'ouverture (0 lecture, 1 ecriture)
# Registres utilises : $v0, $a2
openfile: 
	li   	$v0, 13       # system call for open file
	li   	$a2, 0
	syscall               # open a file (file descriptor returned in $v0)
	jr 		$ra

# Ferme le fichier
#	$a0 le descripteur de fichier qui est ouvert.
# Registres utilises : $v0
closeFile:
	li		$v0, 16 	#Syscall value for closefile.
	syscall
	jr 		$ra

# Lit une ligne du fichier et la mets dans le tableau grille
# Registres utilises : $v0, $a1, $a2
extractionValue:
	li		$v0, 14
	la 		$a1, grille 
	li 		$a2, 81
	syscall
	jr 		$ra

# Affiche la grille.
# Registres utilises : $v0, $a0, $t[0-2] 
printArray:  
	la	 	$t0, grille
	add 	$sp, $sp, -4		# \ Sauvegarde de la reference du dernier jump
	sw 		$ra, 0($sp)			# /
	li		$t1, 0
	boucle_printArray:
		bge 	$t1, 81, end_printArray 	# Si $t1 est plus grand ou egal a 81 alors branchement a end_printArray
			add 	$t2, $t0, $t1			# $t0 + $t1 -> $t2 ($t0 l'adresse du tableau et $t1 la position dans le tableau)
			lb		$a0, ($t2)				# load byte at $t2(adress) in $a0
			li		$v0, 1					# code pour l'affichage d'un entier
			syscall
			add		$t1, $t1, 1				# $t1 += 1;	
		j boucle_printArray
	end_printArray:
		lw 		$ra, 0($sp)					# \ On recharge la reference 
		add 	$sp, $sp, 4					# / du dernier jump
	jr $ra

# Change array from ascii to integer
# Registres utilises : $t[0-3]
changeArrayAsciiCode:  
	add 	$sp, $sp, -4
	sw 		$ra, 0($sp)
	la		$t3, grille
	li		$t0, 0
	boucle_changeArrayAsciiCode:
		bge 	$t0, 81, end_changeArrayAsciiCode
			add		$t1, $t3, $t0
			lb		$t2, ($t1)
			sub 	$t2, $t2, 48
			sb		$t2, ($t1)
			add		$t0, $t0, 1
		j boucle_changeArrayAsciiCode
	end_changeArrayAsciiCode:
	lw 		$ra, 0($sp)
	add 	$sp, $sp, 4
	jr $ra

# Fait le modulo (a mod b)
#	$a0 represente le nombre a (doit etre positif)
#	$a1 represente le nombre b (doit etre positif)
# Resultat dans : $v0
# Registres utilises : $a0
modulo: 
	sub 	$sp, $sp, 4
	sw 		$ra, 0($sp)
	boucle_modulo:
		blt		$a0, $a1, end_modulo
			sub		$a0, $a0, $a1
		j boucle_modulo
	end_modulo:
	move 	$v0, $a0
	lw 		$ra, 0($sp)
	add 	$sp, $sp, 4
	jr $ra

# Zone de dÃ©claration de vos fonctions

# Print trait pour séparer les box
# Registres utilises : $v0, $a0, $a1
neufTrait:
	sub 	$sp, $sp, 4
	sw 		$ra, 0($sp)
	li $a1, 0
	jal traitVert
	boucle_neufTrait:beq $a1, 11, endBoucleNeufTrait
			li		$v0, 11
			li		$a0, 45
			syscall
			add $a1, $a1, 1
			j boucle_neufTrait
	endBoucleNeufTrait:
	lw 		$ra, 0($sp)
	add 	$sp, $sp, 4
	jr $ra

# Print un '|'
# Registres utilises : $v0, $a0	
traitVert:
	sub 	$sp, $sp, 4
	sw 		$ra, 0($sp)
			li		$v0, 11
			li		$a0, 124
			syscall
	lw 		$ra, 0($sp)
	add 	$sp, $sp, 4
	jr $ra



# Affiche la grille en grille.
# Registres utilises : $v0, $a0, $t[0-2] et $a1
printArrayGrid:  
	la	 	$t0, grille
	add 	$sp, $sp, -4		# \ Sauvegarde de la reference du dernier jump
	sw 		$ra, 0($sp)
			
	jal neufTrait
	jal traitVert
	jal newLine				
	jal traitVert
										
	li		$t1, 0
	boucle_printArrayGrid:
		bge 	$t1, 81, end_printArrayGrid 	# Si $t1 est plus grand ou egal a 81 alors branchement a end_printArray
			add 	$t2, $t0, $t1			# $t0 + $t1 -> $t2 ($t0 l'adresse du tableau et $t1 la position dans le tableau)
			lb		$a0, ($t2)				# load byte at $t2(adress) in $a0
			li		$v0, 1					# code pour l'affichage d'un entier
			syscall
			add		$t1, $t1, 1				# $t1 += 1;
		
			move $a0 $t1
			li $a1, 27
			jal modulo 
			bne $v0, 0, sortiez
				jal traitVert
				jal newLine
				jal neufTrait
			sortiez:
				move $a0 $t1
			li $a1, 9
			jal modulo 
			bne $v0, 0, sortiezzz
				jal traitVert
				jal newLine
			sortiezzz:
			move $a0 $t1
			li $a1, 3
			jal modulo 
			bne $v0, 0, sortiezz
				move $a0 $t1
				bge $a0, 79, nothing	
				jal traitVert
			sortiezz:
		nothing:
		
		j boucle_printArrayGrid
	end_printArrayGrid:
		lw 		$ra, 0($sp)					# \ On recharge la reference 
		add 	$sp, $sp, 4					# / du dernier jump
	jr $ra



#Verifie si la colonne N est valide
#	$a3 numero de colonne
# resultat dans $v1
# Registres utilises : $a[0-3], $v1, $t[0-2]
colonneNValide:

	sub 	$sp, $sp, 4
	sw 	$ra, 0($sp)
	
	
	li 	$a1, 1 
	loop_colNValide1: #recherche $a1 dans la colonne $a3
		li	$v1, 0
		li 	$a2, 1
		li	$t1, 0
		move	$t1, $a3
			loop_recherche_col:
				#$a3 charge la cellule
				#beq $a1 $a3
				add 	$t2, $t0, $t1			
				lb	$a0, ($t2)						
				bne 	$a0, $a1, notequalCol 
				add 	$v1, $v1, 1
				notequalCol:
				beq	$a2, 9, end_loop_recherche_col
				add 	$a2, $a2, 1
				add 	$t1, $t1, 9
			j loop_recherche_col	
			end_loop_recherche_col:
		bgt 	$v1, 1, notGoodcol
		beq	$a1, 9, end_loop_colNValide1
		add 	$a1, $a1, 1
	j loop_colNValide1
	
	notGoodcol:
	end_loop_colNValide1:
	bgt $v1, 1, colNFalse
		li 	$v1, 1 #colonnes OK (TRUE)
		j out_col_val
	colNFalse:
		li 	$v1, 0 #colonnes NOT OK (FALSE)
	out_col_val:	
		
	lw 		$ra, 0($sp)
	add 	$sp, $sp, 4
jr $ra


#Verifie si la ligne N est valide
#	$a3 numero de ligne
# resultat dans $v1
# Registres utilises : $a[0-3], $v[0-1], $t[0-2]
ligneNValide:

sub 	$sp, $sp, 4
	sw 	$ra, 0($sp)
	
	
	li 	$a1, 1 
	loop_liNValide1: #recherche $a1 dans la ligne $a3
		li	$v1, 0
		li 	$a2, 1
		li	$t1, 0
		mul	$t1, $a3, 9
			loop_recherche_li:
				#$a3 charge la cellule
				#beq $a1 $a3
				add 	$t2, $t0, $t1			
				lb	$a0, ($t2)				
				bne 	$a0, $a1, notequalli
				add 	$v1, $v1, 1
				notequalli:
				beq	$a2, 9, end_loop_recherche_li
				add 	$a2, $a2, 1
				add 	$t1, $t1, 1
			j loop_recherche_li	
			end_loop_recherche_li:
		bgt 	$v1, 1, notGoodli
		beq	$a1, 9, end_loop_liNValide1
		add 	$a1, $a1, 1
	j loop_liNValide1
	
	notGoodli:
	end_loop_liNValide1:
	bgt $v1, 1, liNFalse
		li 	$v1, 1 #ligne OK (TRUE)
		j out_li_val
	liNFalse:
		li 	$v1, 0 #ligne NOT OK (FALSE)
	out_li_val:	
		
	lw 		$ra, 0($sp)
	add 	$sp, $sp, 4
jr $ra
	
#Verifie si le carre N est valide
#	$a3 numero de carre
# resultat dans $v1
# Registres utilises : $a[0-3], $v[0-1], $t[0-2]
carreNValide:
sub 	$sp, $sp, 4
	sw 	$ra, 0($sp)
	
	
	li 	$a1, 1 
	loop_carNValide1: #recherche $a1 dans la carre $a3
		li	$v1, 0
		li	$a2, 0
		move 	$a2 $a3
		li	$t1, 0
		
		ble	$a3, 2, troisPremiers
		ble	$a3, 5, troisSeconds
		ble	$a3, 8, troisTiers
		troisPremiers:
		mul 	$t1, $a3, 3
		j out_Trois
		troisSeconds:
		li	$t1, 27
		sub	$a3, $a3, 3
		mul	$a3, $a3, 3
		add	$t1, $t1, $a3

		j out_Trois
		troisTiers:
		li	$t1, 54
		sub	$a3, $a3, 6
		mul	$a3, $a3, 3
		add	$t1, $t1, $a3

		j out_Trois
		out_Trois:
		move 	$a3 $a2
		li 	$a2, 1
		
		
			loop_recherche_car:
				#$a3 charge la cellule
				#beq $a1 $a3
				add 	$t2, $t0, $t1			
				lb	$a0, ($t2)				
													
				bne 	$a0, $a1, notequalcar 
				add 	$v1, $v1, 1
				notequalcar:
				beq	$a2, 9, end_loop_recherche_car
				
				beq $a2, 3, changeLigne
				beq $a2, 6, changeLigne
				add $t1, $t1, 1
				j notChangeLigne
				changeLigne:
				add $t1, $t1, 7
				notChangeLigne:
				
				add 	$a2, $a2, 1
				
			j loop_recherche_car	
			end_loop_recherche_car:
		bgt 	$v1, 1, notGoodcar
		beq	$a1, 9, end_loop_carNValide1
		add 	$a1, $a1, 1
	j loop_carNValide1
	
	notGoodcar:
	end_loop_carNValide1:
	bgt $v1, 1, carNFalse
		li 	$v1, 1 #carre OK (TRUE)
		j out_car_val
	carNFalse:
		li 	$v1, 0 #carre NOT OK (FALSE)
	out_car_val:	
		
	lw 		$ra, 0($sp)
	add 	$sp, $sp, 4
jr $ra
colonnesValides:
sub 	$sp, $sp, 4
	sw 	$ra, 0($sp)
	
	# 1ere tentative avec boucle, ECHEC, "jal colonneNValide" me retounre 0 pour la colonne central, 
	#li $a3, 0				je n'ai pas trouvé la raison, du coup, j'ai fait un truc 
	#li $a1, 0				qui n'est pas beau, mais qui fonctionne.
	#loop_all_colonnes:
	#	sw $a1, varcol
	#		
	#	jal colonneNValide
	#	lw $a1, varcol
	#	
	#	#move $a0 $v1
	#	#li $v0, 1
	#	#syscall
	#	
	#	add $a1, $a1, $v1
	#	beq $a3, 8, end_loop_all_colonnes
	#	add $a3, $a3, 1
	#j loop_all_colonnes
	#end_loop_all_colonnes:
	
	li $a1, 0
	
	li $a3, 4	# OUI, si je met le 4 en premier il me sort le bon resultat....
	sw $a1, varcol
	jal colonneNValide
	lw $a1, varcol
	add $a1, $a1 , $v1
	

	
	li $a3, 0
	sw $a1, varcol
	jal colonneNValide
	lw $a1, varcol
	add $a1, $a1 , $v1

	li $a3, 1
	sw $a1, varcol
	jal colonneNValide
	lw $a1, varcol
	add $a1, $a1 , $v1

	li $a3, 2
	sw $a1, varcol
	jal colonneNValide
	lw $a1, varcol
	add $a1, $a1 , $v1

	li $a3, 3
	sw $a1, varcol
	jal colonneNValide
	lw $a1, varcol
	add $a1, $a1 , $v1

	
	li $a3, 5
	sw $a1, varcol
	jal colonneNValide
	lw $a1, varcol
	add $a1, $a1 , $v1
	
	li $a3 6
	sw $a1, varcol
	jal colonneNValide
	lw $a1, varcol
	add $a1, $a1 , $v1

	li $a3 7
	sw $a1, varcol
	jal colonneNValide
	lw $a1, varcol
	add $a1, $a1 , $v1

	li, $a3 8
	sw $a1, varcol
	jal colonneNValide
	lw $a1, varcol
	add $a1, $a1 , $v1


	bne $a1, 9, allColFalse
		li 	$v1, 1 #colonnes OK (TRUE)
		j out_allCol_val
	allColFalse:
		li 	$v1, 0 #colonnes NOT OK (FALSE)
	out_allCol_val:	

	
	lw 		$ra, 0($sp)
	add 	$sp, $sp, 4
jr $ra


lignesValides:
sub 	$sp, $sp, 4
	sw 	$ra, 0($sp)

	li $a1, 0
	
	li $a3, 0
	sw $a1, varcol
	jal ligneNValide
	lw $a1, varcol
	add $a1, $a1 , $v1
	
	li $a3, 1
	sw $a1, varcol
	jal ligneNValide
	lw $a1, varcol
	add $a1, $a1 , $v1
	
	li $a3, 2
	sw $a1, varcol
	jal ligneNValide
	lw $a1, varcol
	add $a1, $a1 , $v1
	
	li $a3, 3
	sw $a1, varcol
	jal ligneNValide
	lw $a1, varcol
	add $a1, $a1 , $v1
	
	li $a3, 4
	sw $a1, varcol
	jal ligneNValide
	lw $a1, varcol
	add $a1, $a1 , $v1
	
	li $a3, 5
	sw $a1, varcol
	jal ligneNValide
	lw $a1, varcol
	add $a1, $a1 , $v1
	
	li $a3, 6
	sw $a1, varcol
	jal ligneNValide
	lw $a1, varcol
	add $a1, $a1 , $v1
	
	li $a3, 7
	sw $a1, varcol
	jal ligneNValide
	lw $a1, varcol
	add $a1, $a1 , $v1
	
	li $a3, 8
	sw $a1, varcol
	jal ligneNValide
	lw $a1, varcol
	add $a1, $a1 , $v1

	bne $a1, 9, allliFalse
		li 	$v1, 1 #lignes OK (TRUE)
		j out_allli_val
	allliFalse:
		li 	$v1, 0 #lignes NOT OK (FALSE)
	out_allli_val:	

	
	lw 		$ra, 0($sp)
	add 	$sp, $sp, 4
jr $ra
carresValides:
sub 	$sp, $sp, 4
	sw 	$ra, 0($sp)

	li $a1, 0
	
	li $a3, 1
	sw $a1, varcol
	jal carreNValide
	lw $a1, varcol
	add $a1, $a1 , $v1
	
	
	li $a3, 0
	sw $a1, varcol
	jal carreNValide
	lw $a1, varcol
	add $a1, $a1 , $v1
	

	
	li $a3, 2
	sw $a1, varcol
	jal carreNValide
	lw $a1, varcol
	add $a1, $a1 , $v1
	
	li $a3, 3
	sw $a1, varcol
	jal carreNValide
	lw $a1, varcol
	add $a1, $a1 , $v1
	
	li $a3, 4
	sw $a1, varcol
	jal carreNValide
	lw $a1, varcol
	add $a1, $a1 , $v1
	
	li $a3, 5
	sw $a1, varcol
	jal carreNValide
	lw $a1, varcol
	add $a1, $a1 , $v1
	
	li $a3, 6
	sw $a1, varcol
	jal carreNValide
	lw $a1, varcol
	add $a1, $a1 , $v1
	
	li $a3, 7
	sw $a1, varcol
	jal carreNValide
	lw $a1, varcol
	add $a1, $a1 , $v1
	
	li $a3, 8
	sw $a1, varcol
	jal carreNValide
	lw $a1, varcol
	add $a1, $a1 , $v1
	
	

	bne $a1, 9, allcarFalse
		li 	$v1, 1 #carre OK (TRUE)
		j out_allcar_val
	allcarFalse:
		li 	$v1, 0 #carre NOT OK (FALSE)
	out_allcar_val:	

	
	lw 		$ra, 0($sp)
	add 	$sp, $sp, 4
jr $ra


sudokuValides:
sub 	$sp, $sp, 4
	sw 	$ra, 0($sp)

	li $a1, 0

	sw $a1, varco2
	jal carresValides
	lw $a1, varco2
	add $a1, $a1 , $v1
	
	move $a0 $v1
	li $v0,  1
	syscall
	
	

	
	sw $a1, varco2
	jal colonnesValides
	lw $a1, varco2
	add $a1, $a1 , $v1
	
	move $a0 $v1
	li $v0,  1
	syscall
	

	sw $a1, varco2
	jal lignesValides
	lw $a1, varco2
	add $a1, $a1 , $v1
	
	move $a0 $v1
	li $v0,  1
	syscall

	
	bne $a1, 3, allsudFalse
		li 	$v1, 1 #sudoku OK (TRUE)
		j out_allsud_val
	allsudFalse:
		li 	$v1, 0 #sudoku NOT OK (FALSE)
	out_allsud_val:	
	
	lw 		$ra, 0($sp)
	add 	$sp, $sp, 4
jr $ra


rechercheAlgo:

# Fin de la zone de dÃ©claration de vos fonctions

main:	
	lw		$a0, 4($a1)
	li 		$a1, 0
	jal	openfile
	move	$a0, $v0
	jal extractionValue
	jal closeFile
	jal changeArrayAsciiCode
	jal printArrayGrid
	jal newLine
	
# Mettre des appels de fonctions dans cette zone.
	#li $a3 0
	#jal ligneNValide
	#move $a0 $v1
	#li $v0,  1
	#syscall
	
	#li $a3 4
	#jal colonneNValide
	#move $a0 $v1
	#li $v0,  1
	#syscall
	
	#li $a3 0
	#jal carreNValide
	#move $a0 $v1
	#li $v0,  1
	#syscall
	#jal newLine
	
	jal colonnesValides
	move $a0 $v1
	li $v0,  1
	syscall
	jal newLine
	
	jal lignesValides
	move $a0 $v1
	li $v0,  1
	syscall
	jal newLine
	
	jal carresValides
	move $a0 $v1
	li $v0,  1
	syscall
	jal newLine

	jal sudokuValides
	move $a0 $v1
	li $v0,  1
	syscall
	jal newLine
	

# Fin de la zone d'appel de fonctions.
jal newLine
exit: 
	li		$v0, 10
	syscall

# End

