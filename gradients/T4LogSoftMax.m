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

-(T4Matrix*)forwardInputs: (T4Matrix*)someInputs
{
  int numColumns = [someInputs numberOfColumns];
  int c, r;

  [outputs resizeWithNumberOfColumns: numColumns];
  for(c = 0; c < numColumns; c++)
  {
    real *inputColumn = [someInputs columnAtIndex: c];
    real *outputColumn = [outputs columnAtIndex: c];

    real sum = T4LogZero;
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

-(T4Matrix*)backwardGradOutputs: (T4Matrix*)someGradOutputs inputs: (T4Matrix*)someInputs
{
  int numColumns = [someInputs numberOfColumns];
  int c, r;

  [gradInputs resizeWithNumberOfColumns: [someInputs numberOfColumns]];
  for(c = 0; c < numColumns; c++)
  {
    real *outputColumn = [outputs columnAtIndex: c];
    real *gradInputColumn = [gradInputs columnAtIndex: c];
    real *gradOutputColumn = [someGradOutputs columnAtIndex: c];

    real sum = 0;
    for(r = 0; r < numInputs; r++)
      sum += gradOutputColumn[r];

    for(r = 0; r < numInputs; r++)
      gradInputColumn[r] = gradOutputColumn[r] - exp(outputColumn[r]) * sum;
  }
  return gradInputs;
}

@end
