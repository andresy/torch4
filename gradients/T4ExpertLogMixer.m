#import "T4ExpertLogMixer.h"
#import "T4LogAdd.h"

@implementation T4ExpertLogMixer

-initWithNumberOfExperts: (int)aNumExperts numberOfOutputs: (int)aNumOutputsPerExpert
{
  if( (self = [super initWithNumberOfInputs: aNumExperts*(aNumOutputsPerExpert+1) numberOfOutputs: aNumOutputsPerExpert
                     numberOfParameters: 0]) )
  {
    numExperts = aNumExperts;
  }

  return self;
}

-(T4Matrix*)forwardMatrix: (T4Matrix*)anInputMatrix
{
  int numColumns = [anInputMatrix numberOfColumns];
  int c, r, e;

  [outputs resizeWithNumberOfColumns: numColumns];
  [outputs fillWithValue: LOG_ZERO];
  for(c = 0; c < numColumns; c++)
  {
    real *weightColumn = [anInputMatrix columnAtIndex: c];
    real *expertInputColumn = weightColumn+numExperts;
    real *outputColumn = [outputs columnAtIndex: c];

    for(e = 0; e < numExperts; e++)
    {
      real z = weightColumn[e];
      for(r = 0; r < numInputs; r++)
        outputColumn[r] = T4LogAdd(outputColumn[r], z + expertInputColumn[r]);
      expertInputColumn += numOutputs;
    }
  }
  return outputs;
}

-(T4Matrix*)backwardMatrix: (T4Matrix*)gradOutputMatrix inputs: (T4Matrix*)anInputMatrix
{
  int numColumns = [anInputMatrix numberOfColumns];
  int c, r, e;

  [gradInputs resizeWithNumberOfColumns: [anInputMatrix numberOfColumns]];

  for(c = 0; c < numColumns; c++)
  {
    real *weightColumn = [anInputMatrix columnAtIndex: c];
    real *expertInputColumn = weightColumn+numExperts;
    real *weightGradInputColumn = [gradInputs columnAtIndex: c];
    real *expertGradInputColumn = weightGradInputColumn+numExperts;
    real *outputColumn = [outputs columnAtIndex: c];
    real *gradOutputColumn = [gradOutputMatrix columnAtIndex: c];

    for(e = 0; e < numExperts; e++)
    {
      real z = weightColumn[e];
      for(r = 0; r < numOutputs; r++)
        expertGradInputColumn[r] = gradOutputColumn[r] * exp(z + expertInputColumn[r] - outputColumn[r]);
      expertGradInputColumn += numOutputs;
      expertInputColumn += numOutputs;
    }

    expertGradInputColumn = weightGradInputColumn+numExperts;
    for(e = 0; e < numExperts; e++)
    {
      real sum = 0;
      for(r = 0; r < numOutputs; r++)
        sum += expertGradInputColumn[r];
      expertGradInputColumn += numOutputs;
      weightGradInputColumn[r] = sum;
    }
  }
  return gradInputs;
}

@end
