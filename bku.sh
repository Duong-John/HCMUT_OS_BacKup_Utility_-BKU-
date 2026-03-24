GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
YELLOW='\033[0;33m'
already_exsit(){
	string="$1"
	file=".bku/tracked_files"
	if [[ "$string" != "bku.sh" ]] && [[ "$string" != "setup.sh" ]] && [[ "$string" != "tracked_files" ]] && [[ "$string" != "history.log" ]]
		then

			if [[ $(grep -c "$string" $file) -gt 0 ]]
				then
					echo -e "${RED}Error: $string is already tracked${NC}"
					return
				fi
			echo -e "${GREEN}Added $string to backup tracking${NC}" 
			echo "$string" >> "$file"
			
			echo "$(date +"%H:%M-%Y/%m/%d"): Added $string to .bku" >> ".bku/history.log"
			filename=$(basename "$string") #basename, it is to get only the name dub :)
			dir_path=$(dirname "$string")

			if [[ "$dir_path" == "." ]]
				then
					cp "$string" ".bku/$filename"
			else
				mkdir -p ".bku/$dir_path"
				cp "$string" ".bku/$string"
			fi
			# # echo "Test: dir_path: $dir_path"
			# mkdir -p "$dir_path"
			# # cp "$string" ".bku/$filename" #copy from src/main.c -> .bku/main.c
			# cp "$string" ".bku/$filename"
			# #echo $(cat ".bku/$filename")
	else
		echo -e "${YELLOW}Note: automatically skip $string found in main folder${NC}"
	fi
}
check_status(){
    	found1="$1"
		found2=0
    	
    	file_found1=$(basename "$found1")
		dir_path=$(dirname "$found1")

    	# found2=".bku/$file_found1"
		if [[ "$dir_path" == "." ]]
			then
      			found2=".bku/$file_found1"
		else
			found2=".bku/$found1"
		fi

    	if [[ -f "$found2" ]]; then
        	if diff "$found1" "$found2" > /dev/null; then
            		echo "$found1: No changes"  
        	else
                        echo "$found1 :"
                        difference=$(diff --unchanged-group-format='%=' --changed-group-format="${BLUE}+%>${NC}" "$found2" "$found1") #This is the syntax, ">" mean found1 :)
            		echo -e "$difference"  
        fi
    	else
        	echo -e "${RED}$file_found1 is not tracked${NC}"  
    	fi
}
commit_change(){
    file_history=".bku/history.log"
	commit_text="$1"
	filename="$2"
	bku_file=$(basename "$filename")
	dir_path=$(dirname "$filename")

	# echo "Test: dir_path: $dir_path"

	if diff "$filename" ".bku/$filename" > /dev/null
 		then
 			echo -e "${RED}Error: $filename has no change to commit${NC}"
 			
 	else
 			# # name_create=${bku_file%.c}
 			# touch ".bku/store/$filename"
 			# echo $(cat ".bku/$bku_file") > ".bku/store/$filename"
 			# cp "$filename" ".bku/$bku_file"
			# # mv "$name_create.txt" ".bku/store"
			if [[ "$dir_path" == "." ]]
				then
					cp ".bku/$filename" ".bku/store/$filename"
					cp "$filename" ".bku/$filename"
			else
				mkdir -p ".bku/store/$dir_path"
				cp ".bku/$filename" ".bku/store/$filename"
				cp "$filename" ".bku/$filename"
			fi
 				
 			current_time=$(date +"%H:%M-%Y/%m/%d")
 			string="Committed $filename with ID $current_time"	
 			echo -e "${GREEN}$string${NC}"
 			history_string="$current_time: $commit_text ($filename)" 
 			#echo "$history_string"
 			echo "$history_string" >> "$file_history"
 	fi
}
restore(){
	filename="$1"
	txt_name=0
	bku_file=$(basename "$filename")
	dir_path=$(dirname "$filename")
	bku_path=0
	# name_create=${bku_file%.c}
	# txt_name=".bku/store/$name_create.txt"
	if [[ "$dir_path" == "." ]]
		then
			txt_name=".bku/store/$bku_file"
			bku_path=".bku/$bku_file"
	else
		txt_name=".bku/store/$filename"
		bku_path=".bku/$filename"
	fi

	#echo $(cat "$txt_name")

	
	if [[ -f "$txt_name" ]]
		then
			if diff "$txt_name" "$bku_path" > /dev/null
				then
					echo -e "${RED}Error: $filename has no file to be restored.${NC}"
			else
				
				# echo $(cat "$txt_name") > "$filename"
				# echo $(cat "$txt_name") > ".bku/$bku_file"
				# #echo $(cat "$filename") > "$txt_name"

				cp "$txt_name" "$filename"
				cp "$txt_name" "$bku_path"
				
				echo "$(date +"%H:%M-%Y/%m/%d"): Restored $filename to its previous version" >> ".bku/history.log"
				
				echo -e "${GREEN}Restored $filename to its previous version${NC}"
			fi
	else
		echo -e "${RED}Error: No previous version available for $filename${NC}"
	fi
}
if [[ $1 == "init" ]]
	then
		if [[ ! -d .bku ]] 
			then
				mkdir .bku
				mkdir .bku/store
				touch .bku/tracked_files
				touch .bku/history.log
				# touch .bku/crontab_log.log
				echo "$(date +"%H:%M-%Y/%m/%d"): BKU Init" >> ".bku/history.log"
				echo -e "${GREEN}Backup initialized${NC}"
		else
				echo -e "${RED}Error: Backup already initialized in this folder${NC}"
		fi
