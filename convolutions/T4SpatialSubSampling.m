#import "T4SpatialSubSampling.h"
#import "T4Random.h"

@implementation T4SpatialSubSampling

-initWithNumberOfInputPlanes: (int)aNumInputPlanes
                  inputWidth: (int)anInputWidth
                outputHeight: (int)anInputHeight
                 kernelWidth: (int)aKW
                kernelHeight: (int)aKH
             kernelWidthStep: (int)aDW
            kernelHeightStep: (int)aDH
{
  int anOutputWidth = (anInputWidth - aKW) / aDW + 1;
  int anOutputHeight = (anInputHeight - aKH) / aDH + 1;

  if(anInputWidth < aKW)
    T4Error(@"SpatialSubSampling: input image width is too small (width = %d < kW = %d) ", anInputWidth, aKW);
  if(anInputHeight < aKH)
    T4Error(@"SpatialSubSampling: input image height is too small (height = %d < kH = %d) ", anInputHeight, aKH);

  T4Message(@"SpatialSubSampling: output image is <%d x %d>", anOutputWidth, anOutputHeight);

  if( (self = [super initWithNumberOfInputs: aNumInputPlanes * anInputHeight * anInputWidth
                     numberOfOutputs: aNumInputPlanes * anOutputHeight * anOutputWidth
                     numberOfParameters: 2*aNumInputPlanes]) )
  {
    numInputPlanes = aNumInputPlanes;
    inputWidth = anInputWidth;
    inputHeight = anInputHeight;
    outputWidth = anOutputWidth;
    outputHeight = anOutputHeight;
    kW = aKW;
    kH = aKH;
    dW = aDW;
    dH = aDH;

    weights = [[parameters objectAtIndex: 0] firstColumn];
    biases = weights + numInputPlanes;

    gradWeights = [[gradParameters objectAtIndex: 0] firstColumn];
    gradBiases = gradWeights + numInputPlanes;

    [self reset];
  }

  return self;
}

-reset
{
  real bound = 1./sqrt((real)(kW*kH));
  int numParameters = [[parameters objectAtIndex: 0] numberOfRows];
  real *parametersData = [[parameters objectAtIndex: 0] firstColumn];
  int i;

  for(i = 0; i < numParameters; i++)
    parametersData[i] = [T4Random uniformBoundedWithValue: -bound value: bound];

  return self;
}

-(T4Matrix*)forwardInputs: (T4Matrix*)someInputs
{
  int numColumns = [someInputs numberOfColumns];
  int i, k, c, xx, yy, kx, ky;

  [outputs resizeWithNumberOfColumns: numColumns];

  for(c = 0; c < numColumns; c++)
  {
    real *currentInputPlane = [someInputs columnAtIndex: c];
    real *currentOutputPlane = [outputs columnAtIndex: c];

    for(k = 0; k < numInputPlanes; k++)
    {
      // Initialize to the bias
      real z = biases[k];
      for(i = 0; i < outputWidth*outputHeight; i++)
        currentOutputPlane[i] = z;
      
      // Go!
      
      // Get the good mask for (k,i) (k out, i in)
      real theWeight = weights[k];
      real *currentOutputPlaneRow = currentOutputPlane;

      // For all output pixels...
      for(yy = 0; yy < outputHeight; yy++)
      {
        for(xx = 0; xx < outputWidth; xx++)
        {
          // Compute the mean of the input image...
          real *subInputPlaneRow = currentInputPlane+yy*dH*inputWidth+xx*dW;

          real sum = 0;
          for(ky = 0; ky < kH; ky++)
          {
            for(kx = 0; kx < kW; kx++)
              sum += subInputPlaneRow[kx];
            subInputPlaneRow += inputWidth;
          }
          
          // Update output
          currentOutputPlaneRow[xx] += theWeight*sum;
        }
        currentOutputPlaneRow += outputWidth;
      }
      
      // Next input/output plane
      currentInputPlane += inputWidth*inputHeight;
      currentOutputPlane += outputWidth*outputHeight;
    }
  }

  return outputs;
}

