#import "T4PNMSaver.h"

//DEBUG: Peut-etre qu'en mode noir et blanc je ne devrais pas inverser
//       les bits pour avoir la meme chose qu'en gris. (Cause 1 c'est normalement
//       blanc! Ceci au chargement et a la sauvegarde.

@implementation T4PNMSaver

-init
{
  if( (self = [super init]) )
  {
    [self setImageWidth: 0];
    [self setImageHeight: 0];
    [self setImageMode: T4PNMGrayLevelsMode];
    [self setImageMaxValue: -1];
  }

  return self;
}

-saveMatrix: (T4Matrix*)aMatrix intoFile: (T4File*)aFile
{
  T4File *file = aFile;
  unsigned char *ucharBuffer;
  int numBytesPerRow;
  real myImageMaxValue;
  unsigned char *currentUcharBuffer;
  int h, i, j;

  real *matrixData = [aMatrix firstColumn];
  int matrixSize = [aMatrix numberOfRows];

  if( (imageMode == T4PNMBlackAndWhiteMode) ||  (imageMode == T4PNMGrayLevelsMode) )
  {
    if(matrixSize != imageWidth*imageHeight)
      T4Error(@"T4PNMSaver: image size [%d x %d x 1] does not fit with matrix size [%d]", imageWidth, imageHeight, matrixSize);
  }

  if(imageMode == T4PNMColorMode)
  {
    if(matrixSize != 3*imageWidth*imageHeight)
      T4Error(@"T4PNMSaver: image size [%d x %d x 3] does not fit with matrix size [%d]", imageWidth, imageHeight, matrixSize);
  }

  switch(imageMode)
  {
    case T4PNMBlackAndWhiteMode:
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

    case T4PNMGrayLevelsMode:
    case T4PNMColorMode:

      if( imageMode == T4PNMGrayLevelsMode )
        [file writeStringWithFormat: @"P5\n"];
      else
        [file writeStringWithFormat: @"P6\n"];

      // Max value ?
      myImageMaxValue = -T4Inf;
      for(i = 0; i < matrixSize; i++)
      {
        real z = matrixData[i];
        if(z < 0)
          T4Error(@"PNMSaver: your image has negative values [%g]", z);

        if(z > myImageMaxValue)
          myImageMaxValue = matrixData[i];
      }

      if((int)myImageMaxValue > 65535)
        T4Error(@"PNMSaver: too large value in your image");

      if(imageMaxValue < (int)myImageMaxValue)
      {
        if(imageMaxValue > 0)
          T4Warning(@"PNMSaver: overriding the provided max value which is too small [%g]", myImageMaxValue);

        int z = (int)myImageMaxValue;
        imageMaxValue = 1;
        while(imageMaxValue-1 < z)
          imageMaxValue <<= 1;
        imageMaxValue -= 1;
      }

      [file writeStringWithFormat: @"%d %d\n%d\n", imageWidth, imageHeight, imageMaxValue];
      if(imageMaxValue > 255)
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

-setImageWidth: (int)aWidth
{
  imageWidth = aWidth;
  return self;
}

-setImageHeight: (int)aHeight
{
  imageHeight = aHeight;
  return self;
}

-setImageMode: (int)aMode
{
  imageMode = aMode;
  if(! ( (imageMode == T4PNMBlackAndWhiteMode) || (imageMode == T4PNMGrayLevelsMode) || (imageMode == T4PNMColorMode) ) )
    T4Error(@"PNMSaver: invalid image mode");
  return self;
}

-setImageMaxValue: (int)aValue
{
  imageMaxValue = aValue;
  return self;
}

@end
