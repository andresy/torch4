#import "T4SoftMax.h"

@implementation T4SoftMax

-initWithNumberOfUnits: (int)aNumUnits
{
  if( (self = [super initWithNumberOfInputs: aNumUnits numberOfOutputs: aNumUnits
                     numberOfParameters: 0]) )
  {
    [self addRealOption: @"shift" address: &shift initValue: 0.];
    [self addBoolOption: @"compute shift" address: &computeShift initValue: YES];
  }

  return self;
}

-(T4Matrix*)forwardMatrix: (T4Matrix*)anInputMatrix
{
  int numColumns = [anInputMatrix numberOfColumns];
  int c, r;
  real sum;

  [outputs resizeWithNumberOfColumns: numColumns];
  for(c = 0; c < numColumns; c++)
  {
    real *inputColumn = [anInputMatrix columnAtIndex: c];
    real *outputColumn = [outputs columnAtIndex: c];

    if(computeShift)
    {
      shift = inputColumn[0];
      for(r = 1; r < numInputs; r++)
      {
        if(inputColumn[r] > shift)
          shift = inputColumn[r];
      }
    }

    sum = 0;
    for(r = 0; r < numInputs; r++)
    {
      real z = exp(inputColumn[r] - shift);
      outputColumn[r] = z;
      sum += z;
    }

    for(r = 0; r < numInputs; r++)
      outputColumn[r] /= sum;
  }
  return outputs;
}

-(T4Matrix*)backwardMatrix: (T4Matrix*)gradOutputMatrix inputs: (T4Matrix*)anInputMatrix
{
  int numColumns = [anInputMatrix numberOfColumns];
  int c, r;

  [gradInputs resizeWithNumberOfColumns: [anInputMatrix numberOfColumns]];
  for(c = 0; c < numColumns; c++)
  {
    real *outputColumn = [outputs columnAtIndex: c];
    real *gradInputColumn = [gradInputs columnAtIndex: c];
    real *gradOutputColumn = [gradOutputMatrix columnAtIndex: c];
    real sum = 0;

    for(r = 0; r < numInputs; r++)
      sum += gradOutputColumn[r] * outputColumn[r];
    
    for(r = 0; r < numInputs; r++)
      gradInputColumn[r] = outputColumn[r] * (gradOutputColumn[r] - sum);
  }
  return gradInputs;
}

@end
