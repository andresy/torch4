#import "T4SumMachine.h"

@implementation T4SumMachine

-initWithNumberOfMachines: (int)aNumMachines numberOfInputs: (int)aNumInputs
{
  if( (self = [super initWithNumberOfInputs: aNumMachines*aNumInputs numberOfOutputs: aNumInputs
                     numberOfParameters: 0]) )
  {
    numMachines = aNumMachines;
  }

  return self;
}

-(T4Matrix*)forwardMatrix: (T4Matrix*)anInputMatrix
{
  real *inputData = [anInputMatrix realData];
  int inputStride = [anInputMatrix stride];
  int i;

  [outputs resizeWithNumberOfColumns: [anInputMatrix numberOfColumns]];
  [outputs zero];

  for(i = 0; i < numMachines; i++)
    [outputs addFromRealData: inputData+i*numOutputs stride: inputStride];

  return outputs;
}

-(T4Matrix*)backwardMatrix: (T4Matrix*)gradOutputMatrix inputs: (T4Matrix*)anInputMatrix
{
  real *gradInputData;
  int gradInputStride;
  int i;

  [gradInputs resizeWithNumberOfColumns: [anInputMatrix numberOfColumns]];
  gradInputData = [gradInputs realData];
  gradInputStride = [gradInputs stride];

  for(i = 0; i < numMachines; i++)
    [gradOutputMatrix copyToRealData: gradInputData+i*numOutputs stride: gradInputStride];

  return gradInputs;
}

@end
