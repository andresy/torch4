#import "T4SpatialConvolution.h"
#import "T4Random.h"

/* Bon. Pour info, j'ai essaye de coder une premiere version degeulasse, ou
   j'essayais de prendre en compte le cache de la becane. Ca m'a pris une demi
   journee, plus quelques heures de debuggage, et c'etait du code horrible.
   J'ai recode ce truc en 10 minutes. Ca a marche du premier coup. Et c'est
   plus rapide! Bordel! Alors vous prenez pas la tete...
*/

@implementation T4SpatialConvolution

-initWithNumberOfInputPlanes: (int)aNumInputPlanes
        numberOfOutputPlanes: (int)aNumOutputPlanes
                  inputWidth: (int)anInputWidth
                 inputHeight: (int)anInputHeight
                 kernelWidth: (int)aKW
                kernelHeight: (int)aKH
             kernelWidthStep: (int)aDW
            kernelHeightStep: (int)aDH
{
  int anOutputWidth = (anInputWidth - aKW) / aDW + 1;
  int anOutputHeight = (anInputHeight - aKH) / aDH + 1;

  if(anInputWidth < aKW)
    T4Error(@"SpatialConvolution: input image width is too small (width = %d < kW = %d) ", anInputWidth, aKW);
  if(anInputHeight < aKH)
    T4Error(@"SpatialConvolution: input image height is too small (height = %d < kH = %d) ", anInputHeight, aKH);

  T4Message(@"SpatialConvolution: output image is <%d x %d>", anOutputWidth, anOutputHeight);

  if( (self = [super initWithNumberOfInputs: aNumInputPlanes * anInputHeight * anInputWidth
                     numberOfOutputs: aNumOutputPlanes * anOutputHeight * anOutputWidth
                     numberOfParameters: aKW*aKH*aNumInputPlanes*aNumOutputPlanes+aNumOutputPlanes]) )
  {
    real *parametersData = [[parameters objectAtIndex: 0] firstColumn];
    real *gradParametersData = [[gradParameters objectAtIndex: 0] firstColumn];
    int i;

    numInputPlanes = aNumInputPlanes;
    numOutputPlanes = aNumOutputPlanes;
    inputWidth = anInputWidth;
    inputHeight = anInputHeight;
    outputWidth = anOutputWidth;
    outputHeight = anOutputHeight;
    kW = aKW;
    kH = aKH;
    dW = aDW;
    dH = aDH;

    weights = (real **)[allocator allocPointerArrayWithCapacity: numOutputPlanes];
    for(i = 0; i < numOutputPlanes; i++)
      weights[i] = parametersData + i*kW*kH*numInputPlanes;
    biases = parametersData + kW*kH*numInputPlanes*numOutputPlanes;
    
    gradWeights = (real **)[allocator allocPointerArrayWithCapacity: numOutputPlanes];
    for(i = 0; i < numOutputPlanes; i++)
      gradWeights[i] = gradParametersData + i*kW*kH*numInputPlanes;
    gradBiases = gradParametersData + kW*kH*numInputPlanes*numOutputPlanes;

    [self reset];
  }
  
  return self;
}

-reset
{
  real bound = 1./sqrt((real)(kW*kH*numInputPlanes));
  int numParameters = [[parameters objectAtIndex: 0] numberOfRows];
  real *parametersData = [[parameters objectAtIndex: 0] firstColumn];
  int i;

  for(i = 0; i < numParameters; i++)
    parametersData[i] = [T4Random uniformBoundedWithValue: -bound value: bound];

  return self;
}

