# EvilShell

>EvilShell its a bash script that simplifies the creation of reverse shells

![image](https://user-images.githubusercontent.com/103772333/205136655-51710b32-be2a-452b-a05d-13bad06f146a.png)

## Instalation


`git clone https://github.com/whitexnd/EvilShell`

## Usage

> By default takes the ip from the iface tun0 and the port 443

`You can specify the ip with -i and the port with -p
also you can select the shell with -s parameter`

> If u want to encode the payload u can use

`-p <encoder>`
Current encoders are b64 (base64) and url

## Optional

I suggest you to add it into your $PATH with the following commands:
- `chmod +x evilshell.sh`

- `sudo mv evilshell.sh /bin/evilshell`

Then u can use it like this:
- `evilshell -s python`







