#import "T4Object.h"

@interface T4ProgressBar : T4Object
{
    int interval;
    int maxValue;
}

-initWithMaxValue: (int)aMaxValue;
-setProgress: (int)currentProgress;

@end
