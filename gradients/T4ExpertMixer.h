#import "T4GradientMachine.h"

@interface T4ExpertMixer : T4GradientMachine
{
    int numExperts;
}

-initWithNumberOfExperts: (int)aNumExperts numberOfOutputs: (int)aNumOutputsPerExpert;
-(T4Matrix*)forwardMatrix: (T4Matrix*)someInputs;
-(T4Matrix*)backwardMatrix: (T4Matrix*)someGradOutputs inputs: (T4Matrix*)someInputs;

@end
