#import "T4ClassNLLCriterion.h"

@implementation T4ClassNLLCriterion

-initWithDatasetClassFormat: (T4ClassFormat*)aClassFormat
{
  if( (self = [super initWithNumberOfInputs: [aClassFormat numberOfClasses]]) )
  {
    classFormat = [aClassFormat retainAndKeepWithAllocator: allocator];
  }

  return self;
}

-(real)forwardExampleAtIndex: (int)anIndex inputs: (T4Matrix*)someInputs
{
  T4Matrix *targets = [[dataset objectAtIndex: anIndex] objectAtIndex: 1];
  int numColumns = [someInputs numberOfColumns];
  int c;

  output = 0;
  for(c = 0; c < numColumns; c++)
  {
    int theClass = [classFormat classFromRealArray: [targets firstColumn]];
    output -= [someInputs columnAtIndex: c][theClass];
  }
  
  return output;
}

-(T4Matrix*)backwardExampleAtIndex: (int)anIndex inputs: (T4Matrix*)someInputs
{  
  T4Matrix *targets = [[dataset objectAtIndex: anIndex] objectAtIndex: 1];
  int numColumns = [someInputs numberOfColumns];
  int c;

  [gradInputs resizeWithNumberOfColumns: numColumns];
  [gradInputs zero];

  for(c = 0; c < numColumns; c++)
  {
    int theClass = [classFormat classFromRealArray: [targets firstColumn]];
    [gradInputs columnAtIndex: c][theClass] = -1;
  }

  return gradInputs;
}

-initWithCoder: (NSCoder*)aCoder
{
  self = [super initWithCoder: aCoder];
  classFormat = [[aCoder decodeObject] retainAndKeepWithAllocator: allocator];
  return self;
}

-(void)encodeWithCoder: (NSCoder*)aCoder
{
  [super encodeWithCoder: aCoder];
  [aCoder encodeObject: classFormat];
}

@end
