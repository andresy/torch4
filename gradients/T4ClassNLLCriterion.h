#import "T4Criterion.h"
#import "T4ClassFormat.h"

@interface T4ClassNLLCriterion : T4Criterion
{
    T4ClassFormat *inputClassFormat;
    T4ClassFormat *datasetClassFormat;
}

-initWithInputClassFormat: (T4ClassFormat*)aClassFormat datasetClassFormat: (T4ClassFormat*)anotherClassFormat;
-initWithClassFormat: (T4ClassFormat*)aClassFormat;

-(real)forwardExampleAtIndex: (int)anIndex inputs: (T4Matrix*)someInputs;
-(T4Matrix*)backwardExampleAtIndex: (int)anIndex inputs: (T4Matrix*)someInputs;

@end
