#import "T4File.h"

@interface T4ArrayFile : T4File
{
    NSMutableArray *contents;
}

-init;
-(int)write: (void*)someData blockSize: (int)aBlockSize numberOfBlocs: (int)aNumBlocks;
-(void)writeStringWithFormat: (NSString*)aFormat, ...;

-(NSArray*)arrayOfContents;

@end
