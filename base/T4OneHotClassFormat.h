#import "T4ClassFormat.h"

@interface T4OneHotClassFormat : T4ClassFormat
{
}

-initWithNumberOfClasses: (int)aNumClasses;
-initWithDataset: (NSArray*)aDataset;

// primitive:
-(int)classFromRealData: (real*)aVector;

@end
