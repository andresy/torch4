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

-(void*)allocByteArrayOfSize: (int)aSize;
-(char*)allocCharArrayOfSize: (int)aSize;
-(int*)allocIntArrayOfSize: (int)aSize;
-(real*)allocRealArrayOfSize: (int)aSize;

+(void*)sysAlloc: (int)size;
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
