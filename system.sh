#!/bin/sh

#All Rights to:
#
#Elliott Geoffroy
#Mathieu Maillard
#
#Please don't use this without our permission
#or you'll be damned to hell ! 
#


#A MINIMA

clear

#***********************#
#			#
#	A MINIMA	#
#                       #
#***********************#

banner "A MINIMA"

#***********************#
#  Info Sys. classique  #
#***********************#
echo "Système d'exploitation : `cat /proc/sys/kernel/ostype`"
echo "Version du noyau : `cat /proc/sys/kernel/osrelease`"

UP=`cat /proc/uptime | cut -d ' ' -f 1 | cut -d '.' -f 1` # Je ne prend que la premiere valeur renvoyee par /proc/uptime puis je garde uniquement la partie entiere de la valeur retournee.
UP=`expr $UP / 3600 / 24`

echo "Temps écoulé depuis le dernier redémarrage : $UP jours"

echo "Utilisation globale moyenne CPU (1 min/5 min/15 min) : `cat /proc/loadavg | cut -d ' ' -f 1-3`"

ramTot=`cat /proc/meminfo | head -1 | tr -s ' ' | cut -d ' ' -f 2`
ramFree=`cat /proc/meminfo | head -2 | tr -s ' ' | cut -d ' ' -f 2 | tail -1`

echo "Mémoire Libre / Mémoire totale : $ramFree Kb / $ramTot Kb" 


NBUSERS=`who | cut -d ' ' -f1 | uniq -u | wc -l`
if [ $NBUSERS -eq 1 ]
then
	echo "Il y a actuellement $NBUSERS utilisateur connecté"
else
	echo "Il y a actuellement $NBUSERS utilisateurs connectés"
fi

#***********************#
# 5 procs. CPU Conso    #
#***********************#

echo "\nLes 5 processus ayant consomme le plus de temps CPU depuis leur lancement :"
echo "PID\tnom\t\ttics"
cat /proc/[0-9]*/stat | cut -d ' ' -f  1,2,15 | sort -t " " -k 3 -n -r | head -5 | tr " " "\t"

#***********************#
# 5 File Size from ./   #
#***********************#

echo "\nLes 5 fichiers (incluant les répertoires) occupant le plus d’espace disque"
echo "taille\tnom"
echo "(Octets)"
find . -type f 2>/dev/null | xargs du -b 2>/dev/null | sort -n -r | head -5 

#***********************#
#			#
#  	 A MEDIA	#
#                       #
#***********************#

echo "\n"
banner "A MEDIA"

#***********************#
#  n procs. CPU Conso   #
#***********************#
echo "\nNombre de processus désiré ?"
read prcss
echo $prcss | grep -E "^[0-9]+$" 1>/dev/null
while [ $? != 0 ] # Verification que l'utilisateur rentre bien un nombre
do
	echo "\nNombre de processus désiré ? (il faut entrer un nombre)"
	read prcss
	
	echo $prcss | grep -E "^[0-9]+$" 1>/dev/null
done


if [ $prcss -eq 1 ] #test pour afficher au singulier ou pluriel
then
	echo "Le $prcss processus ayant consommé le plus de temps CPU depuis son lancement :"
	echo "PID\tnom\t\tticks"
else
	echo "Les $prcss processus ayant consommés le plus de temps CPU depuis leur lancement :"
	echo "PID\tnom\t\tticks"
fi
cat /proc/[0-9]*/stat | cut -d ' ' -f  1,2,15 | sort -t " " -k 3 -n -r | head -"$prcss" | tr " " "\t" #affichage du resultat


#*******************************#
# n File Size from ./ or else   #
#*******************************#
echo "\nNombre de fichier désiré ?"
read prcss
echo $prcss | grep -E "^[0-9]+$" 1>/dev/null
while [ $? -ne 0 ] # Verification que l'utilisateur rentre bien un nombre
do
	echo "\nNombre de fichier désiré ? (il faut entrer un nombre)"
	read prcss
	
	echo $prcss | grep -E "^[0-9]+$" 1>/dev/null
done


# choix du repetroire
echo "\nVoulez-vous changer de répertoire courant ? (y/n)"
read yn

