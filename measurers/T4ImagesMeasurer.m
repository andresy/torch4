#import "T4ImagesMeasurer.h"
#import "T4PNMSaver.h"

static void T4ImagesMeasurerFillBuffer(T4Matrix *inputImage, T4Matrix *buffer, int numImages, int numImagesPerRow, int imageWidth, int imageHeight)
{
  int i, j;
  int img;

  real *inputData = [inputImage firstColumn];
  real *bufferData = [buffer firstColumn];

  for(img = 0; img < numImages; img++)
  {
    real *currentInputData = inputData + img*imageWidth*imageHeight;
    real *currentBufferData = bufferData + (img/numImagesPerRow)*imageWidth*imageHeight*numImagesPerRow + (img%numImagesPerRow)*imageWidth;
    
    for(i = 0; i < imageHeight; i++)
    {
      for(j = 0; j < imageWidth; j++)
        currentBufferData[j] = currentInputData[i*imageWidth+j];
      currentBufferData += imageWidth*numImagesPerRow;
    }
  }
}

@implementation T4ImagesMeasurer

-initWithInputs: (T4Matrix*)someInputs imageWidth: (int)aWidth imageHeight: (int)aHeight 
 numberOfImages: (int)aNumImages
        dataset: (NSArray*)aDataset fileNamePrefix: (NSString*)aFileNamePrefix
{
  if( (self = [super initWithDataset: aDataset file: nil]) )
  {
    inputs = [someInputs retainAndKeepWithAllocator: allocator];

    imageWidth = aWidth;
    imageHeight = aHeight;
    numImages = aNumImages;

    fileNamePrefix = [aFileNamePrefix retainAndKeepWithAllocator: allocator];

    buffer = nil;

    [self setImageMinValue: 0];
    [self setImageMaxValue: 0];
    [self setNumberOfImagesPerRow: -1];
    [self setMeasuresAtEachIteration];
    [self reset];
  }

  return self;
}

-reset
{
  imageIndex = 0;
  return self;
}


-measureExampleAtIndex: (int)anIndex
{
  if(measuresAtEachExample)
    [self writeImage];
  return self;
}
-measureAtIteration: (int)anIteration
{
  if(measuresAtEachIteration)
    [self writeImage];
  return self;
}

-measureAtEnd
{
  if(measuresAtEnd)
    [self writeImage];
  return self;
}

-writeImage
{
  T4ImagesMeasurerFillBuffer(inputs, buffer, numImages, numImagesPerRow, imageWidth, imageHeight);

  NSString *path = [[NSString alloc] initWithFormat: @"%@_%d.pgm", fileNamePrefix, imageIndex];
  T4PNMSaver *saver = [[T4PNMSaver alloc] initWithImageWidth: imageWidth*numImagesPerRow imageHeight: imageHeight*numImagesPerColumn imageType: T4PNMGrayMap];
  [saver saveMatrix: buffer atPath: path];
  [saver setImageMinValue: imageMinValue];
  [saver setImageMaxValue: imageMaxValue];
  [saver release];
  [path release];
 
  imageIndex++;

 return self;
}

-setNumberOfImagesPerRow: (int)aNumImagesPerRow
{
  if(aNumImagesPerRow > 0)
    numImagesPerRow = aNumImagesPerRow;
  else
    numImagesPerRow = (int)sqrt((real)numImages);

  numImagesPerColumn = numImages/numImagesPerRow;
  if(numImagesPerRow*numImagesPerColumn < numImages)
    numImagesPerColumn++;
  
  [allocator freeObject: buffer];
  buffer = [[[T4Matrix alloc] initWithNumberOfRows: imageWidth*imageHeight*numImagesPerRow*numImagesPerColumn] keepWithAllocator: allocator];
  [buffer zero];

  return self;
}

-setMeasuresAtEachIteration
{
  measuresAtEachExample = NO;
  measuresAtEachIteration = YES;
  measuresAtEnd = NO;
  return self;
}

-setMeasuresAtEachExample
{
  measuresAtEachExample = YES;
  measuresAtEachIteration = NO;
  measuresAtEnd = NO;
  return self;
}

-setMeasuresAtEnd
{
  measuresAtEachExample = NO;
  measuresAtEachIteration = NO;
  measuresAtEnd = YES;
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

@end
