#import "T4Measurer.h"
#import "T4ClassFormat.h"

@interface T4ClassMeasurer : T4Measurer
{
    T4Matrix *inputs;
    T4ClassFormat *inputClassFormat;
    T4ClassFormat *datasetClassFormat;
    BOOL computeConfusionMatrix;
    T4Matrix *confusionMatrix;
    real internalError;
    int totalNumColumns;
}

-initWithInputs: (T4Matrix*)someInputs classFormat: (T4ClassFormat*)aClassFormat
        dataset: (NSArray*)aDataset classFormat: (T4ClassFormat*)anotherClassFormat
           file: (T4File*)aFile;

-initWithInputs: (T4Matrix*)someInputs classFormat: (T4ClassFormat*)aClassFormat
        dataset: (NSArray*)aDataset
           file: (T4File*)aFile;

-measureExampleAtIndex: (int)anIndex;
-measureAtIteration: (int)anIteration;
-reset;

-setPrintsConfusionMatrix: (BOOL)aFlag;

@end
