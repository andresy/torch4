#import "T4GradientMachine.h"

@interface T4Sigmoid : T4GradientMachine
{
}

-initWithNumberOfUnits: (int)numUnits;
-(T4Matrix*)forwardMatrix: (T4Matrix*)anInputMatrix;
-(T4Matrix*)backwardMatrix: (T4Matrix*)gradOutputMatrix inputs: (T4Matrix*)anInputMatrix;

@end
