#import "T4Criterion.h"

@interface T4AbsCriterion : T4Criterion
{
    BOOL averageWithNumberOfRows;
    BOOL averageWithNumberOfColumns;
}

-initWithNumberOfInputs: (int)aNumInputs;

-setAveragesWithNumberOfRows: (BOOL)aFlag;
-setAveragesWithNumberOfColumns: (BOOL)aFlag;

@end
