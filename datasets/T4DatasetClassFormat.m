#import "T4DatasetClassFormat.h"

@implementation T4DatasetClassFormat

+(int)numberOfClassesInDataset: (NSArray*)aDataset
{
  int numClasses = -1;
  int numExamples = [aDataset count];
  int i;
  
  for(i = 0; i < numExamples; i++)
  {
    int theClass = (int)[[[aDataset objectAtIndex: i] objectAtIndex: 1] firstValue];
    if(theClass < 0)
      T4Error(@"DatasetClassFormat: negative class detected");
    
    if(theClass > numClasses)
      numClasses = theClass;
  }
  numClasses++;

  if(numClasses == 0)
    T4Error(@"DatasetClassFormat: no class found");

  return numClasses;
}

-initWithClassTable: (T4Matrix*)aClassTable
{
  if( (self = [super initWithNumberOfClasses: [aClassTable numberOfColumns]
                     encodingSize: [aClassTable numberOfRows]]) )
  {
    T4Message(@"DatasetClassFormat: %d classes detected [%d originally]", [aClassTable numberOfColumns], [aClassTable numberOfRows]);
    [classLabels copyMatrix: aClassTable];
    directEncoding = NO;
  }

  return self;
}

-initWithDataset: (NSArray*)aDataset classAgainstOthers: (int)aClassIndex
{
  int numClasses = [T4DatasetClassFormat numberOfClassesInDataset: aDataset];
  T4Matrix *classTable = [[T4Matrix alloc] initWithNumberOfRows: numClasses numberOfColumns: 2];
  real *classTableFirstColumn = [classTable columnAtIndex: 0];
  real *classTableSecondColumn = [classTable columnAtIndex: 1];
  int i;

  for(i = 0; i < numClasses; i++)
  {
    if(i == aClassIndex)
    {
      classTableFirstColumn[i] = 0;
      classTableSecondColumn[i] = 1;
    }
    else
    {
      classTableFirstColumn[i] = 1;
      classTableSecondColumn[i] = 0;
    }
  }

  self = [self initWithClassTable: classTable];

  [classTable release];

  T4Message(@"DatasetClassFormat: considering class %d against the others", aClassIndex);

  return self;
}

-initWithNumberOfClasses: (int)aNumClasses
{
  if( (self = [super initWithNumberOfClasses: aNumClasses encodingSize: aNumClasses]) )
  {
    int i;

    [classLabels zero];

    for(i = 0; i < aNumClasses; i++)
      [classLabels columnAtIndex: i][i] = 1;

    directEncoding = YES;

    T4Message(@"DatasetClassFormat: %d classes detected", aNumClasses);
  }

  return self;
}

-initWithDataset: (NSArray*)aDataset
{  
  return [self initWithNumberOfClasses: [T4DatasetClassFormat numberOfClassesInDataset: aDataset]];
}

-(int)classFromRealArray: (real*)aVector
{
  if(directEncoding)
    return (int)aVector[0];
  else
  {
    int index = (int)aVector[0];
    int numClasses = [classLabels numberOfColumns];
    int stride = [classLabels stride];
    real *data = [classLabels firstColumn];
    int i;
    
    for(i = 0; i < numClasses; i++)
    {
      if(data[i*stride+index] > 0)
        return i;
    }
  }

  return -1;
}

/////////////

-(int)encodingSize
{
  if(!directEncoding)
    T4Error(@"DatasetClassFormat: cannot provide the encoding size");

  return 1;
}

-(real*)encodingForClass: (int)aClass
{
  if(!directEncoding)
    T4Error(@"DatasetClassFormat: cannot provide the encoding for a class");

  return [classLabels columnAtIndex: aClass];
}

@end
