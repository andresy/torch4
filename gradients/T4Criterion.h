#import "T4Object.h"

@interface T4Criterion : T4Object
{
    NSArray *dataset;
    real output;
}

-(T4Matrix*)forwardMatrix: (T4Matrix*)aMatrix;
-(T4Matrix*)backwardTargets: (T4Matrix*)aTargetMatrix inputs: (T4Matrix*)anInputMatrix;
-(void)setDataset: (NSArray*)aDataset;

-(real)output;

@end
