#import "T4Loader.h"

@interface T4AsciiLoader : T4Loader
{
    BOOL transposesMatrix;
    BOOL autodetectsSize;
    int maxNumColumns;
}

-init;
-setTransposesMatrix: (BOOL)aFlag;
-setAutodetectsSize: (BOOL)aFlag;
-setMaxNumberOfColumns: (int)aMaxNumber;

@end
