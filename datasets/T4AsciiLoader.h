#import "T4Loader.h"

@interface T4AsciiLoader : T4Loader
{
    BOOL hasHeader;
}

-(void)setHasHeader: (BOOL)aFlag;

@end
