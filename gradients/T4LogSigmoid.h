#import "T4GradientMachine.h"

@interface T4LogSigmoid : T4GradientMachine
{
    T4Matrix *buffer;
}

-initWithNumberOfUnits: (int)numUnits;
-(T4Matrix*)forwardMatrix: (T4Matrix*)someInputs;
-(T4Matrix*)backwardMatrix: (T4Matrix*)someGradOutputs inputs: (T4Matrix*)someInputs;

@end
