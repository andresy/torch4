#import "T4Timer.h"
#include <sys/times.h>
#import <unistd.h>

real T4TimerRunTime()
{
  struct tms current;
  times(&current);
  
  real norm = (real)sysconf(_SC_CLK_TCK);
  return(((real)current.tms_utime)/norm);
}

@implementation T4Timer

-init
{
  if( (self = [super init]) )
  {
    totalTime = 0;
    isRunning = YES;
    startTime = T4TimerRunTime();
  }
  return self;
}

-reset
{
  totalTime = 0;
  startTime = T4TimerRunTime();
  return self;
}

-stop
{
  if(isRunning)  
  {
    real currentTime = T4TimerRunTime() - startTime;
    totalTime += currentTime;
    isRunning = NO;
  }

  return self;
}

-resume
{
  if(!isRunning)
  {
    startTime = T4TimerRunTime();
    isRunning = YES;
  }
  return self;
}

-(real)time
{
  if(isRunning)
  {
    real currentTime = T4TimerRunTime() - startTime;
    return(totalTime+currentTime);
  }
  else
    return totalTime;
}

@end
