#import "T4GradientMachine.h"

@interface T4LogSigmoid : T4GradientMachine
{
    T4Matrix *buffer;
}

-initWithNumberOfUnits: (int)numUnits;

@end
