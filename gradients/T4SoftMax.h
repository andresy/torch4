#import "T4GradientMachine.h"

@interface T4SoftMax : T4GradientMachine
{
    real shift;
    BOOL computeShift;
}

-initWithNumberOfUnits: (int)numUnits;

-setShift: (real)aValue;
-setComputesShift: (BOOL)aFlag;

-(T4Matrix*)forwardMatrix: (T4Matrix*)someInputs;
-(T4Matrix*)backwardMatrix: (T4Matrix*)someGradOutputs inputs: (T4Matrix*)someInputs;

@end
