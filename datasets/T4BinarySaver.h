#import "T4Saver.h"

@interface T4BinarySaver : T4Saver
{
    BOOL transposesMatrix;
    int diskRealSize;
}

-init;
-setTransposesMatrix: (BOOL)aFlag;
-setEnforcesFloatEncoding: (BOOL)aFlag;
-setEnforcesDoubleEncoding: (BOOL)aFlag;

@end
