#import "T4Loader.h"

@interface T4AsciiLoader : T4Loader
{
    BOOL transposesMatrix;
    BOOL hasHeader;
    int maxNumColumns;
}

-(void)setTransposesMatrix: (BOOL)aFlag;
-(void)setHasHeader: (BOOL)aFlag;
-(void)setMaxNumberOfColumns: (int)aMaxNumber;

@end
