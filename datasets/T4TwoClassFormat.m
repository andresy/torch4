#import "T4TwoClassFormat.h"

@implementation T4TwoClassFormat

-initWithLabel: (real)aLabel1 label: (real)aLabel2
{
  if( (self = [super initWithNumberOfClasses: 2 encodingSize: 1]) )
  {
    classLabelArray = [classLabels firstColumn];
    classLabelArray[0] = aLabel1;
    classLabelArray[1] = aLabel2;
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
