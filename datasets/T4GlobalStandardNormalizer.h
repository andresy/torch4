#import "T4Object.h"
#import "T4Matrix.h"

@interface T4GlobalStandardNormalizer : T4Object <NSCoding>
{
    real mean;
    real standardDeviation;
}

-initWithMean: (real)aMean standardDeviation: (real)aStandardDeviation;
-initWithDataset: (NSArray*)aDataset columnIndex: (int)anIndex;
-initWithDataset: (NSArray*)aDataset;

-normalizeDataset: (NSArray*)aDataset columnIndex: (int)anIndex;
-normalizeDataset: (NSArray*)aDataset;
-normalizeMatrix: (T4Matrix*)aMatrix;

-(real)mean;
-(real)standardDeviation;

@end
