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
-(real)forwardMatrix: (T4Matrix*)aMatrix;
-(T4Matrix*)backwardExampleAtIndex: (int)anIndex inputs: (T4Matrix*)anInputMatrix;

-setDataset: (NSArray*)aDataset;
-(real)output;

@end
