#import "T4Object.h"

@interface T4Timer : T4Object
{
    BOOL isRunning;
    real totalTime;
    real startTime;
}

-init;
-reset;
-stop;
-resume;
-(real)time;

@end
