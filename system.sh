#!/bin/sh

#A MINIMA

echo "Système d'exploitation : `cat /proc/sys/kernel/ostype`"
echo "Version du noyau : `cat /proc/sys/kernel/osrelease`"

UP=`cat /proc/uptime | cut -d ' ' -f 1 | cut -d '.' -f 1` # Je ne prend que la premiere valeur renvoyee par /proc/uptime puis je garde uniquement la partie entiere de la valeur retournee.
UP=`expr $UP / 3600 / 24`

echo "Temps écoulé depuis le dernier redémarrage : $UP jours"

echo "Utilisation globale moyenne CPU (1 min/5 min/15 min) : `cat /proc/loadavg | cut -d ' ' -f 1-3`"

ramTot=`cat /proc/meminfo | head -1 | tr -s ' ' | cut -d ' ' -f 2`
ramFree=`cat /proc/meminfo | head -2 | tr -s ' ' | cut -d ' ' -f 2 | tail -1`

echo "Mémoire Libre / Mémoire totale : $ramFree Kb / $ramTot Kb" 


NBUSERS=`who | wc -l`
if [ $NBUSERS -eq 1 ]
then
	echo "Il y a actuellement $NBUSERS utilisateur connecté (vous)"
else
	echo "Il y a actuellement $NBUSERS utilisateurs connectés"
fi

echo "\nLes 5 processus ayant consomme le plus de temps CPU depuis leur lancement :"
echo "PID\tnom\t\ttics"
cat /proc/[0-9]*/stat | cut -d ' ' -f  1,2,15 | sort -t " " -k 3 -n -r | head -5 | tr " " "\t"

echo "\nLes 5 fichiers (incluant les répertoires) occupant le plus d’espace disque"
echo "taille (Octets)\tnom"
find . -type f 2>/dev/null | xargs du -b 2>/dev/null | sort -n -r | head -5

#A MEDIA

#PARTIE PROCESSUS
echo "\nNombre de processus désiré ?"
read prcss
echo $prcss | grep -E "^[0-9]+$" 1>/dev/null
while [ $? != 0 ]
do
	echo "\nNombre de processus désiré ? (il faut entrer un nombre)"
	read prcss
	
	echo $prcss | grep -E "^[0-9]+$" 1>/dev/null
done


if [ $prcss -eq 1 ]
then
	echo "Le $prcss processus ayant consommé le plus de temps CPU depuis son lancement :"
	echo "PID\tnom\t\tticks"
else
	echo "Les $prcss processus ayant consommés le plus de temps CPU depuis leur lancement :"
	echo "PID\tnom\t\tticks"
fi
cat /proc/[0-9]*/stat | cut -d ' ' -f  1,2,15 | sort -t " " -k 3 -n -r | head -"$prcss" | tr " " "\t"


#PARTIE DISK UTIL.
echo "\nNombre de fichier désiré ?"
read prcss
echo $prcss | grep -E "^[0-9]+$" 1>/dev/null
while [ $? -ne 0 ]
do
	echo "\nNombre de fichier désiré ? (il faut entrer un nombre)"
	read prcss
	
	echo $prcss | grep -E "^[0-9]+$" 1>/dev/null
done

echo "\nVoulez-vous changer de répertoire courant ? (y/n)"
read yn

while ([ "$yn" != "y" ] && [ "$yn" != "n" ])
do
	echo "\n(y/n)"
	read yn
done

if [ "$yn" = "y" ]
then
	boo=0
	while [ $boo -eq 0 ]
	do
		echo "\nEntrez le répertoire souhaité (chemin relatif):"
		read chemin
			if echo $chemin | grep -E "^[.]{1,2}[/].*$" 1>/dev/null
			then : 
			else
				chemin="./""$chemin" 
			fi
		if [ -d $chemin ]
		then
			boo=1
		else
			echo "Répertoire \"$chemin\" inexistant" >&2	
		fi 
	done
elif [ "$yn" = "n" ]
then
	chemin="./"
