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

+(void*)sysAlloc: (int)capacity;
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

@end
