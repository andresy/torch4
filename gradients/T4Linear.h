#import "T4GradientMachine.h"

@interface T4Linear :  T4GradientMachine
{
    real weight_decay;
    real *weights;
    real *biases;
    real *gradWeights;
    real *gradBias;
}

-initWithNumberOfInputs: (int)aNumInputs numberOfOutputs: (int)aNumOutputs;

-(T4Matrix*)forwardMatrix: (T4Matrix*)anInputMatrix;
-(T4Matrix*)backwardMatrix: (T4Matrix*)gradOutputMatrix inputs: (T4Matrix*)anInputMatrix;

@end
