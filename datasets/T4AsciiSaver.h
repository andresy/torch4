#import "T4Saver.h"

@interface T4AsciiSaver : T4Saver
{
    BOOL transposesMatrix;
}

-init;
-setTransposesMatrix: (BOOL)aFlag;

@end
