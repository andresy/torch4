#import "T4GlobalStandardNormalizer.h"

@implementation T4GlobalStandardNormalizer

-initWithMean: (real)aMean standardDeviation: (real)aStandardDeviation
{
  if( (self = [super init]) )
  {
    mean = aMean;
    standardDeviation = aStandardDeviation;
  }

  return self;
}

-initWithDataset: (NSArray*)aDataset columnIndex: (int)anIndex
{  
  int numRows;
  int numExamples;
  int numTotal;
  real aMean;
  real aStandardDeviation;
  int r, c, e;

  numExamples = [aDataset count];
  numRows = [[[aDataset objectAtIndex: 0] objectAtIndex: anIndex] numberOfRows];

  aMean = 0;
  aStandardDeviation = 0;
  numTotal = 0;

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
        aMean += z;
        aStandardDeviation += z*z;        
      }
    }

    numTotal += numRows*numColumns;
  }

  aMean /= (real)numTotal;
  aStandardDeviation /= (real)numTotal;
  aStandardDeviation -= aMean*aMean;
  aStandardDeviation = sqrt(aStandardDeviation);

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
  int r, c;

  for(c = 0; c < numColumns; c++)
  {
    real *matrixColumn = [aMatrix columnAtIndex: c];
    for(r = 0; r < numRows; r++)
    {
      if(standardDeviation > 0)
        matrixColumn[r] = (matrixColumn[r] - mean) / standardDeviation;
      else
        matrixColumn[r] -= mean;
    }
  }
  return self;
}

-(real)mean
{
  return mean;
}

-(real)standardDeviation
{
  return standardDeviation;
}

-initWithCoder: (NSCoder*)aCoder
{
  self = [super initWithCoder: aCoder];
  [aCoder decodeValueOfObjCType: @encode(real) at: &mean];
  [aCoder decodeValueOfObjCType: @encode(real) at: &standardDeviation];
  return self;
}

-(void)encodeWithCoder: (NSCoder*)aCoder
{
  [super encodeWithCoder: aCoder];
  [aCoder encodeValueOfObjCType: @encode(real) at: &mean];
  [aCoder encodeValueOfObjCType: @encode(real) at: &standardDeviation];
}

@end
