#import "T4GradientMachine.h"

@interface T4ConcatMachine : T4GradientMachine
{
    NSMutableArray *machines;
    T4Matrix *gradOutputs;
    int *offsets;
}

-init;
-addMachine: (T4GradientMachine*)aMachine;
-(T4Matrix*)forwardMatrix: (T4Matrix*)anInputMatrix;
-(T4Matrix*)backwardMatrix: (T4Matrix*)gradOutputMatrix inputs: (T4Matrix*)anInputMatrix;

@end
