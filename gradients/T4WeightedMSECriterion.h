#import "T4Criterion.h"

@interface T4WeightedMSECriterion : T4Criterion
{
    BOOL averageWithNumberOfRows;
    BOOL averageWithNumberOfColumns;
}

-initWithNumberOfInputs: (int)aNumInputs;
-(real)forwardExampleAtIndex: (int)anIndex inputs: (T4Matrix*)someInputs;
-(T4Matrix*)backwardExampleAtIndex: (int)anIndex inputs: (T4Matrix*)someInputs;

-setAveragesWithNumberOfRows: (BOOL)aFlag;
-setAveragesWithNumberOfColumns: (BOOL)aFlag;

@end