while ([ "$yn" != "y" ] && [ "$yn" != "n" ]) # Verification que l'utilisateur rentre bien y ou n
do
	echo "\n(y/n)"
	read yn
done

if [ "$yn" = "y" ] #veut changer de repertoire
then
	boo=0
	while [ $boo -eq 0 ]
	do
		echo "\nEntrez le répertoire souhaité (chemin relatif):"
		read chemin
			if echo $chemin | grep -E "^[.]{1,2}[/].*$" 1>/dev/null # test si l'utilisateur a bien mis ./ ou ../ (car chemin relatif)
			then : 
			else
				chemin="./""$chemin" # sinon rajoute ./ par defaut 
			fi
		if [ -d $chemin ] 
		then
			boo=1
		else
			echo "Répertoire \"$chemin\" inexistant" >&2	
		fi 
	done
elif [ "$yn" = "n" ] #reste sur ./
then
	chemin="./"
fi

	echo "Recherche dans répertoire : \"$chemin\""
if [ $prcss -eq 1 ] # Verification pour affichage pluriel singulier
then
	echo "\nLe $prcss fichier (incluant les répertoires) occupant le plus d’espace disque"
else
	echo "\nLes $prcss fichiers (incluant les répertoires) occupant le plus d’espace disque"
fi
	echo "\ntaille\tnom"
	echo "(Octets)"

find "$chemin" -type f 2>/dev/null | xargs du -b 2>/dev/null | sort -n -r | head -"$prcss" 

#***********************#
#   tuer un procs       #
#***********************#
echo "\nVoulez-vous tuer un processus ? (y/n)"
read yn

while ([ "$yn" != "y" ] && [ "$yn" != "n" ]) # Verification que l'utilisateur rentre bien y ou n
do
	echo "(y/n)"
	read yn
done

if [ "$yn" = "y" ]
then
	boo=0
	while [ $boo -eq 0 ]
	do
		echo "\nEntrez le PID du processus :"
		read killer

		find "/proc/$killer" 1>/dev/null 2>/dev/null

		while [ $? != 0 ] #
		do
			echo "PID inexistant "
			echo "\nEntrez un PID de processus EXISTANT:"
			read killer
			find "/proc/$killer" 1>/dev/null 2>/dev/null

		done

		kill $killer
		
		find "/proc/$killer" 1>/dev/null 2>/dev/null

		
		if [ $? -eq 0 ] 2>/dev/null # Si la tentative échoue
		then
			echo "Le processus n'a pas pu être supprimé (en êtes-vous le propriétaire ?)"
		else
			echo "Processus detruit"		
		fi
		
		echo "Tuer un autre processus ? (y/n)"
		read yn

		while ([ "$yn" != "y" ] && [ "$yn" != "n" ]) # Verification que l'utilisateur rentre bien y ou n
		do
			echo "(y/n)"
			read yn
		done
		
		if [ "$yn" = "y" ]
		then
			boo=0
		else
			boo=1
		fi
	done
fi

#***********************#
#			#
#     A MAXIMA          #
#                       #
#***********************#

banner "A MAXIMA"

