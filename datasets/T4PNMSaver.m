#import "T4PNMSaver.h"
#import "T4PNMLoader.h"

//DEBUG: Peut-etre qu'en mode noir et blanc je ne devrais pas inverser
//       les bits pour avoir la meme chose qu'en gris. (Cause 1 c'est normalement
//       blanc! Ceci au chargement et a la sauvegarde.

static void T4PNMSaverNormalizeImage(T4Matrix *inputImage, T4Matrix *outputImage, real imageMinValue, real imageMaxValue, real pnmMaxValue)
{
  int numRows = [inputImage numberOfRows];
  real *inputData = [inputImage firstColumn];
  real *outputData = [outputImage firstColumn];
  real minValue, maxValue;
  int i;

  if(imageMinValue >= imageMaxValue)
  {
    minValue = T4Inf;
    maxValue = -T4Inf;

    for(i = 0; i < numRows; i++)
    {
      real z = inputData[i];
      
      if(z < minValue)
        minValue = z;
      
      if(z > maxValue)
        maxValue = z;
    }

    if(minValue == maxValue)
      maxValue += 1;
  }
  else
  {
    minValue = imageMinValue;
    maxValue = imageMaxValue;
  }

  if(pnmMaxValue < 0)
    pnmMaxValue = 255;

  for(i = 0; i < numRows; i++)
    outputData[i] = (inputData[i]-minValue)/(maxValue-minValue)*pnmMaxValue;
}

@implementation T4PNMSaver

-initWithImageWidth: (int)aWidth imageHeight: (int)aHeight imageType: (int)aType
{
  if( (self = [super init]) )
  {
    imageWidth = aWidth;
    imageHeight = aHeight;
    imageType = aType;
    normalizedImage = nil;

    [self setImageMinValue: 0];
    [self setImageMaxValue: 0];
    [self setNormalizesImage: YES];
    
    [self setPNMMaxValue: -1];
  }

  return self;
}

