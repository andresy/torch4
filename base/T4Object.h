#import "T4General.h"
#import "T4Allocator.h"

@interface T4ObjectOption : NSObject
{
  void *address;
  int size;
}

-initWithAddress: (void*)anAddress size: (int)aSize;

-(void*)address;
-(int)size;

@end

@interface T4Object : NSObject
{
  NSMutableDictionary *internalObjectOptions;
  T4Allocator *allocator;
}

-init;
-(void)addOption: (NSString*)anOption address:(void*)anAddress size:(int)aSize;
-(void)addIntOption: (NSString*)anOption address:(int*)anAddress initValue:(int)aValue;
-(void)addRealOption: (NSString*)anOption address:(real*)anAddress initValue:(real)aValue;
-(void)addBoolOption: (NSString*)anOption address:(BOOL*)anAddress initValue:(BOOL)aValue;
-(void)addObjectOption: (NSString*)anOption address:(NSObject**)anAddress initValue:(NSObject*)aValue;

-(void)setOption: (NSString*)anOption withValueAtAddress: (void*)anAddress;
-(void)setIntOption: (NSString*)anOption withValue: (int)aValue;
-(void)setRealOption: (NSString*)anOption withValue: (real)aValue;
-(void)setBoolOption: (NSString*)anOption withValue: (BOOL)aValue;
-(void)setObjectOption: (NSString*)anOption withValue: (NSObject*)aValue;

@end
