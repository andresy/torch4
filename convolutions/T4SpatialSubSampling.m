#import "T4SpatialSubSampling.h"
#import "T4Random.h"

@implementation T4SpatialSubSampling

-initWithNumberOfInputPlanes: (int)aNumInputPlanes
                  inputWidth: (int)anInputWidth
                intputHeight: (int)anInputHeight
                  kernelSize: (int)aKW
                          dX: (int)aDX
                          dY: (int)aDY
{
  int anOutputWidth = (anInputWidth - aKW) / aDX + 1;
  int anOutputHeight = (anInputHeight - aKW) / aDY + 1;

  if(anInputWidth < aKW)
    T4Error(@"SpatialSubSampling: input image width is too small (width = %d < kW = %d) ", anInputWidth, aKW);
  if(anInputHeight < aKW)
    T4Error(@"SpatialSubSampling: input image height is too small (height = %d < kW = %d) ", anInputHeight, aKW);

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
    dX = aDX;
    dY = aDY;

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
  real bound = 1./sqrt((real)(kW*kW));
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
      
      // For all output pixels...
      for(yy = 0; yy < outputHeight; yy++)
      {
        for(xx = 0; xx < outputWidth; xx++)
        {
          // Compute the mean of the input image...
          real *subInputPlane = currentInputPlane+yy*dY*inputWidth+xx*dX;
          real sum = 0;
          for(ky = 0; ky < kW; ky++)
          {
            for(kx = 0; kx < kW; kx++)
              sum += subInputPlane[ky*inputWidth+kx];
          }
          
          // Update output
          currentOutputPlane[yy*outputWidth+xx] += theWeight*sum;
        }
      }
      
      // Next input/output plane
      currentInputPlane += inputWidth*inputHeight;
      currentOutputPlane += outputWidth*outputHeight;
    }
  }

  return outputs;
}

-(T4Matrix*)backwardMatrix: (T4Matrix*)someGradOutputs inputs: (T4Matrix*)someInputs
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
      
      sum = 0;
      for(yy = 0; yy < outputHeight; yy++)
      {
        for(xx = 0; xx < outputWidth; xx++)
        {
          real *subInputPlane = currentInputPlane+yy*dY*inputWidth+xx*dX;
          real z = currentGradOutputPlane[yy*outputWidth+xx];
          for(ky = 0; ky < kW; ky++)
          {
            for(kx = 0; kx < kW; kx++)
              sum += z * subInputPlane[ky*inputWidth+kx];
          }
        }
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
    
    currentGradInputPlane = [someInputs columnAtIndex: c];
    currentGradOutputPlane = [someGradOutputs columnAtIndex: c];

    for(k = 0; k < numInputPlanes; k++)
    {
      real theWeight = weights[k];
      for(yy = 0; yy < outputHeight; yy++)
      {
        for(xx = 0; xx < outputWidth; xx++)
        {
          real *subGradInputPlane = currentGradInputPlane+yy*dY*inputWidth+xx*dX;
          real z = currentGradOutputPlane[yy*outputWidth+xx] * theWeight;
          for(ky = 0; ky < kW; ky++)
          {
            for(kx = 0; kx < kW; kx++)
              subGradInputPlane[ky*inputWidth+kx] += z;
          }
        }
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

@end
