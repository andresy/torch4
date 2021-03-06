#import "T4ClassAbsMeasurer.h"

@implementation T4ClassAbsMeasurer

-initWithInputs: (T4Matrix*)someInputs classFormat: (T4ClassFormat*)aClassFormat dataset: (NSArray*)aDataset classFormat: (T4ClassFormat*)anotherClassFormat file: (T4File*)aFile
{
  if( (self = [super initWithDataset: aDataset file: aFile]) )
  {
    inputs = someInputs;
    inputClassFormat = aClassFormat;

    if([inputs numberOfRows] != [inputClassFormat encodingSize])
      T4Error(@"ClassMeasurer: input size [%d] is not equal to class format encoding size [%d]", [inputs numberOfRows], [inputClassFormat encodingSize]);

    datasetClassFormat = anotherClassFormat;

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
    real *targetColumn = [inputClassFormat encodingForClass: [datasetClassFormat classFromRealArray: [targets columnAtIndex: c]]];
    real *inputColumn = [inputs columnAtIndex: c];

    for(r = 0; r < numRows; r++)
      currentError += fabs(targetColumn[r] - inputColumn[r]);
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