-(T4Matrix*)forwardMatrix: (T4Matrix*)someInputs
{
  int numColumns = [someInputs numberOfColumns];
  int i, k, c, xx, yy, kx, ky;

  [outputs resizeWithNumberOfColumns: numColumns];

  for(c = 0; c < numColumns; c++)
  {
    real *inputColumn = [someInputs columnAtIndex: c];
    real *currentOutputPlane = [outputs columnAtIndex: c];

    for(k = 0; k < numOutputPlanes; k++)
    {
      // Initialize to the bias
      real z = biases[k];
      for(i = 0; i < outputWidth*outputHeight; i++)
        currentOutputPlane[i] = z;

      // Go!
      for(i = 0; i < numInputPlanes; i++)
      {
        // Get the good mask for (k,i) (k out, i in)
        real *ptrW = weights[k]+i*kW*kH;
      
        // Get the input image
        real *currentInputPlane = inputColumn+i*inputWidth*inputHeight;
        real *currentOutputPlaneRow = currentOutputPlane;

        // For all output pixels...
        for(yy = 0; yy < outputHeight; yy++)
        {
          for(xx = 0; xx < outputWidth; xx++)
          {
            // Dot product in two dimensions... (between input image and the mask)
            real *subInputPlaneRow = currentInputPlane+yy*dH*inputWidth+xx*dW;
            real *ptrWRow = ptrW;

            real sum = 0;
            for(ky = 0; ky < kH; ky++)
            {
              for(kx = 0; kx < kW; kx++)
                sum += subInputPlaneRow[kx]*ptrWRow[kx];
              subInputPlaneRow += inputWidth;
              ptrWRow += kW;
            }
            
            // Update output
            currentOutputPlaneRow[xx] += sum;            
          }
          currentOutputPlaneRow += outputWidth;
        }
      }
      
      // Next output plane
      currentOutputPlane += outputWidth*outputHeight;
    }
  }

  return outputs;
}

-(T4Matrix*)backwardMatrix: (T4Matrix*)someGradOutputs inputs: (T4Matrix*)someInputs
{
  int numColumns = [someInputs numberOfColumns];
  int i, k, c, xx, yy, kx, ky;
  real *gradInputColumn;

  for(c = 0; c < numColumns; c++)
  {
    real *inputColumn = [someInputs columnAtIndex: c];
    real *currentGradOutputPlane = [someGradOutputs columnAtIndex: c];

    //NOTE: boucle *necessaire* avec "partial backprop"
    
    for(k = 0; k < numOutputPlanes; k++)
    {
      real sum = 0;
      for(i = 0; i < outputWidth*outputHeight; i++)
        sum += currentGradOutputPlane[i];
      gradBiases[k] += sum;
      
      for(i = 0; i < numInputPlanes; i++)
      {
        real *gradPtrW = gradWeights[k] + i*kW*kH;
        real *currentInputPlane = inputColumn+i*inputWidth*inputHeight;
        real *currentGradOutputPlaneRow = currentGradOutputPlane;

        for(yy = 0; yy < outputHeight; yy++)
        {
          for(xx = 0; xx < outputWidth; xx++)
          {
            real *subInputPlaneRow = currentInputPlane+yy*dH*inputWidth+xx*dW;            
            real *gradPtrWRow = gradPtrW;

            real z = currentGradOutputPlaneRow[xx];
            for(ky = 0; ky < kH; ky++)
            {
              for(kx = 0; kx < kW; kx++)
                gradPtrWRow[kx] += z * subInputPlaneRow[kx];
              subInputPlaneRow += inputWidth;
              gradPtrWRow += kW;
            }
          }
          currentGradOutputPlaneRow += outputWidth;
        }
      }
      currentGradOutputPlane += outputWidth*outputHeight;
    }
        
    if(partialBackpropagation)
      continue;
    
    // NOTE: boucle *non-necessaire* avec "partial backprop"

    [gradInputs resizeWithNumberOfColumns: numColumns];
    [gradInputs zero];

    gradInputColumn = [gradInputs columnAtIndex: c];
    currentGradOutputPlane = [someGradOutputs columnAtIndex: c];

    for(k = 0; k < numOutputPlanes; k++)
    {
      for(i = 0; i < numInputPlanes; i++)
      {
        real *ptrW = weights[k]+i*kW*kH;
        real *currentGradInputPlane = gradInputColumn+i*inputWidth*inputHeight;
        real *currentGradOutputPlaneRow = currentGradOutputPlane;

        for(yy = 0; yy < outputHeight; yy++)
        {
          for(xx = 0; xx < outputWidth; xx++)
          {
            real *subGradInputPlaneRow = currentGradInputPlane+yy*dH*inputWidth+xx*dW;
            real *ptrWRow = ptrW;

            real z = currentGradOutputPlaneRow[xx];
            for(ky = 0; ky < kH; ky++)
            {
              for(kx = 0; kx < kW; kx++)
                subGradInputPlaneRow[kx] += z * ptrWRow[kx];
              subGradInputPlaneRow += inputWidth;
              ptrWRow += kW;
            }
          }
          currentGradOutputPlaneRow += outputWidth;
        }
      }
      currentGradOutputPlane += outputWidth*outputHeight;
    }
  }

  if(partialBackpropagation)
    return nil;
  else
    return gradInputs;
}

