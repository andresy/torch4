#import "T4Object.h"
#import "T4NSFileHandleExtension.h"

@interface T4Measurer : T4Object
{
    NSFileHandle *file;
    NSArray *dataset;
}

-initWithDataset: (NSArray*)aDataset file: (NSFileHandle*)aFile;
-initWithDataset: (NSArray*)aDataset path: (NSString*)aPath;
-measureExampleAtIndex: (int)anIndex;
-measureAtIteration: (int)anIteration;
-measureAtEnd;
-reset;

-(NSArray*)dataset;

@end
