#import "T4SelectInputs.h"

@implementation T4SelectInputs

-initWithNumberOfInputs: (int)aNumInputs selectedInputs: (int*)someSelectedInputs numberOfSelectedInputs: (int)aNumSelectedInputs
{
  if( (self = [super initWithNumberOfInputs: aNumInputs numberOfOutputs: aNumSelectedInputs
                     numberOfParameters: 0]) )
  {
    int i;

    numSelectedInputs = aNumSelectedInputs;
    selectedInputs = [allocator allocIntArrayWithCapacity: numSelectedInputs];
    for(i = 0; i < numSelectedInputs; i++)
      selectedInputs[i] = someSelectedInputs[i];
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
    for(r = 0; r < numSelectedInputs; r++)
      outputColumn[r] = inputColumn[selectedInputs[r]];
  }
  return outputs;
}

-(T4Matrix*)backwardMatrix: (T4Matrix*)someGradOutputs inputs: (T4Matrix*)someInputs
{
  int numColumns;
  int c, r;

  if(partialBackpropagation)
    return nil;

  numColumns = [someInputs numberOfColumns];
  [gradInputs resizeWithNumberOfColumns: [someInputs numberOfColumns]];
  [gradInputs zero];

  for(c = 0; c < numColumns; c++)
  {
    real *gradInputColumn = [gradInputs columnAtIndex: c];
    real *gradOutputColumn = [someGradOutputs columnAtIndex: c];
    for(r = 0; r < numSelectedInputs; r++)
      gradInputColumn[r] += gradOutputColumn[selectedInputs[r]];
  }
  return gradInputs;
}

-setPartialBackpropagation: (BOOL)aFlag
{
  partialBackpropagation = aFlag;
  return self;
}

@end
