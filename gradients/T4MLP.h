#import "T4SequentialMachine.h"

@interface T4MLP : T4SequentialMachine
{
    BOOL *isLinear;
}

-initWithNumberOfLayers: (int)aNumLayers layers: (int)aNumInputs, ...;
-setWeightDecay: (real)aWeightDecay;

@end
