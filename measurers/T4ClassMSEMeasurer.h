#import "T4Measurer.h"
#import "T4Matrix.h"
#import "T4ClassFormat.h"

@interface T4ClassMSEMeasurer : T4Measurer
{
    T4Matrix *inputs;
    T4ClassFormat *classFormat;

    BOOL averageWithNumberOfExamples;
    BOOL averageWithNumberOfRows;
    BOOL averageWithNumberOfColumns;
    real internalError; 
}

-initWithInputs: (T4Matrix*)someInputs dataset: (NSArray*)aDataset classFormat: (T4ClassFormat*)aClassFormat file: (T4File*)aFile;
-measureExampleAtIndex: (int)anIndex;
-measureAtIteration: (int)anIteration;
-reset;

-setAveragesWithNumberOfExamples: (BOOL)aFlag;
-setAveragesWithNumberOfRows: (BOOL)aFlag;
-setAveragesWithNumberOfColumns: (BOOL)aFlag;

@end
