#import "T4AsciiLoader.h"

@implementation T4AsciiLoader

-init
{
  if( (self = [super init]) )
  {
    [self setTransposesMatrix: YES];
    [self setHasHeader: NO];
    [self setMaxNumberOfColumns: -1];
  }

  return self;
}

-(T4Matrix*)loadMatrixFromFile: (T4File*)aFile
{
  T4Matrix *matrix;
  real *data;
  int numRows, numColumns;

  if(hasHeader || (!autodetectsSize) )
  {
    if(![aFile readStringWithFormat: @"%d" into: &numRows])
      T4Error(@"AsciiLoader: file corrupted");

    if(![aFile readStringWithFormat: @"%d" into: &numColumns])
      T4Error(@"AsciiLoader: file corrupted");
  }
  else
  {
    BOOL finishedReading = NO;
    numRows = 0;
    numColumns = -1;
    
    while(![aFile isEndOfFile])
    {
      NSString *string = [aFile stringToEndOfLine];
      if(string)
      {
        NSScanner *scanner = [NSScanner scannerWithString: string];
        int numberElements = 0;
        real dummy;

        while([scanner scanReal: &dummy])
          numberElements++;

        T4Message(@"[%d] %s", numberElements, [string cString]);
      }
      else
        T4Message(@"string is null");
    }
    exit(0);
  }

  if(transposesMatrix)
  {
    int z = numRows;
    numRows = numColumns;
    numColumns = z;
  }

  T4Message(@"AsciiLoader: %d rows and %d columns detected", numRows, numColumns);

  matrix = [[T4Matrix alloc] initWithNumberOfRows: numRows numberOfColumns: numColumns];
  [allocator keepObject: matrix];
  
  data = [matrix firstColumn];
  if(transposesMatrix)
  {
    int i;

    for(i = 0; i < numRows*numColumns; i++)
    {
#ifdef USE_DOUBLE
      if(![aFile readStringWithFormat: @"%lg" into: &data[i]])
        T4Error(@"AsciiLoader: file corrupted");
#else
      if(![aFile readStringWithFormat: @"%g" into: &data[i]])
        T4Error(@"AsciiLoader: file corrupted");
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
        if(![aFile readStringWithFormat: @"%lg" into: &data[c*stride+r]])
          T4Error(@"AsciiLoader: file corrupted");
#else
        if(![aFile readStringWithFormat: @"%g" into: &data[c*stride+r]])
          T4Error(@"AsciiLoader: file corrupted");
#endif
      }
    }
  }

  return matrix;
}

-(void)setTransposesMatrix: (BOOL)aFlag
{
  transposesMatrix = aFlag;
}

-(void)setHasHeader: (BOOL)aFlag
{
  hasHeader = aFlag;
}

-(void)setMaxNumberOfColumns: (int)aMaxNumber
{
  maxNumColumns = aMaxNumber;
}


@end
