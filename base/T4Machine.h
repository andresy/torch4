#import "T4General.h"
#import "T4Measurer.h"
#import "T4Allocator.h"

T4Allocator *T4ExtractMeasurers(NSArray *someMeasurers, NSArray *aTrainingSet,
                                 NSArray **someSortedDatasets, NSArray **someSortedMeasurers);

@protocol T4Machine
-(void)reset;
-(void)trainWithDataset: (NSArray*)aDataset measurers: (NSArray*)someMeasurers;
-(void)testWithMeasurers: (NSArray*)someMeasurers;
@end
