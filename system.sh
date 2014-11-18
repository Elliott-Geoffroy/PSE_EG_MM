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

echo "nombre de fichier desire ?"
read prcss
echo $prcss | grep -E "^[0-9]+$" 1>/dev/null
while [ $? != 0 ]
do
	echo "nombre de fichier desire ? (il faut entrer un nombre)"
	read prcss
	
	echo $prcss | grep -E "^[0-9]+$" 1>/dev/null
done

echo "les $prcss fichiers (incluant les répertoires) occupant le plus d’espace disque"
echo "taille (Octets)\tnom"
find . -type f 2>/dev/null | xargs du -b 2>/dev/null | sort -n -r | head -"$prcss"
