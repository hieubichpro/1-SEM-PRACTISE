#!/bin/bash

#проверка на запуск от имени админстратора
if [ "$EUID" -eq 0 ]; then
	echo "запуск от имени администратора"
	echo -n "вы хотите продолжить? (y/n): "
	read -r ans
	if [ "$ans" == "n" ]; then
		exit 1
	fi
fi

# возвращаются значение temp_file, work_file ,w_dir, cmline
take_var () {
	temp=$(grep 'temp_file' "$ST"/.myconfig)
	temp_file=( )
	IFS=" "
	for i in $temp; do
		if ! [[ $i == "temp_file=" ]]; then
			temp_file+=( "$i" )
		fi
	done
	work=$(grep "work_file" "$ST"/.myconfig)
	work_file=( )
	IFS=" "
	for i in $work; do
		if ! [[ $i == "work_file=" ]]; then
			work_file+=( "$i" )
		fi
	done
	cmline=$(grep "^commanda" "$ST"/.myconfig)
	IFS=":"
	for i in $cmline; do
		if ! [[ $i == "commanda" ]]; then
			com=$i
		fi
	done
	
	x=$(grep "working_dir" "$ST"/.myconfig)
	IFS="="
	for i in $x; do
		if ! [[ $x == "working_dir" ]]; then
			w_dir=$i
		fi
	done
	
}


# печатка меню
menu () {
echo
take_var
echo -e "temp_file= ""${temp_file[@]}""\nwork_file= ""${work_file[@]}""\nworking_dir=""$w_dir""\ncommanda:""$com"
echo
echo 1. просмотреть список расширений временных файлов.
echo 2. задать заново список расширений временных файлов.
echo 3. добавлять конкретное расширение временных файлов.
echo 4. удалять конкретное расширение из списка расширений временных файлов.
echo 5. просмотреть список расширений рабочих файлов.
echo 6. задать заново список расширений рабочих файлов.
echo 7. добавлять конкретное расширение рабочих файлов.
echo 8. удалять конкретное расширение из списка расширений рабочих файлов.
echo 9. просмотреть рабочую папку скрипта
echo 10. задать заново рабочую папку скрипта
echo 11. удалить временные файлы
echo 12. просмотреть записанную команду
echo 13. выполнить записанную команду.
echo 14.  изменить записанную команду.
echo 15. просмотреть все строки, ограниченные апострофами, во всех рабочих файлах.
echo 16. просмотреть объём каждого временного файла
echo 0. Завершить
}



# Обновление(перезапись) файла .myconfig
update_file () {
	echo -e "temp_file= ""${temp_file[@]}""\nwork_file= ""${work_file[@]}""\nworking_dir=""$w_dir""\ncommanda:""$com" > .myconfig
}

# проверка, сущесвует ли файл .myconfig
if  ! [[ -e ./.myconfig ]]; then
	touch .myconfig
	temp_file=( .log )
	work_file=( .py )
	w_dir=$(pwd)
	ST=$w_dir
	com="grep def* program.py"
	update_file
fi


# проверяет правилный ли выбор
check_choice () {
	menu
    echo -n "какой выбор:  "
	read -r c
	while ! [[ $c -ge 0 && $c -le 16 ]]; do
		echo -n "выбор должен быть от 0 до 9:  "
		read -r c
done
}

# просмотреть список расширений временных файлов
view_temp_files () {
	take_var
	echo "${temp_file[@]}"
}

# задать заново список расширений временных файлов
new_temp_files () {
	take_var
	temp_file=( "$REPLY" )
	update_file
}

# добавлять конкретное расширение временных файлов
add_tfile () {
	take_var
	temp_file+=( "$REPLY" )
	update_file
}

# удалять конкретное расширение из спискарасширений временных файлов
remove_tfile () {
	take_var
	num=$((REPLY-1))
	temp_file[num]=""	
	update_file
}

# просмотреть список расширений рабочих файлов
view_work_files () {
	take_var
	echo "${work_file[@]}"
}

# задать заново список расширений рабочих файлов
new_work_files () {
	take_var
	work_file=( "$REPLY" )
	update_file
}

# добавлять конкретное расширение рабочих файлов.
add_wfile () {
	take_var
	work_file+=( "$REPLY" )
	update_file
}

# удалять конкретное расширение из списка расширений рабочих файлов.
remove_wfile () {
	take_var
	num=$((REPLY-1))
	work_file[num]=""	
	update_file
}

# просмотреть рабочую папку скрипта.
view_working_dir () {
	take_var
	echo "$w_dir"
	check_config
}

# задать заново рабочую папку скрипта.
new_working_dir () {
	take_var
	w_dir=$REPLY
	echo "$w_dir"
	if ! [[ -e $w_dir && -d $w_dir ]]; then
		echo "введите неверно!. Введите например ./Documents/ : "
	else
		cd "$w_dir"
		update_file 2> /dev/null
	fi
}


