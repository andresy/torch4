#import "T4TemporalConvolution.h"
#import "T4Random.h"

-initWithNumberOfInputRows: (int)aNumInputRows
        numberOfOutputRows: (int)aNumOutputRows
                kernelSize: (int)aKW
                        dT: (int)aDT
{

  if( (self = [super initWithNumberOfInputs: aNumInputRows
                     numberOfOutputs: aNumOutputRows
                     numberOfParameters: (aKW*aNumInputRows+1)*aNumOutputRows]) )
  {
    real *parametersData = [[parameters objectAtIndex: 0] firstColumn];
    real *gradParametersData = [[gradParameters objectAtIndex: 0] firstColumn];
    int i;

    kW = aKW;
    dT = dDT;

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


-(T4Matrix*)forwardMatrix: (T4Matrix*)someInputs
{
  int numInputColumns = [someInputs numberOfColumns];
  int numOutputColumns = (numInputColumns - kW) / dT + 1; 
  int currentInputColumn = 0;
  real *inputData = [someInputs firstColumn];
  int inputStride = [someInputs stride];
  int l, i, j;

  if(numInputColumns < kW)
    error("TemporalSubSampling: input sequence too small! (numColumns = %d < kW = %d)", numInputColumns, kW);

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

-(T4Matrix*)backwardMatrix: (T4Matrix*)someGradOutputs inputs: (T4Matrix*)someInputs
{
  int numInputColumns = [someInputs numberOfColumns];
  int numOutputColumns = (numInputColumns - kW) / dT + 1; 
  int currentInputColumn = 0;
  real *inputData = [someInputs firstColumn];
  int inputStride = [someInputs stride];
  int l, i, j;

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
        real *gradPtrW = weights[k]+j*numInputs;
        real *inputColumn = inputData+currentInputColumn*inputStride;

        real z = gradOutputColumn[k];
        for(int l = 0; l < n_inputs; l++)
          gradPtrW[l] += alpha_*inputColumn[l];
      }
    }
    current_input_frame += d_t;
  }

  if(partial_backprop)
    return;

  // NOTE: boucle *non-necessaire* avec "partial backprop"

  beta->resize(inputs->n_frames);
  for(int i = 0; i < beta->n_frames; i++)
  {
    real *beta_frame_ = beta->frames[i];
    for(int j = 0; j < n_inputs; j++)
      beta_frame_[j] = 0;
  }

  int current_beta_frame = 0;
  for(int i = 0; i < n_output_frames; i++)
  {
    real *alpha_frame_ = alpha->frames[i];
    for(int j = 0; j < k_w; j++)
    {
      for(int k = 0; k < n_outputs; k++)
      {
        real *weights_ = weights[k]+j*n_inputs;
        real *beta_frame_ = beta->frames[current_beta_frame+j];

        real alpha_ = alpha_frame_[k];
        for(int l = 0; l < n_inputs; l++)
           beta_frame_[l] += weights_[l]*alpha_;
      }
    }
    current_beta_frame += d_t;
  }
}

@end
