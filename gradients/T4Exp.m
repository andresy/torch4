#import "T4Exp.h"

@implementation T4Exp

-initWithNumberOfUnits: (int)aNumUnits
{
  if( (self = [super initWithNumberOfInputs: aNumUnits numberOfOutputs: aNumUnits
                     numberOfParameters: 0]) )
  {
    
  }

  return self;
}

-(T4Matrix*)forwardMatrix: (T4Matrix*)someInputs
{
  int numColumns = [someInputs numberOfColumns];
  int c, r;

  [outputs resizeWithNumberOfColumns: numColumns];
  for(c = 0; c < numColumns; c++)
  {
    real *inputColumn = [someInputs columnAtIndex: c];
    real *outputColumn = [outputs columnAtIndex: c];
    for(r = 0; r < numInputs; r++)
      outputColumn[r] = exp(inputColumn[r]);
  }
  return outputs;
}

-(T4Matrix*)backwardMatrix: (T4Matrix*)someGradOutputs inputs: (T4Matrix*)someInputs
{
  int numColumns = [someInputs numberOfColumns];
  int c, r;

  [gradInputs resizeWithNumberOfColumns: [someInputs numberOfColumns]];
  for(c = 0; c < numColumns; c++)
  {
    real *outputColumn = [outputs columnAtIndex: c];
    real *gradInputColumn = [gradInputs columnAtIndex: c];
    real *gradOutputColumn = [someGradOutputs columnAtIndex: c];
    for(r = 0; r < numInputs; r++)
      gradInputColumn[r] = gradOutputColumn[r] * outputColumn[r];
  }
  return gradInputs;
}

@end
