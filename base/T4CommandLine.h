#import "T4Object.h"
#import "T4CommandLineOption.h"

@interface T4CommandLine : T4Object
{
  NSMutableArray *cmdArguments;
  NSString *processName;

  NSString *genericHelp;
  NSMutableDictionary *arguments;
  NSMutableDictionary *options;
  NSMutableArray *switches;
  NSString *currentSwitch;
}

-initWithArgv: (char**)argv argc: (int)argc;
-initWithGenericHelp: (NSString*)aGenericHelp argv: (char**)argv argc: (int)argc;

-(int)read;
-printHelp;

-addText: (NSString*)aText;
-addMasterSwitch: (NSString*)aSwitch;

-addOption: (T4CommandLineOption*)option;
-addIntOption: (NSString*)aName at: (int*)anAddress default: (int)aDefault help: (NSString*)aHelp;
-addRealOption: (NSString*)aName at: (real*)anAddress default: (real)aDefault help: (NSString*)aHelp;
-addBoolOption: (NSString*)aName at: (BOOL*)anAddress default: (BOOL)aDefault help: (NSString*)aHelp;
-addStringOption: (NSString*)aName at: (NSString**)anAddress default: (NSString*)aDefault help: (NSString*)aHelp;

-addArgument: (T4CommandLineOption*)argument;
-addIntArgument: (NSString*)aName at: (int*)anAddress help: (NSString*)aHelp;
-addRealArgument: (NSString*)aName at: (real*)anAddress help: (NSString*)aHelp;
//-addBoolArgument: (NSString*)aName at: (BOOL*)anAddress help: (NSString*)aHelp; peut pas exister!!!
-addStringArgument: (NSString*)aName at: (NSString**)anAddress help: (NSString*)aHelp;

@end
