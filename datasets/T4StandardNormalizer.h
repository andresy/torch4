#import "T4Object.h"
#import "T4Matrix.h"

@interface T4StandardNormalizer : T4Object
{
    T4Matrix *mean;
    T4Matrix *standardDeviation;
}

-initWithMean: (T4Matrix*)aMean standardDeviation: (T4Matrix*)aStandardDeviation;
-initWithDataset: (NSArray*)aDataset columnIndex: (int)anIndex;
-initWithDataset: (NSArray*)aDataset;

-(void)normalizeDataset: (NSArray*)aDataset columnIndex: (int)anIndex;
-(void)normalizeDataset: (NSArray*)aDataset;
-(void)normalizeMatrix: (T4Matrix*)aMatrix;

-(T4Matrix*)mean;
-(T4Matrix*)standardDeviation;

@end
