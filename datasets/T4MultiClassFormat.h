#import "T4ClassFormat.h"

@interface T4MultiClassFormat : T4ClassFormat
{
    real *classLabelArray;
}

-initWithNumberOfClasses: (int)aNumClasses labels: (real*)someLabels;

@end
