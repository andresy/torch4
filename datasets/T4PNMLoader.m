#import "T4PNMLoader.h"

//DEBUG: Peut-etre qu'en mode noir et blanc je ne devrais pas inverser
//       les bits pour avoir la meme chose qu'en gris. (Cause 1 c'est normalement
//       blanc! Ceci au chargement et a la sauvegarde.

#ifdef USE_DOUBLE
#define REAL_FORMAT @"%lf"
#else
#define REAL_FORMAT @"%f"
#endif

@implementation T4PNMLoader

-init
{
  if( (self = [super init]) )
  {
    imageWidth = -1;
    imageHeight = -1;
    imageType = -1;
  }

  return self;
}

-(T4Matrix*)loadMatrixFromFile: (T4File*)aFile
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  T4File *file = aFile;
  NSString *stringBuffer;
  const char *charBuffer;
  char charPnmMode[2];
  int pnmType;

  // header
  stringBuffer = [file stringToEndOfLine];

  if( !stringBuffer || ([stringBuffer length] < 2) )
    T4Error(@"PNMLoader: file is not in a PNM format");

  charBuffer = [stringBuffer cString];
  if(charBuffer[0] != 'P')
    T4Error(@"PNMLoader: file is not in a PNM format");

  charPnmMode[0] = charBuffer[1];
  charPnmMode[1] = '\0';
  pnmType = atoi(charPnmMode);
  if( (pnmType <= 0) || (pnmType > 6) )
    T4Error(@"PNMLoader: file is not in a PNM format (wrong mode <%d>)", pnmType);

  stringBuffer = [file stringToEndOfLine];
  if(!stringBuffer)
    T4Error(@"PNMLoader: file is not in a PNM format");

  charBuffer = [stringBuffer cString];
  if(strlen(charBuffer) > 0)
  {
    if(charBuffer[0] == '#')
    {
      stringBuffer = [file stringToEndOfLine];
      if(!stringBuffer)
        T4Error(@"PNMLoader: file is not in a PNM format");
      charBuffer = [stringBuffer cString];
    }
  }
  else
    T4Error(@"PNMLoader: file is not in a PNM format");

  int theImageWidth, theImageHeight;
  sscanf(charBuffer, "%d %d", &theImageWidth, &theImageHeight);

  if( (imageWidth > 0) && (imageWidth != theImageWidth) )
    T4Error(@"PNMLoader: trying to load images of different sizes");
  else
    imageWidth = theImageWidth;
  
  if( (imageHeight > 0) && (imageHeight != theImageHeight) )
    T4Error(@"PNMLoader: trying to load images of different sizes");
  else
    imageHeight = theImageHeight;

  int pnmMaxValue = 0;
  if( (pnmType != 4) && (pnmType != 1) )
  {
    stringBuffer = [file stringToEndOfLine];
    if(!stringBuffer)
      T4Error(@"PNMLoader: file is not in a PNM format");
    charBuffer = [stringBuffer cString];
    sscanf(charBuffer, "%d", &pnmMaxValue);
  }

  int theImageType;
  if( (pnmType == 1) || (pnmType == 4) )
    theImageType = T4PNMBitMap;
  else if( (pnmType == 2) || (pnmType == 5) )
    theImageType = T4PNMGrayMap;
  else
    theImageType = T4PNMPixelMap;

  if( (imageType > 0) && (imageType != theImageType) )
    T4Error(@"PNMLoader: trying to load images of different format");
  else
    imageType = theImageType;

  T4Message(@"PNMLoader: detected image: <%d x %d> with max value: <%d> [mode %d]", imageWidth, imageHeight, pnmMaxValue, pnmType);

  // Reading

  // RGB ?
  int matrixSize;
  if( imageType == T4PNMPixelMap )
    matrixSize = 3*imageWidth*imageHeight;
  else
    matrixSize = imageWidth*imageHeight;

  T4Matrix *matrix = [[T4Matrix alloc] initWithNumberOfRows: matrixSize];

  // Internal /////
  unsigned char *ucharBuffer;
  unsigned char *currentUcharBuffer;
  int numBytesPerRow;
  int h, i, j;
  /////////////////

  real *matrixData = [matrix firstColumn];
  switch(pnmType)
  {
    case 1:
      for(i = 0; i < matrixSize; i++)
      {
        unsigned char c = ' ';
        while( (c != '0') && (c != '1') )
        {
          if(![file readStringWithFormat: @"%c" into: &c])
            T4Error(@"PNMLoader: error while reading");
        }
        if(c == '0')
          matrixData[i] = 1.;
        else
          matrixData[i] = 0.;
      }
      break;
    case 2:
    case 3:
      for(i = 0; i < matrixSize; i++)
      {
        if(![file readStringWithFormat: REAL_FORMAT into: &matrixData[i]])
          T4Error(@"PNMLoader: error while reading");
      }
      break;

    case 4:
      numBytesPerRow = imageWidth/8;
      if(imageWidth % 8)
        numBytesPerRow++;
      ucharBuffer = (unsigned char *)[T4Allocator sysAllocByteArrayWithCapacity: numBytesPerRow*imageHeight];
      if([file readBlocksInto: ucharBuffer blockSize: 1 numberOfBlocks: numBytesPerRow*imageHeight] != numBytesPerRow*imageHeight)
        T4Error(@"PNMLoader: error while reading");

      currentUcharBuffer = ucharBuffer;
      for(h = 0; h < imageHeight; h++)
      {
        real *imageRow = matrixData+h*imageWidth;
        for(i = 0; i < (imageWidth/8); i++)
        {
          unsigned char c = *currentUcharBuffer++;
          for(j = 0; j < 8; j++)
            *imageRow++ = (real)!((c & (128 >> j)) >> (7-j));
        }

        if(imageWidth % 8)
        {
          unsigned char c = *currentUcharBuffer++;
          for(j = 0; j < imageWidth % 8; j++)
            *imageRow++ = (real)!((c & (128 >> j)) >> (7-j));
        }
      }
      [T4Allocator sysFree: ucharBuffer];
      break;

    case 5:
    case 6:
      if(pnmMaxValue > 255)
      {
        ucharBuffer = (unsigned char *)[T4Allocator sysAllocByteArrayWithCapacity: matrixSize*2];

        if([file readBlocksInto: ucharBuffer blockSize: 1  numberOfBlocks: matrixSize*2] != matrixSize*2)
          T4Error(@"PNMLoader: error while reading");

        for(i = 0; i < matrixSize; i++)
          matrixData[i] = ((real)ucharBuffer[2*i])*256.+((real)ucharBuffer[2*i+1]);

        [T4Allocator sysFree: ucharBuffer];
      }
      else
      {
        ucharBuffer = (unsigned char *)[T4Allocator sysAllocByteArrayWithCapacity: matrixSize];

        if([file readBlocksInto: ucharBuffer blockSize: 1  numberOfBlocks: matrixSize] != matrixSize)
          T4Error(@"PNMLoader: error while reading");

        for(i = 0; i < matrixSize; i++)
          matrixData[i] = (real)ucharBuffer[i];

        [T4Allocator sysFree: ucharBuffer];
      }
      break;
  }

  [pool release];

  return [matrix autorelease];
}

-(int)imageWidth
{
  return imageWidth;
}

-(int)imageHeight
{
  return imageHeight;
}

-(int)imageType
{
  return imageType;
}

@end
