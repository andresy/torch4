#import "T4GradientMachine.h"

@interface T4SoftMax : T4GradientMachine
{
    real shift;
    BOOL computeShift;
}

-initWithNumberOfUnits: (int)numUnits;

-setShift: (real)aValue;
-setComputesShift: (BOOL)aFlag;

@end