-saveMatrix: (T4Matrix*)aMatrix intoFile: (T4File*)aFile
{
  T4File *file = aFile;
  unsigned char *ucharBuffer;
  int numBytesPerRow;
  real myPnmMaxValue;
  unsigned char *currentUcharBuffer;
  int h, i, j;

  if(normalizedImage)
  {
    T4PNMSaverNormalizeImage(aMatrix, normalizedImage, imageMinValue, imageMaxValue, (real)pnmMaxValue);
    aMatrix = normalizedImage;
  }

  real *matrixData = [aMatrix firstColumn];
  int matrixSize = [aMatrix numberOfRows];

  if( (imageType == T4PNMBitMap) ||  (imageType == T4PNMGrayMap) )
  {
    if(matrixSize != imageWidth*imageHeight)
      T4Error(@"T4PNMSaver: image size [%d x %d x 1] does not fit with matrix size [%d]", imageWidth, imageHeight, matrixSize);
  }

  if(imageType == T4PNMPixelMap)
  {
    if(matrixSize != 3*imageWidth*imageHeight)
      T4Error(@"T4PNMSaver: image size [%d x %d x 3] does not fit with matrix size [%d]", imageWidth, imageHeight, matrixSize);
  }

  switch(imageType)
  {
    case T4PNMBitMap:
      [file writeStringWithFormat: @"P4\n%d %d\n", imageWidth, imageHeight];

      numBytesPerRow = imageWidth/8;
      if(imageWidth % 8)
        numBytesPerRow++;
      ucharBuffer = (unsigned char *)[T4Allocator sysAllocByteArrayWithCapacity: numBytesPerRow*imageHeight];

      currentUcharBuffer = ucharBuffer;
      for(h = 0; h < imageHeight; h++)
      {
        real *imageRow = matrixData+h*imageWidth;
        for(i = 0; i < (imageWidth/8); i++)
        {
          unsigned char c = 0;
          for(j = 0; j < 8; j++)
          {
            if(!*imageRow++)
              c |= (128 >> j);
          }
          *currentUcharBuffer++ = c;
        }

        if(imageWidth % 8)
        {
          unsigned char c = 0;
          for(j = 0; j < imageWidth % 8; j++)
          {
            if(!*imageRow++)
              c |= (128 >> j);
          }
          *currentUcharBuffer++ = c;
        }
      }
      if([file writeBlocksFrom: ucharBuffer blockSize: 1 numberOfBlocks: numBytesPerRow*imageHeight] != numBytesPerRow*imageHeight)
        T4Error(@"PNMSaver: error while writing");

      [T4Allocator sysFree: ucharBuffer];
      break;

    case T4PNMGrayMap:
    case T4PNMPixelMap:

      if( imageType == T4PNMGrayMap )
        [file writeStringWithFormat: @"P5\n"];
      else
        [file writeStringWithFormat: @"P6\n"];

      // Max value ?
      myPnmMaxValue = -T4Inf;
      for(i = 0; i < matrixSize; i++)
      {
        real z = matrixData[i];
        if(z < 0)
          T4Error(@"PNMSaver: your image has negative values [%g]", z);

        if(z > myPnmMaxValue)
          myPnmMaxValue = matrixData[i];
      }

      if((int)myPnmMaxValue > 65535)
        T4Error(@"PNMSaver: too large value in your image");

      if(pnmMaxValue < (int)myPnmMaxValue)
      {
        if(pnmMaxValue > 0)
          T4Warning(@"PNMSaver: overriding the provided max value which is too small [%g]", myPnmMaxValue);

        int z = (int)myPnmMaxValue;
        pnmMaxValue = 1;
        while(pnmMaxValue-1 < z)
          pnmMaxValue <<= 1;
        pnmMaxValue -= 1;
      }

      [file writeStringWithFormat: @"%d %d\n%d\n", imageWidth, imageHeight, pnmMaxValue];
      if(pnmMaxValue > 255)
      {
        ucharBuffer = (unsigned char *)[T4Allocator sysAllocByteArrayWithCapacity: matrixSize*2];

        for(i = 0; i < matrixSize; i++)
        {
          int z = (int)(*matrixData++);
          ucharBuffer[2*i]   = z/256;
          ucharBuffer[2*i+1] = z%256;
        }

        if([file writeBlocksFrom: ucharBuffer blockSize: 1 numberOfBlocks: matrixSize*2] != matrixSize*2)
          T4Error(@"PNMSaver: error while writing");

        [T4Allocator sysFree: ucharBuffer];
      }
      else
      {
        ucharBuffer = (unsigned char *)[T4Allocator sysAllocByteArrayWithCapacity: matrixSize];

        for(i = 0; i < matrixSize; i++)
          ucharBuffer[i] = (unsigned char)matrixData[i];

        if([file writeBlocksFrom: ucharBuffer blockSize: 1  numberOfBlocks: matrixSize] != matrixSize)
          T4Error(@"PNMSaver: error while writing");

        [T4Allocator sysFree: ucharBuffer];
      }
      break;
    default:
      T4Error(@"PNMSaver: internal bug (?!). The provided image mode is not a valid!!!");
  }

  return self;
}

-setImageMinValue: (real)aValue
{
  imageMinValue = aValue;
  return self;
}

-setImageMaxValue: (real)aValue
{
  imageMaxValue = aValue;
  return self;
}

-setNormalizesImage: (BOOL)aFlag
{
  if(aFlag)
  {
    int matrixSize;

    if( (imageType == T4PNMBitMap) ||  (imageType == T4PNMGrayMap) )
      matrixSize =   imageWidth*imageHeight;
    else
      matrixSize = 3*imageWidth*imageHeight;

    if(!normalizedImage)
      normalizedImage = [[[T4Matrix alloc] initWithNumberOfRows: matrixSize] keepWithAllocator: allocator];
  }
  else
  {
    [allocator freeObject: normalizedImage];
    normalizedImage = nil;
  }
  
  return self;
}

-setPNMMaxValue: (int)aValue
{
  pnmMaxValue = aValue;

  if(pnmMaxValue > 65535)
    T4Error(@"PNMSaver: the provider max value is too large (%d > 65535)", pnmMaxValue);

  return self;
}

@end
