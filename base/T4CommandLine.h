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
-(void)printHelp;

-(void)addText: (NSString*)aText;
-(void)addMasterSwitch: (NSString*)aSwitch;

-(void)addCmdOption: (T4CommandLineOption*)option;
-(void)addIntCmdOption: (NSString*)aName address: (int*)anAddress default: (int)aDefault help: (NSString*)aHelp;
-(void)addRealCmdOption: (NSString*)aName address: (real*)anAddress default: (real)aDefault help: (NSString*)aHelp;
-(void)addBoolCmdOption: (NSString*)aName address: (BOOL*)anAddress default: (BOOL)aDefault help: (NSString*)aHelp;
-(void)addStringCmdOption: (NSString*)aName address: (NSMutableString*)anAddress default: (NSString*)aDefault help: (NSString*)aHelp;

-(void)addCmdArgument: (T4CommandLineOption*)argument;
-(void)addIntCmdArgument: (NSString*)aName address: (int*)anAddress help: (NSString*)aHelp;
-(void)addRealCmdArgument: (NSString*)aName address: (real*)anAddress help: (NSString*)aHelp;
//-(void)addBoolCmdArgument: (NSString*)aName address: (BOOL*)anAddress help: (NSString*)aHelp; peut pas exister!!!
-(void)addStringCmdArgument: (NSString*)aName address: (NSMutableString*)anAddress help: (NSString*)aHelp;

@end
