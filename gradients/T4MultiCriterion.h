#import "T4Criterion.h"

@interface T4MultiCriterion : T4Criterion
{
    NSArray *criterions;
    real *weights;
}

-initWithCriterions: (NSArray*)someCriterions weights: (real*)someWeights;

-(real)forwardExampleAtIndex: (int)anIndex inputs: (T4Matrix*)someInputs;
-(T4Matrix*)backwardExampleAtIndex: (int)anIndex inputs: (T4Matrix*)someInputs;

-setDataset: (NSArray*)aDataset;

@end
