#import "T4TemporalSubSampling.h"
#import "T4Random.h"

@implementation T4TemporalSubSampling

-initWithNumberOfRows: (int)aNumInputRows
           kernelSize: (int)aKW
                   dT: (int)aDT
{
  if( (self = [super initWithNumberOfInputs: aNumInputRows
                     numberOfOutputs: aNumInputRows
                     numberOfParameters: 2*aNumInputRows]) )
  {
    kW = aKW;
    dT = aDT;

    weights = [[parameters objectAtIndex: 0] firstColumn];
    biases = weights + numInputs;
    
    gradWeights = [[gradParameters objectAtIndex: 0] firstColumn];
    gradBiases = gradWeights + numInputs;

    [self reset];
  }

  return self;
}

-reset
{
  real bound = 1./sqrt((real)(kW));
  int numParameters = [[parameters objectAtIndex: 0] numberOfRows];
  real *parametersData = [[parameters objectAtIndex: 0] firstColumn];
  int i;

  for(i = 0; i < numParameters; i++)
    parametersData[i] = [T4Random uniformBoundedWithValue: -bound value: bound];

  return self;
}

-(T4Matrix*)forwardMatrix: (T4Matrix*)someInputs
{
  int numInputColumns = [someInputs numberOfColumns];
  int numOutputColumns = (numInputColumns - kW) / dT + 1; 
  int currentInputColumn = 0;
  real *inputData = [someInputs firstColumn];
  int inputStride = [someInputs stride];
  int l, i, j, k;

  if(numInputColumns < kW)
    T4Error(@"TemporalSubSampling: input sequence too small! (numColumns = %d < kW = %d)", numInputColumns, kW);

  [outputs resizeWithNumberOfColumns: numOutputColumns];

  for(i = 0; i < numOutputColumns; i++)
  {
    real *outputColumn = [outputs columnAtIndex: i];
    for(j = 0; j < numOutputs; j++)
      outputColumn[j] = biases[j];

    // Sur le noyau...
    for(j = 0; j < kW; j++)
    {
      // Sur tous les "neurones" de sorties
      for(k = 0; k < numOutputs; k++)
      {
        real *inputColumn = inputData+currentInputColumn*inputStride;
        real sum = 0;
        for(l = 0; l < numInputs; l++)
          sum += inputColumn[l];

        outputColumn[k] += weights[k]*sum;
      }
    }
    currentInputColumn += dT;
  }

  return outputs;
}

-(T4Matrix*)backwardMatrix: (T4Matrix*)someGradOutputs inputs: (T4Matrix*)someInputs
{
  int numInputColumns = [someInputs numberOfColumns];
  int numOutputColumns = [someGradOutputs numberOfColumns]; 
  int currentInputColumn = 0;
  real *inputData = [someInputs firstColumn];
  real *gradInputData;
  int inputStride = [someInputs stride];
  int l, i, j, k;
  
  // NOTE: boucle *necessaire* avec "partial backprop"

  for(i = 0; i < numOutputColumns; i++)
  {
    real *gradOutputColumn = [someGradOutputs columnAtIndex: i];
    for(j = 0; j < numOutputs; j++)
      gradBiases[j] += gradOutputColumn[j];
    
    for(j = 0; j < kW; j++)
    {
      for(k = 0; k < numOutputs; k++)
      {
        real *inputColumn = inputData+currentInputColumn*inputStride;
        real sum = 0;
        for(l = 0; l < numInputs; l++)
          sum += inputColumn[l];
        gradWeights[k] += gradOutputColumn[k]*sum;
      }
    }
    currentInputColumn += dT;
  }

  if(partialBackpropagation)
    return nil;

  // NOTE: boucle *non-necessaire* avec "partial backprop"

  [gradInputs resizeWithNumberOfColumns: numInputColumns];
  [gradInputs zero];

  gradInputData = [gradInputs firstColumn];
  
  currentInputColumn = 0;
  for(i = 0; i < numOutputColumns; i++)
  {
    real *gradOutputColumn = [someGradOutputs columnAtIndex: i];
    for(j = 0; j < kW; j++)
    {
      for(k = 0; k < numOutputs; k++)
      {
        real *gradInputColumn = gradInputData+currentInputColumn*numInputs;
        real z = gradOutputColumn[k]*weights[k];
        for(l = 0; l < numInputs; l++)
           gradInputColumn[l] += z;
      }
    }
    currentInputColumn += dT;
  }

  return gradInputs;
}

@end
