#import "T4SoftPlus.h"

@implementation T4SoftPlus

-initWithNumberOfUnits: (int)aNumUnits
{
  if( (self = [super initWithNumberOfInputs: aNumUnits numberOfOutputs: aNumUnits
                     numberOfParameters: 0]) )
  {
    
  }

  return self;
}

-(T4Matrix*)forwardMatrix: (T4Matrix*)anInputMatrix
{
  int numColumns = [anInputMatrix numberOfColumns];
  int c, r;

  [outputs resizeWithNumberOfColumns: numColumns];
  for(c = 0; c < numColumns; c++)
  {
    real *inputColumn = [anInputMatrix columnAtIndex: c];
    real *outputColumn = [outputs columnAtIndex: c];
    for(r = 0; r < numInputs; r++)
      outputColumn[r] = log1p(exp(inputColumn[r]));
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
    for(r = 0; r < numInputs; r++)
    {
      real z = exp(outputColumn[r]);
      gradInputColumn[r] = gradOutputColumn[r] * (z - 1.)/z;
    }
  }
  return gradInputs;
}

@end
