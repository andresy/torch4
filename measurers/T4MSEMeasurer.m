#import "T4MSEMeasurer.h"

@implementation T4MSEMeasurer

-initWithInputs: (T4Matrix*)someInputs dataset: (NSArray*)aDataset file: (T4File*)aFile
{
  if( (self = [super initWithDataset: aDataset file: aFile]) )
  {
    inputs = someInputs;

    [self setAveragesWithNumberOfExamples: YES];
    [self setAveragesWithNumberOfRows: YES];
    [self setAveragesWithNumberOfColumns: YES];    
    [self reset];

    [allocator retainAndKeepObject: inputs];
  }

  return self;
}

-measureExampleAtIndex: (int)anIndex
{
  T4Matrix *targets = [[dataset objectAtIndex: anIndex] objectAtIndex: 1];
  int numColumns = [inputs numberOfColumns];
  int numRows = [inputs numberOfRows];
  int c, r;
  real currentError;
  
  currentError = 0;
  for(c = 0; c < numColumns; c++)
  {
    real *targetColumn = [targets columnAtIndex: c];
    real *inputColumn = [inputs columnAtIndex: c];

    for(r = 0; r < numRows; r++)
    {
      real z = targetColumn[r] - inputColumn[r];
      currentError += z*z;
    }
  }
  
  if(averageWithNumberOfRows)
    currentError /= (real)numRows;

  if(averageWithNumberOfColumns)
    currentError /= (real)numColumns;
  
  internalError += currentError;

  return self;
}

-measureAtIteration: (int)anIteration
{
  if(averageWithNumberOfExamples)
    internalError /= (real)[dataset count];
  
  [file writeStringWithFormat: @"%g\n", internalError];
  [file synchronizeFile];

  [self reset];
  
  return self;
}

-reset
{
  internalError = 0;
  return self;
}

-setAveragesWithNumberOfExamples: (BOOL)aFlag
{
  averageWithNumberOfExamples = aFlag;
  return self;
}

-setAveragesWithNumberOfRows: (BOOL)aFlag
{
  averageWithNumberOfRows = aFlag;
  return self;
}

-setAveragesWithNumberOfColumns: (BOOL)aFlag
{
  averageWithNumberOfColumns = aFlag;
  return self;
}

@end
