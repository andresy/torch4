#import "T4Measurer.h"
#import "T4Matrix.h"

@interface T4AbsMeasurer : T4Measurer
{
    T4Matrix *inputs;

    BOOL averageWithNumberOfExamples;
    BOOL averageWithNumberOfRows;
    BOOL averageWithNumberOfColumns;
    real internalError; 
}

-initWithInputs: (T4Matrix*)someInputs dataset: (NSArray*)aDataset file: (T4File*)aFile;

-setAveragesWithNumberOfExamples: (BOOL)aFlag;
-setAveragesWithNumberOfRows: (BOOL)aFlag;
-setAveragesWithNumberOfColumns: (BOOL)aFlag;

@end
