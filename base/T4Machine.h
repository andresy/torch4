#import "T4General.h"

@protocol T4Machine
-(void)train(NSArray *aDataset, NSArray *someMeasurers);
-(void)test(NSArray *someMeasurers);
@end
