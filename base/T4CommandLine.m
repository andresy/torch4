#import "T4CommandLine.h"

@implementation T4CommandLine

-initWithArgv: (char**)argv argc: (int)argc
{
  int i;

  if( (self = [super init]) )
  {
    processName = [[NSString alloc] initWithCString: argv[0]];
    cmdArguments = [[NSMutableArray alloc] init];
    
    for(i = 0; i < argc; i++)
      [cmdArguments addObject: [NSString stringWithCString: argv[i]]];

    genericHelp = [[NSString alloc] initWithString: @"Powered by Torch IV"];
      
    arguments = [[NSMutableDictionary alloc] init];
    options = [[NSMutableDictionary alloc] init];
    switches = [[NSMutableArray alloc] init];

    [allocator keepObject: cmdArguments];
    [allocator keepObject: processName];
    [allocator keepObject: arguments];
    [allocator keepObject: options];
    [allocator keepObject: switches];
    [allocator keepObject: genericHelp];
  
    [self addMasterSwitch: @"default"];
  }

  return self;
}

-initWithGenericHelp: (NSString*)aGenericHelp argv: (char**)argv argc: (int)argc;
{
  if( (self = [self initWithArgv: argv argc: argc]) )
  {
    [allocator freeObject: genericHelp];
    genericHelp = aGenericHelp;
    [allocator retainAndKeepObject: genericHelp];
  }

  return self;
}

-(int)read
{
  //  NSProcessInfo *processInfo = [[NSProcessInfo alloc] init];
  NSMutableArray *currentCmdArguments = [[NSMutableArray alloc] initWithArray: cmdArguments];//[processInfo arguments]];
  NSArray *currentOptions;
  NSArray *currentArguments;
  T4CommandLineOption *option, *argument = nil;
  NSString *cmdArgument;
  NSEnumerator *enumerator;
  int switchIndex = 0;
  int i;

  T4Message(@"program name supposed to be = %@", [currentCmdArguments objectAtIndex: 0]);
  T4Message(@"program name supposed to be = %@ [NSProcessInfo]", [[NSProcessInfo processInfo] processName]);
  [currentCmdArguments removeObjectAtIndex: 0];

  // Look for help request and the Master Switch
  if([currentCmdArguments count] >= 1)
  {
    cmdArgument = [currentCmdArguments objectAtIndex: 0];

    if( [cmdArgument isEqualToString: @"-h"] || [cmdArgument isEqualToString: @"-help"] || [cmdArgument isEqualToString: @"--help"] )
      [self printHelp];

    for(i = 1; i < [switches count]; i++)
    {
      if([cmdArgument isEqualToString: [switches objectAtIndex: i]])
      {
        switchIndex = i;
        [currentCmdArguments removeObjectAtIndex: 0];
        break;
      }
    }
  }

  currentOptions = [options objectForKey: [switches objectAtIndex: switchIndex]];
  currentArguments = [arguments objectForKey: [switches objectAtIndex: switchIndex]];

  // Initialize the options.
  enumerator = [currentOptions objectEnumerator];
  while( (option = [enumerator nextObject]) )
    [option initToDefaultValue];

  while([currentCmdArguments count] > 0)
  {
    // First, check the option.
    int optionIndex = -1;
    cmdArgument = [currentCmdArguments objectAtIndex: 0];
    for(i = 0; i < [currentOptions count]; i++)
    {
      option = [currentOptions objectAtIndex: i];
      if([cmdArgument isEqualToString: [option name]])
      {
        optionIndex = i;
        break;
      }
    }

    if(optionIndex >= 0)
    {
      if([option isSet])
        T4Error(@"CommandLine: option %@ is set twice", [option name]);
      [currentCmdArguments removeObjectAtIndex: 0];
      [option read: currentCmdArguments];
    }
    else
    {
      // Check for arguments
      int argumentIndex = -1;
      for(i = 0; i < [currentArguments count]; i++)
      {
        argument = [currentArguments objectAtIndex: i];
        if(![argument isSet])
        {
          argumentIndex = i;
          break;
        }
      }
       
      if(argumentIndex >= 0)
        [argument read: currentCmdArguments];
      else
        T4Error(@"CommandLine: parse error near <%@>. Too many arguments.", cmdArgument);
    }    
  }

  // Check for empty arguments
  enumerator = [currentArguments objectEnumerator];
  while( (argument = [enumerator nextObject]) )
  {
    if(![argument isSet])
    {
      T4Message(@"CommandLine: not enough arguments! (argument <%@> is not set)", [argument name]);
      [self printHelp];
    }
  }

  [currentCmdArguments release];
  //  [processInfo release];

  return switchIndex;
}

