#import "T4StandardNormalizer.h"

@implementation T4StandardNormalizer

-initWithMeans: (T4Matrix*)someMeans standardDeviations: (T4Matrix*)someStandardDeviations
{
  if( (self = [super init]) )
  {
    if([someMeans numberOfRows] != [someStandardDeviations numberOfRows])
      T4Error(@"StandardNormalizer: mean and standard deviation matrices do not match!!!");

    means = [someMeans retainAndKeepWithAllocator: allocator];
    standardDeviations = [someStandardDeviations retainAndKeepWithAllocator: allocator];
  }

  return self;
}

-initWithDataset: (NSArray*)aDataset columnIndex: (int)anIndex
{  
  int numRows;
  int numExamples;
  int totalNumColumns;
  T4Matrix *someMeans;
  T4Matrix *someStandardDeviations;
  real *meanColumn;
  real *standardDeviationColumn;
  int r, c, e;

  numExamples = [aDataset count];
  numRows = [[[aDataset objectAtIndex: 0] objectAtIndex: anIndex] numberOfRows];
  someMeans = [[[T4Matrix alloc] initWithNumberOfRows: numRows] keepWithAllocator: allocator];
  someStandardDeviations = [[[T4Matrix alloc] initWithNumberOfRows: numRows] keepWithAllocator: allocator];
  meanColumn = [someMeans firstColumn];
  standardDeviationColumn = [someStandardDeviations firstColumn];
  [someMeans zero];
  [someStandardDeviations zero];
  totalNumColumns = 0;

  for(e = 0; e < numExamples; e++)
  {
    T4Matrix *matrix = [[aDataset objectAtIndex: e] objectAtIndex: anIndex];
    int numColumns = [matrix numberOfColumns];

    for(c = 0; c < numColumns; c++)
    {
      real *matrixColumn = [matrix columnAtIndex: c];
      for(r = 0; r < numRows; r++)
      {
        real z = matrixColumn[r];
        meanColumn[r] += z;
        standardDeviationColumn[r] += z*z;
      }
    }

    totalNumColumns += numColumns;
  }

  for(r = 0; r < numRows; r++)
  {
    meanColumn[r] /= (real)totalNumColumns;
    standardDeviationColumn[r] /= (real)totalNumColumns;
    standardDeviationColumn[r] -= meanColumn[r]*meanColumn[r];
    standardDeviationColumn[r] = sqrt(standardDeviationColumn[r]);
  }

  return [self initWithMeans: someMeans standardDeviations: someStandardDeviations];
}

-initWithDataset: (NSArray*)aDataset
{
  return [self initWithDataset: aDataset columnIndex: 0];
}

-normalizeDataset: (NSArray*)aDataset columnIndex: (int)anIndex
{
  int numExamples = [aDataset count];
  int e;

  for(e = 0; e < numExamples; e++)
  {
    T4Matrix *matrix = [[aDataset objectAtIndex: e] objectAtIndex: anIndex];
    [self normalizeMatrix: matrix];
  }
  return self;
}

-normalizeDataset: (NSArray*)aDataset
{
  return [self normalizeDataset: aDataset columnIndex: 0];
}

-normalizeMatrix: (T4Matrix*)aMatrix
{
  int numColumns = [aMatrix numberOfColumns];
  int numRows = [aMatrix numberOfRows];
  real *meanColumn = [means firstColumn];
  real *standardDeviationColumn = [standardDeviations firstColumn];
  int r, c;

  for(c = 0; c < numColumns; c++)
  {
    real *matrixColumn = [aMatrix columnAtIndex: c];
    for(r = 0; r < numRows; r++)
    {
      if(standardDeviationColumn[r] > 0)
        matrixColumn[r] = (matrixColumn[r] - meanColumn[r]) / standardDeviationColumn[r];
      else
        matrixColumn[r] -= meanColumn[r];
    }
  }
  return self;
}

-(T4Matrix*)means
{
  return means;
}

-(T4Matrix*)standardDeviations
{
  return standardDeviations;
}

-initWithCoder: (NSCoder*)aCoder
{
  self = [super initWithCoder: aCoder];
  means = [[aCoder decodeObject] retainAndKeepWithAllocator: allocator];
  standardDeviations = [[aCoder decodeObject] retainAndKeepWithAllocator: allocator];
  return self;
}

-(void)encodeWithCoder: (NSCoder*)aCoder
{
  [super encodeWithCoder: aCoder];
  [aCoder encodeObject: means];
  [aCoder encodeObject: standardDeviations];
}

@end
