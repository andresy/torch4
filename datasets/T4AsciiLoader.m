#import "T4AsciiLoader.h"

NSString *T4AsciiLoaderNextLineAndGetNumberOfElements(T4File *aFile, int *aNumElements)
{
  NSString *string;
  NSScanner *scanner;
  int numElements = 0;
  real dummy;

  while(numElements == 0)
  {
    string = [aFile stringToEndOfLine];

    if(!string)
      break;

    scanner = [NSScanner scannerWithString: string];
    numElements = 0;
    
    while([scanner scanReal: &dummy])
      numElements++;
  }

  *aNumElements = numElements;

  return string;
}

@implementation T4AsciiLoader

-init
{
  if( (self = [super init]) )
  {
    [self setTransposesMatrix: YES];
    [self setAutodetectsSize: YES];
    [self setMaxNumberOfColumns: -1];
  }

  return self;
}

-(T4Matrix*)loadMatrixFromFile: (T4File*)aFile
{
  T4Matrix *matrix;
  real *data;
  int numRows, numColumns;

  if(autodetectsSize)
  {
    numRows = 0;
    numColumns = 0;
    int numElements;
    NSString *currentLine;
    BOOL hasHeader = NO;
    int fakeNumRows = 0;
    int fakeNumColumns = 0;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    while( (currentLine = T4AsciiLoaderNextLineAndGetNumberOfElements(aFile, &numElements)) )
    {
      if(numRows == 0)
      {
        numColumns = numElements;
        if(numColumns == 2)
        {
          NSScanner *scanner = [NSScanner scannerWithString: currentLine];
          [scanner scanInt: &fakeNumRows];
          [scanner scanInt: &fakeNumColumns];
        }
      }

      if(numRows == 1)
      {
        if(numColumns != numElements)
        {
          if(numColumns == 2)
          {
            hasHeader = YES;
            break;
          }
          else
            T4Error(@"AsciiLoader: file has not a valid format at line %d", numRows+1);
        }
        else
        {
          if(numColumns == 2)
          {
            if( (fakeNumRows > 0) && (fakeNumColumns == 2) )
              T4Error(@"AsciiLoader: cannot be sure that you have a header [exceptional case, sorry]");
          }
        }
      }

      if(numRows > 1)
      {
        if(numColumns != numElements)
          T4Error(@"AsciiLoader: file has not a valid format at line %d", numRows+1);
      }

      numRows++;
    }

    [pool release];

    if(hasHeader)
    {
      T4Message(@"AsciiLoader: header found");

      [aFile seekToBeginningOfFile];

      if(![aFile readStringWithFormat: @"%d" into: &numRows])
        T4Error(@"AsciiLoader: file corrupted around header");
      
      if(![aFile readStringWithFormat: @"%d" into: &numColumns])
        T4Error(@"AsciiLoader: file corrupted around header");
    }
    else
    {
      [aFile seekToBeginningOfFile];
    }
  }
  else
  {
    if(![aFile readStringWithFormat: @"%d" into: &numRows])
      T4Error(@"AsciiLoader: file header corrupted");

    if(![aFile readStringWithFormat: @"%d" into: &numColumns])
      T4Error(@"AsciiLoader: file header corrupted");
  }

  if(transposesMatrix)
  {
    int z = numRows;
    numRows = numColumns;
    numColumns = z;
  }

  if( (numRows == 0) || (numColumns == 0) )
    T4Error(@"AsciiLoader: header seems corrupted");

  T4Message(@"AsciiLoader: %d rows and %d columns detected", numRows, numColumns);

  if( (maxNumColumns > 0) && (maxNumColumns < numColumns) )
  {
    numColumns = maxNumColumns;
    T4Warning(@"AsciiLoader: loading only %d columns", numColumns);
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
      if(![aFile readStringWithFormat: @"%lg" into: &data[i]])
        T4Error(@"AsciiLoader: file corrupted around line %d", i/numRows);
#else
      if(![aFile readStringWithFormat: @"%g" into: &data[i]])
        T4Error(@"AsciiLoader: file corrupted around line %d", i/numRows);
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
          T4Error(@"AsciiLoader: file corrupted around line %d", numRows+1);
#else
        if(![aFile readStringWithFormat: @"%g" into: &data[c*stride+r]])
          T4Error(@"AsciiLoader: file corrupted around line %d", numRows+1);
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

-(void)setAutodetectsSize: (BOOL)aFlag
{
  autodetectsSize = aFlag;
}

-(void)setMaxNumberOfColumns: (int)aMaxNumber
{
  maxNumColumns = aMaxNumber;
}

@end