-printHelp
{
  //  NSProcessInfo *processInfo = [[NSProcessInfo alloc] init];
  int nSwitches = [switches count];
  int i, s;
  int maxLength;

  for(i = 0; i < 76; i++)
    T4Print(@"-");
  T4Print(@"\n%@\n", genericHelp);
  for(i = 0; i < 76; i++)
    T4Print(@"-");
  T4Print(@"\n");

  for(s = 0; s < nSwitches; s++)
  {
    NSArray *currentOptions = [options objectForKey: [switches objectAtIndex: s]];
    NSArray *currentArguments = [arguments objectForKey: [switches objectAtIndex: s]];
    T4CommandLineOption *option, *argument;
    NSEnumerator *enumerator;

    if(s == 0)
    {
      T4Print(@"#\n");
      //      T4Print(@"# usage: %@", [processInfo processName]);
      T4Print(@"# usage: %@", processName);
    }
    else
    {
      T4Print(@"\n#\n");
      //     T4Print(@"# or: %@ %@", [processInfo processName], [switches objectAtIndex: s]);
      T4Print(@"# or: %@ %@", processName, [switches objectAtIndex: s]);
    }
    if([currentOptions count] > 0)
      T4Print(@" [options]");
    
    enumerator = [currentArguments objectEnumerator];
    while( (argument = [enumerator nextObject]) )
      T4Print(@" <%@>", [argument name]);
    T4Print(@"\n#\n");

    // Cherche la longueur max du param
    maxLength = 0;
    enumerator = [currentArguments objectEnumerator];
    while( (argument = [enumerator nextObject]) )
    {
      int laurence = [[argument name] length]+2;
      
      if(maxLength < laurence)
        maxLength = laurence;
    }

    enumerator = [currentOptions objectEnumerator];
    while( (option = [enumerator nextObject]) )
    {
      int laurence = [[option name] length]+[[option type] length]+1;

      if(maxLength < laurence)
        maxLength = laurence;
    }

    // Imprime le bordel
    T4Print(@"\nArguments:\n");
    enumerator = [currentArguments objectEnumerator];
    while( (argument = [enumerator nextObject]) )
    {
      NSString *argumentName = [argument name];
      NSString *argumentType = [argument type];
      NSString *argumentHelp = [argument help];

      int z = [argumentName length]+2;
      T4Print(@" <%@>", argumentName);
      for(i = 0; i < maxLength+1-z; i++)
        T4Print(@" ");
      T4Print(@"-> %@ (%@)\n", argumentHelp, argumentType);
    }

    enumerator = [currentOptions objectEnumerator];
    while( (option = [enumerator nextObject]) )
    {
      NSString *optionName = [option name];
      NSString *optionType = [option type];
      NSString *optionHelp = [option help];
      NSString *optionTextValue = [option textValue];

      // Text
      if(![optionName length])
        T4Print(@"%@\n", optionHelp);
      else
      {
        int z = [optionName length]+[optionType length]+1;
        T4Print(@" %@ %@", optionName, optionType);
        for(i = 0; i < maxLength+1-z; i++)
          T4Print(@" ");
        if(optionTextValue)
          T4Print(@"-> %@ [%@]\n", optionHelp, optionTextValue);
        else
          T4Print(@"-> %@\n", optionHelp);
      }
    }
  }

  //  [processInfo release];
  exit(-1);
  return self;
}

