#import "T4Criterion.h"
#import "T4ClassFormat.h"

@interface T4ClassMSECriterion : T4Criterion
{
    T4ClassFormat *classFormat;
    BOOL averageWithNumberOfRows;
    BOOL averageWithNumberOfColumns;
}

-initWithClassFormat: (T4ClassFormat*)aClassFormat;
-(real)forwardExampleAtIndex: (int)anIndex inputs: (T4Matrix*)someInputs;
-(T4Matrix*)backwardExampleAtIndex: (int)anIndex inputs: (T4Matrix*)someInputs;

-setAveragesWithNumberOfRows: (BOOL)aFlag;
-setAveragesWithNumberOfColumns: (BOOL)aFlag;

@end
