#import "T4CommandLineOption.h"

@implementation T4CommandLineOption

-init
{
  if( (self = [super init]) )
  {
    name = nil;
    type = nil;
    help = nil;
    isSet = NO;
  }
  
  return self;
}

-initWithName: (NSString*)aName type: (NSString*)aType help: (NSString*)aHelp
{
  if( (self = [super init]) )
  {
    name = aName;
    type = aType;
    help = aHelp;
    
    [allocator retainAndKeepObject: name];
    [allocator retainAndKeepObject: type];
    [allocator retainAndKeepObject: help];
  }
  
  return self;
}

-read: (NSMutableArray*)arguments
{
  return self;
}

-initToDefaultValue;
{
  return self;
}

-(NSString*)textValue
{
  return nil;
}

-(BOOL)isSet
{
  return isSet;
}

-(NSString*)type
{
  return type;
}

-(NSString*)name
{
  return name;
}

-(NSString*)help
{
  return help;
}

@end


@implementation T4IntCommandLineOption

-initWithName: (NSString*)aName at: (int*)anAddress default: (int)aDefaultValue help: (NSString*)aHelp
{
  if( (self = [super initWithName: aName type: @"<int>" help: aHelp]) )
  {
    address = anAddress;
    defaultValue = aDefaultValue;
  }

  return self;
}

-read: (NSMutableArray*)arguments
{
  if([arguments count] > 0)
  {
    NSScanner *scanner = [[NSScanner alloc] initWithString: [arguments objectAtIndex: 0]];
    if(![scanner scanInt: address])
      T4Error(@"IntCommandLineOption: <%@> is not an integer value!", [arguments objectAtIndex: 0]);
    
    [arguments removeObjectAtIndex: 0];
    [scanner release];
  }
  else
    T4Error(@"IntCommandLineOption: cannot correctly set <%@>", name);
  
  isSet = YES;

  return self;
}

-initToDefaultValue
{
  *address = defaultValue;
  return self;
}

-(NSString*)textValue
{
  if(isSet)
    return [[[NSString alloc] initWithFormat: @"%d", *address] autorelease];
  else
    return [[[NSString alloc] initWithFormat: @"%d", defaultValue] autorelease];
}

@end

@implementation T4RealCommandLineOption

-initWithName: (NSString*)aName at: (real*)anAddress default: (real)aDefaultValue help: (NSString*)aHelp
{
  if( (self = [super initWithName: aName type: @"<real>" help: aHelp]) )
  {
    address = anAddress;
    defaultValue = aDefaultValue;
  }
  
  return self;
}

-read: (NSMutableArray*)arguments
{
  if([arguments count] > 0)
  {
    NSScanner *scanner = [[NSScanner alloc] initWithString: [arguments objectAtIndex: 0]];
    if(![scanner scanReal: address])
      T4Error(@"RealCommandLineOption: <%@> is not an real value!", [arguments objectAtIndex: 0]);
    
    [arguments removeObjectAtIndex: 0];
    [scanner release];
  }
  else
    T4Error(@"RealCommandLineOption: cannot correctly set <%@>", name);
  
  isSet = YES;

  return self;
}

-initToDefaultValue
{
  *address = defaultValue;
  return self;
}

-(NSString*)textValue
{
  if(isSet)
    return [[[NSString alloc] initWithFormat: @"%g", *address] autorelease];
  else
    return [[[NSString alloc] initWithFormat: @"%g", defaultValue] autorelease];
}

@end

@implementation T4BoolCommandLineOption

-initWithName: (NSString*)aName at: (BOOL*)anAddress default: (BOOL)aDefaultValue help: (NSString*)aHelp
{
  if( (self = [super initWithName: aName type: @"" help: aHelp]) )
  {
    address = anAddress;
    defaultValue = aDefaultValue;
  }
  
  return self;
}

-read: (NSMutableArray*)arguments
{
  *address = !defaultValue;
  isSet = YES;
  return self;
}

-initToDefaultValue
{
  *address = defaultValue;
  return self;
}

-(NSString*)textValue
{
  BOOL res = (isSet ? *address : defaultValue);
  
  if(res)
    return [[[NSString alloc] initWithString: @"yes"] autorelease];
  else
    return [[[NSString alloc] initWithFormat: @"no"] autorelease];
}

@end

@implementation T4StringCommandLineOption

-initWithName: (NSString*)aName at: (NSString**)anAddress default: (NSString*)aDefaultValue help: (NSString*)aHelp
{
  if( (self = [super initWithName: aName type: @"<string>" help: aHelp]) )
  {
    address = anAddress;
    defaultValue = aDefaultValue;
  }
  
  return self;
}

-read: (NSMutableArray*)arguments
{
  if([arguments count] > 0)
  {
    *address = [[[NSString alloc] initWithString: [arguments objectAtIndex: 0]] keepWithAllocator: allocator];
    [arguments removeObjectAtIndex: 0];
  }
  else
    T4Error(@"StringCommandLineOption: cannot correctly set <%@>", name);
  
  isSet = YES;

  return self;
}

-initToDefaultValue
{
  *address = [[[NSString alloc] initWithString: defaultValue] keepWithAllocator: allocator];
  return self;
}

-(NSString*)textValue
{
  if(isSet)
    return [[[NSString alloc] initWithString: *address] autorelease];
  else
    return [[[NSString alloc] initWithString: defaultValue] autorelease];
}

@end
