#import "T4GradientMachine.h"

@interface T4SelectInputs : T4GradientMachine
{
    int *selectedInputs;
    int numSelectedInputs;
}

-initWithNumberOfInputs: (int)aNumInputs selectedInputs: (int*)someSelectedInputs numberOfSelectedInputs: (int)aNumSelectedInputs;

@end