elif [[ $1 == "add" ]]
	then
 		filename="$2"
		if [[ ! -d .bku ]] 
			then
				echo -e "${RED}Error: No backup file initialization yet.${NC}"
			
 		elif [[ -n "$filename" ]]
 			then
 				found="$(find . -type f -wholename "./$filename" -print)"
 					if [[ -n "$found" ]]
 						then
							# if [[ "$filename" != "bku.sh" ]] && [[ "$filename" != "setup.sh" ]]
								# then
 						        	already_exsit "$filename"
								# fi
 					else
 						echo -e "${RED}Error: $filename does not exist${NC}"
 					fi
 		else
 			found="$(find . -type d -name ".bku" -prune -o -type f -print)"
 			if [[ -n "$found" ]]
 				then
 					IFS=$'\n'
 					for files in $found
 						do
 							file_s=${files#./}
 							#echo "$file_s"
							# if [[ "$file_s" != "bku.sh" ]] && [[ "$file_s" != "setup.sh" ]]
							# 	then
 						        	already_exsit "$file_s"
								# fi
 						done
 				fi
 		fi
elif [[ $1 == "status" ]]
	then
		# check_empty="$(find .bku -type f -name "*.c" -print)"
		check_empty="$(find .bku -type f -name "*" -print)"
		if [[ ! -d .bku ]] 
			then
				echo -e "${RED}Error: No backup file initialization yet.${NC}"
		elif [[ -z "$check_empty" ]]
			then
				echo -e "${RED}Error: Nothing has been tracked${NC}"
			fi
 		filename="$2"
 		if [[ -n "$filename" ]]
 			then
 				found1="$(find . -type f -wholename "./$filename" -print)"
 					if [[ -n "$found1" ]]
 						then
							
 									check_status "$found1"		
										                        
 					else
 						echo -e "${RED}Error: $filename isn't tracked yet${NC}"
 					fi
 		else
 			found="$(find . -type d -name ".bku" -prune -o -type f -print)"
 			if [[ -n "$found" ]]
 				then
 					IFS=$'\n'
 					for files in $found
 						do
						
 						        	check_status "$files"
								
 						done
 			else
 				echo -e "${RED}No file has been tracked${NC}"
 			fi
 		fi
elif [[ $1 == "commit" ]]
	then
	 	
		commit_text="$2"
		if [[ ! -d .bku ]] 
			then
				echo -e "${RED}Error: No backup file initialization yet.${NC}"
		elif [[ -z "$commit_text" ]]
			then
				echo -e "${RED}Error: Commit message is required.${NC}"
			fi
		filename="$3"
		if [[ -n "$filename" ]]
 			then
 				file_found=$(basename "$filename")
     				# found=".bku/$file_found"
					found=".bku/$filename"
 					if [[ -n "$found" ]]
 						then
 							commit_change "$commit_text" "$filename"
 					else
 						echo -e "${RED}Error: No added file similiar to this one to commit${NC}" 
 					fi
 		else
 			# get_all_file="$(find .bku -path .bku/store -prune -o -type f -name "*.c" -print)"
			get_all_file="$(find .bku -path .bku/store -prune -o -type f -name "*" -print)"
 			if [[ -n "$get_all_file" ]]
 				then
 					IFS=$'\n'
 					for files in $get_all_file
 						do
							file=".bku/tracked_files"  
							# file_s=$(basename "$files")
							file_s="${files#.bku/}"
							# found_path=$(grep ".*$file_s" "$file" | sed -E 's/(.*)/\1/')
							found_path=$(grep -Fx "$file_s" "$file")
							if [[ -n "$found_path" ]]
								then
									commit_change "$commit_text" "$found_path"
								fi
 						done
 			else
 				echo -e "${RED}Error: No change to commit${NC}"
 				
 			fi
 		fi
 		
elif [[ $1 == "history" ]]
	then
		if [[ ! -d .bku ]] 
			then
				echo -e "${RED}Error: No backup file initialization yet.${NC}"
		else
			file_history=".bku/history.log"
			# echo "$(date +"%H:%M-%Y/%m/%d"): BKU Init" >> "$file_history"
			# echo $(cat "$file_history")  
			while IFS= read -r line; do
				echo "$line"
			done < $file_history
				
		fi
		
elif [[ $1 == "restore" ]]
	then
 		filename="$2"
		if [[ ! -d .bku ]] 
			then
				echo -e "${RED}Error: No backup file initialization yet.${NC}"
 		elif [[ -n "$filename" ]]
 			then
 				found="$(find . -type f -wholename "./$filename" -print)"
 					if [[ -n "$found" ]]
 						then 
 						        restore "$filename"
 					else
 						echo -e "${RED}Error: No file to be restored${NC}"
 					fi
 		else
 			# get_all_file="$(find .bku -path .bku/store -prune -o -type f -name "*.c" -print)"
			get_all_file="$(find .bku -path .bku/store -prune -o -type f -name "*" -print)"
 			if [[ -n "$get_all_file" ]]
 				then
 					IFS=$'\n'
 					for files in $get_all_file
 						do
							file=".bku/tracked_files"  
							file_s="${files#.bku/}"
							found_path=$(grep -Fx "$file_s" "$file")
							if [[ -n "$found_path" ]]
								then
 						        	restore "$found_path"
								fi
 						done
 			else
 				echo -e "${RED}Error: No file to be restored${NC}"
 				
 			fi
 		fi
elif [[ $1 == "schedule" ]]
	then
		input="$2"
		input_min="$3"
		MIN=1
		MAX=59
		if [[ ! -d .bku ]] 
			then
				echo -e "${RED}Error: No backup file initialization yet.${NC}"
		elif [[ -z "$input" ]]
			then
				echo "------------------------------------------------------"
				echo "| --daily                                            |"
				echo "| --weekly                                           |"
				echo "| --yearly                                           |"
				echo "| --off                                              |"
				echo "| --minute <number of minute>, Ex: --minute 5 |"
				echo "------------------------------------------------------"
		elif [[ "$input" == "--minute" ]] && [[ -z "$input_min" ]];
			then
				echo "------------------------------------------------------"
				echo "| --minute <number period of minute>, Ex: --minute 5 |"
				echo "------------------------------------------------------"
		elif [[ "$input" == "--minute" ]] && [[ -n "$input_min" ]] && ([[ !("$input_min" =~ ^[0-9]+$) ]] || [[ "$input_min" -gt "$MAX" ]] || [[ "$input_min" -lt "$MIN" ]]);
			then
				echo -e "${RED}Error: Input must be a number, and the number must be in range of [1-59].${NC}"
				
		else
			text="$0 commit \"Scheduled backup\""
			case "$input" in
				"--minute") echo "*/$input_min * * * * $text" | crontab -
						# "$0" commit "Scheduled backup" 
						echo -e "${GREEN}Scheduled backups every $input_min minute(s)${NC}"
				;;
				"--daily") 	echo "0 0 * * * $text" | crontab -
						# "$0" commit "Scheduled backup" 
						echo -e "${GREEN}Scheduled daily backups at daily${NC}"
				;;
				"--hourly") 	echo "0 * * * * $text" | crontab -
						# "$0" commit "Scheduled backup" 
						echo -e "${GREEN}Scheduled hourly backups at daily${NC}"
				;;
				"--weekly") 	echo "0 0 * * 1 $text" | crontab -
						# "$0" commit "Scheduled backup" 
						
						echo -e "${GREEN}Scheduled weekly backups at daily${NC}"
				;;
				"--off") 	string=$(crontab -l)
						if [[ -n "$string" ]]; then 
							crontab -r
						fi
						echo -e "${GREEN}Backup scheduling disabled${NC}"
				;;
			esac
		fi
