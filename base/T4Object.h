#import "T4General.h"
#import "T4Allocator.h"

@interface NSObject (T4NSObjectAllocator)
-keepWithAllocator: (T4Allocator*)anAllocator;
-retainAndKeepWithAllocator: (T4Allocator*)anAllocator;
@end

@interface T4Object : NSObject <NSCoding>
{
  T4Allocator *allocator;
}

-init;
-initWithCoder: (NSCoder*)aCoder;
-(void)encodeWithCoder: (NSCoder*)aCoder;

-subclassResponsibility:(SEL)aSel;

@end