fi

	echo "Recherche dans répertoire : \"$chemin\""
if [ $prcss -eq 1 ]
then
	echo "\nLe $prcss fichier (incluant les répertoires) occupant le plus d’espace disque"
else
	echo "\nLes $prcss fichiers (incluant les répertoires) occupant le plus d’espace disque"
fi
	echo "\ntaille (Octets)\tnom"

find "$chemin" -type f 2>/dev/null | xargs du -b 2>/dev/null | sort -n -r | head -"$prcss"

#PARTIE KILL PROCESS

echo "\nVoulez-vous tuer un processus ? (y/n)"
read yn

while ([ "$yn" != "y" ] && [ "$yn" != "n" ])
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
		kill $killer
		if [ $? -ne 0 ]
		then
			echo "Le processus n'a pas pu être supprimé (en êtes-vous le propriétaire ?)"
		else
			echo "Processus detruit"		
		fi
		
		echo "Tuer un autre processus ? (y/n)"
		read yn

		while ([ "$yn" != "y" ] && [ "$yn" != "n" ])
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

#A MAXIMA

#SELECTION CRITERE

echo "\nNombre de processus désiré ?"
read prcss
echo $prcss | grep -E "^[0-9]+$" 1>/dev/null
while [ $? != 0 ]
do
	echo "\nNombre de processus désiré ? (il faut entrer un nombre)"
	read prcss
	
	echo $prcss | grep -E "^[0-9]+$" 1>/dev/null
done

echo "\nVoulez-vous trier les processus par :"
echo "-Quantité de mémoire occupée (m)\n-Temps écoulé depuis son lancement (t)\n-Date de lancement (d)\n-priorité du processus (p)\n (m/t/d/p) :"
read crit

while ([ "$crit" != "m" ] && [ "$crit" != "t" ] && [ "$crit" != "d" ] && [ "$crit" != "p" ])
do
	echo "\n(m/t/d/p) :"
	read crit
done

	case $crit in

	"m")
		# cat /proc/[pid]/status -> VmRSS (Kb)
	;;

	"t")
		if [ $prcss -lte 1 ]
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
			SAVE="$LIGNE $NOM $INTERVALLE"  # Sauvegarde pour le tri
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
		cat /proc/[0-9]*/stat | cut -d ' ' -f  1,2,15 | sort -t " " -k 3 -n -r | head -"$prcss" | tr " " "\t" > /tmp/PSEProc.$$

		cat /tmp/PSEProc.$$ | tr "\t" " " | cut -d " " -f 1
		# ls -dl /proc/18054  Starttime
	;;
	
	"p")
		#nice : priorité 19
	;;
	esac



# RENICE

echo "\nVoulez-vous modifier la priorité d'un processus ? (y/n)"
read yn

while ([ "$yn" != "y" ] && [ "$yn" != "n" ])
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
	
		renice $prio $pid

		if [ $? -ne 0 ]
		then
			echo "Le changements de priorité n'a pas pu être effectué (en êtes-vous le propriétaire ? en avez-vous les droits ?)"
		else
			echo "Modification de la priorité effectuée"		
		fi
		
		echo "\nVoulez-vous modifier la priorité d'un autre processus ? (y/n)"
		read yn

		while ([ "$yn" != "y" ] && [ "$yn" != "n" ])
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

#Partie kill processus selon le signal

echo "\nVoulez-vous tuer un processus ? (y/n)"
read yn

while ([ "$yn" != "y" ] && [ "$yn" != "n" ])
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
		kill -1 $killer #Tentative avec signal HUP
		if [ $? -ne 0 ] 2>/dev/null # Si la tentative échoue
		then
			kill -2 $killer #Tentative avec signal INT
			if [ $? -ne 0 ] 2>/dev/null # Si la tentative échoue
			then
				kill -9 $killer 2>/dev/null # Tentative ultime qui ne devrait pas pouvoir échouer
				if [ $? -ne 0 ]
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

rm /tmp/PSEProc.$$
exit 0