-addText: (NSString*)aText
{
  NSMutableArray *currentOptions = [options objectForKey: currentSwitch];
  T4CommandLineOption *option = [[T4CommandLineOption alloc] initWithName: @"" type: @"" help: aText];

  [currentOptions addObject: option];
  [allocator keepObject: option];
  return self;
}

-addMasterSwitch: (NSString*)aSwitch
{
  NSMutableArray *currentOptions = [[NSMutableArray alloc] init];
  NSMutableArray *currentArguments = [[NSMutableArray alloc] init];
  
  [options setObject: currentOptions forKey: aSwitch];
  [arguments setObject: currentArguments forKey: aSwitch];
  [switches addObject: aSwitch];
  currentSwitch = aSwitch;

  [allocator retainAndKeepObject: aSwitch];
  [allocator keepObject: currentOptions];
  [allocator keepObject: currentArguments];
  return self;
}

-addOption: (T4CommandLineOption*)option
{
  NSMutableArray *currentOptions = [options objectForKey: currentSwitch];
  [currentOptions addObject: option];
  [allocator retainAndKeepObject: option]; //arg: si c'est pas retained???
  return self;
}

-addIntOption: (NSString*)aName at: (int*)anAddress default: (int)aDefault help: (NSString*)aHelp
{
  T4IntCommandLineOption *option = [T4IntCommandLineOption alloc];
  [option initWithName: aName at: anAddress default: aDefault help: aHelp];
  [allocator keepObject: option];
  return [self addOption: option];
}

-addRealOption: (NSString*)aName at: (real*)anAddress default: (real)aDefault help: (NSString*)aHelp
{
  T4RealCommandLineOption *option = [T4RealCommandLineOption alloc];
  [option initWithName: aName at: anAddress default: aDefault help: aHelp];
  [allocator keepObject: option];
  return [self addOption: option];
}

-addBoolOption: (NSString*)aName at: (BOOL*)anAddress default: (BOOL)aDefault help: (NSString*)aHelp
{
  T4BoolCommandLineOption *option = [T4BoolCommandLineOption alloc];
  [option initWithName: aName at: anAddress default: aDefault help: aHelp];
  [allocator keepObject: option];
  return [self addOption: option];
}

-addStringOption: (NSString*)aName at: (NSString**)anAddress default: (NSString*)aDefault help: (NSString*)aHelp
{
  T4StringCommandLineOption *option = [T4StringCommandLineOption alloc];
  [option initWithName: aName at: anAddress default: aDefault help: aHelp];
  [allocator keepObject: option];
  return [self addOption: option];
}

-addArgument: (T4CommandLineOption*)argument
{
  NSMutableArray *currentArguments = [arguments objectForKey: currentSwitch];
  [currentArguments addObject: argument];
  [allocator retainAndKeepObject: argument]; //arg: si c'est pas retained???
  return self;
}

-addIntArgument: (NSString*)aName at: (int*)anAddress help: (NSString*)aHelp
{
  T4IntCommandLineOption *option = [T4IntCommandLineOption alloc];
  [option initWithName: aName at: anAddress default: 0 help: aHelp];
  [allocator keepObject: option];
  return [self addArgument: option];
}

-addRealArgument: (NSString*)aName at: (real*)anAddress help: (NSString*)aHelp
{
  T4RealCommandLineOption *option = [T4RealCommandLineOption alloc];
  [option initWithName: aName at: anAddress default: 0 help: aHelp];
  [allocator keepObject: option];
  return [self addArgument: option];
}

-addStringArgument: (NSString*)aName at: (NSString**)anAddress help: (NSString*)aHelp
{
  T4StringCommandLineOption *option = [T4StringCommandLineOption alloc];
  [option initWithName: aName at: anAddress default: @"" help: aHelp];
  [allocator keepObject: option];
  return [self addArgument: option];
}

@end
