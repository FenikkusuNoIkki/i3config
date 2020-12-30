#!/usr/bin/env bash
get_available_sinks_list () {
	declare -n sinks_list="$1"
	pacmd_list_sinks=$(pacmd list-sinks)
	nb_sinks=$(echo "$pacmd_list_sinks" | head -n1 | awk '{print $1;}')
	for (( index=1; index <= "$((nb_sinks))"; index++ )); do
		sink_index=$(echo "$pacmd_list_sinks" | awk '/index:/{i++} i=='$index'{for (x=1; x<=NF; x++) printf("%s ",$x); exit}' | sed 's/*//g' | awk '{print $2}')
		sink_description=$(echo "$pacmd_list_sinks" | awk '/device.description =/{i++} i=='$index'{for (x=3; x<=NF; x++) printf("%s ",$x); exit}' | sed 's/"//g' | sed 's/.$//')
		sinks_list[$sink_index]="$sink_description"
	done
}

change_sinks () {
	pacmd_list_sink_inputs=$(pacmd list-sink-inputs)
	declare -A available_sinks_list
	rofi_command="rofi"
	nb_inputs_sink=$(echo "$pacmd_list_sink_inputs" | head -n1 | awk '{print $1;}')
	for (( index=1; index <= "$((nb_inputs_sink))"; index++ )); do
		sink_index=$(echo "$pacmd_list_sink_inputs" | awk '/index:/{i++} i=='$index'{for (x=1; x<=NF; x++) printf("%s ",$x); exit}' | sed 's/*//g' | awk '{print $2}')
		application=$(echo "$pacmd_list_sink_inputs" | awk '/application.name =/{i++} i=='$index'{for (x=3; x<=NF; x++) printf("%s ",$x); exit}' | sed 's/"//g' | sed 's/.$//')
		application_list[$sink_index]="$application"
		rofi_selection+="${application_list[$sink_index]}"
		if [ $index != $((nb_inputs_sink)) ]; then
			rofi_selection+="\n"
		fi
	done
	chosen="$(echo -e "$rofi_selection" | rofi -dmenu -p "[Changing audio sink] Select the application" -lines ${#application_list[@]})"
	for key in "${!application_list[@]}"; do
		if [ "${application_list[$key]}" == "$chosen" ]; then
			echo "${application_list[$key]} - $key"
			index_to_change="$key"
		fi
	done
	get_available_sinks_list available_sinks_list
	for index in "${!available_sinks_list[@]}"; do
		echo "$index - ${available_sinks_list[$index]}"
		rofi_sinks_list+="${available_sinks_list[$index]}"
		if [ $index != ${#available_sinks_list[@]} ]; then
			rofi_sinks_list+="\n"
		fi
	done
	chosen="$(echo -e "$rofi_sinks_list" | rofi -dmenu -p "[Changing audio sink] Select the application" -lines ${#available_sinks_list[@]})"
	for key in "${!available_sinks_list[@]}"; do
		if [ "${available_sinks_list[$key]}" == "$chosen" ]; then
			echo "${available_sinks_list[$key]} - $key"
			new_index="$key"
		fi
	done
	pacmd move-sink-input "$index_to_change" "$new_index"
}

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
		declare -A array
		for (( current_input_sink=1; current_input_sink <= "$((nb_inputs_sink))"; current_input_sink++ )); do
			sink=$(echo "$pacmd_list_sink_inputs" | awk '/sink:/{i++} i=='$current_input_sink'{print $2; exit}')
			application=$(echo "$pacmd_list_sink_inputs" | awk '/application.name =/{i++} i=='$current_input_sink'{for (x=3; x<=NF; x++) printf("%s ",$x); exit}' | sed 's/"//g' | sed 's/.$//')
			sink_description=$(echo "$pacmd_list_sinks" | sed -e "1,/index: $(($sink))/ d" | awk '/device.description =/{for (x=3; x<=NF; x++) printf("%s ",$x); exit}' | sed 's/"//g' | sed 's/.$//')
			volume=$(echo "$pacmd_list_sinks" | sed -e "1,/index: $(($sink))/ d" | awk '/volume:/{print $5; exit}' | sed 's/"//g')
			sink_and_vol="$sink_description [$volume]"
			array[$sink_and_vol]="${array[$sink_and_vol]}${array[$sink_and_vol]:+/}$application"
		done
		count=1
		for key in "${!array[@]}"; do
			output+="${array[$key]} - $key"
			if [ $count != ${#array[@]} ]; then
				output+=" | "
			fi
			((count++))
		done
		echo "$output"
	fi
}

while getopts "dsv:" option; do
	case "${option}" in
		d) # display the sink informations in the i3blocks bar
			display_sinks
			;;
		s) # change the sink for the specified application
			change_sinks
			;;
		v) # change the volume for the specified application
			;;
		*) # incorrect option
            echo "Error: Invalid option $option"
            ;;
    esac
done
