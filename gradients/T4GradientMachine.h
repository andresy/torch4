#import "T4Object.h"
#import "T4Machine.h"
#import "T4Matrix.h"
#import "T4Criterion.h"
#import "T4Measurer.h"

@interface T4GradientMachine : T4Object <T4Machine>
{
    int numInputs;
    int numOutputs;

    NSMutableArray *parameters;
    NSMutableArray *gradParameters;

    T4Matrix *gradInputs;
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
-(T4Matrix*)backwardMatrix: (T4Matrix*)gradOutputMatrix inputs: (T4Matrix*)anInputMatrix;

-reset;
-setPartialBackpropagation: (BOOL)aFlag;
-setEndAccuracy: (real)aValue;
-setLearningRate: (real)aValue;
-setLearningRateDecay: (real)aValue;
-setMaxNumberOfIterations: (int)aValue;
-setShuffles: (BOOL)aFlag;

-(void)setCriterion: (T4Criterion*)aCriterion;
-(void)trainWithDataset: (NSArray*)aDataset measurers: (NSArray*)someMeasurers;
-(void)testWithMeasurers: (NSArray*)someMeasurers;

-(int)numberOfInputs;
-(int)numberOfOutputs;
-(T4Matrix*)outputs;
-(T4Matrix*)gradInputs;
-(NSArray*)parameters;
-(NSArray*)gradParameters;

@end
