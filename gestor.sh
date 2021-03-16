#!/bin/bash

#source ../bashsimplecurses/simple_curses.sh

#main (){
#	window "Esto es el gestor de Among Meme" "red"
#	append "¿Qué quieres hacer?"
#	endwin
#}

#main_loop

DEBUG="1"

#zenity
#dialog --title "Esto es el gestor de Among Meme" --default-item 1 \
#	--radiolist "¿Qué quieres hacer?" 0 0 6\
#	1 "Mostrar Personajes" off \
#	2 "Mostrar Inventario de un Personaje" off \
#	3 "Crear Personaje" off \
#	4 "Crear Item" off \
#	5 "Dar Item a Personaje" off \
#	6 "Salir" off


echo $?

echo "Esto es el gestor de Among Meme"
echo "==============================="

echo "¿Qué quieres hacer?"
echo "-------------------"

echo "1.- Mostrar Personajes"
echo "2.- Mostrar Inventario de un Personaje"
echo "3.- Crear Personaje"
echo "4.- Crear Item" 
echo "5.- Dar Item a Personaje" 
echo "6.- Actualizar Personaje"
echo "7.- Eliminar Personaje"
echo "Q.- Salir"

read INPUT

if [ "$INPUT" == "Q" ] || [ "$INPUT" == "q" ] || [ "$INPUT" == "" ]; then
	echo "Pos hasta luego"
	exit 0
fi


if [ "$INPUT" == "1" ]; then

	echo "Personajes:"

	echo "select id_character,name from characters" | mysql -u consultas amongmeme

elif [ "$INPUT" == "2" ]; then

	echo "Inventario"
	echo "=========="
	echo "¿De qué personaje quieres ver el inventario?"

	read INPUT

	if [ "$INPUT" == "" ]; then
		echo "Has de introducir algún valor"
		exit 1
	fi

	QUERY="select * from characters_items_summary where id_character=$INPUT" 
	echo $QUERY | mysql -u consultas amongmeme | cut -d $'\t' -f 4

elif [ "$INPUT" == "3" ]; then

	echo "Inserción de personaje"
	echo "======================"

	echo -n "Nombre: "
	read NOMBRE

	echo -n "Edad: "
	read EDAD

	echo -n "HP: "
	read HP

	echo -n "Género (1): "
	read GENDER

	echo -n "Style (1): "
	read STYLE

	echo -n "Mana: "
	read MANA
	
	echo -n "Clase (2): "
	read CLASS

	echo -n "Raza (2): "
	read RACE
	
	echo -n "XP: "
	read XP
	
	echo -n "Nivel: "
	read LEVEL
	
	echo -n "Altura: "
	read HEIGHT

	QUERY="INSERT INTO characters (name, age, hp, gender, style, mana, class,"
	QUERY="$QUERY race, xp, level, height)"
	QUERY="$QUERY VALUES ('$NOMBRE', $EDAD, $HP, '$GENDER', '$STYLE', $MANA, '$CLASS',"
	QUERY="$QUERY '$RACE', $XP, $LEVEL, $HEIGHT)"

	if [ "$DEBUG" == "1" ]; then
		echo $QUERY
	fi

	echo $QUERY | mysql -u gestor amongmeme

elif [ "$INPUT" == "5" ]; then
	echo "¿Qué personaje quieres usar? (id_character)"
	read ID_CHARACTER

	echo "¿Qué item quieres darle? (id_item)"
	read ID_ITEM

	QUERY="INSERT INTO characters_items (id_character, id_item) "
	QUERY="$QUERY VALUES($ID_CHARACTER, $ID_ITEM)";

	if [ "$DEBUG" == "1" ]; then
		echo $QUERY
	fi

	echo $QUERY | mysql -u gestor amongmeme

elif [ "$INPUT" == "6" ]; then

	echo "¿Qué personaje quieres actualizar? Introduce el nombre (o parte)"
	read NOMBRE

	LEN=`echo -n $NOMBRE | wc -c`

	if [ $LEN -lt 4 ]; then
		echo "Error en el largo del nombre: ha de ser igual o mayor que 4"	
		exit 1
	fi

	QUERY="SELECT id_character,name FROM characters WHERE name LIKE '%$NOMBRE%'"
	CHAR=`echo $QUERY | mysql -u gestor amongmeme | tail -n 1`

	if [ "$CHAR" == "" ]; then
		echo "ERROR: Nombre no encontrado"

		exit 4
	fi

	ID_CHAR=`echo $CHAR | cut -d " " -f 1`
	CHAR_NAME=`echo $CHAR | cut -d " " -f 2`

	echo "Nombre completo: $CHAR_NAME"
	echo -n "Introduce el nuevo nombre: "

	read NOMBRE

	if [ "$NOMBRE" == "" ]; then
		echo "ERROR: Debes introducir un nombre"

		exit 2
	fi

	if [ `echo -n $NOMBRE | wc -c` -lt 4 ]; then
		echo "ERROR: el nombre es más corto de 4 carácteres"

		exit 3
	fi

	QUERY="UPDATE characters SET name='$NOMBRE' WHERE id_character=$ID_CHAR"

	echo $QUERY | mysql -u gestor amongmeme

elif [ "$INPUT" == "7" ]; then

	echo "Introduce password de Admin"
	read -s PASS	

	echo "Introduce el nombre (o parte) del personaje a eliminar:"
	read NOMBRE

	LEN=`echo -n $NOMBRE | wc -c`

	if [ $LEN -lt 4 ]; then
		echo "Error en el largo del nombre: ha de ser igual o mayor que 4"	
		exit 1
	fi

	QUERY="SELECT id_character FROM characters WHERE name LIKE '%$NOMBRE%'"
	ID_CHAR=`echo $QUERY | mysql -u gestor amongmeme | tail -n 1`

	if [ "$ID_CHAR" == "" ]; then
		echo "No hay coincidencias"
		exit 3
	fi

	QUERY="DELETE FROM characters_items WHERE id_character=$ID_CHAR"
#	echo $QUERY
	echo $QUERY | mysql -u enti -p$PASS amongmeme

	QUERY="DELETE FROM characters WHERE id_character=$ID_CHAR"
#	echo $QUERY
	echo $QUERY | mysql -u enti -p$PASS amongmeme

else

	echo "Opción incorrecta"

fi
