#import "T4Loader.h"

@interface T4BinaryLoader : T4Loader
{
    BOOL transposesMatrix;
    int maxNumColumns;
}

-(void)setTransposesMatrix: (BOOL)aFlag;
-(void)setMaxNumberOfColumns: (int)aMaxNumber;

@end
