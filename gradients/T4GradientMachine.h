#import "T4Object.h"
#import "T4Machine.h"
#import "T4Matrix.h"
#import "T4Criterion.h"
#import "T4Measurer.h"

@interface T4GradientMachine : T4Object <T4Machine>
{
//    bool partial_backprop;
    int numInputs;
    int numOutputs;

    NSMutableArray *parameters;
    NSMutableArray *dParameters;

    T4Matrix *dInputs;
    T4Matrix *outputs;

    T4Criterion *criterion;
    real learningRate;
    real learningRateDecay;
    real endAccuracy;
    int maxIteration;
    BOOL doShuffle;
}

-initWithNumberOfInputs: (int)aNumInputs numberOfOutputs: (int)aNumOutputs numberOfParameters: (int)aNumParams;

//-(void)iterInitialize;

-(T4Matrix*)forwardMatrix: (T4Matrix*)anInputMatrix;
-(T4Matrix*)backwardMatrix: (T4Matrix*)dOutputMatrix inputs: (T4Matrix*)anInputMatrix;
//    virtual void setPartialBackprop(bool flag=true);

-(void)setCriterion: (T4Criterion*)aCriterion;
-(void)trainWithDataset: (NSArray*)aDataset measurers: (NSArray*)someMeasurers;
-(void)testWithMeasurers: (NSArray*)someMeasurers;

@end
