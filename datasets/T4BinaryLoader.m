#import "T4BinaryLoader.h"

@implementation T4BinaryLoader

-init
{
  if( (self = [super init]) )
  {
    [self setTransposesMatrix: YES];
    [self setMaxNumberOfColumns: -1];
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

@end
