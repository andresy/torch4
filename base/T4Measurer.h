#import "T4Object.h"

@interface T4Measurer : T4Object
{
    NSFileHandle *file;
    NSArray *dataset;
}

-initWithDataset: (NSArray*)aDataset file: (NSFileHandle*)aFile;
-initWithDataset: (NSArray*)aDataset path: (NSString*)aPath;
-measureExample: (int)anIndex;
-measureIteration: (int)anIteration;
-measureEnd;
-reset;

-(NSArray*)dataset;

@end
