#import "T4DiagonalGMM.h"
#import "T4Random.h"
#import "T4LogAdd.h"

#define        max(a,b) ((a) > (b) ? (a) : (b))

@implementation T4DiagonalGMM

-initWithNumberOfInputs: (int)aNumInputs numberOfGaussians: (int)aNumGaussians
{
	if( (self = [super initWithNumberOfInputs: aNumInputs numberOfParameters: aNumGaussians*(1+aNumInputs*2)]) )
	{
		real *parametersAddr, *accumulatorsAddr;

		numGaussians = aNumGaussians;
		priorWeights = .0001;

		parametersAddr = [[parameters objectAtIndex: 0] firstColumn];
		logWeights = [[T4Matrix alloc] initWithRealData: parametersAddr numberOfRows: numGaussians numberOfColumns: 1 stride: -1];
		means = [[T4Matrix alloc] initWithRealData: parametersAddr+numGaussians numberOfRows: numInputs numberOfColumns: numGaussians stride: -1];
		variances = [[T4Matrix alloc] initWithRealData: parametersAddr+numGaussians+(numInputs*numGaussians) numberOfRows: numInputs numberOfColumns: numGaussians stride: -1];
		[allocator keepObject: logWeights];
		[allocator keepObject: means];
		[allocator keepObject: variances];

		accumulatorsAddr = [[accumulators objectAtIndex: 0] firstColumn];
		accWeights = [[T4Matrix alloc] initWithRealData: accumulatorsAddr numberOfRows: numGaussians numberOfColumns: 1 stride: -1];
		accMeans = [[T4Matrix alloc] initWithRealData: accumulatorsAddr+numGaussians numberOfRows: numInputs numberOfColumns: numGaussians stride: -1];
		accVariances = [[T4Matrix alloc] initWithRealData: accumulatorsAddr+numGaussians+(numInputs*numGaussians) numberOfRows: numInputs numberOfColumns: numGaussians stride: -1];
		[allocator keepObject: accWeights];
		[allocator keepObject: accMeans];
		[allocator keepObject: accVariances];

		minusHalfOverVar = [[T4Matrix alloc] initWithNumberOfRows: numInputs numberOfColumns: numGaussians];
		[allocator keepObject: minusHalfOverVar];

		sumLogVarPlusNObsLog2Pi = [[T4Matrix alloc] initWithNumberOfRows: numGaussians numberOfColumns: 1];
		[allocator keepObject: sumLogVarPlusNObsLog2Pi];

		variancesFlooring = [[T4Matrix alloc] initWithNumberOfRows: numInputs numberOfColumns: 2];
		[allocator keepObject: variancesFlooring];

		logProbabilitiesGaussians = [[T4Matrix alloc] initWithNumberOfRows: numGaussians numberOfColumns:1];
		[allocator keepObject: logProbabilitiesGaussians];

		logProbabilities = [[T4Matrix alloc] initWithNumberOfRows: 1 numberOfColumns: 1];
		[allocator keepObject: logProbabilities];

		[self reset];
	}
	return self;

}


-(int)numGaussians
{
	return numGaussians;
}

-setVariancesFlooring:(T4Matrix*)someValues
{
	[variancesFlooring copyMatrix:someValues];
	return self;
}

-setPriorWeights: (real)aValue
{
	priorWeights = aValue;
	return self;
}

-resetAccumulators
{
	int i,j;
	[super resetAccumulators];
	real* accWeightsAddr = [accWeights firstColumn ];
	real *sumAddr = [sumLogVarPlusNObsLog2Pi firstColumn];
	real *minusAddr = [minusHalfOverVar firstColumn];
	real *variancesAddr = [variances firstColumn];
	for (i=0;i<numGaussians;i++) {
		sumAddr[i] = numInputs * LOG_2_PI;
		for (j=0;j<numInputs;j++) {
			minusAddr[j] = -0.5 / variancesAddr[j];
			sumAddr[i] += log(variancesAddr[j]);
		}
		sumAddr[i] *= -0.5;
		accWeightsAddr[i] = priorWeights;
		minusAddr += numInputs;
		variancesAddr += numInputs;
	}
	return self;
}
-reset
{
	int i,j;
	real sum = 0.;
	real* logWeightsAddr = [logWeights firstColumn];
	for (i=0;i<numGaussians;i++) {
		logWeightsAddr[i] = [T4Random uniformBoundedWithValue: 0.1 andValue:1];
		sum += logWeightsAddr[i];
	}
	for (i=0;i<numGaussians;i++) {
		logWeightsAddr[i] = log(1.0/(real)numGaussians);
		//logWeightsAddr[i] = log(logWeightsAddr[i]/sum);
	}

	// then the means and variances
	for (i=0;i<numGaussians;i++) {
		real* meansAddr = [means columnAtIndex:i];
		real* variancesAddr = [variances columnAtIndex:i];
		for (j=0;j<numInputs;j++) {
			meansAddr[j] = [T4Random uniformBoundedWithValue: 0 andValue:1];
			variancesAddr[j] = 1.0;
			//variancesAddr[j] = [T4Random uniformBoundedWithValue: 0.1 andValue:1];
		}
	}

	return self;
}


