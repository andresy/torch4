#import "T4HMM.h"
#import "T4Random.h"
#import "T4LogAdd.h"

@implementation T4HMM

-initWithLogTransitions: (T4Matrix*) someInitialLogTransitions states: (T4Distribution**) someStates;
{
	if( (self = [super initWithNumberOfInputs: [someStates[1] numberOfInputs] numberOfParameters: ([someInitialLogTransitions numberOfColumns]*[someInitialLogTransitions numberOfRows])]))
	{
		real *parametersAddr, *accumulatorsAddr;

    states = someStates;

		numStates = [someInitialLogTransitions numberOfColumns];
		priorOnTransitions = .0001;

		parametersAddr = [[parameters objectAtIndex: 0] firstColumn];
		logTransitions = [[T4Matrix alloc] initWithRealData: parametersAddr numberOfRows: numStates numberOfColumns: numStates stride: -1];
		[allocator keepObject: logTransitions];

		accumulatorsAddr = [[accumulators objectAtIndex: 0] firstColumn];
		accLogTransitions = [[T4Matrix alloc] initWithRealData: accumulatorsAddr numberOfRows: numStates numberOfColumns: numStates stride: -1];
		[allocator keepObject: accLogTransitions];

    initialLogTransitions = someInitialLogTransitions;
		[allocator keepObject: initialLogTransitions];

		logProbabilitiesStates = [[T4Matrix alloc] initWithNumberOfRows: numStates numberOfColumns:1];
		[allocator keepObject: logProbabilitiesStates];

		partialInputs = [[T4Matrix alloc] init];
		[allocator keepObject: partialInputs];

		[self reset];
	}
	return self;

}


-(int)numStates
{
	return numStates;
}

-setPriorOnTransitions: (real)aValue
{
	priorOnTransitions = aValue;
	return self;
}

-resetAccumulators
{
	int i;
	[super resetAccumulators];
  real logPrior = log(priorOnTransitions);
  [accLogTransitions fillWithValue: logPrior];
  for (i=1;i<numStates-1;i++)
    [states[i] resetAccumulators];
	return self;
}

-reset
{
  [logTransitions copyMatrix: initialLogTransitions];
  int i;
  for (i=1;i<numStates;i++)
    [states[i] reset];
	return self;
}


-resetWithDataset: (NSArray*)aDataset
{
	return self;
}

-logAlphaWithInputs: (T4Matrix*) someInputs
{
  int f,i,j;
  int numFrames = [someInputs numberOfColumns];
  // first, initialize everything to LOG_ZERO
  for (f=0;f<numFrames;f++) {
    real* logAlphaF = [logAlpha columnAtIndex: f];
    for (i=1;i<numStates-1;i++) {
      logAlphaF[i] = LOG_ZERO;
    }
  }   
  // case for first frame
  real* logAlpha0 = [logAlpha columnAtIndex: 0];
  for (i=1;i<numStates-1;i++) {
    if ([logTransitions columnAtIndex: i][0] != LOG_ZERO)
      logAlpha0[i] = [logProbabilitiesStates firstColumn][i] + 
        [logTransitions columnAtIndex: i][0];
  }
  // other cases 
  for (f=1;f<numFrames;f++) {
    real* logAlphaF = [logAlpha columnAtIndex: f];
    real* logAlphaFm1 = [logAlpha columnAtIndex: f-1];
    real* logProbabilitiesStatesF = [logProbabilitiesStates columnAtIndex: f];
    for (i=1;i<numStates-1;i++) {
      real* logTransitionsI = [logTransitions columnAtIndex: i];
      for (j=1;j<numStates-1;j++) {
        logAlphaF[i] = T4LogAdd(logAlphaF[i],
          logTransitionsI[j] +
          logProbabilitiesStatesF[i] +
          logAlphaFm1[j]);
      }
    }
  }
  // last case
  logProbability = LOG_ZERO;
  f = numFrames-1;
  i = numStates-1;
  real* logTransitionsI = [logTransitions columnAtIndex: i];
  real* logAlphaF = [logAlpha columnAtIndex: f];
  for (j=1;j<numStates-1;j++) {
    logProbability = T4LogAdd(logProbability,
      logAlphaF[j]+logTransitionsI[j]);
  }
  return self;
}

-logBetaWithInputs: (T4Matrix*) someInputs;
{
  int f,i,j;
  int numFrames = [someInputs numberOfColumns];
  // first, initialize everything to LOG_ZERO
  for (f=0;f<numFrames;f++) {
    real* logBetaF = [logBeta columnAtIndex: f];
    for (i=1;i<numStates-1;i++) {
      logBetaF[i] = LOG_ZERO;
    }
  }
  // case for last frame
  real* logBetaF = [logBeta columnAtIndex: numFrames-1];
  real* logTransitionsN = [logTransitions columnAtIndex: numStates-1];
  for (i=1;i<numStates-1;i++) {
      logBetaF[i] = logTransitionsN[i];
  }
  // other cases
  for (f=numFrames-2;f>=0;f--) {
    real* logBetaF = [logBeta columnAtIndex: f];
    real* logBetaFp1 = [logBeta columnAtIndex: f+1];
    real* logProbabilitiesStatesFp1 = [logProbabilitiesStates columnAtIndex: f+1];
    for (i=1;i<numStates-1;i++) {
      real* logTransitionsI = [logTransitions columnAtIndex: i];
      for (j=1;j<numStates-1;j++) {
        logBetaF[j] = T4LogAdd(logBetaF[j],
          logTransitionsI[j] +
          logProbabilitiesStatesFp1[i] +
          logBetaFp1[i]);
      }
    }
  }
  return self;
}

