#import "T4InputSelection.h"

@implementation T4InputSelection

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
  if(partialBackpropagation)
    return nil;
  else
  {
    int numColumns = [someInputs numberOfColumns];
    int r, c;

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
}

-initWithCoder: (NSCoder*)aCoder
{
  self = [super initWithCoder: aCoder];
  [aCoder decodeValueOfObjCType: @encode(int) at: &numSelectedInputs];
  selectedInputs = [allocator allocIntArrayWithCapacity: numSelectedInputs];
  [aCoder decodeArrayOfObjCType: @encode(int) count: numSelectedInputs at: selectedInputs];
  return self;
}

-(void)encodeWithCoder: (NSCoder*)aCoder
{
  [super encodeWithCoder: aCoder];
  [aCoder encodeValueOfObjCType: @encode(int) at: &numSelectedInputs];
  [aCoder encodeArrayOfObjCType: @encode(int) count: numSelectedInputs at: selectedInputs];
}

@end
