#import "T4GradientMachine.h"

@interface T4SelectInputs : T4GradientMachine
{
    int *selectedInputs;
    int numSelectedInputs;
    BOOL partialBackpropagation;
}

-initWithNumberOfInputs: (int)aNumInputs selectedInputs: (int*)someSelectedInputs numberOfSelectedInputs: (int)aNumSelectedInputs;

-setPartialBackpropagation: (BOOL)aFlag;

-(T4Matrix*)forwardMatrix: (T4Matrix*)someInputs;
-(T4Matrix*)backwardMatrix: (T4Matrix*)someGradOutputs inputs: (T4Matrix*)someInputs;

@end
