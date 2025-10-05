#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include "util.h"
#include "command.h"

#define BACKGROUND_ON 1
#define BACKGROUND_OFF 0

static Command currentCommand;
static SimpleCommand *currentSimpleCommand;


void Command_init()
{
    currentCommand.noOfAvailableSimpleCommands = 10;
    currentCommand.noOfSimpleCommands = 0;
    currentCommand.background = 0; // BACKGROUND_OFF
    currentCommand.outFile = NULL;
    currentCommand.inputFile = NULL;
    currentCommand.errFile = NULL;
    currentCommand.simpleCommands = (SimpleCommand **)malloc(
        currentCommand.noOfAvailableSimpleCommands * sizeof(SimpleCommand *));
    if (currentCommand.simpleCommands == NULL)
    {
        perror("Command_init failed");
        exit(1);
    }
}

void Command_clear()
{
    currentCommand.background = 0;
    currentCommand.outFile = NULL;
    currentCommand.inputFile = NULL;
    currentCommand.errFile = NULL;
    for (int i = 0; i < currentCommand.noOfSimpleCommands; i++)
    {
        if (currentCommand.simpleCommands[i] != NULL)
        {
            free(currentCommand.simpleCommands[i]->arguments);
            free(currentCommand.simpleCommands[i]);
        }
    }
    currentCommand.noOfSimpleCommands = 0;
}

//getter function to access currentCommand
Command* getCurrentCommand(){
    return &currentCommand;
}

//setter functions for io redirection
void setInputFile(char *file){
    if (file == NULL) {
        printError("NULL input file in setInputFile");
        return;
    }
    currentCommand.inputFile=file;
}

void setOutputFile(char *file){
    if (file == NULL) {
        printError("NULL output file in setOutputFile");
        return;
    }
    currentCommand.outFile=file;
}

void setErrorFile(char *file){
    if (file == NULL) {
        printError("NULL error file in setErrorFile");
        return;
    }
    currentCommand.errFile=file;
}

void setBackgroundProcess(int bg){
    if (bg != 0 && bg != 1) {
        printError("Invalid background value (must be 0 or 1)");
        return;
    }
    currentCommand.background=bg;
}

SimpleCommand *new_simpleCommand()
{
    SimpleCommand *command = (SimpleCommand *)malloc(sizeof(SimpleCommand));
    if (command == NULL)
    {
        printError("failed to allocate memory for SimpleCommand");
        return NULL;
    }
    // initialize fields
    command->noOfAvailableArguments = 7;
    command->noOfArguments = 0;
    command->arguments = (char **)malloc(command->noOfAvailableArguments * sizeof(char *));
    if (command->arguments == NULL)
    {
        free(command);
        printError("failed to allocate memory for arguments array");
        return NULL;
    }
    return command;
}

void insertArgument(SimpleCommand *simpleCommand, char *argument)
{
    // Add NULL checks
    if (simpleCommand == NULL) {
        printError("NULL SimpleCommand pointer in insertArgument");
        return;
    }
    if (argument == NULL) {
        printError("NULL argument in insertArgument");
        return;
    }
    
    if (simpleCommand->noOfArguments >= simpleCommand->noOfAvailableArguments)
    {
        printError("too many arguments greater than limit");
        return;
    }
    simpleCommand->arguments[simpleCommand->noOfArguments] = argument;
    simpleCommand->noOfArguments++;
}

void insertSimpleCommand(SimpleCommand *simpleCmd)
{
    // Add NULL check
    if (simpleCmd == NULL) {
        printError("NULL SimpleCommand pointer in insertSimpleCommand");
        return;
    }
    
    if (currentCommand.noOfSimpleCommands >= currentCommand.noOfAvailableSimpleCommands)
    {
        printError("too many simpleCommand");
        return;
    }
    currentCommand.simpleCommands[currentCommand.noOfSimpleCommands] = simpleCmd;
    currentCommand.noOfSimpleCommands++;
}


void printCommand() {
    printf("\n");
    printf("              Command Table\n");
    printf("==================================================\n");
    
    // Print SimpleCommand array header
    printf("SimpleCommand array:\n");
    printf("┌────┬──────────────────┬──────────────────┬──────────────────┐\n");
    printf("│    │ Command          │ Arguments        │ NULL             │\n");
    printf("├────┼──────────────────┼──────────────────┼──────────────────┤\n");
    
    // Print each SimpleCommand
    for (int i = 0; i < currentCommand.noOfSimpleCommands; i++) {
        SimpleCommand *cmd = currentCommand.simpleCommands[i];
        if (cmd != NULL && cmd->noOfArguments > 0) {
            printf("│ %d: │ %-16s │", i, cmd->arguments[0]);
            
            // Print first argument after command
            if (cmd->noOfArguments > 1) {
                printf(" %-16s │", cmd->arguments[1]);
            } else {
                printf("                  │");
            }
            
            printf(" %-16s │\n", "NULL");
            
            // Print additional arguments if any
            for (int j = 2; j < cmd->noOfArguments; j++) {
                printf("│    │                  │ %-16s │                  │\n", 
                       cmd->arguments[j]);
            }
        }
    }
    printf("└────┴──────────────────┴──────────────────┴──────────────────┘\n");
    
    // Print IO Redirection section
    printf("\nIO Redirection:\n");
    printf("┌──────────────────┬──────────────────┬──────────────────┐\n");
    printf("│ in: %-12s │ out: %-11s │ err: %-11s │\n",
           currentCommand.inputFile ? currentCommand.inputFile : "default",
           currentCommand.outFile ? currentCommand.outFile : "default",
           currentCommand.errFile ? currentCommand.errFile : "default");
    printf("└──────────────────┴──────────────────┴──────────────────┘\n");
    
    // Print background status
    printf("\nBackground: %s\n", currentCommand.background ? "yes" : "no");
    printf("==================================================\n\n");
}