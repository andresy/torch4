#import "T4GradientMachine.h"

@interface T4Linear :  T4GradientMachine
{
    real weightDecay;
    BOOL partialBackpropagation;

    T4Matrix *weights;
    T4Matrix *biases;
    T4Matrix *gradWeights;
    T4Matrix *gradBiases;
}

-initWithNumberOfInputs: (int)aNumInputs numberOfOutputs: (int)aNumOutputs;

-(T4Matrix*)forwardMatrix: (T4Matrix*)anInputMatrix;
-(T4Matrix*)backwardMatrix: (T4Matrix*)gradOutputMatrix inputs: (T4Matrix*)anInputMatrix;

@end
