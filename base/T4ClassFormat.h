#import "T4Object.h"
#import "T4Matrix.h"

@interface T4ClassFormat : T4Object
{
    T4Matrix *classLabels;
}


-initWithNumberOfClasses: (int)aNumClasses encodingSize: (int)anEncodingSize;
-(int)encodingSize;
-(int)numberOfClasses;

// primitives:
-(void)transformRealData: (real*)aVector toOneHotData: (real*)aOneHotVector;
-(void)transformOneHotData: (real*)aOneHotVector toRealData: (real*)aVector;
-(int)classFromRealData: (real*)aVector;

@end
