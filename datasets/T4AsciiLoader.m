#import "T4AsciiLoader.h"

@implementation T4AsciiLoader

-init
{
  if( (self = [super init]) )
  {
    [self setHasHeader: YES];
  }

  return self;
}

-(T4Matrix*)loadMatrixFromFile: (T4File*)aFile
{
  T4Matrix *matrix;
  real *data;
  int numRows, numColumns;

  if(hasHeader)
  {
    if(transposesMatrix)
    {
      [aFile readStringWithFormat: @"%d" into: &numColumns];
      [aFile readStringWithFormat: @"%d" into: &numRows];
    }
    else
    {
      [aFile readStringWithFormat: @"%d" into: &numRows];
      [aFile readStringWithFormat: @"%d" into: &numColumns];
    }
    T4Message(@"AsciiLoader: %d rows and %d columns detected", numRows, numColumns);
  }
  else
  {
    numRows = 0;
    numColumns = -1;

    
    T4Message(@"AsciiLoader: %d rows and %d columns detected", numRows, numColumns);
  }

  matrix = [[T4Matrix alloc] initWithNumberOfRows: numRows numberOfColumns: numColumns];
  [allocator keepObject: matrix];
  
  data = [matrix firstColumn];
  if(transposesMatrix)
  {
    int i;

    for(i = 0; i < numRows*numColumns; i++)
    {
#ifdef USE_DOUBLE
      [aFile readStringWithFormat: @"%lg" into: &data[i]];
#else
      [aFile readStringWithFormat: @"%g" into: &data[i]];
#endif
    }
  }
  else
  {
    int stride = [matrix stride];
    int r, c;

    for(r = 0; r < numRows; r++)
    {
      for(c = 0; c < numColumns; c++)
      {
#ifdef USE_DOUBLE
        [aFile readStringWithFormat: @"%lg" into: &data[c*stride+r]];
#else
        [aFile readStringWithFormat: @"%g" into: &data[c*stride+r]];
#endif
      }
    }
  }

  return matrix;
}

-(void)setHasHeader: (BOOL)aFlag
{
  hasHeader = aFlag;
}

@end
