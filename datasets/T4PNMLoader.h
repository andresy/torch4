#import "T4Loader.h"

#define T4PNMBitMap 0
#define T4PNMGrayMap 1
#define T4PNMPixelMap 2

@interface T4PNMLoader : T4Loader
{
    int imageWidth;
    int imageHeight;
    int imageType;
}

-init;

-(int)imageWidth;
-(int)imageHeight;
-(int)imageType;

@end
