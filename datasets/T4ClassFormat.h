#import "T4Object.h"
#import "T4Matrix.h"

@interface T4ClassFormat : T4Object
{
    T4Matrix *classLabels;
}

-initWithNumberOfClasses: (int)aNumClasses encodingSize: (int)anEncodingSize;

-(real*)encodingForClass: (int)aClass;
-(int)encodingSize;
-(int)numberOfClasses;

// primitive:
-(int)classFromRealArray: (real*)aVector;

@end
