#!/bin/bash

[ -z "$1" ] && echo "Napaka!" || pwd=$( mkpasswd -m sha-512 $1 )
useradd "beton" -c "Rudolf Eror" -p $pwd   && { echo "Uporabnik ustvarjen!" && exit 0; } || { echo "Napaka!" && exit 42;  }

