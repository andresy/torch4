#import "T4Object.h"

@implementation NSObject (T4NSObjectAllocator)

-keepWithAllocator: (T4Allocator*)anAllocator
{
  [anAllocator keepObject: self];
  return self;
}

-retainAndKeepWithAllocator: (T4Allocator*)anAllocator
{
  [anAllocator retainAndKeepObject: self];
  return self;
}

@end


@implementation T4Object

-init
{
  if( (self = [super init]) )
  {
    allocator = [[T4Allocator alloc] init];
//    T4Message(@"Allocating object <%@>", [[self class] description]);
  }
  
  return self;
}

-subclassResponsibility:(SEL)aSel
{
  NSString *selectorName = NSStringFromSelector(aSel);
  T4Error(@"Subclass <%@> should override the method <%s>", [self class], [selectorName cString]);
  return self;
}

-(void)dealloc
{
  [allocator release];
//  T4Message(@"Freeing object <%@>", [[self class] description]);
  [super dealloc];
}

@end
