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
-addIntOption: (NSString*)aName address: (int*)anAddress default: (int)aDefault help: (NSString*)aHelp;
-addRealOption: (NSString*)aName address: (real*)anAddress default: (real)aDefault help: (NSString*)aHelp;
-addBoolOption: (NSString*)aName address: (BOOL*)anAddress default: (BOOL)aDefault help: (NSString*)aHelp;
-addStringOption: (NSString*)aName address: (NSMutableString*)anAddress default: (NSString*)aDefault help: (NSString*)aHelp;

-addArgument: (T4CommandLineOption*)argument;
-addIntArgument: (NSString*)aName address: (int*)anAddress help: (NSString*)aHelp;
-addRealArgument: (NSString*)aName address: (real*)anAddress help: (NSString*)aHelp;
//-addBoolArgument: (NSString*)aName address: (BOOL*)anAddress help: (NSString*)aHelp; peut pas exister!!!
-addStringArgument: (NSString*)aName address: (NSMutableString*)anAddress help: (NSString*)aHelp;

@end
