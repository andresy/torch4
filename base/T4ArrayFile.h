#import "T4File.h"

@interface T4ArrayFile : T4File
{
    NSMutableArray *contents;
}

-init;
-(NSArray*)arrayOfContents;

@end
