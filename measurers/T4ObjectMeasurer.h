#import "T4Measurer.h"
#import "T4Matrix.h"

@interface T4ObjectMeasurer : T4Measurer
{
    id object;

    BOOL measuresAtEachIteration;
    BOOL measuresAtEachExample;
    BOOL measuresAtEnd;
}

-initWithObject: (id)anObject dataset: (NSArray*)aDataset file: (T4File*)aFile;

-setMeasuresAtEachIteration;
-setMeasuresAtEachExample;
-setMeasuresAtEnd;

@end
