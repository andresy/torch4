#import "T4OneHotClassFormat.h"

@implementation T4OneHotClassFormat

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
