#import "T4ClassFormat.h"

@interface T4TwoClassFormat : T4ClassFormat
{
    real *classLabelArray;
}

-initWithLabel: (real)aLabel1 label: (real)aLabel2;
-initWithDataset: (NSArray*)aDataset;

// primitive:
-(int)classFromRealData: (real*)aVector;

@end
