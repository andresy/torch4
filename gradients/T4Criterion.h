#import "T4Object.h"
#import "T4Matrix.h"

@interface T4Criterion : T4Object
{
    NSArray *dataset;
    real output;

    int numInputs;
    T4Matrix *gradInputs;
}

-initWithNumberOfInputs: (int)aNumInputs;
-(real)forwardExampleAtIndex: (int)anIndex inputs: (T4Matrix*)someInputs;
-(T4Matrix*)backwardExampleAtIndex: (int)anIndex inputs: (T4Matrix*)someInputs;

-setDataset: (NSArray*)aDataset;
-(real)output;
-(T4Matrix*)gradInputs;

-(int)numberOfInputs;

@end
