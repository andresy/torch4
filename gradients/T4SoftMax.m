#import "T4SoftMax.h"

@implementation T4SoftMax

-initWithNumberOfUnits: (int)aNumUnits
{
  if( (self = [super initWithNumberOfInputs: aNumUnits numberOfOutputs: aNumUnits
                     numberOfParameters: 0]) )
  {
    [self setShift: 0.];
    [self setComputesShift: YES];
  }

  return self;
}

-(T4Matrix*)forwardInputs: (T4Matrix*)someInputs
{
  int numColumns = [someInputs numberOfColumns];
  int c, r;
  real sum;

  [outputs resizeWithNumberOfColumns: numColumns];
  for(c = 0; c < numColumns; c++)
  {
    real *inputColumn = [someInputs columnAtIndex: c];
    real *outputColumn = [outputs columnAtIndex: c];

    if(computeShift)
    {
      shift = inputColumn[0];
      for(r = 1; r < numInputs; r++)
      {
        if(inputColumn[r] > shift)
          shift = inputColumn[r];
      }
    }

    sum = 0;
    for(r = 0; r < numInputs; r++)
    {
      real z = exp(inputColumn[r] - shift);
      outputColumn[r] = z;
      sum += z;
    }

    for(r = 0; r < numInputs; r++)
      outputColumn[r] /= sum;
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
      sum += gradOutputColumn[r] * outputColumn[r];
    
    for(r = 0; r < numInputs; r++)
      gradInputColumn[r] = outputColumn[r] * (gradOutputColumn[r] - sum);
  }
  return gradInputs;
}

-setShift: (real)aValue
{
  shift = aValue;
  return self;
}

-setComputesShift: (BOOL)aFlag
{
  computeShift = aFlag;
  return self;
}

-initWithCoder: (NSCoder*)aCoder
{
  self = [super initWithCoder: aCoder];
  [aCoder decodeValueOfObjCType: @encode(real) at: &shift];
  [aCoder decodeValueOfObjCType: @encode(BOOL) at: &computeShift];
  return self;
}

-(void)encodeWithCoder: (NSCoder*)aCoder
{
  [super encodeWithCoder: aCoder];
  [aCoder encodeValueOfObjCType: @encode(real) at: &shift];
  [aCoder encodeValueOfObjCType: @encode(BOOL) at: &computeShift];
}

@end
