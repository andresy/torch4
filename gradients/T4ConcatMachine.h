#import "T4GradientMachine.h"

@interface T4ConcatMachine : T4GradientMachine
{
    NSMutableArray *machines;
    T4Matrix *gradOutputs;
    int *offsets;
}

-init;
-addMachine: (T4GradientMachine*)aMachine;
-(NSArray*)machines;

@end
