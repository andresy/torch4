#import "T4ConnectedMachine.h"

@interface T4MLP : T4ConnectedMachine
{
    BOOL *isLinear;
}

-initWithNumberOfLayers: (int)aNumLayers layers: (int)aNumInputs, ...;
-setWeightDecay: (real)aWeightDecay;

@end
