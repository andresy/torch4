#import "T4Object.h"
#import "T4Matrix.h"

@interface T4StandardNormalizer : T4Object <NSCoding>
{
    T4Matrix *means;
    T4Matrix *standardDeviations;
}

-initWithMeans: (T4Matrix*)someMeans standardDeviations: (T4Matrix*)someStandardDeviations;
-initWithDataset: (NSArray*)aDataset columnIndex: (int)anIndex;
-initWithDataset: (NSArray*)aDataset;

-normalizeDataset: (NSArray*)aDataset columnIndex: (int)anIndex;
-normalizeDataset: (NSArray*)aDataset;
-normalizeMatrix: (T4Matrix*)aMatrix;

-(T4Matrix*)means;
-(T4Matrix*)standardDeviations;

@end
