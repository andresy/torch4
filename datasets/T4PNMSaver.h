#import "T4Saver.h"

@interface T4PNMSaver : T4Saver
{    
    int imageWidth;
    int imageHeight;
    int imageType;
    int imageMaxValue;
}

-initWithImageWidth: (int)aWidth imageHeight: (int)aHeight imageType: (int)aType;
-setImageMaxValue: (int)aValue;

@end
