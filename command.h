

typedef struct SimpleCommand
{
    // available space for argument currently preallocated
    int noOfAvailableArguments;
    // number of argument present
    int noOfArguments;
    // array of arguments
    char **arguments;
} SimpleCommand;

typedef struct Command
{
    int noOfAvailableSimpleCommands;
    int noOfSimpleCommands;
    // array of simpleCommands
    SimpleCommand **simpleCommands;
    char *outFile;
    char *inputFile;
    char *errFile;
    int background;

} Command;

// function prototypes
void Command_init();
void Command_clear();
void insertSimpleCommand(SimpleCommand *cmd);
void printCommand();

SimpleCommand *new_simpleCommand();
void insertArgument(SimpleCommand *cmd, char *argument);

//getter and setter function
Command* getCurrentCommand();
void setInputFile(char *file);
void setOutputFile(char *file);
void setErrorFile(char *file);
void setBackgroundProcess(int bg);