-(T4Matrix*)backwardGradOutputs: (T4Matrix*)someGradOutputs inputs: (T4Matrix*)someInputs
{
  int numColumns = [someInputs numberOfColumns];
  int i, k, c, xx, yy, kx, ky;
  real *currentGradInputPlane;

  for(c = 0; c < numColumns; c++)
  {
    real *currentInputPlane = [someInputs columnAtIndex: c];
    real *currentGradOutputPlane = [someGradOutputs columnAtIndex: c];

    // NOTE: boucle *necessaire* avec "partial backprop"

    for(k = 0; k < numInputPlanes; k++)
    {
      real sum = 0;
      for(i = 0; i < outputWidth*outputHeight; i++)
        sum += currentGradOutputPlane[i];
      gradBiases[k] += sum;
      
      real *currentGradOutputPlaneRow = currentGradOutputPlane;

      sum = 0;
      for(yy = 0; yy < outputHeight; yy++)
      {
        for(xx = 0; xx < outputWidth; xx++)
        {
          real *subInputPlaneRow = currentInputPlane+yy*dH*inputWidth+xx*dW;
          
          real z = currentGradOutputPlaneRow[xx];
          for(ky = 0; ky < kH; ky++)
          {
            for(kx = 0; kx < kW; kx++)
              sum += z * subInputPlaneRow[kx];
            subInputPlaneRow += inputWidth;
          }
        }
        currentGradOutputPlaneRow += outputWidth;
      }
      gradWeights[k] += sum;
      currentInputPlane += inputWidth*inputHeight;
      currentGradOutputPlane += outputWidth*outputHeight;
    }

    if(partialBackpropagation)
      continue;

    // NOTE: boucle *non-necessaire* avec "partial backprop"
    
    [gradInputs resizeWithNumberOfColumns: numColumns];
    [gradInputs zero];
    
    currentGradInputPlane = [gradInputs columnAtIndex: c];
    currentGradOutputPlane = [someGradOutputs columnAtIndex: c];

    for(k = 0; k < numInputPlanes; k++)
    {
      real theWeight = weights[k];
      real *currentGradOutputPlaneRow = currentGradOutputPlane;

      for(yy = 0; yy < outputHeight; yy++)
      {
        for(xx = 0; xx < outputWidth; xx++)
        {
          real *subGradInputPlaneRow = currentGradInputPlane+yy*dH*inputWidth+xx*dW;

          real z = currentGradOutputPlaneRow[xx] * theWeight;
          for(ky = 0; ky < kH; ky++)
          {
            for(kx = 0; kx < kW; kx++)
              subGradInputPlaneRow[kx] += z;
            subGradInputPlaneRow += inputWidth;
          }
        }
        currentGradOutputPlaneRow += outputWidth;
      }
      currentGradInputPlane += inputWidth*inputHeight;
      currentGradOutputPlane += outputWidth*outputHeight;
    }
  }

  if(partialBackpropagation)
    return nil;
  else
    return gradInputs;
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
  [aCoder decodeValueOfObjCType: @encode(int) at: &inputWidth];
  [aCoder decodeValueOfObjCType: @encode(int) at: &inputHeight];
  [aCoder decodeValueOfObjCType: @encode(int) at: &outputWidth];
  [aCoder decodeValueOfObjCType: @encode(int) at: &outputHeight];
  
  weights = [[parameters objectAtIndex: 0] firstColumn];
  biases = weights + numInputPlanes;
  
  gradWeights = [[gradParameters objectAtIndex: 0] firstColumn];
  gradBiases = gradWeights + numInputPlanes;
  
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
  [aCoder encodeValueOfObjCType: @encode(int) at: &inputWidth];
  [aCoder encodeValueOfObjCType: @encode(int) at: &inputHeight];
  [aCoder encodeValueOfObjCType: @encode(int) at: &outputWidth];
  [aCoder encodeValueOfObjCType: @encode(int) at: &outputHeight];
}

@end
