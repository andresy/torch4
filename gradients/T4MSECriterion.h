#import "T4Criterion.h"

@interface T4MSECriterion : T4Criterion
{
    BOOL averageWithNumberOfRows;
    BOOL averageWithNumberOfColumns;
}

-initWithNumberOfInputs: (int)aNumInputs;
-(real)forwardExampleAtIndex: (int)anIndex inputs: (T4Matrix*)anInputMatrix;
-(T4Matrix*)backwardExampleAtIndex: (int)anIndex inputs: (T4Matrix*)anInputMatrix;

-setAveragesWithNumberOfRows: (BOOL)aFlag;
-setAveragesWithNumberOfColumns: (BOOL)aFlag;

@end
