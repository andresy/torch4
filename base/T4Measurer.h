#import "T4Object.h"

@interface T4Measurer : T4Object
{
    NSFileHandle *file;
    NSArray *dataset;
}

-initWithDataset: (NSArray*)aDataset file: (NSFileHandle*)aFile;
-initWithDataset: (NSArray*)aDataset path: (NSString*)aPath;
-(void)measureExample;
-(void)measureIteration;
-(void)measureEnd;
-(void)reset;

@end
