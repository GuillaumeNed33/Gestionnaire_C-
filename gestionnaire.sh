#!/bin/bash

#Guillaume Nédélec/Gaëtan Viola

#Fonction d'affichage uniquement
function Menu
{
	echo ""
	echo "Que voulez-vous faire avec $nomFichier.cpp ?"
	echo "1-Voir"
	echo "2-Editer"
	echo "3-Générer"
	echo "4-Lancer"
	echo "5-Debugguer"
	echo "6-Imprimer"
	echo "7-Shell"
	echo "8-Quitter"
}

#Fonction ou on selectionne l'action que l'on souhaite réaliser
#Renvoie au diverses fonctions présentes dans le script.
function Selection
{
	read choix #L'utilisateur choisi son action
	case "$choix" in
		1 )
		clear #Rafraichis pour plus de lisibilité
		Voir ;;
		2 )
		clear
		Editer ;;
		3 )
		clear
		Generer;;
		4 )
		clear
		Lancer;;
		5 )
		clear
		Debugger;;
		6 )
		clear
		Imprimer;;
		7 )
		clear
		Shell ;;
		8 )
		clear
		Quitter ;;
		* )
		echo "Erreur" ;;
	esac
	#Permet de ne pas sortir du script et enchainer les actions sur un fichier
	Menu
	Selection
}


#Fonction qui creer un nouveau fichier C++
function CréerNouveauFichier
{
	newFichier=$nomFichier.cpp #Pour que la variable "newFichier" contienne l'extension .cpp

	#Phase d'écriture dans le fichier qui se créé donc automatiquement.
	#Le fichier contiendra donc un code qui affichera "Hello World !"
	echo "#include <iostream>" > $newFichier
	echo >> $newFichier
	echo "using namespace std;" >> $newFichier
	echo >> $newFichier
	echo "int main(int argc, char **argv) {" >> $newFichier
	echo "	cout << \"Hello World !\" << endl;" >> $newFichier
	echo "	return 0; " >> $newFichier
	echo "}" >> $newFichier
	echo "Fichier créé avec succés."
}


#Fonction qui ouvre un "Sur Shell"
function Shell
{
	echo "La commande "exit" vous permettra de revenir au script précédent" #Indiquation pour revenir au script initial
	bash #Ouvre le "Sur shell"
}


#Quitte le script
function Quitter
{
	exit
}


#Permet de voir le contenu du fichier traité
function Voir
{
	less $nomFichier.cpp
}


#Permet d'éditer le fichier traiter avec l'éditeur "nano"
function Editer
{
	nano $nomFichier.cpp
}


#Converti le fichier C++ en pdf et l'affiche
function Imprimer
{
	echo "Impression en cours..."
	a2ps "$nomFichier.cpp" -o "$nomFichier.ps"
	ps2pdf "$nomFichier.ps" "$nomFichier.pdf"
	rm -f "$nomFichier.ps"
	xpdf $nomFichier.pdf&
}


#Fonction de compilation des fichiers C++
function Generer
{
	if g++ -o $nomFichier $nomFichier.cpp 2> erreur.txt #Si il y a des erreur lors de la compilation, elles
																											#seront redirigées dans le fichier texte erreur.txt
		then
		echo "Compilation réussie"

	else
		echo "Problème rencontré"
		echo "Voulez-vous consultez l'erreur [y/n] ?"

		#On propose de consulter l'erreur
		read decision

		if test $decision = "o" || test $decision = "y"
			then
			echo "" >> erreur.txt
			echo "" >> erreur.txt
			echo "APPUYER SUR Q POUR QUITTER" >> erreur.txt
			less erreur.txt #lecture du fichier
		fi
	fi
}


#Fonction d'execution du fichier
function Lancer
{
	if test -f $nomFichier #On verifie que l'executable existe
		then
		if test -x $nomFichier #Si le droit d'execution existe, on execute le fichier executable
			then
			./$nomFichier

		else chmod u+x $nomFichier #Sinon on rajoute les droits nécessaires à l'execution
			./$nomFichier #Puis on execute
		fi

	else #Si il n'existe pas
		echo "Il manque un executable ! Veuillez compiler le fichier."
	fi
}


#Fonction pour entrer en mode "Débug"
function Debugger
{
	if test -x $nomFichier.cpp #Si le fichier a les droits d'execution
		then
		g++ -g -o $nomFichier $nomFichier.cpp #On compile pour passer en mode debug
		echo "APPUYER SUR Q PUIS ENTREE POUR QUITTER"
		echo
		echo
		gdb $nomFichier #Fonction du mode debug

	else chmod u+x $nomFichier.cpp #Sinon on rajoute les droits nécéssaire avant de débugguer
		g++ -g -o $nomFichier $nomFichier.cpp
		echo "APPUYER SUR Q PUIS ENTREE POUR QUITTER"
		echo
		echo
		gdb $nomFichier
	fi
}

clear


if test -n "$1" #Si il y a un parametre a l'execution du script
	then

	if test -f $1.cpp #Si le fichier existe
		then
		nomFichier=$1

	elif test "$1" = "-h" || test "$1" = "-H" #Si le parametre est -h ou -H n affiche le mode d'emploi du script
		then
		echo "Usage : ./gestionnaire.sh [fichier]"
		echo "fichier est un fichier C++ existant ou pas, donné sans extension."
		echo
		nomFichier=-1

	elif test ! -f $1.cpp #Si le fichier n'existe pas
		then
		echo "Fichier Introuvable pour $1.cpp !"
		echo
		echo "Liste des fichiers C++ :"
		ls *.cpp #On affiche la liste des fichiers C++ existants
		echo
		echo "Entrez le nom d'un fichier (sans extension .cpp) :"
		read nomFichier #On demande de rentrer le nom du fichier que l'on souhaite traiter
	fi

else #Si le script est lancé sans parametre
	echo "Liste des fichiers C++ :"
	ls *.cpp #On affiche la liste des fichiers C++ existants
	echo
	echo "Entrez le nom d'un fichier (sans extension .cpp):"
	read nomFichier #On demande de rentrer le nom du fichier que l'on souhaite traiter
fi

if test -f "$nomFichier.cpp" #Si le fichier selectionné existe
	then
	Menu #On affiche le menu
	Selection #L'utilisateur peut choisir l'action a réaliser

elif test $nomFichier != -1 #Si le fichier n'existe pas et qu'il est different de -h et -H
	then
	echo "Ce fichier n'existe pas. Voulez-vous le créer ? [o/n]" #On expose le probleme
	read decision #On demande si on souhaite le creer ou non
	if test $decision = "o" || test $decision = "y" #Si la decision est de le creer
		then
		CréerNouveauFichier #On le creer
		Menu #On affiche le menu
		Selection #L'utilisateur peut choisir l'action a réaliser

	else
		echo "Le fichier n'a pas été créé." #On informe de la situation
	fi
fi
