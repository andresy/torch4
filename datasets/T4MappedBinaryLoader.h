#import "T4Loader.h"

@interface T4MappedBinaryLoader : T4Loader
{
    real **mappedAddresses;
    int *mappedSizes;
    int numMapped;
    int maxNumColumns;
}

-init;
-setMaxNumberOfColumns: (int)aMaxNumber;

@end
