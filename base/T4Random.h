#import "T4General.h"

@interface T4Random : NSObject
{
}

+(void)nextState;
+(void)setRandomSeed;
+(void)setSeed: (unsigned long)aSeed;
+(unsigned long)initialSeed;
+(unsigned long)random;
+(real)uniform;
+(void)getArrayOfShuffledIndices: (int*)indices size: (int)aSize;
+(void)shuffleArray: (void*)anArray size: (int)aSize elementSize: (int)anElementSize;
+(real)uniformBoundedWith: (real)a and: (real)b;
+(real)normalWithMean: (real)mean deviation: (real)stdv;
+(real)normal;
+(real)exponential: (real)lambda;
+(real)cauchyWithMedian: (real)median sigma: (real)sigma;
+(real)logNormalWithMean: (real)mean deviation: (real)stdv;
+(int)geometric: (real)p;
+(BOOL)bernoulli: (real)p;

@end
