#import "T4GradientMachine.h"

@interface T4Linear :  T4GradientMachine
{
    real weightDecay;

    T4Matrix *weights;
    T4Matrix *biases;
    T4Matrix *gradWeights;
    T4Matrix *gradBiases;
}

-initWithNumberOfInputs: (int)aNumInputs numberOfOutputs: (int)aNumOutputs;

-setWeightDecay: (real)aWeightDecay;



@end
