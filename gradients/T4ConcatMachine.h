#import "T4GradientMachine.h"

@interface T4ConcatMachine : T4GradientMachine
{
    NSMutableArray *machines;
    T4Matrix *gradOutputs;
    int *offsets;
}

-init;
-addMachine: (T4GradientMachine*)aMachine;

-setPartialBackpropagation: (BOOL)aFlag;
-(NSArray*)machines;

-(T4Matrix*)forwardMatrix: (T4Matrix*)someInputs;
-(T4Matrix*)backwardMatrix: (T4Matrix*)someGradOutputs inputs: (T4Matrix*)someInputs;

@end
