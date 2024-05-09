#Hussain Radwan ---- 1200475

# Function to get command description from man pages
get_description() {
    man $1 | col -bx | awk '/^DESCRIPTION/,/^$/' | sed '1d;$d'
}

get_name() {
    local cmd=$1
    local name=$(man $cmd | col -bx | awk '/^NAME/,/^SYNOPSIS/' | sed '1d;$d')
    echo "$name"
}

# Function to get related commands
get_related_commands() {
    man -k $1 | awk '{print $1}' | grep -v "^$1$" | xargs || echo "No related commands found"
}

get_version() {
    local cmd=$1
    # Try common version flags
    ($cmd --version || $cmd -V || $cmd -v) 2>/dev/null | head -n 1
}

# Function to generate documentation for a command
generate_documentation() {
    local cmd=$1
    # Create a new text file for each command
    filename="${cmd}_command_info.txt"
    touch "$filename"

     # Try to get command name
    local name=$(get_name $cmd)
    if [ -z "$name" ]; then
        name="Name not available for $cmd"
    fi

    # Try to get command description
    local description=$(get_description $cmd)
    if [ -z "$description" ]; then
        description="Description not available for $cmd"
    fi

    # Try to get command version
    local version=$(get_version $cmd)
    if [ -z "$version" ]; then
        version="Version not available for $cmd"
    fi

    # Try to get related commands
    local related=$(get_related_commands $cmd)
    if [ -z "$related" ]; then
        related="Related commands not available for $cmd"
    fi

    # Write information to file
    echo "Command Names : $name" > "$filename"
    echo "------------------------------------------------------------------" >> "$filename"
    echo "Description:" >> "$filename"
    echo "$description" >> "$filename"
    echo "------------------------------------------------------------------" >> "$filename"
    echo "version:" >> "$filename"
    echo "$version" >> "$filename"
    echo "------------------------------------------------------------------" >> "$filename"
    echo "Example:" >> "$filename"
    echo "> ${commands_examples[$cmd]}" >> "$filename"
    eval "${commands_examples[$cmd]}" >> "$filename" 2>&1
    echo "------------------------------------------------------------------" >> "$filename"
    echo "Related Commands: $related" >> "$filename"
    echo "------------------------------------------------------------------" >> "$filename"
    echo "Notes:" >> "$filename"
    echo "- This documentation is generated automatically." >> "$filename"
    echo "------------------------------------------------------------------" >> "$filename"
    echo "End" >> "$filename"
}

verify_all_commands() {
    echo "Verifying all commands..."

    for cmd in "${!commands_examples[@]}"; do
    	
    	mkdir -p "new_versions"
    	cd "new_versions"
    	generate_documentation "$cmd"
    	cd ".."
    
        local old_file="documents/${cmd}_command_info.txt"
        local new_file="new_versions/${cmd}_command_info.txt"

        if [ -f "$old_file" ] && [ -f "$new_file" ]; then
            # Perform the diff and capture the output
            local diff_output=$(diff "$old_file" "$new_file")
            
            if [ -n "$diff_output" ]; then
                echo "Differences found in $cmd:"
                echo "$diff_output"
                echo "----------------------------------------------------"
            fi
        else
            echo "Documentation for $cmd not found or new version not available."
        fi
    done
}

