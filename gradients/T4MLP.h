#import "T4SequentialMachine.h"

@interface T4MLP : T4SequentialMachine
{
}

-initWithNumberOfLayers: (int)aNumLayers layers: (int)aNumInputs, ...;
-setWeightDecay: (real)aWeightDecay;

@end
