#import "T4GradientMachine.h"

@interface T4ExpertLogMixer : T4GradientMachine
{
    int numExperts;
}

-initWithNumberOfExperts: (int)aNumExperts numberOfOutputs: (int)aNumOutputsPerExpert;

@end
