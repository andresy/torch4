#import "T4Linear.h"
#import "T4Random.h"

@implementation T4Linear

-initWithNumberOfInputs: (int)aNumInputs numberOfOutputs: (int)aNumOutputs
{
  if( (self = [super initWithNumberOfInputs: aNumInputs numberOfOutputs: aNumOutputs
                     numberOfParameters: (aNumInputs+1)*aNumOutputs]) )
  {
    real *parametersAddr, *gradParametersAddr;

    [self addRealOption: @"weight decay" address: &weight_decay initValue: 0];
    parametersAddr = [[parameters objectAtIndex: 0] data];
    gradParametersAddr = [[gradParameters objectAtIndex: 0] data];
    
    weights = parametersAddr;
    biases = parametersAddr+numInputs*numOutputs;
    gradWeights = gradParametersAddr;
    gradBiases = gradParametersAddr+numInputs*numOutputs;

    [self reset];
  }

  return self;
}

-reset
{
  // Note: just to be compatible with "Torch II Dev"
  real *weights_ = weights;
  real bound = 1./sqrt((real)n_inputs);
  int i, j;

  for(i = 0; i < numOutputs; i++)
  {
    for(j = 0; j < numInputs; j++)
      weights_[j] = [T4Random boundedUniform(-bound, bound)];
    weights_ += numInputs;
    biases[i] = [T4Random boundedUniform(-bound, bound)];
  }
  return self;
}

-(T4Matrix*)forwardMatrix: (T4Matrix*)anInputMatrix
{
  [outputs resizeWithNumberOfColumns: [anInputMatrix numberOfColumns]];
  [outputs copyMatrix: biases];
  [outputs dotValue: 1. plusValue: 1. dotMatrix: weights dotMatrix: anInputMatrix];
}

-(T4Matrix*)backwardMatrix: (T4Matrix*)gradOutputMatrix inputs: (T4Matrix*)anInputMatrix
{
  [gradInputs resizeWithNumberOfColumns: [anInputMatrix numberOfColumns]];
  [gradInputs zero];
  
  if(!partial_backprop)
  {
    for(int i = 0; i < n_inputs; i++)
      beta_[i] = 0;
    
    real *weights_ = weights;
    for(int i = 0; i < n_outputs; i++)
    {
      real z = alpha_[i];
      for(int j = 0; j < n_inputs; j++)
        beta_[j] += z * weights_[j];
      weights_ += n_inputs;
    }
  }

  real *der_weights_ = der_weights;
  for(int i = 0; i < n_outputs; i++)
  {
    real z = alpha_[i];
    for(int j = 0; j < n_inputs; j++)
      der_weights_[j] += z * f_inputs[j];
    der_weights_ += n_inputs;

    der_bias[i] += z;
  }

  if(weight_decay != 0)
  {
    real *src_ = params->data[0];
    real *dest_ = der_params->data[0];
    // Note: pas de weight decay sur les biais.
    for(int i = 0; i < n_inputs*n_outputs; i++)
      dest_[i] += weight_decay * src_[i];
  }
}

Linear::~Linear()
{
}

}
