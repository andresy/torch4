#import "T4Criterion.h"
#import "T4ClassFormat.h"

@interface T4ClassNLLCriterion : T4Criterion
{
    T4ClassFormat *classFormat;
}

-initWithClassFormat: (T4ClassFormat*)aClassFormat;
-(real)forwardExampleAtIndex: (int)anIndex inputs: (T4Matrix*)anInputMatrix;
-(T4Matrix*)backwardExampleAtIndex: (int)anIndex inputs: (T4Matrix*)anInputMatrix;

@end
