#import "T4Object.h"
#import "T4Matrix.h"
#import "T4Machine.h"
#import "T4Measurer.h"

@interface T4Distribution : T4Object <T4Machine>
{
  int numInputs;
  real logProbability;
  real endAccuracy;

  NSMutableArray *parameters;
  NSMutableArray *accumulators;

  int maxIteration;
    
}

-initWithNumberOfInputs: (int)aNumInputs numberOfParameters: (int)aNumParams;


-(real)forwardInputs: (T4Matrix*)someInputs;
-backwardLogPosterior: (real)aLogPosterior inputs: (T4Matrix*)someInputs;
-update;

-reset;
-resetAccumulators;
-setEndAccuracy: (real)aValue;
-setMaxNumberOfIterations: (int)aValue;

-trainWithDataset: (NSArray*)aDataset measurers: (NSArray*)someMeasurers;
-testWithMeasurers: (NSArray*)someMeasurers;

-(int)numberOfInputs;
-(NSArray*)parameters;
-resetWithDataset: (NSArray*)aDataset;

@end
