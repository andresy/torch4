#import "T4BinarySaver.h"

@implementation T4BinarySaver

-init
{
  if( (self = [super init]) )
  {
    [self setTransposesMatrix: YES];
    [self setEnforcesFloatEncoding: NO];
    [self setEnforcesDoubleEncoding: NO];
  }

  return self;
}

-saveMatrix: (T4Matrix*)aMatrix intoFile: (T4File*)aFile
{
  int numRows = [aMatrix numberOfRows];
  int numColumns = [aMatrix numberOfColumns];
  int r, c;

  if(transposesMatrix)
  {
    if([aFile writeBlocksFrom: &numColumns blockSize: sizeof(int) numberOfBlocks: 1] != 1)
      T4Error(@"BinarySaver: error while writing");

    if([aFile writeBlocksFrom: &numRows blockSize: sizeof(int) numberOfBlocks: 1] != 1)
      T4Error(@"BinarySaver: error while writing");    
  }
  else
  {
    if([aFile writeBlocksFrom: &numRows blockSize: sizeof(int) numberOfBlocks: 1] != 1)
      T4Error(@"BinarySaver: error while writing");
    
    if([aFile writeBlocksFrom: &numColumns blockSize: sizeof(int) numberOfBlocks: 1] != 1)
      T4Error(@"BinarySaver: error while writing");
  }

  if(sizeof(real) == diskRealSize)
  {
    if(transposesMatrix)
    {
      if([aFile writeBlocksFrom: [aMatrix firstColumn] blockSize: sizeof(real) numberOfBlocks: numRows*numColumns] != numRows*numColumns)
        T4Error(@"BinarySaver: error while writing");
    }
    else
    {
      real *data = [aMatrix firstColumn];
      int stride = [aMatrix stride];
      
      for(r = 0; r < numRows; r++)
      {
        for(c = 0; c < numColumns; c++)
        {
          if([aFile writeBlocksFrom: &data[c*stride+r] blockSize: sizeof(real) numberOfBlocks: 1] != 1)
            T4Error(@"BinarySaver: error while writing");
        }
      }
    }
  }
  else
  {
    if(diskRealSize == sizeof(float))
    {
      T4Message(@"BinarySaver: enforcing float encoding");
      if(transposesMatrix)
      {
        float *buffer = [T4Allocator sysAllocByteArrayWithCapacity: sizeof(float)*numRows];

        for(c = 0; c < numColumns; c++)
        {
          real *currentColumn = [aMatrix columnAtIndex: c];
          for(r = 0; r < numRows; r++)
            buffer[r] = (float)currentColumn[r];
          
          if([aFile writeBlocksFrom: buffer blockSize: sizeof(float) numberOfBlocks: numRows] != numRows)
            T4Error(@"BinarySaver: error while writing");
        }

        [T4Allocator sysFree: buffer];
      }
      else
      {
        real *data = [aMatrix firstColumn];
        int stride = [aMatrix stride];
        float buffer;

        for(r = 0; r < numRows; r++)
        {
          for(c = 0; c < numColumns; c++)
          {
            buffer = (float)data[c*stride+r];
            if([aFile writeBlocksFrom: &buffer blockSize: sizeof(float) numberOfBlocks: 1] != 1)
              T4Error(@"BinarySaver: error while writing");
          }
        }
      }
    }
    else
    {
      T4Message(@"BinarySaver: enforcing double encoding");
      if(transposesMatrix)
      {
        double *buffer = [T4Allocator sysAllocByteArrayWithCapacity: sizeof(double)*numRows];

        for(c = 0; c < numColumns; c++)
        {
          real *currentColumn = [aMatrix columnAtIndex: c];
          for(r = 0; r < numRows; r++)
            buffer[r] = (double)currentColumn[r];

          if([aFile writeBlocksFrom: buffer blockSize: sizeof(double) numberOfBlocks: numRows] != numRows)
            T4Error(@"BinarySaver: file corrupted");
        }

        [T4Allocator sysFree: buffer];
      }
      else
      {
        real *data = [aMatrix firstColumn];
        int stride = [aMatrix stride];
        double buffer;

        for(r = 0; r < numRows; r++)
        {
          for(c = 0; c < numColumns; c++)
          {
            buffer = (double)data[c*stride+r];
            if([aFile writeBlocksFrom: &buffer blockSize: sizeof(double) numberOfBlocks: 1] != 1)
              T4Error(@"BinarySaver: file corrupted");
          }
        }
      }
    }
  }
  
  return self;
}

-setTransposesMatrix: (BOOL)aFlag
{
  transposesMatrix = aFlag;
  return self;
}

-setEnforcesFloatEncoding: (BOOL)aFlag
{
  if(aFlag)
    diskRealSize = sizeof(float);
  else
    diskRealSize = sizeof(real);

  return self;
}

-setEnforcesDoubleEncoding: (BOOL)aFlag
{
  if(aFlag)
    diskRealSize = sizeof(double);
  else
    diskRealSize = sizeof(real);

  return self;
}

@end
