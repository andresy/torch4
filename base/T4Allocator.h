#import "T4General.h"

@interface T4Allocator : NSObject
{
  NSMutableArray *objects;
  NSMutableArray *pointers;
}

-init;
-keepObject:(NSObject*)anObject;
-(void*)keepPointer: (void*)aPointer;
-retainAndKeepObject:(NSObject*)anObject;
-(void)freeObject:(NSObject*)anObject;
-(void)freePointer:(void*)aPointer;
-(void)dealloc;

-(void*)allocByteArrayWithCapacity: (int)aCapacity;
-(char*)allocCharArrayWithCapacity: (int)aCapacity;
-(int*)allocIntArrayWithCapacity: (int)aCapacity;
-(real*)allocRealArrayWithCapacity: (int)aCapacity;

-(void*)realloc: (void*)aPointer byteArrayWithCapacity: (int)aCapacity;
-(char*)realloc: (void*)aPointer charArrayWithCapacity: (int)aCapacity;
-(int*)realloc: (void*)aPointer intArrayWithCapacity: (int)aCapacity;
-(real*)realloc: (void*)aPointer realArrayWithCapacity: (int)aCapacity;

+(void*)sysAllocWithCapacity: (int)capacity;
+(void*)sysRealloc: (void*)anAddress withCapacity: (int)capacity;
+(void)sysFree: (void*)ptr;

-(BOOL)isMyObject: (NSObject*)anObject;
-(BOOL)isMyPointer: (void*)aPointer;

@end

@interface T4AllocatorPointer : NSObject
{
    void *address;
}

-initWithPointer: (void*)aPointer;
-(void)dealloc;
-(void*)address;
-(void)setAddress: (void*)anAddress;

@end
