#import "T4Loader.h"

@interface T4MappedBinaryLoader : T4Loader
{
    real **mappedAddresses;
    int *mappedSizes;
    int numMapped;
    int maxNumColumns;
}

-(void)setMaxNumberOfColumns: (int)aMaxNumber;

@end
