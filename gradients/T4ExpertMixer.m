#import "T4ExpertMixer.h"

@implementation T4ExpertMixer

-initWithNumberOfExperts: (int)aNumExperts numberOfOutputs: (int)aNumOutputsPerExpert
{
  if( (self = [super initWithNumberOfInputs: aNumExperts*(aNumOutputsPerExpert+1) numberOfOutputs: aNumOutputsPerExpert
                     numberOfParameters: 0]) )
  {
    numExperts = aNumExperts;
  }

  return self;
}

-(T4Matrix*)forwardMatrix: (T4Matrix*)someInputs
{
  int numColumns = [someInputs numberOfColumns];
  int c, r, e;

  [outputs resizeWithNumberOfColumns: numColumns];
  [outputs zero];
  for(c = 0; c < numColumns; c++)
  {
    real *weightColumn = [someInputs columnAtIndex: c];
    real *expertInputColumn = weightColumn+numExperts;
    real *outputColumn = [outputs columnAtIndex: c];

    for(e = 0; e < numExperts; e++)
    {
      real z = weightColumn[e];
      for(r = 0; r < numOutputs; r++)
        outputColumn[r] += z * expertInputColumn[r];
      expertInputColumn += numOutputs;
    }
  }
  return outputs;
}

-(T4Matrix*)backwardMatrix: (T4Matrix*)someGradOutputs inputs: (T4Matrix*)someInputs
{
  int numColumns = [someInputs numberOfColumns];
  int c, r, e;

  [gradInputs resizeWithNumberOfColumns: [someInputs numberOfColumns]];

  for(c = 0; c < numColumns; c++)
  {
    real *weightColumn = [someInputs columnAtIndex: c];
    real *gradInputColumn = [gradInputs columnAtIndex: c];
    real *gradOutputColumn = [someGradOutputs columnAtIndex: c];
    real *expertInputColumn = weightColumn+numExperts;
    for(e = 0; e < numExperts; e++)
    {
      real z = 0;
      for(r = 0; r < numOutputs; r++)
        z += gradOutputColumn[r] * expertInputColumn[r];
      gradInputColumn[e] = z;
      expertInputColumn += numOutputs;
    }

    gradInputColumn += numExperts;
    for(e = 0; e < numExperts; e++)
    {
      real z = weightColumn[e];
      for(r = 0; r < numOutputs; r++)
        gradInputColumn[r] = gradOutputColumn[r]*z;
      gradInputColumn += numOutputs;
    }
  }
  return gradInputs;
}

-initWithCoder: (NSCoder*)aCoder
{
  self = [super initWithCoder: aCoder];
  [aCoder decodeValueOfObjCType: @encode(int) at: &numExperts];
  return self;
}

-(void)encodeWithCoder: (NSCoder*)aCoder
{
  [super encodeWithCoder: aCoder];
  [aCoder encodeValueOfObjCType: @encode(int) at: &numExperts];
}

@end
