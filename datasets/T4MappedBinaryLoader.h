#import "T4Loader.h"

@interface T4MappedBinaryLoader : T4Loader
{
    int maxNumColumns;
}

-init;
-setMaxNumberOfColumns: (int)aMaxNumber;

@end
