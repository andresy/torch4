#import "T4Linear.h"
#import "T4Random.h"

@implementation T4Linear

-initWithNumberOfInputs: (int)aNumInputs numberOfOutputs: (int)aNumOutputs
{
  if( (self = [super initWithNumberOfInputs: aNumInputs numberOfOutputs: aNumOutputs
                     numberOfParameters: (aNumInputs+1)*aNumOutputs]) )
  {
    real *parametersAddr, *gradParametersAddr;

    [self addRealOption: @"weight decay" address: &weightDecay initValue: 0];
    [self addBoolOption: @"partial backpropagation" address: &partialBackpropagation initValue: NO];

    parametersAddr = [[parameters objectAtIndex: 0] realData];
    gradParametersAddr = [[gradParameters objectAtIndex: 0] realData];
    
    weights = [[T4Matrix alloc] initWithData: parametersAddr numberOfRows: numOutputs numberOfColumns: numInputs stride: -1];
    biases = [[T4Matrix alloc] initWithData: parametersAddr+numInputs*numOutputs numberOfRows: numOutputs numberOfColumns: numInputs stride: -1];
    gradWeights = [[T4Matrix alloc] initWithData: gradParametersAddr numberOfRows: numOutputs numberOfColumns: numInputs stride: -1];
    gradBiases = [[T4Matrix alloc] initWithData: gradParametersAddr+numInputs*numOutputs numberOfRows: numOutputs numberOfColumns: numInputs stride: -1];

    [self reset];
  }

  return self;
}

-reset
{
  // Note: just to be compatible with "Torch II Dev"
  real *weightsAddr = [weights realData];
  real *biasesAddr = [biases realData];
  real bound = 1./sqrt((real)numInputs);
  int i, j;

  for(i = 0; i < numOutputs; i++)
  {
    for(j = 0; j < numInputs; j++)
      weightsAddr[j] = [T4Random uniformBoundedWithValue: -bound andValue: bound];
    weightsAddr += [weights stride];
    biasesAddr[i] = [T4Random uniformBoundedWithValue: -bound andValue: bound];
  }
  return self;
}

-(T4Matrix*)forwardMatrix: (T4Matrix*)anInputMatrix
{
  [outputs resizeWithNumberOfColumns: [anInputMatrix numberOfColumns]];
  [outputs copyMatrix: biases];
  [outputs dotValue: 1. addValue: 1. dotMatrix: weights dotMatrix: anInputMatrix];
  return outputs;
}

-(T4Matrix*)backwardMatrix: (T4Matrix*)gradOutputMatrix inputs: (T4Matrix*)anInputMatrix
{
  [gradInputs resizeWithNumberOfColumns: [anInputMatrix numberOfColumns]];
//  [gradInputs zero];

  if(!partialBackpropagation)
    [gradInputs dotValue: 0. addValue: 1. dotTrMatrix: weights dotMatrix: gradOutputMatrix];

  [gradWeights dotValue: 1. addValue: 1. dotMatrix: gradOutputMatrix dotTrMatrix: anInputMatrix];
  [gradBiases addValue: 1. dotSumMatrixColumns: gradOutputMatrix];

  if(weightDecay != 0)
    [gradWeights addValue: weightDecay dotMatrix: weights];

  return gradInputs;
}

@end
