#import "T4Object.h"

@interface T4Measurer : T4Object
{
    NSFileHandle *file;
    NSArray *dataset;
}

-initWithDataset: (NSArray*)aDataset file: (NSFileHandle*)aFile;
-initWithDataset: (NSArray*)aDataset path: (NSString*)aPath;
-(void)measureExample: (int)anIndex;
-(void)measureIteration: (int)anIteration;
-(void)measureEnd;
-(void)reset;

-(NSArray*)dataset;

@end
