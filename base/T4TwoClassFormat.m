#import "T4TwoClassFormat.h"

@implementation T4TwoClassFormat

-initWithDataset: (NSArray*)aDataset
{
  if( (self = [self initWithLabel: 0 andLabel: 0]) )
  {
    int numClassSet = 0;
    int numExamples = [aDataset count];
    int i, j;

    for(i = 0; i < numExamples; i++)
    {
      real *targets = [[[aDataset objectAtIndex: i] objectAtIndex: 1] realData];
    
      BOOL classExists = NO;
      for(j = 0; j < numClassSet; j++)
      {
        if(targets[0] == classLabelArray[j])
          classExists = YES;
      }
      
      if(!classExists)
      {
        if(numClassSet == 2)
          T4Error(@"TwoClassFormat: you have more than two classes");
        
        classLabelArray[numClassSet++] = targets[0];
      }
    }
    
    switch(numClassSet)
    {
      case 0:
        T4Warning(@"TwoClassFormat: you have no examples");
        break;
      case 1:
        T4Warning(@"TwoClassFormat: you have only one class [%g]", classLabelArray[0]);
        classLabelArray[1] = classLabelArray[0];
        break;
      case 2:
        if(classLabelArray[0] > classLabelArray[1])
        {
          real z = classLabelArray[1];
          classLabelArray[1] = classLabelArray[0];
          classLabelArray[0] = z;
        }
        T4Message(@"TwoClassFormat: two classes detected [%g and %g]", classLabelArray[0], classLabelArray[1]);
        break;
    }
  }
  
  return self;
}

-initWithLabel: (real)aLabel1 andLabel: (real)aLabel2
{
  if( (self = [super initWithNumberOfClasses: 2 encodingSize: 1]) )
  {
    classLabelArray = [classLabels realData];
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