elif [[ $1 == "stop" ]]
	then
		if [[ ! -d .bku ]] 
			then
				echo -e "${RED}Error: No backup file initialization yet.${NC}"
		else
			"$0" schedule --off > /dev/null
			if [[ -d ".bku" ]]
				then
					rm -r ".bku" > /dev/null
					# rm -d ".bku" > /dev/null
					echo -e "${GREEN}Backup system removed${NC}"
			else
				echo -e "${RED}Error: No backup system to be removed${NC}"
			fi
		fi
		
else
	echo "These are the action use the system:"
	echo "--------------------------------------------------------------------------------------------------------"
	echo "| init                                | start the system.                                              |"   
	echo "| add <filename>                      | include the file to prepare to save.                           |"
	echo "| add                                 | include all of the files.                                      |"
	echo "| status                              | check if there is any file in the backup save.                 |"
	echo "| status <filename>                   | track the status, changes of the file.                         |"
	echo "| commit <commit_message> <filename>  | to add the message of the commit, and make changes of the file.|"
	echo "| commit <commit_message>             | to commit all.                                                 |"
	echo "| history                             | to view the history of commitment.                             |"
	echo "| restore <filename>                  | to undo changes commited to the file.                          |"
	echo "| restore                             | to reverse changes made to all files.                          |"
	echo "| schedule                            | create a schedule to automactically make save.                 |"
	echo "|         --daily                     |                                                                |"
	echo "|         --weekly                    |                                                                |"
	echo "|         --yearly                    |                                                                |"
	echo "|         --off                       |                                                                |"
	echo "| stop                                | stop the schedule and the system. Remove the installed system. |" 
	echo "--------------------------------------------------------------------------------------------------------"
fi

