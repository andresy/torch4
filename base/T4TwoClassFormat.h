#import "T4ClassFormat.h"

@interface T4TwoClassFormat : T4ClassFormat
{
}

-init;

// primitives:
-(void)transformRealData: (real*)aVector toOneHotData: (real*)aOneHotVector;
-(void)transformOneHotData: (real*)aOneHotVector toRealData: (real*)aVector;
-(int)classFromRealData: (real*)aVector;

@end
