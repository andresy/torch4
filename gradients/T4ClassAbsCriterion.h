#import "T4Criterion.h"
#import "T4ClassFormat.h"

@interface T4ClassAbsCriterion : T4Criterion
{
    T4ClassFormat *datasetClassFormat;
    T4ClassFormat *inputClassFormat;
    BOOL averageWithNumberOfRows;
    BOOL averageWithNumberOfColumns;
}

-initWithDatasetClassFormat: (T4ClassFormat*)aClassFormat inputClassFormat: (T4ClassFormat*)anotherClassFormat;

-setAveragesWithNumberOfRows: (BOOL)aFlag;
-setAveragesWithNumberOfColumns: (BOOL)aFlag;

@end
