#import "T4Loader.h"

@interface T4BinaryLoader : T4Loader
{
    BOOL transposesMatrix;
    int maxNumColumns;
}

-init;
-setTransposesMatrix: (BOOL)aFlag;
-setMaxNumberOfColumns: (int)aMaxNumber;

@end