-resetWithDataset: (NSArray*)aDataset
{
	int t,i,j;
	int numTrain = [aDataset count];
	int totalOfNumColumns = 0;
	int* exampleSize = (int*) malloc(sizeof(int)*numTrain);
	[variancesFlooring zero];
	real *x2 = [variancesFlooring firstColumn];
	real *x = [variancesFlooring columnAtIndex:1];
	for(t = 0; t < numTrain; t++)
	{
		NSArray *example = [aDataset objectAtIndex: t];
		T4Matrix *inputs = [example objectAtIndex:0];
		exampleSize[t] = [inputs numberOfColumns];
		totalOfNumColumns += exampleSize[t];
		for(i=0;i<[inputs numberOfColumns];i++){
			real *z = [inputs columnAtIndex:i];
			for(j=0;j<numInputs;j++){
				x[j] += z[j];	
				x2[j] += z[j] * z[j];
			}
		}
	}

	for(j=0;j<numInputs;j++){
		x[j] /= totalOfNumColumns;
		x2[j] = 0.1 * (x2[j] / totalOfNumColumns - (x[j] * x[j]) );
	}
	T4Message(@"Number of columns: %d",totalOfNumColumns);
	{
		int numberOfPart = totalOfNumColumns/(real)numGaussians;
		// initialize the parameters using some examples in the dataset randomly
		int sum = 0;
		int ex = 0; 
		int i,j;
		for (i=0;i<numGaussians;i++) {
			int from = (int)(i*numberOfPart);
			int to = (int)((i+1)*numberOfPart);
			int diff = max(to - from,1);
			int index = from + (int)([T4Random uniform]*(real)diff);
			while(sum <= index){
				sum += exampleSize[ex++];
			}
			sum -= exampleSize[--ex];
			NSArray *example = [aDataset objectAtIndex: ex];
			T4Matrix *inputs = [example objectAtIndex: 0];
			real *x = [inputs columnAtIndex: (index -sum)];
			real *meansAddr = [means columnAtIndex: i];
			//real *var_i = var[i];
			//real *thresh = var_threshold;
			for(j = 0; j < numInputs; j++) {
				meansAddr[j] = x[i];
			}
			[logWeights firstColumn][i] = log(1./(real)numGaussians);
		}
	}
	free(exampleSize);
	//T4Message(@"means: %@",means);
	//T4Message(@"logW: %@",logWeights);
	return self;

}


-(real)columnLogProbabilityOneGaussian: (int)gaussianIndex inputColumn: (real*) aInputColumn
{

	int j;
	real* meansAddr = [means columnAtIndex:gaussianIndex];
	real* minusAddr = [minusHalfOverVar columnAtIndex:gaussianIndex];
	real sumXDotMu = 0.;
	for(j = 0; j < numInputs; j++) {
		real xDotMu = (aInputColumn[j] - meansAddr[j]);
		sumXDotMu += xDotMu*xDotMu * minusAddr[j];
	}
	return sumXDotMu + [sumLogVarPlusNObsLog2Pi firstColumn][gaussianIndex];
}


-(real)columnLogProbability: (int)columnIndex inputColumn: (real*)aInputColumn
{
	int i;
	real logProba = LOG_ZERO;
	real *logWeightsAddr = [logWeights firstColumn];
	real* logProbabilitiesGaussianAddr = [logProbabilitiesGaussians columnAtIndex:columnIndex];
	real* meansAddr = [means firstColumn];
	real* minusAddr = [minusHalfOverVar firstColumn];
	real* sumAddr = [sumLogVarPlusNObsLog2Pi firstColumn];
	for (i=0;i<numGaussians;i++) {
		int j;
		real sumXDotMu = 0.;
		for(j = 0; j < numInputs; j++) {
			real xDotMu = (aInputColumn[j] - meansAddr[j]);
			sumXDotMu += xDotMu*xDotMu * minusAddr[j];
		}
		logProbabilitiesGaussianAddr[i] = sumXDotMu + sumAddr[i];
		//*logProbabilitiesGaussianAddr = [self columnLogProbabilityOneGaussian: i inputColumn:aInputColumn];
		//T4Message(@"%g %g %g",logProba,*logProbabilitiesGaussianAddr,*logWeightsAddr);
		logProba = T4LogAdd(logProba, logProbabilitiesGaussianAddr[i] + logWeightsAddr[i]);
		meansAddr += numInputs;
		minusAddr += numInputs;
	}

	return logProba;
}


