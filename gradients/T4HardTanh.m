#import "T4HardTanh.h"

@implementation T4HardTanh

-initWithNumberOfUnits: (int)aNumUnits
{
  if( (self = [super initWithNumberOfInputs: aNumUnits numberOfOutputs: aNumUnits
                     numberOfParameters: 0]) )
  {
    
  }

  return self;
}

-(T4Matrix*)forwardInputs: (T4Matrix*)someInputs
{
  int numColumns = [someInputs numberOfColumns];
  int c, r;

  [outputs resizeWithNumberOfColumns: numColumns];
  for(c = 0; c < numColumns; c++)
  {
    real *inputColumn = [someInputs columnAtIndex: c];
    real *outputColumn = [outputs columnAtIndex: c];
    for(r = 0; r < numInputs; r++)
    {      
      if(inputColumn[r] < -1)
        outputColumn[r] = -1;
      else
      {
        if(inputColumn[r] <= 1)
          outputColumn[r] = inputColumn[r];
        else
          outputColumn[r] = 1;
      }
    }
  }
  return outputs;
}

-(T4Matrix*)backwardGradOutputs: (T4Matrix*)someGradOutputs inputs: (T4Matrix*)someInputs
{
  int numColumns = [someInputs numberOfColumns];
  int c, r;

  [gradInputs resizeWithNumberOfColumns: [someInputs numberOfColumns]];
  for(c = 0; c < numColumns; c++)
  {
    real *inputColumn = [someInputs columnAtIndex: c];
    real *gradInputColumn = [gradInputs columnAtIndex: c];
    real *gradOutputColumn = [someGradOutputs columnAtIndex: c];
    for(r = 0; r < numInputs; r++)
    {
      if( (inputColumn[r] < -1) || (inputColumn[r] > 1) )
        gradInputColumn[r] = 0;
      else
        gradInputColumn[r] = gradOutputColumn[r];
    }
  }
  return gradInputs;
}

@end