# Function to verify documentation of a specific command
verify_specific_document() {
    echo "Available commands for verification:"
    local i=1
    local commands_array=("${!commands_examples[@]}")
    
    for cmd in "${commands_array[@]}"; do
        echo "$i. $cmd"
        i=$((i+1))
    done

    read -p "Enter the number of the command you want to verify: " cmd_num
    local selected_cmd_index=$((cmd_num - 1))

    if [ $selected_cmd_index -ge 0 ] && [ $selected_cmd_index -lt ${#commands_array[@]} ]; then
        local selected_cmd=${commands_array[$selected_cmd_index]}
        echo "Selected Command for Verification: $selected_cmd"
	
	mkdir -p "new_versions"
	cd "new_versions"
	generate_documentation "$selected_cmd"
	cd ".."
        
        # Verification logic for the selected command
        local old_file="documents/${selected_cmd}_command_info.txt"
        local new_file="new_versions/${selected_cmd}_command_info.txt"

        if [ -f "$old_file" ] && [ -f "$new_file" ]; then
            echo "Verifying $selected_cmd"
            echo "Checking for differences..."

            # Check each section using diff
            echo "Name and Description Differences:"
            local diff_output=$(diff <(sed -n '/^Command Names:/,/^-----/p' "$old_file") <(sed -n '/^Command Names:/,/^-----/p' "$new_file"))
            
            if [ $? -eq 0 ]; then
            	echo "No differences found."
            else
            	echo "Differences found:"
            	echo "$diff_output"
            fi
        
            echo "Version Differences:"
            local diff_output=$(diff <(sed -n '/^version:/,/^-----/p' "$old_file") <(sed -n '/^version:/,/^-----/p' "$new_file"))
            
            if [ $? -eq 0 ]; then
            	echo "No differences found."
            else
            	echo "Differences found:"
            	echo "$diff_output"
            fi

            echo "Example Differences:"
            local diff_output=$(diff <(sed -n '/^Example:/,/^-----/p' "$old_file") <(sed -n '/^Example:/,/^-----/p' "$new_file"))
            
            if [ $? -eq 0 ]; then
            	echo "No differences found."
            else
            	echo "Differences found:"
            	echo "$diff_output"
            fi

            echo "Related Commands Differences:"
            local diff_output=$(diff <(sed -n '/^Related Commands:/,/^-----/p' "$old_file") <(sed -n '/^Related Commands:/,/^-----/p' "$new_file"))
            
            if [ $? -eq 0 ]; then
            	echo "No differences found."
            else
            	echo "Differences found:"
            	echo "$diff_output"
            fi

            echo "Notes Differences:"
            local diff_output=$(diff <(sed -n '/^Notes:/,/^End/p' "$old_file") <(sed -n '/^Notes:/,/^End/p' "$new_file"))
            
            if [ $? -eq 0 ]; then
            	echo "No differences found."
            else
            	echo "Differences found:"
            	echo "$diff_output"
            fi
   
        else
            echo "Documentation for $selected_cmd not found or new version not available."
        fi
    else
        echo "Invalid selection. Exiting."
        return
    fi
}

suggest_commands() {
    echo "Suggested Commands based on your history:"

    # Get the last commands from the history, count them, and sort by frequency
    local suggested_cmds=$(cat ~/.bash_history | awk '{CMD[$1]++} END {for (a in CMD)print CMD[a], a}' | sort -rn | head -n 5)
    
    echo "$suggested_cmds"

    read -p "Enter a command name to view its manual: " selected_cmd

    if [ -f "documents/${selected_cmd}_command_info.txt" ]; then
        cat "documents/${selected_cmd}_command_info.txt"
        
    else
        echo "No manual available for the selected command."
        read -p "Do you want to create a manual for this command? (yes/no/back) " answer
        case $answer in
            [Yy]* )
                read -p "Enter an example usage of '$selected_cmd': " example_usage
                commands_examples["$selected_cmd"]="$example_usage"
                mkdir -p "documents"
                cd "documents"
                generate_documentation "$selected_cmd"
                cd ".."
                echo "Documentation for '$selected_cmd' generated."
                cat "documents/${selected_cmd}_command_info.txt"
                ;;
            [Bb]* )
                echo "Returning to the main menu."
                return
                ;;
            * )
                echo "Not creating a manual. Returning to the main menu."
                return
                ;;
        esac
    fi
}


