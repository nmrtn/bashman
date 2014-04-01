#! /bin/bash

. ./heap.sh

function initialisation(){ 		#initialisation du terminal
save = stty -g             		#sauvegarde de l'etat initial du terminal
tput clear				#effacement du terminal
tput civis				#enleve le clignotement du curseur
map=./map
highs=./highscore
boucle=0 
stty -icanon -echo time 1 min 0 	#mode sans echo, saisie automatique

HAUT=$(echo -e "\033[A\n")  		#affectation des variables pour la gestion du clavier
BAS=$(echo -e "\033[B\n")
GAUCHE=$(echo -e "\033[D\n")
DROITE=$(echo -e "\033[C\n")

dxm=-1
dym=0	 
}

function noschersvoisins () {
    local -i x="$1"
    local -i y="$2"
    
    voisins=()

    # à gauche
    if (( x > 0 )); then
        voisins[${#voisins[@]}]=$((y*width+(x-1)))
    fi
    # à droite
    if (( x < width )); then
        voisins[${#voisins[@]}]=$((y*width+(x+1)))
    fi
    # en haut
    if (( y > 0 )); then
        voisins[${#voisins[@]}]=$(((y-1)*width+x))
    fi
    # en bas
    if (( y < height )); then
        voisins[${#voisins[@]}]=$(((y+1)*width+x))
    fi
    # ces soirées là ... ♫ ♪ ♬ 
}

function googlemaps () {    # calcul le chemin le plus court du monstre
                            # vers le perso
                            # (note: l'auteur est devenu aveugle en relisant son code)
    local x="$1"
    local y="$2"
    local -i src=$((y*width+x))
    local -a visited=()
    local -a dist=()
    local -i maxdist=65535

    heap_init

    previous=()

    for (( vertex=0; vertex < width*height; vertex++ )); do
        if [[ ${maping:$vertex:1} -eq 1 ]]; then
            continue
        fi
        if (( vertex == src )); then
            (( d = 0 ))
        else
            (( d = $maxdist ))
        fi
        dist[$vertex]=$d
        heap_add $vertex $d
    done

    while true; do

        u=${heap_values[1]}

        if [[ -z "$u" ]]; then
            break
        fi

        heap_remove
        visited[$u]=1

        if (( dist[u] == maxdist )); then
            throw "Le perso n'est pas reachable"
        fi

        if (( u == (ym*width+xm) )); then
            break
        fi

        # mise à jour de la liste des voisins
        noschersvoisins $((u % width)) $((u / width))

        for v in "${voisins[@]}"; do
            if [[ ${maping:$v:1} -eq 1 ]] || ! [[ -z "${visited[$v]}" ]]; then
                continue
            fi
            if (((dist[u] + 1) < dist[v])); then
                ((dist[v] = dist[u] + 1))
                previous[v]=$u
                ((d=dist[v]))
                heap_add $v $d
            fi
        done
    done

    echo ${previous[$((ym*width+xm))]}
}

function throw () {
    # throw table
    echo "$1 (╯°□°）╯︵ ┻━┻ "
    exit 1
}

function affichemap () {
tmp=`cat map`

width=${tmp%%"#"*}
height=${tmp%"#"*}
height=${height:$((${#width}+1)):2}
xm=$((($width-2)))
ym=$((($height-2)))

if [ -f $map ] ; then
    maping=${tmp##*"#"}
else
    echo "Vous devez charger une map dans le fichier map du repertoire contenant bashman"
    sleep 3
    tput reset
    stty sane
    exit

fi

tmp=0
#for i in $(seq 0 $((($width*height)-1)));do #boucle d'affichage de la map
for ((i=$tmp;i<=$((($width*height)-1));i+=1)); do
var=${maping:$i:1} 

    if [ $var -eq 1 ] ; 		#si le caractere est un 1 on affiche un #
        then
	
	tput cup $((($i-($i%$width))/$width)) $(($i%$width)) #placement du curseur dans le tableau a 2 dimensions, gere par la position dans la chaine a une dimension
	
	tput setf 2	 
	#echo -e "\033[1m#\033[0m"
	echo "#"
    
    else 
     if [ $var -eq 2 ] ; 		#si le caractere est un 2, afficher le symbole d'un transporteur 
     then
      tput cup $((($i-($i%$width))/$width)) $(($i%$width)) 
      tput setaf 4
	#echo "¤"
	echo -e "\033[1m¤\033[0m"
     else 				#sinon afficher un point	     
     tput cup $((($i-($i%$width))/$width)) $(($i%$width))
     tput setaf 3
     echo "." 
     fi
    fi

done

compte_zero
}

function compte_zero () { 		#fonction comptant le nombre de zero dans la chaine maping permettant de compter les pointds
nbpoints=0
tmp=0

for ((i=$tmp;i<=$((($width*height)-1));i+=1)); do
    if [ ${maping:$i:1} -eq 0 ] ; then
    nbpoints=$(($nbpoints+1))

  
    fi
done
}



function affichepac () {

x=1
y=1
dx=0
dy=0
}

function transporteur (){ 			#fonction permettant de gerer la transportation mur a mur du bashman
tput cup $y $x
echo -n " "
if [ $dy -eq -1 ] || [ $dy -eq 1 ];	 	#gestion des mur horizontaux
        then
        yy=-1
       
	for ((i=$((((($height-($y+$dy))*$width)-$width)));i<=$((($height-($y+$dy))*$width-1));i+=1)); do
                if [ ${maping:$i:1} -eq 2 ]; then
                        x=$(($i%$width))
                        y=$(((($i-($i%$width))/$width+$dy)))
                        if [ $yy -eq -1 ]; then
                                xx=$x
                                yy=$y
                        else
                                if [ $RANDOM -ge 16384 ]; then #gestion aleatoire du point d'arrivee si il y a plusieurs teleporteur
                                        xx=$x
                                        yy=$y
                                fi
                        fi

                fi
        done
        x=$xx
        y=$(($yy-$dy))
	points
	y=$yy
        tput cup $y $x
        tput setaf 6

	echo "@"
fi


if [ $dx -eq -1 ] || [ $dx -eq 1 ]; 		#gestion des murs verticaux
        then
        yy=-1
tmp=0
       
	for ((i=$tmp;i<=$((height-1));i+=1)); do
                if [ ${maping:$(($i*$width-((($dx-1)/2)*($width-1)))):1} -eq 2 ]; then
                        x=$((1-((($dx-1)/2)*($width-3))))
                        y=$i
                        if [ $yy -eq -1 ]; then
                                xx=$x
                                yy=$y
                        else
                                if [ $RANDOM -ge 16384 ]; then #gestion aleatoire si plusieurs possibilites d'arrivee
                                        xx=$x
                                        yy=$y
                                fi
                        fi

                fi
        done
        x=$(($xx-$dx))
        y=$yy
	points
        x=$xx
	tput cup $y $x
        tput setaf 6
	echo "@"
	
fi
}


function points () { 			#cette fonction permet de savoir si le bashman est pass ou non a un point, elle transforme le 0 initial en 3 dans la chaine maping
if [ ${maping:$(((($y+$dy)*$width)+($x+$dx))):1} -eq 0 ] ; then
    maping=${maping::$((((($y+$dy)*$width)+$x+$dx)))}"3"${maping:$(((($y+$dy)*$width)+$x+$dx+1)):$((($width*$height)-1))}
    nbpoints=$(($nbpoints-1))
fi

tput cup 40 0
tput setaf 7
echo -n "Vous devez encore attraper $(($nbpoints)) points "
}							

function boucle_jeu() { 		#fonction principale du script; elle gere la boucle du jeu
while [ $boucle -eq 0 ] ; do
    read
    case "$REPLY" in
	    
	$HAUT | u ) dx=0 ; dy=-1;;      #gestion des deplacements clavier
	$BAS | n ) dx=0 ; dy=1 ;;	
	$GAUCHE | h ) dx=-1 ; dy=0 ;;
	$DROITE | j ) dx=1 ; dy=0 ;;
	
	q)  stty $save                  #lorsque l'on quitte, on rend le terminal dans un etat propre
	    stty sane
	    tput reset
	    clear
	    exit
	    ;;
		
	* ) ;;
	    
    esac
	   

    
if [ ${maping:$(((($y+$dy)*$width)+($x+$dx))):1} -eq 0 ] ; then #si la future position du perso n'est pas un mur et est un point,alors, on le deplace	   
    
    points
    tput cup $y $x 
    echo -n " "
    x=$(($x+$dx))
    y=$(($y+$dy))
    tput cup $y $x
    tput setaf 6
    echo -n "@"

	    
    


elif [ ${maping:$(((($y+$dy)*$width)+($x+$dx))):1} -eq 3 ] ; then  #si la future position ,n'est pas un point et n'est pas un mur, alors on le deplace
    tput cup $y $x
    echo -n " "
    x=$(($x+$dx))
    y=$(($y+$dy))
    tput cup $y $x
    tput setaf 6
    echo -n "@"
										

elif [ ${maping:$(((($y+$dy)*$width)+($x+$dx))):1} -eq 2 ] ; then #si la futur position se refere a un transporteur

    transporteur			#on apelle la fonction gerant les deplacements du aux transporteurs

fi

monstre
done 
}


function highscore () { 		#Cette fonction permet d'enregister le score que l'on avait en perdant (se faisant toucher par le monstre)
					#et l'enregistre dans le fichier highscore

    tput reset
    stty $save
    stty sane
    clear 
    tput cup 40 0
    echo  " Vous avez perdu, il vous restait $nbpoints a attraper"
    echo " Quel est votre nom ?? "
    read nom 
    if [ $nbpoints -lt 100 ] ; then
	nbpoints="0"$nbpoints
    fi 
    echo $nbpoints $nom "|" >> $highs
    echo "score enregistre dans le fichier highscore"
    sleep 1
    exit
    
}

function monstre () { 			#cette fonction gere les deplacement "intelligents" du monstre

if [ $y -eq $ym ] ; then     		#si la position du perso est egale a la position du monstre		
    if [ $x -eq $xm ] ; then
	clear 				#effacement de la carte
	highscore			
	boucle=1			#sortie de la boucle jeu
    fi
fi
 

#deplacement du monstre  

    vm=$(googlemaps $x $y)

	tput cup $ym $xm 
	tput setaf 3
	if [ ${maping:$(((($ym)*$width)+($xm))):1} -eq 0 ] ; then #si le caractere sous le monstre est un points
	echo -n "." 			#on reecrit un point, car le monstre ne mange pas les points
	fi
	if [ ${maping:$(((($ym)*$width)+($xm))):1} -eq 3 ] ; then #sinon
	echo -n " "			#on laisse l'espace
	fi

    ((xm = vm % width))
    ((ym = vm / width))
	
	tput cup $ym $xm
	tput setaf 5
	echo -n "$"
	    
	

 	
}

function presentation () { 		#Cette fonction est la fonction gerant la presentation du jeu
clear
tput setaf 4

echo '  ____________________________________________________________    '
echo '  |     \/    \  /     \|  | |  ||   \ /   |  /    \ |   \ | |   '
echo '  |  D  /  /\  \ \  \__/|  |_|  || |\ V /| | /  /\  \| |\ \| |   '
echo '  |  D  \_      \/\__  \|   _   || | \_/ | |/        | | \   |   '
echo '  |______/__/\___\_____/|__| |__||_|     |_|___/\____|_|  \__|   '  
echo '                                                                 ' 
echo '                 2004                        '
echo -e '              MARTIN NICOLAS et DALLE AURELIEN                   \n\n\n'


tput setaf 2


echo -e " MENU : \n\n\n"
echo " 1. Jouer a bashman "
echo " 2. Voir le fichier Highscore "
echo " q. Quitter "

echo -n "          "
  
                                    
read choix




case "$choix" in 
    1) ;;
    2)  tput reset
    clear
    echo `sort highscore`
    echo -e '\n\n\n\n\n\n'
    echo "Appuyer sur n'importe quelle touche pour revenir au menu principal"    
    read 
    presentation ;;
    
    q) boucle=1;
    tput reset 
    clear
    exit ;;


esac 
             
tput reset
clear
}
#programme principal
presentation
menu
initialisation
clear
affichemap
affichepac
boucle_jeu

}
