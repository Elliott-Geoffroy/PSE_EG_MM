#!/bin/sh

#A MINIMA

echo "Systeme d'exploitation : `cat /proc/sys/kernel/ostype`"
echo "Version du noyau : `cat /proc/sys/kernel/osrelease`"

UP=`cat /proc/uptime | cut -d ' ' -f 1 | cut -d '.' -f 1` # Je ne prend que la premiere valeur renvoyee par /proc/uptime puis je garde uniquement la partie entiere de la valeur retournee.
UP=`expr $UP / 3600 / 24`

echo "Temps ecoule depuis le dernier redemarrage : $UP jours"

echo "Utilisation globale moyenne CPU (1 min/5 min/15 min) : `cat /proc/loadavg | cut -d ' ' -f 1-3`"

ramTot=`cat /proc/meminfo | head -1 | tr -s ' ' | cut -d ' ' -f 2`
ramFree=`cat /proc/meminfo | head -2 | tr -s ' ' | cut -d ' ' -f 2 | tail -1`

echo "Memoire Libre / Memoire totale : $ramFree Kb / $ramTot Kb" 


NBUSERS=`who | wc -l`
if [ $NBUSERS -eq 1 ]
then
	echo "Il y a actuellement $NBUSERS utilisateur connecte (vous)"
else
	echo "Il y a actuellement $NBUSERS utilisateurs connectes"
fi

echo "les 5 processus ayant consomme le plus de temps CPU depuis leur lancement :"
echo "PID\tnom\t\ttics"
cat /proc/[0-9]*/stat | cut -d ' ' -f  1,2,15 | sort -t " " -k 3 -n -r | head -5 | tr " " "\t"

echo "les 5 fichiers (incluant les répertoires) occupant le plus d’espace disque"
echo "taille (Octets)\tnom"
find . -type f 2>/dev/null | xargs du -b 2>/dev/null | sort -n -r | head -5

#A MEDIA

#PARTIE PROCESSUS
echo "nombre de processus desire ?"
read prcss
echo $prcss | grep -E "^[0-9]+$" 1>/dev/null
while [ $? != 0 ]
do
	echo "nombre de processus desire ? (il faut entrer un nombre)"
	read prcss
	
	echo $prcss | grep -E "^[0-9]+$" 1>/dev/null
done

echo "les $prcss processus ayant consomme le plus de temps CPU depuis leur lancement :"
echo "PID\tnom\t\ttics"
cat /proc/[0-9]*/stat | cut -d ' ' -f  1,2,15 | sort -t " " -k 3 -n -r | head -"$prcss" | tr " " "\t"


#PARTIE DISK UTIL.
echo "nombre de fichier desire ?"
read prcss
echo $prcss | grep -E "^[0-9]+$" 1>/dev/null
while [ $? -ne 0 ]
do
	echo "nombre de fichier desire ? (il faut entrer un nombre)"
	read prcss
	
	echo $prcss | grep -E "^[0-9]+$" 1>/dev/null
done

echo "Voulez vous changer de repertoire courant ? (y/n)"
read yn

while ([ "$yn" != "y" ] && [ "$yn" != "n" ])
do
	echo "Voulez vous changer de repertoire courant ? (y/n)"
	read yn
done

if [ "$yn" = "y" ]
then
	boo=0
	while [ $boo -eq 0 ]
	do
		echo "Entrez le repertoire souhaite (chemin relatif):"
		read chemin
			if echo $chemin | grep -E "^[.]{1,2}[/].*$" 1>/dev/null
			then : 
			else
				chemin="./""$chemin" 
			fi
		if [ -d $chemin ]
		then
			echo "Recherche dans repertoire : \"$chemin\""
			echo "les $prcss fichiers (incluant les répertoires) occupant le plus d’espace disque"
			echo "taille (Octets)\tnom"
			find "$chemin" -type f 2>/dev/null | xargs du -b 2>/dev/null | sort -n -r | head -"$prcss"
			boo=1
		else
			echo "repertoire \"$chemin\" inexistant" >&2	
		fi 
	done
elif [ "$yn" = "n" ]
then
	echo "les $prcss fichiers (incluant les répertoires) occupant le plus d’espace disque"
	echo "taille (Octets)\tnom"
	find . -type f 2>/dev/null | xargs du -b 2>/dev/null | sort -n -r | head -"$prcss"
fi

#PARTIE KILL PROCESS

echo "Voulez-vous kill un processus ? (y/n)"
read yn

while ([ "$yn" != "y" ] && [ "$yn" != "n" ])
do
	echo "Voulez-vous kill un processus ? (y/n)"
	read yn
done

if [ "$yn" = "y" ]
then
	boo=0
	while [ $boo -eq 0 ]
	do
		echo "Entrez le PID du processus :"
		read killer
		kill $killer
		if [ $? -ne 0 ]
		then
			echo "Le processus n'a pas pu etre supprime (en etes-vous le proprietaire ?)"
		else
			echo "processus detruit"		
		fi
		
		echo "kill un autre processus ? (y/n)"
		read yn

		while ([ "$yn" != "y" ] && [ "$yn" != "n" ])
		do
			echo "Voulez-vous kill un processus ? (y/n)"
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

#nice : priorité 19

# ls -dl /proc/18054  Starttime

# cat /proc/[pid]/status -> VmRSS (Kb)

echo "Combien de processus voulez-vous lister (date creation) ?"
read prcss
echo $prcss | grep -E "^[0-9]+$" 1>/dev/null

while [ $? -ne 0 ]
do
	echo "nombre de processus desire (date creation) ? (il faut entrer un nombre)"
	read prcss
	
	echo $prcss | grep -E "^[0-9]+$" 1>/dev/null
done

echo "Date de création des $prcss processus :"
cat /proc/[0-9]*/stat | cut -d ' ' -f  1,2,15 | sort -t " " -k 3 -n -r | head -"$prcss" | tr " " "\t" > /tmp/PSEProc.$$

while read LIGNE
do
	PID=`echo $LIGNE | cut -d ' ' -f 1`
	DATECREA=`ls -dl /proc/$PID | cut -d ' ' -f 6,7`
	TPS=`date --utc --rfc-3339=seconds | cut -d '+' -f 1`
	FIN=`date -u +%s --date="$TPS"`
	DEBUT=`date -u +%s --date="$DATECREA"`

	INTERVALLE=`echo $(($FIN - $DEBUT))`
	SAVE="$SAVE\n$LIGNE $INTERVALLE"  # Sauvegarde pour le tri
	INTERVALLE=$(($INTERVALLE / 60))    # intervalle exprimé en minutes
	minutes=$(($INTERVALLE % 60))       # le reste d'une division par 60
	INTERVALLE=$(( ($INTERVALLE - $minutes)/60 )) # on retire le surplus et on
		                                      # divise par 60 pour avoir
		                                      # l'intervalle en heures 
	heures=$(($INTERVALLE % 24))        # idem pour les heures                                
	INTERVALLE=$(( ($INTERVALLE - $heures)/24 ))  # intervalle expr. en jours 
	echo "Processus (PID/NOM) : `echo $LIGNE | cut -d ' ' -f 1,2`"
	SAVE="$SAVE ($INTERVALLE jours, $heures heures et $minutes minutes.)"
done < /tmp/PSEProc.$$
rm /tmp/PSEProc.$$

echo $SAVE | sort -r -k 4
exit 0
