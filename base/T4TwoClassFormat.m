#import "T4ClassFormat.h"

@implementation T4ClassFormat

-initWithDataset: (NSArray)aDataset
{
  
}

-initWithClassLabel: (real)aLabel1 andClassLabel: (real)aLabel2
{
  if( (self = [super initWithNumberOfClasses: 2 encodingSize: 1]) )
  {
    [classLabels columnAtIndex: 0][0] = aLabel1;
    [classLabels columnAtIndex: 1][0] = aLabel2;
  }

  return self;
}

-(void)transformRealData: (real*)aVector toOneHotData: (real*)aOneHotVector
{
  int maxClass = (tabclasses[1]>tabclasses[0]);
  int minClass = (tabclasses[0]>tabclasses[1]);
  one_hot_outputs[0] = fabs(outputs[0] - tabclasses[maxclass]);
  one_hot_outputs[1] = fabs(outputs[0] - tabclasses[minclass]);

}

-(void)transformOneHotData: (real*)aOneHotVector toRealData: (real*)aVector
{
  outputs[0] = one_hot_outputs[0] - one_hot_outputs[1];
  if([classLabels columnAtIndex: 0][1] > [classLabels columnAtIndex: 0][0]) 
    outputs[0] = one_hot_outputs[1] - one_hot_outputs[0];
  else
    outputs[0] = one_hot_outputs[0] - one_hot_outputs[1];

  
}

-(int)classFromRealData: (real*)aVector
{
  real value = aVector[0];
  
  return(fabs(value - [classLabels columnAtIndex: 0][0])
         > fabs(value - [classLabels columnAtIndex: 1][0]) ? 1 : 0);
}

@end
