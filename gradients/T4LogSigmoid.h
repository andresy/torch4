#import "T4GradientMachine.h"

@interface T4LogSigmoid : T4GradientMachine
{
    T4Matrix *buffer;
}

-initWithNumberOfUnits: (int)numUnits;
-(T4Matrix*)forwardMatrix: (T4Matrix*)anInputMatrix;
-(T4Matrix*)backwardMatrix: (T4Matrix*)gradOutputMatrix inputs: (T4Matrix*)anInputMatrix;

@end
