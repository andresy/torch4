#import "T4Loader.h"

@interface T4BinaryLoader : T4Loader
{
    BOOL transposesMatrix;
    int maxNumColumns;
    int diskRealSize;
}

-init;
-setTransposesMatrix: (BOOL)aFlag;
-setMaxNumberOfColumns: (int)aMaxNumber;
-setEnforcesFloatEncoding: (BOOL)aFlag;
-setEnforcesDoubleEncoding: (BOOL)aFlag;

@end
