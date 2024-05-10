# CommandDocs Automated Generation of Linux/Unix Manuals
The primary goal of this project is to automate the generation of a comprehensive manual for Linux/Unix commands. This will be achieved through the development of scripts using Python or shell scripting. These scripts will create text files for each command, formatted according to a predefined template, which will facilitate consistent and efficient documentation.

## Code discription
This script automates the creation of documentation for Linux commands. It includes several functions to extract information about commands, verify documentation, and manage user interactions. Here's a breakdown of the key components:

### Core Functions:
##### 1.get_description:
- Retrieves the description of a command from its man page.
##### 2.get_name: 
- Extracts the command name from its man page.
##### 3.get_related_commands: 
- Finds related commands using keyword search in man pages.
##### 4.get_version: 
- Attempts to get the command version using common flags like --version.
##### 5.generate_documentation: 
- Generates a detailed documentation file for a command, including its name, description, version, example usage, and related commands.

### Documentation Generation:
- For each command, a text file is created containing structured information fetched by the aforementioned functions.
- If certain information (name, description, version) cannot be retrieved, placeholders are used.
- The script also handles the execution of an example command and captures its output, adding practical usage insights to the documentation.

### Verification Functions:
- #### verify_all_commands:
  Compares new documentation against existing files to detect changes.
- #### verify_specific_document:
  Allows verification of a specific command's documentation by comparing it against an existing file.

### User Interaction:
- suggest_commands: Recommends commands based on usage history.
- search_manuals: Provides options to search within command documentation.
- validate_command: Checks if a given command exists in the system.
- prompt_for_custom_command: Prompts users to enter a valid command name.
- create_manuals_for_selected_commands and create_manuals_for_custom_commands: Guides users through creating manuals for pre-defined or new custom commands.

### Workflow Management:
- initial_setup: Initially presents options to generate documentation for all commands, select specific commands, or input custom commands.
- A comprehensive main menu loop provides various functionalities, including verification of generated documentation, command recommendation, manual search, and adding manuals for custom commands, with the option to exit the program.

## Interacting with the project
This project involves various choices and interfaces designed to facilitate user interaction and streamline workflow. Here's a detailed explanation of the choices available and the interfaces used in the project:

### Main Choices
1. Generate Documentation: Users can choose to generate documentation for all commands known to the system, for a selected subset of commands, or for custom commands that users specify.
2. Verify Documentation: After generating documentation, users can verify the accuracy of the content by comparing the newly generated documents against existing ones or verify specific command documentation to ensure it's up-to-date and accurate.
3. Recommend Commands: Based on user history or frequently used commands, the system can suggest relevant commands, which helps users discover new or related functionalities.
4. Search in Manuals: Users can search within the generated documentation either by text within the manuals or specifically by command names. This feature enhances the usability of the documentation by making it easy to find information.
5. Custom Command Interaction: Users can add documentation for new custom commands by providing the command name and an example of its usage, thus extending the utility of the tool.

### Workflow Description
- ### Initialization:
  The script starts with an initial setup where users choose to generate documentation for all, selected, or custom commands.
  ![image](https://github.com/HussainRadwan/CommandDocs-Automated-Generation-of-Linux-Unix-Manuals-using-shell/assets/161932786/bc6649d5-0721-434f-99e0-6518b656047b)
- ### Main Menu Loop:
  After initial setup, the script enters a loop offering various options like verifying documentation, recommending commands, searching within manuals, or adding new custom commands.
  ![image](https://github.com/HussainRadwan/CommandDocs-Automated-Generation-of-Linux-Unix-Manuals-using-shell/assets/161932786/21a83a3b-6784-4966-8e84-be5fc4bd7b8d)
- ### Selection and Execution:
  Users make selections based on their needs (e.g., generating new documentation, verifying existing ones, or searching for specific details), and the script executes the appropriate functions
  #### Example:
  ![image](https://github.com/HussainRadwan/CommandDocs-Automated-Generation-of-Linux-Unix-Manuals-using-shell/assets/161932786/cdb06c45-c2bd-4549-a120-08281069d92b)
- ### Review and Adjust:
  Users can review the output, check for errors, and make further selections based on the feedback provided by the script.

### This structured approach ensures that users can efficiently manage and utilize Linux/Unix command documentation, making the tool both powerful and user-friendly in a technical environment.
  
