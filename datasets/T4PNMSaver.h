#import "T4Saver.h"

@interface T4PNMSaver : T4Saver
{    
    int imageWidth;
    int imageHeight;
    int imageType;

    real imageMaxValue;
    real imageMinValue;

    int pnmMaxValue;

    T4Matrix *normalizedImage;
}

-initWithImageWidth: (int)aWidth imageHeight: (int)aHeight imageType: (int)aType;

-setImageMinValue: (real)aValue;
-setImageMaxValue: (real)aValue;
-setNormalizesImage: (BOOL)aFlag;

-setPNMMaxValue: (int)aValue;

@end
