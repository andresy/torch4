#import "T4Saver.h"

#define T4PNMBlackAndWhiteMode 0
#define T4PNMGrayLevelsMode 1
#define T4PNMColorMode 2

@interface T4PNMSaver : T4Saver
{    
    int imageWidth;
    int imageHeight;
    int imageMode;
    int imageMaxValue;
}

-init;

-setImageWidth: (int)aWidth;
-setImageHeight: (int)aHeight;
-setImageMode: (int)aMode;
-setImageMaxValue: (int)aValue;

@end
