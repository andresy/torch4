#import "T4LogSoftMax.h"
#import "T4LogAdd.h"

@implementation T4LogSoftMax

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

    real sum = LOG_ZERO;
    for(r = 0; r < numInputs; r++)
    {
      real z = inputColumn[r];
      outputColumn[r] = z;
      sum = T4LogAdd(sum, z);
    }

    for(r = 0; r < numInputs; r++)
      outputColumn[r] -= sum;
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
      sum += gradOutputColumn[r];

    for(r = 0; r < numInputs; r++)
      gradInputColumn[r] = gradOutputColumn[r] - exp(outputColumn[r]) * sum;
  }
  return gradInputs;
}

@end
