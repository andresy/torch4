#import "T4Tanh.h"

@implementation T4Tanh

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
    real *srcColumn = [anInputMatrix columnAtIndex: c];
    real *destColumn = [outputs columnAtIndex: c];
    for(r = 0; r < numInputs; r++)
      destColumn[r] = tanh(srcColumn[r]);
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
    real *srcColumn = [outputs columnAtIndex: c];
    real *destColumn = [gradInputs columnAtIndex: c];
    real *gradOutputsColumn = [gradOutputMatrix columnAtIndex: c];
    for(r = 0; r < numInputs; r++)
    {
      real z = srcColumn[r];
      destColumn[r] = gradOutputsColumn[r] * (1. - z*z);
    }
  }
  return gradInputs;
}

@end
