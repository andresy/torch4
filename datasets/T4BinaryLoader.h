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
-setReadsFloat: (BOOL)aFlag;
-setReadsDouble: (BOOL)aFlag;

@end
