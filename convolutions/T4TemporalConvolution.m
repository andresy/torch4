#import "T4TemporalConvolution.h"
#import "T4Random.h"

@implementation T4TemporalConvolution

-initWithNumberOfInputRows: (int)aNumInputRows
        numberOfOutputRows: (int)aNumOutputRows
           kernelTimeWidth: (int)aKW
            kernelTimeStep: (int)aDT
{

  if( (self = [super initWithNumberOfInputs: aNumInputRows
                     numberOfOutputs: aNumOutputRows
                     numberOfParameters: (aKW*aNumInputRows+1)*aNumOutputRows]) )
  {
    real *parametersData = [[parameters objectAtIndex: 0] firstColumn];
    real *gradParametersData = [[gradParameters objectAtIndex: 0] firstColumn];
    int i;

    kW = aKW;
    dT = aDT;

    weights = (real **)[allocator allocPointerArrayWithCapacity: numOutputs];
    for(i = 0; i < numOutputs; i++)
      weights[i] = parametersData + i*kW*numInputs;
    biases = parametersData + kW*numInputs*numOutputs;
        
    gradWeights = (real **)[allocator allocPointerArrayWithCapacity: numOutputs];
    for(i = 0; i < numOutputs; i++)
      gradWeights[i] = gradParametersData + i*kW*numInputs;
    gradBiases = gradParametersData + kW*numInputs*numOutputs;

    [self reset];
  }

  return self;
}

-reset
{
  real bound = 1./sqrt((real)(kW*numInputs)); // ah bon???
  int numParameters = [[parameters objectAtIndex: 0] numberOfRows];
  real *parametersData = [[parameters objectAtIndex: 0] firstColumn];
  int i;

  for(i = 0; i < numParameters; i++)
    parametersData[i] = [T4Random uniformBoundedWithValue: -bound value: bound];

  return self;
}


-(T4Matrix*)forwardInputs: (T4Matrix*)someInputs
{
  int numInputColumns = [someInputs numberOfColumns];
  int numOutputColumns = (numInputColumns - kW) / dT + 1; 
  int currentInputColumn = 0;
  real *inputData = [someInputs firstColumn];
  int inputStride = [someInputs stride];
  int l, i, j, k;

  if(numInputColumns < kW)
    T4Error(@"TemporalConvolution: input sequence too small! (numColumns = %d < kW = %d)", numInputColumns, kW);

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
        real *ptrW = weights[k]+j*numInputs;
        real *inputColumn = inputData+currentInputColumn*inputStride;

        real sum = 0;
        for(l = 0; l < numInputs; l++)
          sum += ptrW[l]*inputColumn[l];

        outputColumn[k] += sum;
      }
    }
    currentInputColumn += dT;
  }

  return outputs;
}

-(T4Matrix*)backwardGradOutputs: (T4Matrix*)someGradOutputs inputs: (T4Matrix*)someInputs
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
        real *gradPtrW = gradWeights[k]+j*numInputs;
        real *inputColumn = inputData+currentInputColumn*inputStride;
        real z = gradOutputColumn[k];
        for(l = 0; l < numInputs; l++)
          gradPtrW[l] += z*inputColumn[l];
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
        real *ptrW = weights[k]+j*numInputs;
        real *gradInputColumn = gradInputData+currentInputColumn*numInputs;

        real z = gradOutputColumn[k];
        for(l = 0; l < numInputs; l++)
           gradInputColumn[l] += ptrW[l]*z;
      }
    }
    currentInputColumn += dT;
  }

  return gradInputs;
}

-(int)kernelTimeWidth
{
  return kW;
}

-(int)kernelTimeStep
{
  return dT;
}

-initWithCoder: (NSCoder*)aCoder
{
  self = [super initWithCoder: aCoder];

  [aCoder decodeValueOfObjCType: @encode(int) at: &kW];
  [aCoder decodeValueOfObjCType: @encode(int) at: &dT];

  real *parametersData = [[parameters objectAtIndex: 0] firstColumn];
  real *gradParametersData = [[gradParameters objectAtIndex: 0] firstColumn];
  int i;

  weights = (real **)[allocator allocPointerArrayWithCapacity: numOutputs];
  for(i = 0; i < numOutputs; i++)
    weights[i] = parametersData + i*kW*numInputs;
  biases = parametersData + kW*numInputs*numOutputs;
  
  gradWeights = (real **)[allocator allocPointerArrayWithCapacity: numOutputs];
  for(i = 0; i < numOutputs; i++)
    gradWeights[i] = gradParametersData + i*kW*numInputs;
  gradBiases = gradParametersData + kW*numInputs*numOutputs;
  
  return self;
}

-(void)encodeWithCoder: (NSCoder*)aCoder
{
  [super encodeWithCoder: aCoder];
  [aCoder encodeValueOfObjCType: @encode(int) at: &kW];
  [aCoder encodeValueOfObjCType: @encode(int) at: &dT];
}

@end
