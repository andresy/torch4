#import "T4Allocator.h"

@implementation T4Allocator

-init
{
  if( (self = [super init]) )
    objects = nil;

  return self;
}

-(void)keepObject:(NSObject*)anObject
{
  int index;
  
  if(!anObject)
    return;

  if(!objects)
    objects = [[NSMutableArray alloc] init];
  
  index = [objects indexOfObjectIdenticalTo: anObject];

  if(index == NSNotFound)
    [objects addObject: anObject];
}

-(void)retainAndKeepObject:(NSObject*)anObject
{
  int index;

  if(!objects)
    objects = [[NSMutableArray alloc] init];
  
  index = [objects indexOfObjectIdenticalTo: anObject];

  if(index == NSNotFound)
  {
    [objects addObject: anObject];
    [anObject retain];
  }
}

-(void)freeObject:(NSObject*)anObject
{
  int index;

  if(!anObject)
    return;

  index = [objects indexOfObjectIdenticalTo: anObject];

  if(index == NSNotFound)
    T4Error(@"Allocator: cannot free an object which is not mine!");
  else
  {
    NSObject *object = [objects objectAtIndex: index];
    [objects removeObjectAtIndex: index];
    [object release];
  }
}

-(void)dealloc
{
  int i;
  int nObjects = [objects count];

  for(i = nObjects-1; i >= 0; i--)
  {
    NSObject *object = [objects objectAtIndex: i];
    [objects removeObjectAtIndex: i];
    [object release];
  }
  [objects release];
  [super dealloc];
}

+(void*)sysAlloc: (int)size
{
  void *ptr;

  if(size <= 0)
    return(nil);

  ptr = malloc(size);

  if(!ptr)
    T4Error(@"Allocator: not enough memory. Buy new ram!!!");

  return(ptr);
}

+(void)sysFree: (void*)ptr
{
  if(ptr)
    free(ptr);
}

@end
