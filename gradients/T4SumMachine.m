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

-(T4Matrix*)forwardMatrix: (T4Matrix*)someInputs
{
  real *inputData = [someInputs firstColumn];
  int inputStride = [someInputs stride];
  int i;

  [outputs resizeWithNumberOfColumns: [someInputs numberOfColumns]];
  [outputs zero];

  for(i = 0; i < numMachines; i++)
    [outputs addFromRealArray: inputData+i*numOutputs stride: inputStride];

  return outputs;
}

-(T4Matrix*)backwardMatrix: (T4Matrix*)someGradOutputs inputs: (T4Matrix*)someInputs
{
  real *gradInputData;
  int gradInputStride;
  int i;

  [gradInputs resizeWithNumberOfColumns: [someInputs numberOfColumns]];
  gradInputData = [gradInputs firstColumn];
  gradInputStride = [gradInputs stride];

  for(i = 0; i < numMachines; i++)
    [someGradOutputs copyToRealArray: gradInputData+i*numOutputs stride: gradInputStride];

  return gradInputs;
}

-initWithCoder: (NSCoder*)aCoder
{
  self = [super initWithCoder: aCoder];
  [aCoder decodeValueOfObjCType: @encode(int) at: &numMachines];
  return self;
}

-(void)encodeWithCoder: (NSCoder*)aCoder
{
  [super encodeWithCoder: aCoder];
  [aCoder encodeValueOfObjCType: @encode(int) at: &numMachines];
}

@end
