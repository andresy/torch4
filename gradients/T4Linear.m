#import "T4Linear.h"
#import "T4Random.h"
#import "cblas.h"

@implementation T4Linear

-initWithNumberOfInputs: (int)aNumInputs numberOfOutputs: (int)aNumOutputs
{
  if( (self = [super initWithNumberOfInputs: aNumInputs numberOfOutputs: aNumOutputs
                     numberOfParameters: (aNumInputs+1)*aNumOutputs]) )
  {
    real *parametersAddr, *gradParametersAddr;

    [self setWeightDecay: 0];

    parametersAddr = [[parameters objectAtIndex: 0] realData];
    gradParametersAddr = [[gradParameters objectAtIndex: 0] realData];
    
    weights = [[T4Matrix alloc] initWithRealData: parametersAddr numberOfRows: numInputs numberOfColumns: numOutputs stride: -1];
    biases = [[T4Matrix alloc] initWithRealData: parametersAddr+numInputs*numOutputs numberOfRows: numOutputs numberOfColumns: 1 stride: -1];
    gradWeights = [[T4Matrix alloc] initWithRealData: gradParametersAddr numberOfRows: numInputs numberOfColumns: numOutputs stride: -1];
    gradBiases = [[T4Matrix alloc] initWithRealData: gradParametersAddr+numInputs*numOutputs numberOfRows: numOutputs numberOfColumns: 1 stride: -1];

    [allocator keepObject: weights];
    [allocator keepObject: biases];
    [allocator keepObject: gradWeights];
    [allocator keepObject: gradBiases];

    [self reset];
  }

  return self;
}

-reset
{
  real *biasesData = [biases realData];
  real bound = 1./sqrt((real)numInputs);
  int i, j;

  for(i = 0; i < numOutputs; i++)
  {
    real *weightsColumn = [weights columnAtIndex: i];
    for(j = 0; j < numInputs; j++)
      weightsColumn[j] = [T4Random uniformBoundedWithValue: -bound andValue: bound];
    biasesData[i] = [T4Random uniformBoundedWithValue: -bound andValue: bound];
  }

  return self;
}

-(T4Matrix*)forwardMatrix: (T4Matrix*)someInputs
{
  [outputs resizeWithNumberOfColumns: [someInputs numberOfColumns]];
  [outputs copyMatrix: biases];
  [outputs dotValue: 1. addValue: 1. dotTrMatrix: weights dotMatrix: someInputs];
  return outputs;
}

-(T4Matrix*)backwardMatrix: (T4Matrix*)someGradOutputs inputs: (T4Matrix*)someInputs
{
  [gradWeights dotValue: 1. addValue: 1. dotMatrix: someInputs dotTrMatrix: someGradOutputs];
  [gradBiases addValue: 1. dotSumMatrixColumns: someGradOutputs];

  if(weightDecay != 0)
    [gradWeights addValue: weightDecay dotMatrix: weights];

  if(partialBackpropagation)
    return nil;
  else
  {
    [gradInputs resizeWithNumberOfColumns: [someInputs numberOfColumns]];
    [gradInputs dotValue: 0. addValue: 1. dotMatrix: weights dotMatrix: someGradOutputs];
    return gradInputs;
  }
}

-setWeightDecay: (real)aWeightDecay
{
  aWeightDecay = weightDecay;
  return self;
}

@end
