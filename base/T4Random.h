#import "T4General.h"

@interface T4Random : NSObject
{
}

+nextState;
+setRandomSeed;
+setSeed: (unsigned long)aSeed;
+(unsigned long)initialSeed;
+(unsigned long)random;
+(real)uniform;
+getArrayOfShuffledIndices: (int*)indices capacity: (int)aCapacity;
+shuffleArray: (void*)anArray capacity: (int)aCapacity elementCapacity: (int)anElementCapacity;
+(real)uniformBoundedWithValue: (real)a value: (real)b;
+(real)normalWithMean: (real)mean deviation: (real)stdv;
+(real)normal;
+(real)exponential: (real)lambda;
+(real)cauchyWithMedian: (real)median sigma: (real)sigma;
+(real)logNormalWithMean: (real)mean deviation: (real)stdv;
+(int)geometric: (real)p;
+(BOOL)bernoulli: (real)p;

@end
