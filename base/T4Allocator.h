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
-(id*)allocIdArrayWithCapacity: (int)aCapacity;
-(char*)allocCharArrayWithCapacity: (int)aCapacity;
-(int*)allocIntArrayWithCapacity: (int)aCapacity;
-(real*)allocRealArrayWithCapacity: (int)aCapacity;
-(BOOL*)allocBoolArrayWithCapacity: (int)aCapacity;

-(void*)reallocByteArray: (void*)aPointer withCapacity: (int)aCapacity;
-(id*)reallocIdArray: (id*)aPointer withCapacity: (int)aCapacity;
-(char*)reallocCharArray: (void*)aPointer withCapacity: (int)aCapacity;
-(int*)reallocIntArray: (void*)aPointer withCapacity: (int)aCapacity;
-(real*)reallocRealArray: (void*)aPointer withCapacity: (int)aCapacity;
-(BOOL*)reallocBoolArray: (void*)aPointer withCapacity: (int)aCapacity;

+(void*)sysAllocByteArrayWithCapacity: (int)capacity;
+(id*)sysAllocIdArrayWithCapacity: (int)aCapacity;
+(char*)sysAllocCharArrayWithCapacity: (int)aCapacity;
+(int*)sysAllocIntArrayWithCapacity: (int)aCapacity;
+(real*)sysAllocRealArrayWithCapacity: (int)aCapacity;
+(BOOL*)sysAllocBoolArrayWithCapacity: (int)aCapacity;

+(void*)sysReallocByteArray: (void*)anAddress withCapacity: (int)capacity;
+(id*)sysReallocIdArray: (id*)aPointer withCapacity: (int)aCapacity;
+(char*)sysReallocCharArray: (void*)aPointer withCapacity: (int)aCapacity;
+(int*)sysReallocIntArray: (void*)aPointer withCapacity: (int)aCapacity;
+(real*)sysReallocRealArray: (void*)aPointer withCapacity: (int)aCapacity;
+(BOOL*)sysReallocBoolArray: (void*)aPointer withCapacity: (int)aCapacity;

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
