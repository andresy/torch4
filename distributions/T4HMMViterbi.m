#import "T4HMMViterbi.h"
#import "T4Random.h"
#import "T4LogAdd.h"

@implementation T4HMMViterbi

-initWithLogTransitions: (T4Matrix*) someInitialLogTransitions states: (T4Distribution**) someStates;
{
	if( (self = [super initWithLogTransitions: someInitialLogTransitions states: someStates]) )
	{

    viterbi = YES;

		[self reset];
	}
	return self;

}

-setViterbi: (BOOL)aValue
{
  viterbi = aValue;
  return self;
}

-logViterbiWithInputs: (T4Matrix*) someInputs
{
  int lastArgViterbi = -1;
  int f,i,j;
  int numFrames = [someInputs numberOfColumns];
  // first, initialize everything to T4LogZero
  for (f=0;f<numFrames;f++) {
    real* logAlphaF = [logAlpha columnAtIndex: f];
    for (i=1;i<numStates-1;i++) {
      logAlphaF[i] = T4LogZero;
    }
  }   
  // case for first frame
  real* logAlpha0 = [logAlpha columnAtIndex: 0];
  for (i=1;i<numStates-1;i++) {
    real v = [logProbabilitiesStates firstColumn][i] + 
        [logTransitions columnAtIndex:i][0];
    if (v > logAlpha0[i])
      logAlpha0[i] = v;
      [argViterbi firstColumn][i] = 0.0;
  }
  // other cases 
  for (f=1;f<numFrames;f++) {
    real* logAlphaF = [logAlpha columnAtIndex: f];
    real* logAlphaFm1 = [logAlpha columnAtIndex: f-1];
    real* logProbabilitiesStatesF = [logProbabilitiesStates columnAtIndex: f];
    for (i=1;i<numStates-1;i++) {
      real* logTransitionsI = [logTransitions columnAtIndex: i];
      for (j=1;j<numStates-1;j++) {
        real v = logTransitionsI[j] + logProbabilitiesStatesF[i] + logAlphaFm1[j];
        if (v > logAlphaF[i]) {
          logAlphaF[i] = v;
          [argViterbi columnAtIndex: f][i] = (real)j;
        }
      }
    }
  }
  // last case
  logProbability = T4LogZero;
  f = numFrames-1;
  i = numStates-1;
  real* logTransitionsI = [logTransitions columnAtIndex: i];
  real* logAlphaF = [logAlpha columnAtIndex: f];
  for (j=1;j<numStates-1;j++) {
    real v = logTransitionsI[j] + logAlphaF[j];
    if (v > logProbability) {
      logProbability = v;
      lastArgViterbi = j;
    }
  }
  // now recall the state sequence
  if (logProbability > T4LogZero) {
    [viterbiStates firstColumn][f] = lastArgViterbi;
    for (f=numFrames-2;f>=0;f--) {
      [viterbiStates firstColumn][f] = [argViterbi columnAtIndex: f+1][(int)[viterbiStates firstColumn][f+1]];
    }
  } else {
    T4Warning(@"sequence impossible to train: probably too short for target");
    for (f=0;f<numFrames;f++)
      [viterbiStates firstColumn][f] = -1;
    logProbability = T4LogZero;
  }
  return self;
}

-(real)forwardInputs: (T4Matrix*)someInputs
{
  int numFrames = [someInputs numberOfColumns];
  [logProbabilitiesStates resizeWithNumberOfColumns: numFrames];

  [self logProbabilitiesWithInputs: someInputs];

  if (viterbi) {
    [argViterbi resizeWithNumberOfColumns: numFrames];
    [viterbiStates resizeWithNumberOfRows: numFrames];
    [self logViterbiWithInputs: someInputs];
  } else {
    [logAlpha resizeWithNumberOfColumns: numFrames];
    [logBeta resizeWithNumberOfColumns: numFrames];
    [self logAlphaWithInputs: someInputs];
  }
  return logProbability;
}

-backwardLogPosterior: (real)aLogPosterior inputs: (T4Matrix*)someInputs
{
  if (viterbi) {
    int f,i,j;
    int numFrames = [someInputs numberOfColumns];
    real * viterbiStatesValues = [viterbiStates firstColumn];
    for (f=0;f<numFrames;f++) {
      i = (int)viterbiStatesValues[f];
      if (i>=0) {
        [partialInputs setMatrixFromRealArray: [someInputs columnAtIndex: f] numberOfRows: [someInputs numberOfRows] numberOfColumns: 1 stride: -1];
        [states[i] backwardLogPosterior: aLogPosterior inputs: partialInputs];
        j = (int)([argViterbi columnAtIndex: f][i]);
        if (j>0) {
          real* a = [accLogTransitions columnAtIndex: i];
          a[j] = T4LogAdd(a[j],aLogPosterior);
        }   
      }   
    }       
  } else {
    [super backwardLogPosterior: aLogPosterior inputs: someInputs];
  }
	return self;
}

@end
