#import "T4GradientMachine.h"

@interface T4SequentialMachine : T4GradientMachine
{
    NSMutableArray *machines;
}

-init;
-addMachine: (T4GradientMachine*)aMachine;

-(NSArray*)machines;

@end