-(int)numberOfOutputPlanes
{
  return numOutputPlanes;
}

-(int)outputHeight
{
  return outputHeight;
}

-(int)outputWidth
{
  return outputWidth;
}

-initWithCoder: (NSCoder*)aCoder
{
  self = [super initWithCoder: aCoder];

  [aCoder decodeValueOfObjCType: @encode(int) at: &kW];
  [aCoder decodeValueOfObjCType: @encode(int) at: &kH];
  [aCoder decodeValueOfObjCType: @encode(int) at: &dW];
  [aCoder decodeValueOfObjCType: @encode(int) at: &dH];
  [aCoder decodeValueOfObjCType: @encode(int) at: &numInputPlanes];
  [aCoder decodeValueOfObjCType: @encode(int) at: &numOutputPlanes];
  [aCoder decodeValueOfObjCType: @encode(int) at: &inputWidth];
  [aCoder decodeValueOfObjCType: @encode(int) at: &inputHeight];
  [aCoder decodeValueOfObjCType: @encode(int) at: &outputWidth];
  [aCoder decodeValueOfObjCType: @encode(int) at: &outputHeight];

  real *parametersData = [[parameters objectAtIndex: 0] firstColumn];
  real *gradParametersData = [[gradParameters objectAtIndex: 0] firstColumn];
  int i;
  
  weights = (real **)[allocator allocPointerArrayWithCapacity: numOutputPlanes];
  for(i = 0; i < numOutputPlanes; i++)
    weights[i] = parametersData + i*kW*kH*numInputPlanes;
  biases = parametersData + kW*kH*numInputPlanes*numOutputPlanes;
  
  gradWeights = (real **)[allocator allocPointerArrayWithCapacity: numOutputPlanes];
  for(i = 0; i < numOutputPlanes; i++)
    gradWeights[i] = gradParametersData + i*kW*kH*numInputPlanes;
  gradBiases = gradParametersData + kW*kH*numInputPlanes*numOutputPlanes;
  
  return self;
}

-(void)encodeWithCoder: (NSCoder*)aCoder
{
  [super encodeWithCoder: aCoder];
  [aCoder encodeValueOfObjCType: @encode(int) at: &kW];
  [aCoder encodeValueOfObjCType: @encode(int) at: &kH];
  [aCoder encodeValueOfObjCType: @encode(int) at: &dW];
  [aCoder encodeValueOfObjCType: @encode(int) at: &dH];
  [aCoder encodeValueOfObjCType: @encode(int) at: &numInputPlanes];
  [aCoder encodeValueOfObjCType: @encode(int) at: &numOutputPlanes];
  [aCoder encodeValueOfObjCType: @encode(int) at: &inputWidth];
  [aCoder encodeValueOfObjCType: @encode(int) at: &inputHeight];
  [aCoder encodeValueOfObjCType: @encode(int) at: &outputWidth];
  [aCoder encodeValueOfObjCType: @encode(int) at: &outputHeight];
}
  
@end
