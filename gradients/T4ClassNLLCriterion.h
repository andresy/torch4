#import "T4Criterion.h"
#import "T4ClassFormat.h"

@interface T4ClassNLLCriterion : T4Criterion
{
    T4ClassFormat *classFormat;
}

-initWithDatasetClassFormat: (T4ClassFormat*)aClassFormat;

@end
