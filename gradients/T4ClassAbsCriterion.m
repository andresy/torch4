#import "T4ClassAbsCriterion.h"

@implementation T4ClassAbsCriterion

-initWithDatasetClassFormat: (T4ClassFormat*)aClassFormat inputClassFormat: (T4ClassFormat*)anotherClassFormat
{
  if( (self = [super initWithNumberOfInputs: [anotherClassFormat encodingSize]]) )
  {
    datasetClassFormat = [aClassFormat retainAndKeepWithAllocator: allocator];
    inputClassFormat = [anotherClassFormat retainAndKeepWithAllocator: allocator];
    [self setAveragesWithNumberOfRows: YES];
    [self setAveragesWithNumberOfColumns: YES];
  }

  return self;
}

-(real)forwardExampleAtIndex: (int)anIndex inputs: (T4Matrix*)someInputs
{
  T4Matrix *targets = [[dataset objectAtIndex: anIndex] objectAtIndex: 1];
  int numColumns = [someInputs numberOfColumns];
  int c, r;

  output = 0;
  for(c = 0; c < numColumns; c++)
  {
    real *targetColumn = [inputClassFormat encodingForClass: [datasetClassFormat classFromRealArray: [targets columnAtIndex: c]]];
    real *inputColumn = [someInputs columnAtIndex: c];

    for(r = 0; r < numInputs; r++)
      output += fabs(targetColumn[r] - inputColumn[r]);
  }
  
  if(averageWithNumberOfRows)
    output /= (real)numInputs;

  if(averageWithNumberOfColumns)
    output /= (real)numColumns;
  
  return output;
}

-(T4Matrix*)backwardExampleAtIndex: (int)anIndex inputs: (T4Matrix*)someInputs
{  
  T4Matrix *targets = [[dataset objectAtIndex: anIndex] objectAtIndex: 1];
  int numColumns = [someInputs numberOfColumns];
  real norm = 1.;
  int c, r;

  [gradInputs resizeWithNumberOfColumns: numColumns];
  
  if(averageWithNumberOfRows)
    norm /= (real)numInputs;

  if(averageWithNumberOfColumns)
    norm /= (real)numColumns;

  for(c = 0; c < numColumns; c++)
  {
    real *targetColumn = [inputClassFormat encodingForClass: [datasetClassFormat classFromRealArray: [targets firstColumn]]];
    real *inputColumn = [someInputs columnAtIndex: c];
    real *gradInputColumn = [gradInputs columnAtIndex: c];

    for(r = 0; r < numInputs; r++)
    {
      real z = targetColumn[r] - inputColumn[r];
      if(z > 0)
        gradInputColumn[r] = -norm;
      else
        gradInputColumn[r] =  norm;
    }
  } 

  return gradInputs;
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

-initWithCoder: (NSCoder*)aCoder
{
  self = [super initWithCoder: aCoder];

  datasetClassFormat = [[aCoder decodeObject] retainAndKeepWithAllocator: allocator];
  inputClassFormat = [[aCoder decodeObject] retainAndKeepWithAllocator: allocator];
  [aCoder decodeValueOfObjCType: @encode(BOOL) at: &averageWithNumberOfRows];  
  [aCoder decodeValueOfObjCType: @encode(BOOL) at: &averageWithNumberOfColumns];

  return self;
}

-(void)encodeWithCoder: (NSCoder*)aCoder
{
  [super encodeWithCoder: aCoder];

  [aCoder encodeObject: datasetClassFormat];
  [aCoder encodeObject: inputClassFormat];
  [aCoder encodeValueOfObjCType: @encode(BOOL) at: &averageWithNumberOfRows];  
  [aCoder encodeValueOfObjCType: @encode(BOOL) at: &averageWithNumberOfColumns];
}

@end
