#import "T4Object.h"

@implementation T4ObjectOption

-initWithAddress: (void*)anAddress size: (int)aSize
{
  if( (self = [super init]) )
  {
    address = anAddress;
    size = aSize;  
  }
  
  return self;
}

-(void*)address
{
  return address;
}

-(int)size
{
  return size;
}

@end

@implementation T4Object

-init
{
  if( (self = [super init]) )
  {
    internalObjectOptions = nil;
    allocator = [[T4Allocator alloc] init];
    T4Message(@"Allocating object <%@>", [[self class] description]);
  }
  
  return self;
}

-(void)addOption: (NSString*)anOption address:(void*)anAddress size:(int)aSize
{
  T4ObjectOption *option = [[T4ObjectOption alloc] initWithAddress: anAddress size: aSize];
  [allocator keepObject: option];
  [allocator retainAndKeepObject: anOption];

  if(!internalObjectOptions)
    {
      internalObjectOptions = [[NSMutableDictionary alloc] init];
      [allocator keepObject: internalObjectOptions];
    }

  [internalObjectOptions setObject: option forKey: anOption];
}

-(void)addIntOption: (NSString*)anOption address:(int*)anAddress initValue:(int)aValue
{
  *anAddress = aValue;
  [self addOption: anOption address: anAddress size: sizeof(int)];
}

-(void)addRealOption: (NSString*)anOption address:(real*)anAddress initValue:(real)aValue
{
  *anAddress = aValue;
  [self addOption: anOption address: anAddress size: sizeof(real)];
}

-(void)addBoolOption: (NSString*)anOption address:(BOOL*)anAddress initValue:(BOOL)aValue
{
  *anAddress = aValue;
  [self addOption: anOption address: anAddress size: sizeof(BOOL)];
}

-(void)addObjectOption: (NSString*)anOption address:(NSObject**)anAddress initValue:(NSObject*)aValue
{
  *anAddress = aValue;
  [self addOption: anOption address: anAddress size: sizeof(NSObject*)];
}


-(void)setOption: (NSString*)anOption withValueAtAddress: (void*)anAddress
{
  T4ObjectOption *option = [internalObjectOptions objectForKey: anOption];

  if(!option)
    T4Error(@"Option <%@> does not exist", anOption);

  memmove([option address], anAddress, [option size]);
}

-(void)setIntOption: (NSString*)anOption withValue: (int)aValue
{
  [self setOption: anOption withValueAtAddress: &aValue];
}

-(void)setRealOption: (NSString*)anOption withValue: (real)aValue
{
  [self setOption: anOption withValueAtAddress: &aValue];
}

-(void)setBoolOption: (NSString*)anOption withValue: (BOOL)aValue
{
  [self setOption: anOption withValueAtAddress: &aValue];
}

-(void)setObjectOption: (NSString*)anOption withValue: (NSObject*)aValue
{
  [self setOption: anOption withValueAtAddress: &aValue];
}

-(void)dealloc
{
  [allocator release];
  T4Message(@"Freeing object <%@>", [[self class] description]);
  [super dealloc];
}

@end
