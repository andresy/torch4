#import "T4OneHotClassFormat.h"

@implementation T4OneHotClassFormat

-initWithDataset: (NSArray*)aDataset
{
  int numClasses = -1;
  int numExamples = [aDataset count];
  int i;
  
  for(i = 0; i < numExamples; i++)
  {
    int numTargets = [[[aDataset objectAtIndex: i] objectAtIndex: 1] numberOfRows];
    
    if(numClasses < 0)
      numClasses = numTargets;
    else
    {
      if(numTargets != numClasses)
        T4Error(@"OneHotClassFormat: targets in the dataset have different sizes");
    }
    
    if(numClasses == 0)
      T4Error(@"OneHotClassFormat: no targets available!!!");
  }

  if(numClasses < 0)
  {
    T4Warning(@"OneHotClassFormat: no examples available!!!");
    numClasses = 0;
  }

  return [self initWithNumberOfClasses: numClasses];
}

-initWithNumberOfClasses: (int)aNumClasses
{
  if( (self = [super initWithNumberOfClasses: aNumClasses encodingSize: aNumClasses]) )
  {
    int i;

    [classLabels zero];
    for(i = 0; i < aNumClasses; i++)
      [classLabels columnAtIndex: i][i] = 1;

    T4Message(@"OneHotClassFormat: %d classes detected", aNumClasses);
  }

  return self;
}

-(int)classFromRealData: (real*)aVector
{
  real z = aVector[0];
  int index = 0;
  int numClasses = [self numberOfClasses];
  int i;
  
  for(i = 1; i < numClasses; i++)
  {
    if(aVector[i] > z)
    {
      index = i;
      z  = aVector[i];
    }
  }
  return(index);
}

@end
