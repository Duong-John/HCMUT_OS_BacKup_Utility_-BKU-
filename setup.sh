	# cp bku.sh bku
	# chmod +x bku
	# sudo cp bku /usr/local/bin
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
create_now(){
	cp bku.sh bku
	chmod +x bku
	sudo cp bku /usr/local/bin
	# sudo chmod +x bku
	rm bku
}
install_or_not="$1"
if [[ "$install_or_not" == "--install" ]]
	then
		dependencies=("diff" "cron" "grep" "sed" "find" "mkdir")
		echo "Checking dependencies..."
		for stuff in "${dependencies[@]}"
			do
				if ! command -v "$stuff"
					then
						echo -e "${RED}Error: Failed to install packages. Please check your package manager or install them manually${NC}"
						break
					fi
			done
		echo -e "${GREEN}All dependencies installed${NC}"
		create_now
                echo -e "${GREEN}BKU installed to /usr/local/bin/bku${NC}"
                
elif [[ "$install_or_not" == "--uninstall" ]]
	then
		echo "Checking BKU uninstallation..."
		if [[ -f "/usr/local/bin/bku" ]]
			then
				bku stop
				sudo rm -f /usr/local/bin/bku
				echo "Removing BKU from /usr/local/bin/bku..."
				echo "Removing scheduled backups..."
				echo -e "${GREEN}BKU successfully uninstalled${NC}"
		else
			echo -e "${RED}Error: BKU is not installed in /usr/local/bin/bku${NC}"
			echo "Nothing to uninstall"
		fi


else
	echo "These are the action to set up the system:"
	echo "---------------------------------------------------------------"
	echo "| --install   | check dependecies and install the BKU system. |"   
	echo "| --uninstall | to uninstall the system.                      |"
	echo "---------------------------------------------------------------"
fi
