#import "T4Allocator.h"

@implementation T4Allocator

-init
{
  if( (self = [super init]) )
  {
    objects = nil;
    pointers = nil;
  }

  return self;
}

-(BOOL)isMyObject: (NSObject*)anObject
{
  int index;

  if(!anObject)
    return NO;

  if(!objects)
    return NO;

  index = [objects indexOfObjectIdenticalTo: anObject];

  if(index == NSNotFound)
    return NO;

  return YES;
}

-keepObject:(NSObject*)anObject
{
  int index;
  
  if(!anObject)
    return nil;

  if(!objects)
    objects = [[NSMutableArray alloc] init];
  
  index = [objects indexOfObjectIdenticalTo: anObject];

  if(index == NSNotFound)
    [objects addObject: anObject];

  return anObject;
}

-(void)freeObject:(NSObject*)anObject
{
  int index;

  if(!anObject)
    return;

  if(!objects)
    T4Error(@"Allocator: cannot free an object which is not mine!");

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

-(BOOL)isMyPointer: (void*)aPointer
{
  int index, nPointers, i;
  T4AllocatorPointer *pointer;

  if(!aPointer)
    return NO;

  if(!pointers)
    return NO;

  nPointers = [pointers count];
  index = NSNotFound;
  for(i = 0; i < nPointers; i++)
  {
    pointer = [pointers objectAtIndex: i];
    if(aPointer == [pointer address])
    {
      index = i;
      break;
    }
  }

  if(index == NSNotFound)
    return NO;
  
  return YES;
}

-(void*)keepPointer: (void*)aPointer
{
  int index, nPointers, i;
  T4AllocatorPointer *pointer;

  if(!aPointer)
    return NULL;

  if(!pointers)
    pointers = [[NSMutableArray alloc] init];

  nPointers = [pointers count];
  index = NSNotFound;
  for(i = 0; i < nPointers; i++)
  {
    pointer = [pointers objectAtIndex: i];
    if(aPointer == [pointer address])
    {
      index = i;
      break;
    }
  }

  if(index == NSNotFound)
    [pointers addObject: [[T4AllocatorPointer alloc] initWithPointer: aPointer]];

  return aPointer;
}

-(void)freePointer: (void*)aPointer
{
  int index, nPointers, i;
  T4AllocatorPointer *pointer;

  if(!aPointer)
    return;

  if(!pointers)
    T4Error(@"Allocator: cannot free a pointer which is not mine!");

  nPointers = [pointers count];
  index = NSNotFound;
  for(i = 0; i < nPointers; i++)
  {
    pointer = [pointers objectAtIndex: i];
    if(aPointer == [pointer address])
    {
      index = i;
      break;
    }
  }

  if(index == NSNotFound)
    T4Error(@"Allocator: cannot free a pointer which is not mine!");
  else
  {
    NSObject *pointer = [pointers objectAtIndex: index];
    [pointers removeObjectAtIndex: index];
    [pointer release];
  }
}


-retainAndKeepObject:(NSObject*)anObject
{
  int index;

  if(!anObject)
    return nil;

  if(!objects)
    objects = [[NSMutableArray alloc] init];
  
  index = [objects indexOfObjectIdenticalTo: anObject];

  if(index == NSNotFound)
  {
    [objects addObject: anObject];
    [anObject retain];
  }

  return anObject;
}

-(void)dealloc
{
  int i;
  int nObjects = [objects count];
  int nPointers = [pointers count];

  for(i = nObjects-1; i >= 0; i--)
  {
    NSObject *object = [objects objectAtIndex: i];
    [objects removeObjectAtIndex: i];
    [object release];
  }
  [objects release];

  for(i = nPointers-1; i >= 0; i--)
  {
    NSObject *pointer = [pointers objectAtIndex: i];
    [pointers removeObjectAtIndex: i];
    [pointer release];
  }
  [pointers release];

  [super dealloc];
}

+(void*)sysAllocWithCapacity: (int)capacity
{
  void *ptr;

  if(capacity <= 0)
    return NULL;

//  T4Message(@"j'alloc");
  ptr = malloc(capacity);

  if(!ptr)
    T4Error(@"Allocator: not enough memory. Buy new ram!!!");

  return ptr;
}

+(void*)sysRealloc: (void*)anAddress withCapacity: (int)capacity
{
  if(capacity <= 0)
  {
    if(anAddress)
      free(anAddress);
    
    return NULL;
  }

  if(anAddress)
  {
//    T4Message(@"j'realloc");
    anAddress = realloc(anAddress, capacity);
  }
  else
  {
//    T4Message(@"j'alloc [re]");
    anAddress = malloc(capacity);
  }

  if(!anAddress)
    T4Error(@"Allocator: not enough memory. Buy new ram!!!");

  return anAddress;
}

+(void)sysFree: (void*)ptr
{
  if(ptr)
    free(ptr);
}

-(id*)allocIdArrayWithCapacity: (int)aCapacity
{
  return (id*)[self keepPointer: [T4Allocator sysAllocWithCapacity: aCapacity*sizeof(id)]];
}

-(void*)allocByteArrayWithCapacity: (int)aCapacity
{
  return [self keepPointer: [T4Allocator sysAllocWithCapacity: aCapacity]];
}

-(char*)allocCharArrayWithCapacity: (int)aCapacity
{
  return (char*)[self allocByteArrayWithCapacity: aCapacity];
}


-(int*)allocIntArrayWithCapacity: (int)aCapacity
{
  return (int*)[self allocByteArrayWithCapacity: aCapacity*sizeof(int)];
}

-(real*)allocRealArrayWithCapacity: (int)aCapacity
{
  return (real*)[self allocByteArrayWithCapacity: aCapacity*sizeof(real)];
}

-(BOOL*)allocBoolArrayWithCapacity: (int)aCapacity
{
  return (BOOL*)[self allocByteArrayWithCapacity: aCapacity*sizeof(BOOL)];
}

-(id*)reallocIdArray: (id*)aPointer withCapacity: (int)aCapacity
{
  return (id*)[self reallocByteArray: aPointer withCapacity: aCapacity*sizeof(id)];
}

-(void*)reallocByteArray: (void*)aPointer withCapacity: (int)aCapacity
{
  T4AllocatorPointer *pointer = nil;
  void *anAddress;
  int nPointers, index, i;

  if(!aPointer)
    return [self allocByteArrayWithCapacity: aCapacity];

  if(!pointers)
    T4Error(@"Allocator: cannot realloc a pointer which is not mine!");

  nPointers = [pointers count];
  index = NSNotFound;
  for(i = 0; i < nPointers; i++)
  {
    pointer = [pointers objectAtIndex: i];
    if(aPointer == [pointer address])
    {
      index = i;
      break;
    }
  }

  if(index == NSNotFound)
    T4Error(@"Allocator: cannot realloc a pointer which is not mine!");

  anAddress = [T4Allocator sysRealloc: [pointer address] withCapacity: aCapacity];
  [pointer setAddress: anAddress];

  return anAddress;
}

-(char*)reallocCharArray: (void*)aPointer withCapacity: (int)aCapacity
{
  return [self reallocByteArray: aPointer withCapacity: aCapacity];
}

-(int*)reallocIntArray: (void*)aPointer withCapacity: (int)aCapacity
{
  return [self reallocByteArray: aPointer withCapacity: aCapacity*sizeof(int)];
}

-(real*)reallocRealArray: (void*)aPointer withCapacity: (int)aCapacity
{
  return [self reallocByteArray: aPointer withCapacity: aCapacity*sizeof(real)];
}

-(BOOL*)reallocBoolArray: (void*)aPointer withCapacity: (int)aCapacity
{
  return [self reallocByteArray: aPointer withCapacity: aCapacity*sizeof(BOOL)];
}

@end

@implementation T4AllocatorPointer

-initWithPointer: (void*)aPointer
{
  if( (self = [super init]) )
    address = aPointer;

  return self;
}

-(void*)address
{
  return address;
}

-(void)setAddress: (void*)anAddress
{
  address = anAddress;
}

-(void)dealloc
{
  free(address);
  [super dealloc];
}

@end
