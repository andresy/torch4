#import "T4ClassMSECriterion.h"

@implementation T4ClassMSECriterion

-initWithClassFormat: (T4ClassFormat*)aClassFormat
{
  if( (self = [super initWithNumberOfInputs: [aClassFormat encodingSize]]) )
  {
    classFormat = aClassFormat;
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
    real *targetColumn = [classFormat encodingForClass: (int)[targets firstValue]];
    real *inputColumn = [someInputs columnAtIndex: c];

    for(r = 0; r < numInputs; r++)
    {
      real z = targetColumn[r] - inputColumn[r];
//      T4Message(@"target = %g, input = %g", targetColumn[r], inputColumn[r]);
      output += z*z;
    }
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
  real norm = 2.;
  int c, r;

  [gradInputs resizeWithNumberOfColumns: numColumns];
  
  if(averageWithNumberOfRows)
    norm /= (real)numInputs;

  if(averageWithNumberOfColumns)
    norm /= (real)numColumns;

  for(c = 0; c < numColumns; c++)
  {
    real *targetColumn = [classFormat encodingForClass: (int)[targets firstValue]];
    real *inputColumn = [someInputs columnAtIndex: c];
    real *gradInputColumn = [gradInputs columnAtIndex: c];

    for(r = 0; r < numInputs; r++)
      gradInputColumn[r] = norm * (inputColumn[r] - targetColumn[r]);
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

@end
