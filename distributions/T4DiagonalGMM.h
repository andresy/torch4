#import "T4Distribution.h"

@interface T4DiagonalGMM : T4Distribution
{
    int numGaussians;
		real priorWeights;
		T4Matrix* means;
		T4Matrix* variances;
		T4Matrix* logWeights;
		T4Matrix* accMeans;
		T4Matrix* accVariances;
		T4Matrix* accWeights;
		T4Matrix* sumLogVarPlusNObsLog2Pi;
		T4Matrix* minusHalfOverVar;
		T4Matrix* variancesFlooring;
		T4Matrix* logProbabilitiesGaussians;
    T4Matrix* logProbabilities;
}


-initWithNumberOfInputs: (int)aNumInputs numberOfGaussians: (int)aNumGaussians;
-(int)numGaussians;
-setPriorWeights: (real)aValue;
-setVariancesFlooring:(T4Matrix*)someValues;
-(real)frameLogProbabilityOfGaussian: (int)gaussianIndex frame: (real*) aFrame;
-(real)frameLogProbability: (real*)aFrame index: (int)anIndex;


@end
