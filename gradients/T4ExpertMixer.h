#import "T4GradientMachine.h"

@interface T4ExpertMixer : T4GradientMachine
{
    int numExperts;
}

-initWithNumberOfExperts: (int)aNumExperts numberOfOutputs: (int)aNumOutputsPerExpert;
-initWithCoder: (NSCoder*)aCoder;

@end
