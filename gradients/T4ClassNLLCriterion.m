#import "T4ClassNLLCriterion.h"

@implementation T4ClassNLLCriterion

-initWithClassFormat: (T4ClassFormat*)aClassFormat
{
  if( (self = [super initWithNumberOfInputs: [aClassFormat numberOfClasses]]) )
  {
    classFormat = aClassFormat;
  }

  return self;
}

-(real)forwardExampleAtIndex: (int)anIndex inputs: (T4Matrix*)anInputMatrix
{
  T4Matrix *targets = [[dataset objectAtIndex: anIndex] objectAtIndex: 1];
  int numColumns = [anInputMatrix numberOfColumns];
  int c;

  output = 0;
  for(c = 0; c < numColumns; c++)
  {
    int theClass = [classFormat classFromRealData: [targets columnAtIndex: c]];
    output -= [anInputMatrix columnAtIndex: c][theClass];
  }
  
  return output;
}

-(T4Matrix*)backwardExampleAtIndex: (int)anIndex inputs: (T4Matrix*)anInputMatrix
{  
  T4Matrix *targets = [[dataset objectAtIndex: anIndex] objectAtIndex: 1];
  int numColumns = [anInputMatrix numberOfColumns];
  int c;

  [gradInputs resizeWithNumberOfColumns: numColumns];
  [gradInputs zero];

  for(c = 0; c < numColumns; c++)
  {
    int theClass = [classFormat classFromRealData: [targets columnAtIndex: c]];
    [gradInputs columnAtIndex: c][theClass] = -1;
  }

  return gradInputs;
}

@end
