#import "T4Measurer.h"
#import "T4Matrix.h"
#import "T4ClassFormat.h"

@interface T4ClassMSEMeasurer : T4Measurer
{
    T4Matrix *inputs;
    T4ClassFormat *inputClassFormat;
    T4ClassFormat *datasetClassFormat;

    BOOL averageWithNumberOfExamples;
    BOOL averageWithNumberOfRows;
    BOOL averageWithNumberOfColumns;
    real internalError; 
}

-initWithInputs: (T4Matrix*)someInputs classFormat: (T4ClassFormat*)aClassFormat dataset: (NSArray*)aDataset classFormat: (T4ClassFormat*)anotherClassFormat file: (T4File*)aFile;

-setAveragesWithNumberOfExamples: (BOOL)aFlag;
-setAveragesWithNumberOfRows: (BOOL)aFlag;
-setAveragesWithNumberOfColumns: (BOOL)aFlag;

@end
