#import "T4Measurer.h"
#import "T4Matrix.h"

@interface T4ImagesMeasurer : T4Measurer
{
    T4Matrix *inputs;
    T4Matrix *buffer;

    int imageWidth;
    int imageHeight;
    int numImages;
    int numImagesPerRow;
    int numImagesPerColumn;

    NSString *fileNamePrefix;
    int imageIndex;

    real imageMinValue;
    real imageMaxValue;

    BOOL measuresAtEachIteration;
    BOOL measuresAtEachExample;
    BOOL measuresAtEnd;
}

-initWithInputs: (T4Matrix*)someInputs imageWidth: (int)aWidth imageHeight: (int)aHeight 
 numberOfImages: (int)aNumImages
        dataset: (NSArray*)aDataset fileNamePrefix: (NSString*)aFileNamePrefix;

-setNumberOfImagesPerRow: (int)aNumImagesPerRow;

-writeImage;

-setImageMinValue: (real)aValue;
-setImageMaxValue: (real)aValue;


-setMeasuresAtEachIteration;
-setMeasuresAtEachExample;
-setMeasuresAtEnd;

@end
