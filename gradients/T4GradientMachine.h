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

    BOOL partialBackpropagation;

    T4Criterion *criterion;
    real learningRate;
    real learningRateDecay;
    real endAccuracy;
    int maxIteration;
    BOOL shufflesExamples;
}

-initWithNumberOfInputs: (int)aNumInputs numberOfOutputs: (int)aNumOutputs numberOfParameters: (int)aNumParams;

//-(void)iterInitialize;

-(T4Matrix*)forwardInputs: (T4Matrix*)someInputs;
-(T4Matrix*)backwardGradOutputs: (T4Matrix*)someGradOutputs inputs: (T4Matrix*)someInputs;

-reset;
-setPartialBackpropagation: (BOOL)aFlag;
-setEndAccuracy: (real)aValue;
-setLearningRate: (real)aValue;
-setLearningRateDecay: (real)aValue;
-setMaxNumberOfIterations: (int)aValue;
-setShufflesExamples: (BOOL)aFlag;

-setCriterion: (T4Criterion*)aCriterion;

-copyParametersFromMachine: (T4GradientMachine*)aMachine;

-(int)numberOfInputs;
-(int)numberOfOutputs;
-(T4Matrix*)outputs;
-(T4Matrix*)gradInputs;
-(int)numberOfParameters;
-(NSArray*)parameters;
-(NSArray*)gradParameters;

@end