#***********************#
#    Choix tri procs    #
#***********************#
yn="y"
while [ "$yn" = "y" ] # Loop pour plusieurs tri d'affilé si souhaité
do
	echo "\nNombre de processus désiré ?"
	read prcss
	echo $prcss | grep -E "^[0-9]+$" 1>/dev/null
	while [ $? != 0 ] # verif si bien un nomre
	do
		echo "\nNombre de processus désiré ? (il faut entrer un nombre)"
		read prcss

		echo $prcss | grep -E "^[0-9]+$" 1>/dev/null
	done

		echo "\nVoulez-vous trier les processus par :"
		echo "-Quantité de mémoire occupée (m)\n-Temps écoulé depuis son lancement (t)\n-Date de lancement (d)\n-priorité du processus (p)\n (t/d/p) (m coming soon, but try it ! yeah really ! try it !):"
		read crit

		while ([ "$crit" != "m" ] && [ "$crit" != "t" ] && [ "$crit" != "d" ] && [ "$crit" != "p" ])
		do
			echo "\n(t/d/p) :"
			read crit
		done
	
		case $crit in

		 "m")
		#	Impossible de trouver les bonnes valeurs... sry
		
		
			#cat /proc/*/status | grep VmRSS | tr -s  " " | cut -d " " -f 2
		
			#cat /proc/*/status | grep VmSize | tr -s  " " | cut -d " " -f 2
		
			# cat /proc/*/statm
			
			
			#cat /proc/*/status | grep VmData | tr -s  " " | cut -d " " -f 2 

			echo "\033[1;36m\nsry"
			echo "\033[1;32mthat's not available today"	
			echo "\033[1;35mtry again, but, try it tomorrow"
			echo "\033[1;31mmaybe it will work"
			echo "\033[1;33mif not, well, wait a bit more!"
			echo "\n\033[1;37mhave a nice day =)\033[m\n"
		;;

		"t")
			if [ $prcss -eq 1 ]
			then
				echo "Durée d'exécution du processus :"
			else
				echo "Durée d'exécution des $prcss processus :"
			fi
			ls -dl /proc/* 2>/dev/null | tr -s " " | cut -d ' ' -f 6,7,8 | sort -t " " -k 1 | grep -E "^.*/[0-9]+$" | head -$prcss | cut -d '/' -f 3 > /tmp/PSEProc.$$
			echo "\nPID\t(nom)\t\tdurée"		
			while read LIGNE
			do
				PID=$LIGNE
				NOM=`cat /proc/$PID/stat | cut -d ' ' -f 2`
				DATECREA=`ls -dl /proc/$PID | cut -d ' ' -f 6,7` 2>/dev/null
				TPS=`date --utc --rfc-3339=seconds | cut -d '+' -f 1 | cut -d ':' -f 1,2`
				FIN=`date -u +%s --date="$TPS"` # Heure actuelle convertie en seconde (à partir du 1/01/1970)
				DEBUT=`date -u +%s --date="$DATECREA"`

				INTERVALLE=`echo $(($FIN - $DEBUT))`
				SAVE="$LIGNE\t$NOM\t$INTERVALLE\t"  # Sauvegarde pour le tri
				INTERVALLE=$(($INTERVALLE / 60))    # intervalle exprimé en minutes
				minutes=$(($INTERVALLE % 60))       # le reste d'une division par 60
				INTERVALLE=$(( ($INTERVALLE - $minutes)/60 )) # on retire le surplus et on
									      # divise par 60 pour avoir
									      # l'intervalle en heures 
				heures=$(($INTERVALLE % 24))        # idem pour les heures
				INTERVALLE=$(( ($INTERVALLE - $heures)/24 ))  # intervalle expr. en jours 
				SAVE="$SAVE ($INTERVALLE jours, $heures heures et $minutes minutes.)"
				echo $SAVE 
			done < /tmp/PSEProc.$$
			;;

		"d")
	
			ls -dl /proc/* 2>/dev/null | tr -s " " | cut -d ' ' -f 6,7,8 | sort -t " " -k 1 | grep -E "^.*/[0-9]+$" | head -$prcss | cut -d '/' -f 3 > /tmp/PSEProc.$$
			echo "PID\tNOM\tDate"
			while read LIGNE
			do
				PIDNOM=`cat /proc/"$LIGNE"/stat | cut -d ' ' -f  1,2 | tr " " "\t"`
				DATE=`ls -dl /proc/"$LIGNE" | cut -d ' ' -f 6,7`
		
				echo "$PIDNOM""\t""$DATE" 
		
			done < /tmp/PSEProc.$$
		;;

		"p")
			echo "PID\tNOM\tPriorité"
			cat /proc/*/stat 2>/dev/null | sort -t " " -k 19 -n | head -"$prcss" | cut -d " " -f 1,19,2 | sort -t " " -k 3 -r | tr " " "\t"
		;;
		esac
	echo "\nVoulez-vous retrier les processus ? (y/n)" #Recommencer 
	read yn

	while ([ "$yn" != "y" ] && [ "$yn" != "n" ]) #verif y / n
	do
		echo "\nVoulez-vous retrier les processus ? (y/n)"
		read yn
	done
done


#***********************#
#       renice un procs #
#***********************#
echo "\nVoulez-vous modifier la priorité d'un processus ? (y/n)"
read yn

while ([ "$yn" != "y" ] && [ "$yn" != "n" ]) # yn
do
	echo "\nVoulez-vous modifier la priorité d'un processus ? (y/n)"
	read yn
done

if [ "$yn" = "y" ]
then
	boo=0
	while [ $boo -eq 0 ]
	do
		echo "\nEntrez le PID du processus :"
		read pid
		while [ $pid -lt 1 ]  #Boucle car renice renvoie 0 lorsque l'on effectue "renice -15 -24" (exemple)
		do
			echo "\n(PID < 1 ; Entrez le PID du processus)"
			read pid
		done 	

		echo "\nEntrez la valeur de priorité désirée : (-20 <=> +19)"
		read prio
		while [ "$prio" -gt 19 ] || [ "$prio" -lt -20 ]
		do
			echo "\n(-20 <=> +19)"
			read prio
		done 		
	
		renice $prio $pid 1>/dev/null 2>/dev/null


		if [ $? -ne 0 ]
		then
			echo "Le changement de priorité n'a pas pu être effectué (en êtes-vous le propriétaire ? en avez-vous les droits ?)"
		else
			echo "Modification de la priorité effectuée"		
		fi
		
		echo "\nVoulez-vous modifier la priorité d'un autre processus ? (y/n)"
		read yn

		while ([ "$yn" != "y" ] && [ "$yn" != "n" ]) #
		do
			echo "\nVoulez-vous modifier la priorité d'un autre processus ? (y/n)"
			read yn
		done
		
		if [ "$yn" = "y" ]
		then
			boo=0
		else
			boo=1
		fi
	done
fi

#***********************#
#    Kill procs avec SIG#
#***********************#
echo "\nVoulez-vous tuer un processus via les signaux HUP -> INT -> KILL ? (y/n)"
read yn

while ([ "$yn" != "y" ] && [ "$yn" != "n" ]) #
do
	echo "\n(y/n)"
	read yn
done

if [ "$yn" = "y" ]
then
	boo=0
	while [ $boo -eq 0 ]
	do
		echo "\nEntrez le PID du processus :"
		read killer

		find "/proc/$killer" 1>/dev/null 2>/dev/null

		while [ $? != 0 ] #
		do
			echo "PID inexistant "
			echo "\nEntrez un PID de processus EXISTANT:"
			read killer
			find "/proc/$killer" 1>/dev/null 2>/dev/null

		done


		kill -1 $killer 1>/dev/null 2>/dev/null
 #Tentative avec signal HUP

		find "/proc/$killer" 1>/dev/null 2>/dev/null

		
		if [ $? -eq 0 ] 2>/dev/null # Si la tentative échoue
		then
			kill -2 $killer 1>/dev/null 2>/dev/null
 #Tentative avec signal INT	

			find "/proc/$killer" 1>/dev/null 2>/dev/null
		
			
			if [ $? -eq 0 ] 1>/dev/null 2>/dev/null
 # Si la tentative échoue
			then
				kill -9 $killer 1>/dev/null 2>/dev/null
 # Tentative ultime qui ne devrait pas pouvoir échouer

				find "/proc/$killer" 1>/dev/null 2>/dev/null

				if [ $? -eq 0 ]
				then
					echo "La suppression a échouée, en êtes-vous le propriétaire ou avez-vous les droits nécessaires ?"
				fi
			else
				echo "Processus détruit"
			fi
		else
			echo "Processus détruit"		
		fi
		
		echo "\nTuer un autre processus ? (y/n)"
		read yn

		while ([ "$yn" != "y" ] && [ "$yn" != "n" ])
		do
			echo "\n(y/n)"
			read yn
		done
	
		if [ "$yn" = "y" ]
		then
			boo=0
		else
			boo=1
		fi
	done
fi

rm "/tmp/PSEProc.$$" 2>/dev/null  # suppression ficher temp

exit 0 # exit

# The script will explode in 10 seconds: ...1 ...2 ...3 ...4 ...5 ...6 ...7 ...8 ...9 ...Boom!
