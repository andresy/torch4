#import "T4Loader.h"

@interface T4PNMLoader : T4Loader
{
    int imageWidth;
    int imageHeight;
    int imageDepth;
}

-init;

-(int)imageWidth;
-(int)imageHeight;
-(int)imageDepth;

@end
