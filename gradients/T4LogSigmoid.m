#import "T4LogSigmoid.h"

@implementation T4LogSigmoid

-initWithNumberOfUnits: (int)aNumUnits
{
  if( (self = [super initWithNumberOfInputs: aNumUnits numberOfOutputs: aNumUnits
                     numberOfParameters: 0]) )
  {
    buffer = [[T4Matrix alloc] initWithNumberOfRows: aNumUnits];
  }

  return self;
}

-(T4Matrix*)forwardMatrix: (T4Matrix*)anInputMatrix
{
  int numColumns = [anInputMatrix numberOfColumns];
  int c, r;

  [outputs resizeWithNumberOfColumns: numColumns];
  [buffer resizeWithNumberOfColumns: numColumns];
  for(c = 0; c < numColumns; c++)
  {
    real *inputColumn = [anInputMatrix columnAtIndex: c];
    real *outputColumn = [outputs columnAtIndex: c];
    real *bufferColumn = [buffer columnAtIndex: c];
    for(r = 0; r < numInputs; r++)
    {
      real z = exp(-inputColumn[r]);
      bufferColumn[r] = z;
      outputColumn[r] = -log(1. + z);
    }
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
    real *bufferColumn = [buffer columnAtIndex: c];
    real *gradInputColumn = [gradInputs columnAtIndex: c];
    real *gradOutputColumn = [gradOutputMatrix columnAtIndex: c];
    for(r = 0; r < numInputs; r++)
    {
      real z = bufferColumn[r];
      gradInputColumn[r] = gradOutputColumn[r] * z / (1. + z);
    }
  }
  return gradInputs;
}

@end
