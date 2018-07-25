#!/bin/bash

[ "$#" -le 1 ] && echo "Not enough arguments were given"

[ ! -p $1 ] &&  mkfifo $1

[ -f $2 ] && rm $2 && touch $2 || touch $2

declare -A ukazi
mypid=$$
#echo "$mypid"

function run {

	local command=$3
	local counter=0
	local interval=$2
	local target=$1
	local children=""
	local log=0
	trap 'log=1' SIGUSR1
	while true; do
	#	if [ $(pgrep -xfc "$command") -lt $target ]; then
	if [ $(pgrep -xfc -g "$$" "$command") -lt $target ]; then
			#eval $3 &
			$3 &
			children="$children $!"
			local counter=$((counter+1))
		fi
		sleep $interval
		local counter=0
	done

}


last=""
while true; do
	if read line < $1; then
		validate=$(echo "${line}" | awk -F: '{print NF-1}')
		if [ -z "$validate" -o "$validate" = "3" ];then
			if [[ "$line" =~ ^run:[0-9]+:[0-9.]+:.+$ ]]; then
				metaCom=$(cut -d ":" -f 1 <<< "$line")
	        	        targetNum=$(cut -d ":" -f 2 <<< "$line")
	               		interval=$(cut -d ":" -f 3 <<< "$line")
	                	command=$(cut -d ":" -f 4 <<< "$line")
				splCm=$(cut -d " " -f 1 <<< "$command")
				if [ "$command" = "" ]; then
					continue
				
				elif  [ ! -x "$(command -v ${splCm})" ]; then
	#			if [[ "$line" =~ ^run:[0-9]+:[0-9.]+:.+$ ]]; then
					>&2 echo "Command not runnable: $splCm"
					continue
				fi
	               		[ "$metaCom" = "run" ] || echo "Unknown command, it should be run" 
#				echo "metaCom: $metaCom, targetNum: $targetNum, interval: $interval, command: $command"
				run "$targetNum" "$interval" "$command" &
				ukazi["$command"]=$!
				last="$command"
			else
				>&2 echo "Command not runnable: $splCm"
				continue
			fi
		elif [ -z "$validate" -o "$validate" = "1" ];then
                        metaCom=$(cut -d ":" -f 1 <<< "$line")
                        command=$(cut -d ":" -f 2 <<< "$line")
			someval=${ukazi[$command]}
			[ "$metaCom" != "stop" ] &&  echo "Unknown command, should be stop" && continue || echo "metaCom: $metaCom, command: $command"
			if [ "$metaCom" = "stop" ]; then
				kill "$someval" > /dev/null
				wait "$someval" 2>/dev/null
				ukazi["$command"]=""
			fi
                elif [ -z "$validate" -o "$validate" = "0" ];then
                        metaCom=$(cut -d ":" -f 1 <<< "$line")
			[ "$metaCom" != "exit" ] && [ "$metaCom" != "log" ] && echo "Unknown command, should be log or exit" && continue #||  echo "metaCom: $metaCom"
			if [ "$metaCom" = "log" ] && [ $(cut -d " " -f 2 <<< $line) = "last" ];then
				args=$(cut -d " " -f 2- <<< $last)
				echo "$(command -v ${last}) $args" >> $2
                                echo $(pgrep -P  ${ukazi[$last]}) >> $2
			elif [ "$metaCom" = "log" ]; then
				echo $(date +%s%3N) >> $2
				for line2 in "${!ukazi[@]}"; do
					args=$(cut -d " " -f 2- <<< $line2)
					echo "$(command -v ${line2}) $args" >> $2
					echo $(pgrep -P  ${ukazi[$line2]}) >> $2
				done
			fi
		else
			echo "Unsplittable string error occured"
                	continue
		fi
        	if [[ "$metaCom" == "exit" ]]; then
            		echo "Exiting script"
			pgid=$(ps opgid= "$mypid")
			kill -9 -$(ps -o pgid= $$ | grep -o '[0-9]*')
			exit 0
        	fi
		validate=""
    	   fi

done
