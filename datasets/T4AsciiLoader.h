#import "T4Loader.h"

@interface T4AsciiLoader : T4Loader
{
    BOOL transposesMatrix;
    BOOL autodetectsSize;
    int maxNumColumns;
}

-(void)setTransposesMatrix: (BOOL)aFlag;
-(void)setAutodetectsSize: (BOOL)aFlag;
-(void)setMaxNumberOfColumns: (int)aMaxNumber;

@end
