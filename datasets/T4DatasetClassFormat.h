#import "T4ClassFormat.h"

@interface T4DatasetClassFormat : T4ClassFormat
{
    BOOL directEncoding;
}

+(int)numberOfClassesInDataset: (NSArray*)aDataset;

-initWithClassTable: (T4Matrix*)aClassTable;
-initWithDataset: (NSArray*)aDataset classAgainstOthers: (int)aClassIndex;

-initWithNumberOfClasses: (int)aNumClasses;
-initWithDataset: (NSArray*)aDataset;

@end
