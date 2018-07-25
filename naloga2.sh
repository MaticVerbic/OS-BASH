#!/bin/bash

#rdy
[ -f /tmp/userstemporarystorage.txt ] && rm /tmp/userstemporarystorage.txt
[ -f /tmp/output.txt ] && rm /tmp/output.txt

sort "$1" -t ";" -k 2,2 -k 3,3 -o /tmp/output.txt
clean() {
        cleaned=$1
        cleaned=${cleaned//č/c}
        cleaned=${cleaned//Č/C}
        cleaned=${cleaned//ć/c}
        cleaned=${cleaned//Ć/C}
        cleaned=${cleaned//đ/d}
        cleaned=${cleaned//Đ/D}
        cleaned=${cleaned//š/s}
        cleaned=${cleaned//Š/S}
        cleaned=${cleaned//ž/z}
        cleaned=${cleaned//Ž/Z}

        echo "$cleaned"
}
olduser=""
count=2
while read line; do
	vpisna=$(cut -d ';' -f1 <<< $line)
	ime=$(cut -d ';' -f2 <<< $line)
	brezime=$(clean $ime)
	priimek=$(cut -d ';' -f3 <<< $line)
	brezPriimek=$(clean $priimek)
	username=${brezime:0:8}${brezPriimek:0:1}
	username=$(echo "$username" | tr '[:upper:]' '[:lower:]')
	if [ "$olduser" = "$username" ]; then
		 username="$username$count" 
		 count=$((count+1)) 
	else
		olduser=$username
		count=2
	fi
	#geslo
	geslo=$(mkpasswd -m sha-512 $vpisna -s "12345678")

	#username
	#get substring
	echo "$vpisna;$ime $priimek;$username;$geslo" >> /tmp/userstemporarystorage.txt
done < "/tmp/output.txt"

cat /tmp/userstemporarystorage.txt
