#import "T4ProgressBar.h"

@implementation T4ProgressBar

-initWithMaxValue: (int)aMaxValue
{
  if( (self = [super init]) )
  {
    maxValue = aMaxValue;
    interval = aMaxValue/10;
    T4Print(@"[");
  }

  return self;
}

-setProgress: (int)currentProgress
{
  if( !(currentProgress % interval) )
    T4Print(@".");
  
  if(currentProgress == maxValue)
    T4Print(@"]");

  return self;
}

@end
