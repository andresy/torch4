#import "T4LogSigmoid.h"

@implementation T4LogSigmoid

-initWithNumberOfUnits: (int)aNumUnits
{
  if( (self = [super initWithNumberOfInputs: aNumUnits numberOfOutputs: aNumUnits
                     numberOfParameters: 0]) )
  {
    buffer = [[[T4Matrix alloc] initWithNumberOfRows: aNumUnits] keepWithAllocator: allocator];
  }

  return self;
}

-(T4Matrix*)forwardMatrix: (T4Matrix*)someInputs
{
  int numColumns = [someInputs numberOfColumns];
  int c, r;

  [outputs resizeWithNumberOfColumns: numColumns];
  [buffer resizeWithNumberOfColumns: numColumns];
  for(c = 0; c < numColumns; c++)
  {
    real *inputColumn = [someInputs columnAtIndex: c];
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

-(T4Matrix*)backwardMatrix: (T4Matrix*)someGradOutputs inputs: (T4Matrix*)someInputs
{
  int numColumns = [someInputs numberOfColumns];
  int c, r;

  [gradInputs resizeWithNumberOfColumns: [someInputs numberOfColumns]];
  for(c = 0; c < numColumns; c++)
  {
    real *bufferColumn = [buffer columnAtIndex: c];
    real *gradInputColumn = [gradInputs columnAtIndex: c];
    real *gradOutputColumn = [someGradOutputs columnAtIndex: c];
    for(r = 0; r < numInputs; r++)
    {
      real z = bufferColumn[r];
      gradInputColumn[r] = gradOutputColumn[r] * z / (1. + z);
    }
  }
  return gradInputs;
}

-initWithCoder: (NSCoder*)aCoder
{
  self = [super initWithCoder: aCoder];
  buffer = [[[T4Matrix alloc] initWithNumberOfRows: numInputs] keepWithAllocator: allocator];
  return self;
}

@end