-(real)forwardMatrix: (T4Matrix*)someInputs
{
	real ll = 0;
	int i;
	int numColumns = [someInputs numberOfColumns];
	[logProbabilities resizeWithNumberOfColumns: numColumns];
	[logProbabilitiesGaussians resizeWithNumberOfColumns: numColumns];
	real* logProbabilitiesAddr = [logProbabilities firstColumn];
	real *logWeightsAddr = [logWeights firstColumn];

	real* sumAddr = [sumLogVarPlusNObsLog2Pi firstColumn];

	for (i=0;i<numColumns;i++) {
		int g;
		real* meansAddr = [means firstColumn];
		real* minusAddr = [minusHalfOverVar firstColumn];
		real logProba = LOG_ZERO;
		real* logProbabilitiesGaussianAddr = [logProbabilitiesGaussians columnAtIndex:i];
		real* aInputColumn = [someInputs columnAtIndex:i];

		for (g=0;g<numGaussians;g++) {
			int j;
			real sumXDotMu = 0.;
			for(j = 0; j < numInputs; j++) {
				real xDotMu = (aInputColumn[j] - meansAddr[j]);
				sumXDotMu += xDotMu*xDotMu * minusAddr[j];
			}
			logProbabilitiesGaussianAddr[g] = sumXDotMu + sumAddr[g];
			//*logProbabilitiesGaussianAddr = [self columnLogProbabilityOneGaussian: i inputColumn:aInputColumn];
			//T4Message(@"%g %g %g",logProba,*logProbabilitiesGaussianAddr,*logWeightsAddr);
			logProba = T4LogAdd(logProba, logProbabilitiesGaussianAddr[g] + logWeightsAddr[g]);
			meansAddr += numInputs;
			minusAddr += numInputs;
		}

		logProbabilitiesAddr[i] = logProba;




		//	logProbabilitiesAddr[i] =  [self columnLogProbability:i inputColumn:[someInputs columnAtIndex:i]];
		ll += logProbabilitiesAddr[i];
	}
	//T4Warning(@"proba: %g",ll);	
	return ll;
}


-accumulateMatrix: (T4Matrix*)someInputs logPosterior: (real) aLogPosterior
{
	int i;
	int numColumns = [someInputs numberOfColumns];
	for (i=0;i<numColumns;i++)
		[self accumulateColumn:i inputColumn: [someInputs columnAtIndex:i] logPosterior: aLogPosterior];

	return self;
}


-accumulateColumn: (int)aColumnIndex inputColumn: (real*)aInputColumn logPosterior: (real)aLogPosterior
{
	int i,j;
	real logProba = [logProbabilities firstColumn][aColumnIndex];
	real *accWeightsAddr = [accWeights firstColumn];
	real *logProbabilitiesGaussianAddr = [logProbabilitiesGaussians columnAtIndex:aColumnIndex]; 
	real *logWeightsAddr = [logWeights firstColumn];
	real* accMeansAddr = [accMeans firstColumn];
	real* accVariancesAddr = [accVariances firstColumn];
	for (i=0;i<numGaussians;i++) {
		real posteriorGaussian = exp(aLogPosterior + logWeightsAddr[i] + logProbabilitiesGaussianAddr[i] - logProba);
		accWeightsAddr[i] += posteriorGaussian;

		for(j = 0; j < numInputs; j++) {
			real z = aInputColumn[j];
			accVariancesAddr[j] += posteriorGaussian * z * z;
			accMeansAddr[j] += posteriorGaussian * z;
		} 
		accMeansAddr += numInputs;
		accVariancesAddr += numInputs;
	}
	return self;
}

-update
{
	// first the gaussians
	int i,j;
	real* accWeightsAddr = [accWeights firstColumn];
	for ( i=0;i<numGaussians;i++) {
		if (accWeightsAddr[i] == 0) {
			T4Warning(@"Gaussian %d of GMM is not used in EM",i);
		} else {
			real* meansAddr = [means columnAtIndex:i];
			real* variancesAddr = [variances columnAtIndex:i];
			real* accMeansAddr = [accMeans columnAtIndex:i];
			real* accVariancesAddr = [accVariances columnAtIndex:i];
			real *vFloorAddr = [variancesFlooring firstColumn];
			for (j=0;j<numInputs;j++) {
				meansAddr[j] = accMeansAddr[j] / accWeightsAddr[i];
				real v = accVariancesAddr[j] / accWeightsAddr[i] - (meansAddr[j] * meansAddr[j]);
				variancesAddr[j] = v >= vFloorAddr[j] ? v : vFloorAddr[j];
			}
		}
	}
	// then the weights
	{
		int i;
		real sumAccWeights = 0;
		real* accWeightsAddr = [accWeights firstColumn];
		real *logWeightsAddr = [logWeights firstColumn];
		//T4Message(@"%@",logWeights);
		for (i=0;i<numGaussians;i++)
			sumAccWeights += accWeightsAddr[i];
		sumAccWeights = log(sumAccWeights);
		for (i=0;i<numGaussians;i++)
			logWeightsAddr[i] = log(accWeightsAddr[i]) - sumAccWeights;
	}
	return self;
}


@end
