#import "T4AsciiSaver.h"

@implementation T4AsciiSaver

-init
{
  if( (self = [super init]) )
  {
    [self setTransposesMatrix: YES];
    [self setWritesHeader: NO];
  }

  return self;
}

-saveMatrix: (T4Matrix*)aMatrix intoFile: (T4File*)aFile
{
  int numRows = [aMatrix numberOfRows];
  int numColumns = [aMatrix numberOfColumns];
  int r, c;

  if(writesHeader)
  {
    if(transposesMatrix)
      [aFile writeStringWithFormat: @"%d %d\n", numColumns, numRows];
    else
      [aFile writeStringWithFormat: @"%d %d\n", numRows, numColumns];
  }

  real *data = [aMatrix firstColumn];
  int stride = [aMatrix stride];
  if(transposesMatrix)
  {
    for(c = 0; c < numColumns; c++)
    {
      for(r = 0; r < numRows-1; r++)
      {
#ifdef USE_DOUBLE
        [aFile writeStringWithFormat: @"%lg ", data[c*stride+r]];
#else
        [aFile writeStringWithFormat: @"%g ", data[c*stride+r]];
#endif
      }
#ifdef USE_DOUBLE
      [aFile writeStringWithFormat: @"%lg\n", data[c*stride+numRows-1]];
#else
      [aFile writeStringWithFormat: @"%g\n", data[c*stride+numRows-1]];
#endif
    }
  }
  else
  {
    for(r = 0; r < numRows; r++)
    {
      for(c = 0; c < numColumns-1; c++)
      {
#ifdef USE_DOUBLE
        [aFile writeStringWithFormat: @"%lg ", data[c*stride+r]];
#else
        [aFile writeStringWithFormat: @"%g ", data[c*stride+r]];
#endif
      }
#ifdef USE_DOUBLE
        [aFile writeStringWithFormat: @"%lg\n", data[(numColumns-1)*stride+r]];
#else
        [aFile writeStringWithFormat: @"%g\n", data[(numColumns-1)*stride+r]];
#endif
    }
  }

  return self;
}

-setTransposesMatrix: (BOOL)aFlag
{
  transposesMatrix = aFlag;
  return self;
}

-setWritesHeader: (BOOL)aFlag
{
  writesHeader = aFlag;
  return self;
}

@end
