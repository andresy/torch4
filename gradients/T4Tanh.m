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
#if 0
  int numColumns = anInputMatrix->numColumns;
  int c, r;
  real *inputColumn = anInputMatrix->data;
  real *outputColumn = outputs->data;

  [outputs resizeWithNumberOfColumns: numColumns];
  for(c = 0; c < numColumns; c++)
  {
    for(r = 0; r < numInputs; r++)
      outputColumn[r] = tanh(inputColumn[r]);
    inputColumn += anInputMatrix->stride;
    outputColumn += outputs->stride;
  }
  return outputs;
#else
  int numColumns = [anInputMatrix numberOfColumns];
  int c, r;

  [outputs resizeWithNumberOfColumns: numColumns];
  for(c = 0; c < numColumns; c++)
  {
    real *inputColumn = [anInputMatrix columnAtIndex: c];
    real *outputColumn = [outputs columnAtIndex: c];
    for(r = 0; r < numInputs; r++)
      outputColumn[r] = tanh(inputColumn[r]);
  }
  return outputs;
#endif
}

-(T4Matrix*)backwardMatrix: (T4Matrix*)gradOutputMatrix inputs: (T4Matrix*)anInputMatrix
{
#if 0
  int numColumns = anInputMatrix->numColumns;
  int c, r;
  real *outputColumn = outputs->data;
  real *gradInputColumn = gradInputs->data;
  real *gradOutputColumn = gradOutputMatrix->data;
  
  [gradInputs resizeWithNumberOfColumns: numColumns];
  for(c = 0; c < numColumns; c++)
  {
    for(r = 0; r < numInputs; r++)
    {
      real z = outputColumn[r];
      gradInputColumn[r] = gradOutputColumn[r] * (1. - z*z);
    }
    outputColumn += outputs->stride;
    gradInputColumn += gradInputs->stride;
    gradOutputColumn += gradOutputMatrix->stride;
  }
  return gradInputs;
#else
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
      real z = outputColumn[r];
      gradInputColumn[r] = gradOutputColumn[r] * (1. - z*z);
    }
  }
  return gradInputs;
#endif
}

@end
