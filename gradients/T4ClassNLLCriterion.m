#import "T4ClassNLLCriterion.h"

@implementation T4ClassNLLCriterion

-initWithClassFormat: (T4ClassFormat*)aClassFormat
{
  return [self initWithInputClassFormat: aClassFormat datasetClassFormat: aClassFormat];
}

-initWithInputClassFormat: (T4ClassFormat*)aClassFormat datasetClassFormat: (T4ClassFormat*)anotherClassFormat
{
  if( (self = [super initWithNumberOfInputs: [aClassFormat numberOfClasses]]) )
  {
    inputClassFormat = aClassFormat;
    datasetClassFormat = anotherClassFormat;
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
    int theClass = [inputClassFormat classFromRealData: [datasetClassFormat encodingForClass: (int)[targets firstValueAtColumn: c]]];
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
    int theClass = [inputClassFormat classFromRealData: [datasetClassFormat encodingForClass: (int)[targets firstValueAtColumn: c]]];
    [gradInputs columnAtIndex: c][theClass] = -1;
  }

  return gradInputs;
}

@end