-logProbabilitiesWithInputs: (T4Matrix*)someInputs
{
  int i;
  for (i=1;i<numStates-1;i++) {
    [states[i] forwardInputs: someInputs];
  }
  return self;
}

-(real)forwardInputs: (T4Matrix*)someInputs
{
  int numFrames = [someInputs numberOfColumns];
  [logProbabilitiesStates resizeWithNumberOfColumns: numFrames];
  [logAlpha resizeWithNumberOfColumns: numFrames];
  [logBeta resizeWithNumberOfColumns: numFrames];

  [self logProbabilitiesWithInputs: someInputs];
  [self logAlphaWithInputs: someInputs];
  return logProbability;
}


-backwardLogPosterior: (real)aLogPosterior inputs: (T4Matrix*)someInputs
{
  int f,i,j;
  int numFrames = [someInputs numberOfColumns];

  [self logBetaWithInputs: someInputs];

  // accumulate the emission and transition posteriors
  for (f=0;f<numFrames;f++) {
    real* logAlphaF = [logAlpha columnAtIndex: f];
    real* logBetaF = [logBeta columnAtIndex: f];
    for (i=1;i<numStates-1;i++) {
      if (logAlphaF[i] != LOG_ZERO && logBetaF[i] != LOG_ZERO) {
        real logPosteriorIF = aLogPosterior + logAlphaF[i] +
          logBetaF[i] - logProbability;
        [partialInputs setMatrixFromRealData: [someInputs columnAtIndex: f] numberOfRows: [someInputs numberOfRows] numberOfColumns: 1 stride: -1];
        [states[i] backwardLogPosterior: logPosteriorIF inputs: partialInputs];
      }
    }
  }
  for (f=1;f<numFrames;f++) {
    real* logAlphaFm1 = [logAlpha columnAtIndex: f-1];
    real* logBetaF = [logBeta columnAtIndex: f];
    real* logEmitF = [logProbabilitiesStates columnAtIndex: f];
    for (i=1;i<numStates-1;i++) {
      real* logTransitionsI = [logTransitions columnAtIndex: i];
      real* accLogTransitionsI = [accLogTransitions columnAtIndex: i];
      for (j=1;j<numStates-1;j++) {
        if (logTransitionsI[j] != LOG_ZERO && logAlphaFm1[j] != LOG_ZERO && logBetaF[i] != LOG_ZERO && logEmitF[i] != LOG_ZERO)
          accLogTransitionsI[j] = T4LogAdd(accLogTransitionsI[j],
            aLogPosterior + logAlphaFm1[j] +
            logTransitionsI[j] + logEmitF[i] + logBetaF[i] -
            logProbability);
      }
    }
  }
  // particular case of transitions from initial state
  real* logBeta0 = [logBeta firstColumn];
  real* logEmit0 = [logProbabilitiesStates firstColumn];
  for (j=1;j<numStates-1;j++) {
    real* logTransitionsJ = [logTransitions columnAtIndex: j];
    real* accLogTransitionsJ = [accLogTransitions columnAtIndex: j];
    if (logTransitionsJ[0] != LOG_ZERO && logBeta0[j] != LOG_ZERO && logEmit0[j] != LOG_ZERO)
      accLogTransitionsJ[0] = T4LogAdd(accLogTransitionsJ[0],
        aLogPosterior + logBeta0[j] + logEmit0[j] +
        logTransitionsJ[0] - logProbability);
  }
  // particular case of transitions to last state
  f = numFrames-1;
  i = numStates-1;
  real* logTransitionsI = [logTransitions columnAtIndex: i];
  real* accLogTransitionsI = [logTransitions columnAtIndex: i];
  real* logAlphaF = [logAlpha columnAtIndex: f];
  for (j=1;j<numStates-1;j++) {
    if (logTransitionsI[j] != LOG_ZERO && logAlphaF[j] != LOG_ZERO)
      accLogTransitionsI[j] = T4LogAdd(accLogTransitionsI[j],
        aLogPosterior + logAlphaF[j] + logTransitionsI[j] - 
        logProbability);
  }

	return self;
}

-update
{
  int i,j;
  // first the states
  for (i=1;i<numStates-1;i++) {
    [states[i] update];
  }
  // then the transitions;
  for (i=0;i<numStates-1;i++) {
    real logSum = LOG_ZERO;
    for (j=1;j<numStates;j++) {
      if ([logTransitions columnAtIndex: j][i] != LOG_ZERO)
        logSum = T4LogAdd(logSum,[accLogTransitions columnAtIndex:j][i]);
    }
    for (j=0;j<numStates;j++) {
      if ([logTransitions columnAtIndex: j][i] != LOG_ZERO)
        [logTransitions columnAtIndex: j][i] = [accLogTransitions columnAtIndex: j][i] - logSum;
    }
  }
	return self;
}


@end
