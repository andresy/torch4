#import "T4Object.h"
#import "T4File.h"

@interface T4Measurer : T4Object
{
    T4File *file;
    NSArray *dataset;
}

-initWithDataset: (NSArray*)aDataset file: (T4File*)aFile;
-measureExampleAtIndex: (int)anIndex;
-measureAtIteration: (int)anIteration;
-measureAtEnd;
-reset;

-(NSArray*)dataset;

@end
