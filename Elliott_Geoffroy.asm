.data
grille: .byte 81

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

# Zone de déclaration de vos fonctions
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
#	$a0 numero de colonne
# resultat dans $v0
# Registres utilises : $a0

colonneNValide:

	sub 	$sp, $sp, 4
	sw 	$ra, 0($sp)


		li $v0,  1
		
	
	bge $v0, 1, colNFalse
		li $v0, 1
		j out_col_val
	colNFalse:
		li $v0, 0
	out_col_val:	
		
	lw 		$ra, 0($sp)
	add 	$sp, $sp, 4
	jr $ra

ligneNValide:

carreNValide:

colonnesValides:

lignesValides:

carresValides:

sudokuValides:

rechercheAlgo:

# Fin de la zone de déclaration de vos fonctions

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
	li $a0 4
	jal colonneNValide
	move $a0 $v0
	li $v0,  1
	syscall

# Fin de la zone d'appel de fonctions.
jal newLine
exit: 
	li		$v0, 10
	syscall

# End

