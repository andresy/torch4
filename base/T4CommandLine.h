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

-(void)addOption: (T4CommandLineOption*)option;
-(void)addIntOption: (NSString*)aName address: (int*)anAddress default: (int)aDefault help: (NSString*)aHelp;
-(void)addRealOption: (NSString*)aName address: (real*)anAddress default: (real)aDefault help: (NSString*)aHelp;
-(void)addBoolOption: (NSString*)aName address: (BOOL*)anAddress default: (BOOL)aDefault help: (NSString*)aHelp;
-(void)addStringOption: (NSString*)aName address: (NSMutableString*)anAddress default: (NSString*)aDefault help: (NSString*)aHelp;

-(void)addArgument: (T4CommandLineOption*)argument;
-(void)addIntArgument: (NSString*)aName address: (int*)anAddress help: (NSString*)aHelp;
-(void)addRealArgument: (NSString*)aName address: (real*)anAddress help: (NSString*)aHelp;
//-(void)addBoolArgument: (NSString*)aName address: (BOOL*)anAddress help: (NSString*)aHelp; peut pas exister!!!
-(void)addStringArgument: (NSString*)aName address: (NSMutableString*)anAddress help: (NSString*)aHelp;

@end