#  удалить временные файлы.
remove_tempfilie () {
	take_var
	rm -rf "$REPLY"
	update_file			
}

# просмотреть записанную команду
view_cmd () {
	take_var
	echo "$com"	
}

# выполнить записанную команду
executecmd () {
	take_var
	echo "$com" > execfile
	chmod +x execfile
	./execfile 2> /dev/null
	rm execfile
}

# изменить записанную команду
changecmd () {
	take_var
	com=$REPLY		
	update_file
}

# просмотреть все строки, ограниченные апострофами, во всех рабочих файлах.
find_strings () {
	take_var
	for extension in "${work_file[@]}"; do
		for file in "$w_dir"/*; do
			if echo "$file" | grep -q "$extension$"; then
				less "$file" | grep -o "'.*'"
			fi
		done
	done
}

# просмотреть объём каждого временного файла 
view_size () {
	take_var
	for extension in "${temp_file[@]}"; do
		for file in "$w_dir"/*; do
			if echo "$file" | grep -q "$extension$"; then
				echo  "$(less "$file" | wc -c)  $file"
			fi
		done
	done
}


if [ $# -eq 0 ]; then
	check_choice
	while true; do
		if [ "$c" -eq 1 ]; then
			view_temp_files
			check_choice
		elif [ "$c" -eq 2 ]; then
			read -r -p "введите новые расширения через пробел( пример .log .dat .bin ): "
			new_temp_files
			check_choice
		elif [ "$c" -eq 3 ]; then
			read -r -p "введите новое расширение (пример .log): "
			add_tfile
			check_choice
		elif [ "$c" -eq 4 ]; then
			take_var
			count=1
			for file in "${temp_file[@]}"; do
				echo "$count$file"
				count=$((count+1))
			done
			read -r -p "введите номер, который необходимо удалить: "
			remove_tfile
			check_choice
		elif [ "$c" -eq 5 ]; then
			view_work_files
			check_choice
		elif [ "$c" -eq 6 ]; then
			read -r -p "введите новые расширения через пробел( пример .py .cpp .txt ): "
			new_work_files
			check_choice
		elif [ "$c" -eq 7 ]; then
			read -r -p "введите новое расширение (пример .log): "
			add_wfile
			check_choice
		elif [ "$c" -eq 8 ]; then
			take_var
			count=1
			for file in "${work_file[@]}"; do
				echo "$count$file"
				count=$((count+1))
			done
			read -r -p "введите номер, который необходимо удалить: "
			remove_wfile
			check_choice
		elif [ "$c" -eq 9 ]; then
			view_working_dir
			check_choice
		elif [ "$c" -eq 10 ]; then
			read -r -p "введите новую рабочую папку(например /): "
			new_working_dir
			check_choice
		elif [ "$c" -eq 11 ]; then
			take_var
			count=1
			for extension in "${temp_file[@]}"; do
				for file in "$w_dir"/*; do
					if echo "$file" | grep -q "$extension$"; then
						echo "$file"
						count=$((count+1))
					fi
				done
			done
			read -r -p "введите название файла для удаления:(например aa.log, *.log): "
			remove_tempfilie
			check_choice
		elif [ "$c" -eq 12 ]; then
			view_cmd
			check_choice
		elif [ "$c" -eq 13 ]; then
			executecmd
			check_choice
		elif [ "$c" -eq 14 ]; then
			read -r -p "введите новую команду: "
			changecmd
			check_choice
		elif [ "$c" -eq 15 ]; then
			find_strings
			check_choice
		elif [ "$c" -eq 16 ]; then
			view_size
			check_choice
		else
			exit

		fi
	done
else
	if [ "$1" -eq 1 ]; then
		view_temp_files
	elif [ "$1" -eq 2 ]; then
		REPLY=$2
		new_temp_files
	elif [ "$1" -eq 3 ]; then
		REPLY=$2
		add_tfile
	elif [ "$1" -eq 4 ]; then
		REPLY=$2
		remove_tfile
	elif [ "$1" -eq 5 ]; then
		view_work_files
	elif [ "$1" -eq 6 ]; then
		REPLY=$2
		new_work_files
	elif [ "$1" -eq 7 ]; then
		REPLY=$2
		add_wfile
	elif [ "$1" -eq 8 ]; then
		REPLY=$2
		remove_wfile
	elif [ "$1" -eq 9 ]; then
		view_working_dir
	elif [ "$1" -eq 10 ]; then
		REPLY=$2
		new_working_dir
	elif [ "$1" -eq 11 ]; then
		REPLY=$2
		remove_tempfilie
	elif [ "$1" -eq 12 ]; then
		view_cmd
	elif [ "$1" -eq 13 ]; then
		executecmd
	elif [ "$1" -eq 14 ]; then
		REPLY=$2
		changecmd
	elif [ "$1" -eq 15 ]; then
		find_strings
	elif [ "$1" -eq 16 ]; then
		view_size
	fi
fi
