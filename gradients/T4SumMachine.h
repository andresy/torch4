#import "T4GradientMachine.h"

@interface T4SumMachine : T4GradientMachine
{
    int numMachines;
}

-initWithNumberOfMachines: (int)aNumMachines numberOfInputs: (int)aNumInputs;

-(T4Matrix*)forwardMatrix: (T4Matrix*)someInputs;
-(T4Matrix*)backwardMatrix: (T4Matrix*)someGradOutputs inputs: (T4Matrix*)someInputs;

@end
