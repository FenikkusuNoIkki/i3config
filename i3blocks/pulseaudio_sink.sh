#!/usr/bin/env bash

## Get all the available sinks and fill the array given in the parameter
## $1 the array which will contain the sink index / sink description
get_available_sinks_list () {
	declare -n sinks_list="$1"
	pacmd_list_sinks=$(pacmd list-sinks)
	nb_sinks=$(echo "$pacmd_list_sinks" | head -n1 | awk '{print $1;}')
	for (( x=1; x <= "$((nb_sinks))"; x++ )); do
		sink_index=$(echo "$pacmd_list_sinks" | awk '/index:/{i++} i=='$x'{for (x=1; x<=NF; x++) printf("%s ",$x); exit}' | sed 's/*//g' | awk '{print $2}')
		sink_description=$(echo "$pacmd_list_sinks" | awk '/device.description =/{i++} i=='$x'{for (x=3; x<=NF; x++) printf("%s ",$x); exit}' | sed 's/"//g' | sed 's/.$//')
		sinks_list[$sink_index]="$sink_description"
	done
}

## Increase/Decrease the volume for the selected sink
## $1 increase or decrease
increase_decrease_volume_sink () {
	pacmd_list_sinks=$(pacmd list-sinks)
	pacmd_list_sink_inputs=$(pacmd list-sink-inputs)
	nb_inputs_sink=$(echo "$pacmd_list_sink_inputs" | head -n1 | awk '{print $1;}')
	# If no sink in use there's nothing to do
	if [ $((nb_inputs_sink)) == 0 ]; then
		exit 1
	fi

	# Register the sink description for the current apps with its index
	declare -A sink_index
	for (( x=1; x <= "$((nb_inputs_sink))"; x++ )); do
		sink=$(echo "$pacmd_list_sink_inputs" | awk '/sink:/{i++} i=='$x'{print $2; exit}')
		sink_description=$(echo "$pacmd_list_sinks" | sed -e "1,/index: $(($sink))/ d" | awk '/device.description =/{for (x=3; x<=NF; x++) printf("%s ",$x); exit}' | sed 's/"//g' | sed 's/.$//')
		sink_index[$sink_description]="$sink"
	done

	# Register the current sinks for the rofi menu
	count=1
	for key in "${!sink_index[@]}"; do
		echo "$key - ${sink_index[$key]}"
		rofi_current_sinks+="$key"
		if [ $count != ${#sink_index[@]} ]; then
			rofi_current_sinks+="\n"
		fi
		((count++))
	done

	# Display the rofi menu with the sinks / If only one sink no need to display the menu selection
	if [ "${#sink_index[@]}" -gt "1" ]; then
		if [ "$1" == "inc" ]; then
			chosen_sink="$(echo -e "$rofi_current_sinks" | rofi -dmenu -p "[Increase volume] Select the sink" -lines ${#sink_index[@]})"
		elif [ "$1" == "dec" ]; then
			chosen_sink="$(echo -e "$rofi_current_sinks" | rofi -dmenu -p "[Decrease volume] Select the sink" -lines ${#sink_index[@]})"
		fi
		# If cancel (escape key) nothing to do
		if [ -z "$chosen_sink" ]; then
			exit 1
		fi
	fi

	# Register the sink index and the volume for the chosen sink
	for key in "${!sink_index[@]}"; do
		# If only one app save the informations on the first occurence and exit the loop
		if [ ${#sink_index[@]} == 1 ]; then
			index_to_change="${sink_index[$key]}"
			current_volume=$(echo "$pacmd_list_sinks" | sed -e "1,/index: ${sink_index[$key]}/ d" | awk '/volume:/{print $5; exit}' | sed 's/"//g' | sed 's/%//g')
			break
		fi
		if [ "$key" == "$chosen_sink" ]; then
			index_to_change="${sink_index[$key]}"
			current_volume=$(echo "$pacmd_list_sinks" | sed -e "1,/index: ${sink_index[$key]}/ d" | awk '/volume:/{print $5; exit}' | sed 's/"//g' | sed 's/%//g')
			break
		fi
	done
	if [ "$1" == "inc" ]; then
		new_vol_level=$(((current_volume + 10)*65536/100))
	elif [ "$1" == "dec" ]; then
		new_vol_level=$(((current_volume - 10)*65536/100))
	fi
	echo "$index_to_change - $current_volume"
	pacmd set-sink-volume "$index_to_change" "$new_vol_level"
}

## Change the audio source for the application selected in the rofi menu
change_sinks () {
	pacmd_list_sink_inputs=$(pacmd list-sink-inputs)
	rofi_command="rofi"
	nb_inputs_sink=$(echo "$pacmd_list_sink_inputs" | head -n1 | awk '{print $1;}')
	# If no application in use there's nothing to do
	if [ $((nb_inputs_sink)) == 0 ]; then
		exit 1
	fi

	declare -A available_sinks_list
	# Function to get all the sinks available
	get_available_sinks_list available_sinks_list
	# If no sink or only one there's nothing to do
	if [ "${#available_sinks_list[@]}" -lt "2" ]; then
		exit 1
	fi

	# Get the applications list to display in the rofi menu
	# Register the application with its sink index
	for (( x=1; x <= "$((nb_inputs_sink))"; x++ )); do
		sink_index=$(echo "$pacmd_list_sink_inputs" | awk '/index:/{i++} i=='$x'{for (x=1; x<=NF; x++) printf("%s ",$x); exit}' | sed 's/*//g' | awk '{print $2}')
		application=$(echo "$pacmd_list_sink_inputs" | awk '/application.name =/{i++} i=='$x'{for (x=3; x<=NF; x++) printf("%s ",$x); exit}' | sed 's/"//g' | sed 's/.$//')
		sink_number=$(echo "$pacmd_list_sink_inputs" | awk '/sink:/{i++} i=='$x'{print $2; exit}')
		echo "$application - $sink_index - $sink_number"
		application_list[$sink_index]="$application"
		application_list_sink_nb[$sink_number]="$application"
		rofi_selection+="${application_list[$sink_index]}"
		# If still have applications put a new line for the next entry
		if [ $x != "$((nb_inputs_sink))" ]; then
			rofi_selection+="\n"
		fi
	done

	# Display the rofi menu with the applications / If only one app no need to display the menu selection
	if [ $((nb_inputs_sink)) != 1 ]; then
		chosen_app="$(echo -e "$rofi_selection" | rofi -dmenu -p "[Changing audio sink] Select the application" -lines ${#application_list[@]})"
		# If cancel (escape key) nothing to do
		if [ -z "$chosen_app" ]; then
			exit 1
		fi
	fi

	# Register the index for the chosen application
	for key in "${!application_list[@]}"; do
		# If only one app save the informations on the first occurence and exit the loop
		if [ $((nb_inputs_sink)) == 1 ]; then
			index_to_change="$key"
			chosen_app=${application_list[$key]}
			break
		fi
		if [ "${application_list[$key]}" == "$chosen_app" ]; then
			echo "${application_list[$key]} - $key"
			index_to_change="$key"
			break
		fi
	done

	# Get the sink number for the chosen application. Used for highlighting the current sink for the chosen application in the rofi menu
	for key in "${!application_list_sink_nb[@]}"; do
		if [ "${application_list_sink_nb[$key]}" == "$chosen_app" ]; then
			sink_number="$key"
			break
		fi
	done

	count=1
	for index in "${!available_sinks_list[@]}"; do
		echo "$index - ${available_sinks_list[$index]}"
		rofi_sinks_list+="${available_sinks_list[$index]}"
		# If still have sinks put a new line for the next entry
		if [ $count != ${#available_sinks_list[@]} ]; then
			rofi_sinks_list+="\n"
		fi
		# Get the index for of available_sinks_list array for the source of the chosen app
		if [ "$sink_number" == "$index" ]; then
			current_sink=$(($count-1))
		fi
		((count++))
	done

	# Display the rofi menu with all the sinks available
	chosen_sink="$(echo -e "$rofi_sinks_list" | rofi -dmenu -p "[Changing audio sink] Select the sink for $chosen_app" -lines ${#available_sinks_list[@]} -a $current_sink )"
	# If cancel (escape key) nothing to do
	if [ -z "$chosen_sink" ]; then
		exit 1
	fi

	# Register the index for the chosen sink
	for key in "${!available_sinks_list[@]}"; do
		if [ "${available_sinks_list[$key]}" == "$chosen_sink" ]; then
			echo "${available_sinks_list[$key]} - $key"
			new_index="$key"
			break
		fi
	done

	# Move the chosen application to the chosen sink
	pacmd move-sink-input "$index_to_change" "$new_index"
}

## Display the applications with their sink and volume in the i3 bar
## Ex : Google Chrome - Built-in Audio Analog Stereo [71%] | Plex Media Player - Razer USB Sound Card Analog Stereo [86%]
## If the apps have the same sink :
## Plex Media Player/Google Chrome - Built-in Audio Analog Stereo [71%]
display_sinks () {
	pacmd_list_sinks=$(pacmd list-sinks)
	pacmd_list_sink_inputs=$(pacmd list-sink-inputs)
	nb_inputs_sink=$(echo "$pacmd_list_sink_inputs" | head -n1 | awk '{print $1;}')

	if [ "$nb_inputs_sink" == 0 ] || [ -z "$nb_inputs_sink" ]; then
		# First echo updates the full_text i3bar key
		echo "No input(s) sink available"
		# Second echo updates the short_text i3bar key
		echo "No input(s) sink available"
	else
		declare -A sink_vol_app
		for (( x=1; x <= "$((nb_inputs_sink))"; x++ )); do
			sink=$(echo "$pacmd_list_sink_inputs" | awk '/sink:/{i++} i=='$x'{print $2; exit}')
			application=$(echo "$pacmd_list_sink_inputs" | awk '/application.name =/{i++} i=='$x'{for (x=3; x<=NF; x++) printf("%s ",$x); exit}' | sed 's/"//g' | sed 's/.$//')
			sink_description=$(echo "$pacmd_list_sinks" | sed -e "1,/index: $(($sink))/ d" | awk '/device.description =/{for (x=3; x<=NF; x++) printf("%s ",$x); exit}' | sed 's/"//g' | sed 's/.$//')
			volume=$(echo "$pacmd_list_sinks" | sed -e "1,/index: $(($sink))/ d" | awk '/volume:/{print $5; exit}' | sed 's/"//g')
			sink_and_vol="$sink_description [$volume]"
			# Associative array : register several values for a given key
			sink_vol_app[$sink_and_vol]="${sink_vol_app[$sink_and_vol]}${sink_vol_app[$sink_and_vol]:+/}$application"
		done

		count=1
		# Format the output : '-' between the app(s) and the sink and a '|' between the app(s) from different sinks
		for key in "${!sink_vol_app[@]}"; do
			output+="${sink_vol_app[$key]} - $key"
			if [ $count != ${#sink_vol_app[@]} ]; then
				output+=" | "
			fi
			((count++))
		done
		# First echo updates the full_text i3bar key
		echo "$output"
		# Second echo updates the short_text i3bar key
		echo "$output"
	fi
}

while getopts "gsid" option; do
	case "${option}" in
		g) # display the sink informations in the i3blocks bar
			display_sinks
			;;
		s) # change the sink for the specified application
			change_sinks
			;;
		i) # Increase the volume for the specified sink
			increase_decrease_volume_sink inc
			;;
		d) # Decrease the volume for the specified sink
			increase_decrease_volume_sink dec
			;;
		*) # incorrect option
            echo "Error: Invalid option $option"
            ;;
    esac
done
