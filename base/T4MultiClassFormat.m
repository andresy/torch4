#import "T4MultiClassFormat.h"

int T4MultiClassSort(const void *a, const void *b)
{
  real *ar = (real *)a;
  real *br = (real *)b;

  if(*ar < *br)
    return -1;
  else
    return  1;
}

@implementation T4MultiClassFormat

-initWithDataset: (NSArray*)aDataset
{
  real *currentClassLabelArray = NULL;
  int numExamples = [aDataset count];
  int numClassSet = 0;
  int i, j;
  
  for(i = 0; i < numExamples; i++)
  {
    real target = [[[aDataset objectAtIndex: i] objectAtIndex: 1] realData][0];
    
    BOOL classExists = NO;
    for(j = 0; j < numClassSet; j++)
    {
      if(target == currentClassLabelArray[j])
        classExists = YES;
    }

    if(!classExists)
    {
      currentClassLabelArray = [allocator reallocRealArray: currentClassLabelArray withCapacity: numClassSet+1];
      currentClassLabelArray[numClassSet++] = target;
    }
  }

  switch(numClassSet)
  {
    case 0:
      T4Warning(@"MultiClassFormat: you have no examples");
      break;
    case 1:
      T4Warning(@"MultiClassFormat: you have only one class [%g]", currentClassLabelArray[0]);
      break;
    default:
      T4Message(@"MultiClassFormat: %d classes detected", numClassSet);
      break;
  }

  if(numClassSet > 0)
    qsort(currentClassLabelArray, numClassSet, sizeof(real), T4MultiClassSort);
  
  return [self initWithNumberOfClasses: numClassSet labels: currentClassLabelArray];
}

-initWithNumberOfClasses: (int)aNumClasses labels: (real*)someLabels
{
  if( (self = [super initWithNumberOfClasses: aNumClasses encodingSize: 1]) )
  {
    int i;

    classLabelArray = [classLabels realData];

    for(i = 0; i < aNumClasses; i++)
      classLabelArray[i] = someLabels[i];
  }

  return self;
}

-(int)classFromRealData: (real*)aVector
{
  real value = aVector[0];
  
  return(fabs(value - classLabelArray[0])
         > fabs(value - classLabelArray[1]) ? 1 : 0);
}

@end
