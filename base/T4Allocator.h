#import "T4General.h"

@interface T4Allocator : NSObject
{
  NSMutableArray *objects;
}

-init;
-(void)keepObject:(NSObject*)anObject;
-(void)retainAndKeepObject:(NSObject*)anObject;
-(void)freeObject:(NSObject*)anObject;
-(void)dealloc;

+(void*)sysAlloc: (int)size;
+(void)sysFree: (void*)ptr;

@end
