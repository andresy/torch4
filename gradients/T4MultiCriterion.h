#import "T4Criterion.h"

@interface T4MultiCriterion : T4Criterion
{
    NSArray *criterions;
    real *weights;
}

-initWithCriterions: (NSArray*)someCriterions weights: (real*)someWeights;

@end
