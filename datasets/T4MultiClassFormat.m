#import "T4MultiClassFormat.h"

@implementation T4MultiClassFormat

-initWithNumberOfClasses: (int)aNumClasses labels: (real*)someLabels
{
  if( (self = [super initWithNumberOfClasses: aNumClasses encodingSize: 1]) )
  {
    int i;

    classLabelArray = [classLabels firstColumn];

    for(i = 0; i < aNumClasses; i++)
      classLabelArray[i] = someLabels[i];
  }

  return self;
}

-(int)classFromRealArray: (real*)aVector
{
  int numClasses = [classLabels numberOfColumns];
  real value = aVector[0];
  real dist = T4Inf;
  int index = -1;
  int i;

  for(i = 0; i < numClasses; i++)
  {
    real z = fabs(value - classLabelArray[i]);
    if(z < dist)
    {
      index = i;
      dist = z;
    }
  }
  
  return(index);
}

-initWithCoder: (NSCoder*)aCoder
{
  self = [super initWithCoder: aCoder];
  classLabelArray = [classLabels firstColumn];
  return self;
}

@end
