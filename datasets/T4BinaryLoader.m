#import "T4BinaryLoader.h"

@implementation T4BinaryLoader

-init
{
  if( (self = [super init]) )
  {
    [self setTransposesMatrix: YES];
    [self setMaxNumberOfColumns: -1];
    [self setReadsFloat: NO];
    [self setReadsDouble: NO];
  }

  return self;
}

-(T4Matrix*)loadMatrixFromFile: (T4File*)aFile
{
  T4Matrix *matrix;
  int numRows, numColumns;

  if([aFile read: &numRows blockSize: sizeof(int) numberOfBlocks: 1] != 1)
    T4Error(@"BinaryLoader: file header corrupted");

  if([aFile read: &numColumns blockSize: sizeof(int) numberOfBlocks: 1] != 1)
    T4Error(@"BinaryLoader: file header corrupted");

  if( (numRows <= 0) || (numColumns <= 0) )
    T4Error(@"BinaryLoader: file header seems corrupted");

  if(transposesMatrix)
  {
    int z = numRows;
    numRows = numColumns;
    numColumns = z;
  }

  T4Message(@"BinaryLoader: %d rows and %d columns detected", numRows, numColumns);

  if( (maxNumColumns > 0) && (maxNumColumns < numColumns) )
  {
    numColumns = maxNumColumns;
    T4Warning(@"BinaryLoader: loading only %d columns", numColumns);
  }

  matrix = [[T4Matrix alloc] initWithNumberOfRows: numRows numberOfColumns: numColumns];

  if(sizeof(real) == diskRealSize)
  {
    if(transposesMatrix)
    {
      if([aFile read: [matrix firstColumn] blockSize: sizeof(real) numberOfBlocks: numRows*numColumns] != numRows*numColumns)
        T4Error(@"BinaryLoader: file corrupted");
    }
    else
    {
      int r, c;
      real *data = [matrix firstColumn];
      int stride = [matrix stride];
      
      for(r = 0; r < numRows; r++)
      {
        for(c = 0; c < numColumns; c++)
        {
          if([aFile read: &data[c*stride+r] blockSize: sizeof(real) numberOfBlocks: 1] != 1)
            T4Error(@"BinaryLoader: file corrupted");
        }
      }
    }
  }
  else
  {
    if(diskRealSize == sizeof(float))
    {
      T4Message(@"BinaryLoader: enforcing float reading");
      if(transposesMatrix)
      {
        float *buffer = [T4Allocator sysAllocByteArrayWithCapacity: sizeof(float)*numRows];
        int c, r;

        for(c = 0; c < numColumns; c++)
        {
          if([aFile read: buffer blockSize: sizeof(float) numberOfBlocks: numRows] != numRows)
            T4Error(@"BinaryLoader: file corrupted");

          real *currentColumn = [matrix columnAtIndex: c];
          for(r = 0; r < numRows; r++)
            currentColumn[r] = (real)buffer[r];
        }

        [T4Allocator sysFree: buffer];
      }
      else
      {
        int r, c;
        real *data = [matrix firstColumn];
        int stride = [matrix stride];
        float buffer;

        for(r = 0; r < numRows; r++)
        {
          for(c = 0; c < numColumns; c++)
          {
            if([aFile read: &buffer blockSize: sizeof(float) numberOfBlocks: 1] != 1)
              T4Error(@"BinaryLoader: file corrupted");
            data[c*stride+r] = (real)buffer;
          }
        }
      }
    }
    else
    {
      T4Message(@"BinaryLoader: enforcing double reading");
      if(transposesMatrix)
      {
        double *buffer = [T4Allocator sysAllocByteArrayWithCapacity: sizeof(double)*numRows];
        int c, r;

        for(c = 0; c < numColumns; c++)
        {
          if([aFile read: buffer blockSize: sizeof(double) numberOfBlocks: numRows] != numRows)
            T4Error(@"BinaryLoader: file corrupted");

          real *currentColumn = [matrix columnAtIndex: c];
          for(r = 0; r < numRows; r++)
            currentColumn[r] = (real)buffer[r];
        }

        [T4Allocator sysFree: buffer];
      }
      else
      {
        int r, c;
        real *data = [matrix firstColumn];
        int stride = [matrix stride];
        double buffer;

        for(r = 0; r < numRows; r++)
        {
          for(c = 0; c < numColumns; c++)
          {
            if([aFile read: &buffer blockSize: sizeof(double) numberOfBlocks: 1] != 1)
              T4Error(@"BinaryLoader: file corrupted");
            data[c*stride+r] = (real)buffer;
          }
        }
      }
    }
  }
  
  return [matrix autorelease];
}

-setTransposesMatrix: (BOOL)aFlag
{
  transposesMatrix = aFlag;
  return self;
}

-setMaxNumberOfColumns: (int)aMaxNumber
{
  maxNumColumns = aMaxNumber;
  return self;
}

-setReadsFloat: (BOOL)aFlag
{
  if(aFlag)
    diskRealSize = sizeof(float);
  else
    diskRealSize = sizeof(real);

  return self;
}

-setReadsDouble: (BOOL)aFlag
{
  if(aFlag)
    diskRealSize = sizeof(double);
  else
    diskRealSize = sizeof(real);

  return self;
}

@end
