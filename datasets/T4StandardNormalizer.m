#import "T4StandardNormalizer.h"

@implementation T4StandardNormalizer

-initWithMean: (T4Matrix*)aMean standardDeviation: (T4Matrix*)aStandardDeviation
{
  if( (self = [super init]) )
  {
    if([aMean numberOfRows] != [aStandardDeviation numberOfRows])
      T4Error(@"StandardNormalizer: mean and standard deviation matrices do not match!!!");

    mean = [aMean retainAndKeepWithAllocator: allocator];
    standardDeviation = [aStandardDeviation retainAndKeepWithAllocator: allocator];
  }

  return self;
}

-initWithDataset: (NSArray*)aDataset columnIndex: (int)anIndex
{  
  int numRows;
  int numExamples;
  int totalNumColumns;
  T4Matrix *aMean;
  T4Matrix *aStandardDeviation;
  real *meanColumn;
  real *standardDeviationColumn;
  int r, c, e;

  numExamples = [aDataset count];
  numRows = [[[aDataset objectAtIndex: 0] objectAtIndex: anIndex] numberOfRows];
  aMean = [[[T4Matrix alloc] initWithNumberOfRows: numRows] keepWithAllocator: allocator];
  aStandardDeviation = [[[T4Matrix alloc] initWithNumberOfRows: numRows] keepWithAllocator: allocator];
  meanColumn = [aMean firstColumn];
  standardDeviationColumn = [aStandardDeviation firstColumn];
  [aMean zero];
  [aStandardDeviation zero];
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

  return [self initWithMean: aMean standardDeviation: aStandardDeviation];
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
  real *meanColumn = [mean firstColumn];
  real *standardDeviationColumn = [standardDeviation firstColumn];
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

-(T4Matrix*)mean
{
  return mean;
}

-(T4Matrix*)standardDeviation
{
  return standardDeviation;
}

-initWithCoder: (NSCoder*)aCoder
{
  self = [super initWithCoder: aCoder];
  mean = [[aCoder decodeObject] retainAndKeepWithAllocator: allocator];
  standardDeviation = [[aCoder decodeObject] retainAndKeepWithAllocator: allocator];
  return self;
}

-(void)encodeWithCoder: (NSCoder*)aCoder
{
  [super encodeWithCoder: aCoder];
  [aCoder encodeObject: mean];
  [aCoder encodeObject: standardDeviation];
}

@end