search_manuals() {
    
    echo "Search Options:"
    echo "1. Search within manuals text"
    echo "2. Search command names only"
    echo "3. Exit searching"
    read -p "Choose your search option (1/2): " search_option
    read -p "Enter the keyword to search for: " keyword

    local search_results=()
    case $search_option in
        1)
            echo "Searching for '$keyword' in command manuals text..."
            for file in documents/*_command_info.txt; do
                if grep -iq "$keyword" "$file"; then
                    search_results+=("$(basename "$file" "_command_info.txt")")
                fi
            done
            ;;
        2)
            echo "Searching for '$keyword' in command names..."
            for file in documents/*_command_info.txt; do
                local cmd=$(basename "$file" "_command_info.txt")
                if [[ "$cmd" == "$keyword" ]]; then
                    search_results+=("$cmd")
                fi
            done
            ;;
            
        3)
            echo "Exiting..."
      	    return
      	    ;;
      	    
        *)
            echo "Invalid search option. Exiting."
            return
            ;;
    esac

    # Check if any results were found
    if [ ${#search_results[@]} -eq 0 ]; then
        echo "No commands found with the keyword '$keyword'."
        return
    fi

    # List all matching commands alphabetically with numbers
    IFS=$'\n' sorted_cmds=($(sort <<<"${search_results[*]}"))
    unset IFS
    echo "Commands containing '$keyword':"
    for i in "${!sorted_cmds[@]}"; do
        echo "$((i+1)). ${sorted_cmds[i]}"
    done

    # Prompt user to select a command
    read -p "Enter the number of the command to view its manual: " cmd_num
    selected_cmd_index=$((cmd_num - 1))

    if [ $selected_cmd_index -ge 0 ] && [ $selected_cmd_index -lt ${#sorted_cmds[@]} ]; then
        local selected_cmd=${sorted_cmds[$selected_cmd_index]}
        if [ -f "documents/${selected_cmd}_command_info.txt" ]; then
            cat "documents/${selected_cmd}_command_info.txt"
        else
            echo "Manual for $selected_cmd not found."
        fi
    else
        echo "Invalid selection."
    fi
}

# Function to validate if a command exists
validate_command() {
    local cmd=$1
    type $cmd &> /dev/null
    if [ $? -ne 0 ]; then
        echo "$cmd is not a valid command in the Linux shell."
        return 1
    fi
    return 0
}


# Function to prompt for custom command input
prompt_for_custom_command() {
    local custom_cmd=""
    local valid_command=0
    while [ $valid_command -eq 0 ]; do
        read -p "Enter command name: " custom_cmd
        validate_command "$custom_cmd"
        valid_command=$?
    done
    echo "$custom_cmd"
}

create_manuals_for_selected_commands() {
    echo "Available commands:"
    local i=1
    local cmds_per_line=5  # Number of commands to display per line
    local line=""

    for cmd in "${!commands_examples[@]}"; do
        line+="$i. $cmd  "
        if ((i % cmds_per_line == 0)); then
            echo "$line"
            line=""
        fi
        i=$((i+1))
    done
    # Print any remaining commands if the last line is not empty
    if [ -n "$line" ]; then
        echo "$line"
    fi

    echo "Enter the numbers of the commands for which you want to generate manuals (separated by spaces):"
    read -a cmd_indices

    # Clear the commands_examples array
    declare -A new_commands_examples

    mkdir -p "documents"
    cd "documents"

    for index in "${cmd_indices[@]}"; do
        local adjusted_index=$((index - 1))
        local cmd_names=("${!commands_examples[@]}")
        local cmd=${cmd_names[$adjusted_index]}
        
        if [[ -n "$cmd" ]]; then
            new_commands_examples["$cmd"]="${commands_examples[$cmd]}"
            generate_documentation "$cmd"
            echo "Documentation for $cmd command generated."
        else
            echo "Invalid command number: $index"
        fi
    done
    
    cd ".."
    
    # Update the commands_examples array to only contain the custom commands
    commands_examples=()
    for cmd in "${!new_commands_examples[@]}"; do
        commands_examples["$cmd"]="${new_commands_examples[$cmd]}"
    done
}

create_manuals_for_custom_commands() {
    echo "Enter the number of custom commands you want to create:"
    read num_custom
    if ! [[ "$num_custom" =~ ^[0-9]+$ ]]; then
        echo "Invalid number. Please enter a valid number."
        return
    fi
    
    commands_examples=()
	
    mkdir -p "documents"
    cd "documents"
    
    for ((i=1; i<=num_custom; i++)); do
        local is_new_command=0
        local custom_cmd=""

        while [ $is_new_command -eq 0 ]; do
            echo "Enter command name ($i):"
            read custom_cmd

            # Check if the command already exists in the array
            if [[ -n "${commands_examples[$custom_cmd]}" ]]; then
                echo "The command '$custom_cmd' already exists. Please enter a different command."
                continue
            fi

            # Validate the command
            if ! command -v "$custom_cmd" &> /dev/null; then
                echo "'$custom_cmd' is not a valid command. Try again."
            else
                is_new_command=1
            fi
        done

        echo "Enter an example usage for '$custom_cmd':"
        read example_usage
        commands_examples["$custom_cmd"]="$example_usage"
        generate_documentation "$custom_cmd"
        echo "Documentation for '$custom_cmd' generated."
    done
    
    cd ".."
}

add_manuals_for_custom_commands() {
    echo "Enter the number of custom commands you want to add:"
    read num_custom
    if ! [[ "$num_custom" =~ ^[0-9]+$ ]]; then
        echo "Invalid number. Please enter a valid number."
        return
    fi
	
    mkdir -p "documents"
    cd "documents"
    
    for ((i=1; i<=num_custom; i++)); do
        local is_new_command=0
        local custom_cmd=""

        while [ $is_new_command -eq 0 ]; do
            echo "Enter command name ($i):"
            read custom_cmd

            # Check if the command already exists in the array
            if [[ -n "${commands_examples[$custom_cmd]}" ]]; then
                echo "The command '$custom_cmd' already exists. Please enter a different command."
                continue
            fi

            # Validate the command
            if ! command -v "$custom_cmd" &> /dev/null; then
                echo "'$custom_cmd' is not a valid command. Try again."
            else
                is_new_command=1
            fi
        done

        echo "Enter an example usage for '$custom_cmd':"
        read example_usage
        commands_examples["$custom_cmd"]="$example_usage"
        generate_documentation "$custom_cmd"
        echo "Documentation for '$custom_cmd' generated."
    done
    
    cd ".."
}

# List of commands and their safe example usages
declare -A commands_examples
commands_examples["ls"]="ls -l"
commands_examples["cd"]="cd .; pwd"
commands_examples["pwd"]="pwd"
commands_examples["mkdir"]="mkdir -p tempDir; ls | grep 'tempDir'; rmdir tempDir"
commands_examples["rmdir"]="mkdir -p tempDir; rmdir tempDir; ls | grep 'tempDir'"
commands_examples["rm"]="echo 'Example of rm: remove a file'"
commands_examples["cp"]="echo 'file1' > tempFile1; cp tempFile1 tempFile2; cat tempFile2; rm tempFile1 tempFile2"
commands_examples["mv"]="echo 'file1' > tempFile1; mv tempFile1 tempFile2; cat tempFile2; rm tempFile1 tempFile2"
commands_examples["touch"]="touch tempFile; ls | grep 'tempFile'; rm tempFile"
commands_examples["cat"]="echo 'Hello' > tempFile; cat tempFile; rm tempFile"
commands_examples["echo"]="echo 'Hello World'"
commands_examples["grep"]="echo 'Hello World' | grep 'World'"
commands_examples["find"]="find . -maxdepth 1 -type f"
commands_examples["df"]="df -h"
commands_examples["du"]="du -h ."
commands_examples["head"]="echo 'Line 1\nLine 2\nLine 3' | head -n 2"
commands_examples["tail"]="echo 'Line 1\nLine 2\nLine 3' | tail -n 2"
commands_examples["tar"]="tar -cf temp.tar tempFile; rm temp.tar"
commands_examples["chmod"]="mkdir tempFile; chmod 644 tempFile; rmdir tempFile"


# Function to show initial options and create manuals based on the choice
initial_setup() {
    echo "Available commands:"
    local i=1
    for cmd in "${!commands_examples[@]}"; do
        echo "$i. $cmd"
        i=$((i+1))
    done

    echo "Select an option:"
    echo "1. Create manuals for all commands"
    echo "2. Create manuals for some of these commands"
    echo "3. Create manuals for custom commands"
    read -p "Enter your choice: " initial_choice

    case $initial_choice in
        1)
            mkdir -p "documents"
            cd "documents"
            for cmd in "${!commands_examples[@]}"; do
                generate_documentation "$cmd"
            done
            cd ".."
            
            echo "Documentation for all commands generated."
            ;;
            
        2)
            create_manuals_for_selected_commands
            ;;
        3)
            create_manuals_for_custom_commands
    	    ;;
    	    
        *)
            echo "Invalid choice. Exiting."
            exit 1
            ;;
    esac
}

# Start with initial setup
initial_setup

# Main menu in a loop
while true; do
    echo "Select an option:"
    echo "1. Verify generated documentation"
    echo "2. recommend Commands"
    echo "3. Search in Manuals"
    echo "4. Create manual for a custom command"
    echo "5. Exit"
    read -p "Enter your choice (1/2/3/4/5): " choice

    case $choice in
            
        1)
            
            echo "Verification options:"
            echo "1. Verify all commands"
            echo "2. Verify specific command"
            echo "3. Exit verification"
            read -p "Enter your choice (1/2/3): " verify_choice

            case $verify_choice in
                1)
            	    verify_all_commands
                    ;;
                    
                2)
                    verify_specific_document
                    ;;
                    
                3)
                    echo "Exiting verification."
                    ;;
                    
                *)
                    echo "Invalid choice. Exiting."
                    ;;
                    
            esac
            ;;
            
        2)
            suggest_commands
            ;;
            
        3)	
            search_manuals
            ;;
            
        4)
            add_manuals_for_custom_commands
            ;;
            
        5)
            echo "Exiting."
            exit 0
            ;;
            
        *)
            echo "Invalid choice. Exiting."
            exit 1
            ;;
            
    esac
    
done
