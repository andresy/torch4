#import "T4Saver.h"

@interface T4AsciiSaver : T4Saver
{
    BOOL transposesMatrix;
    BOOL writesHeader;
}

-init;
-setTransposesMatrix: (BOOL)aFlag;
-setWritesHeader: (BOOL)aFlag;

@end
