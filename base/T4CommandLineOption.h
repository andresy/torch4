#import "T4Object.h"

@interface T4CommandLineOption : T4Object
{
  NSString *name;
  NSString *type;
  NSString *help;
  BOOL isSet;
}

-init;
-initWithName: (NSString*)aName type: (NSString*)aTypeName help: (NSString*)aHelp;

-read: (NSMutableArray*)arguments;
-initToDefaultValue;
-(NSString*)textValue;

-(BOOL)isSet;
-(NSString*)type;
-(NSString*)name;
-(NSString*)help;

@end


@interface T4IntCommandLineOption : T4CommandLineOption
{
  int *address;
  int defaultValue;
}

-initWithName: (NSString*)aName at: (int*)anAddress default: (int)aDefaultValue help: (NSString*)aHelp;
-read: (NSMutableArray*)arguments;
-initToDefaultValue;
-(NSString*)textValue;

@end

@interface T4RealCommandLineOption : T4CommandLineOption
{
  real *address;
  real defaultValue;
}

-initWithName: (NSString*)aName at: (real*)anAddress default: (real)aDefaultValue help: (NSString*)aHelp;
-read: (NSMutableArray*)arguments;
-initToDefaultValue;
-(NSString*)textValue;

@end

@interface T4BoolCommandLineOption : T4CommandLineOption
{
  BOOL *address;
  BOOL defaultValue;
}

-initWithName: (NSString*)aName at: (BOOL*)anAddress default: (BOOL)aDefaultValue help: (NSString*)aHelp;
-read: (NSMutableArray*)arguments;
-initToDefaultValue;
-(NSString*)textValue;

@end

@interface T4StringCommandLineOption : T4CommandLineOption
{
  NSString **address;
  NSString *defaultValue;
}

-initWithName: (NSString*)aName at: (NSString**)anAddress default: (NSString*)aDefaultValue help: (NSString*)aHelp;
-read: (NSMutableArray*)arguments;
-initToDefaultValue;
-(NSString*)textValue;

@end
