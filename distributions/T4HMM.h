#import "T4Distribution.h"

@interface T4HMM : T4Distribution
{
  int numStates;
  real priorOnTransitions;
  T4Distribution** states;

  T4Matrix* logTransitions;
  T4Matrix* accLogTransitions;
  T4Matrix* initialLogTransitions;

  T4Matrix* logAlpha;
  T4Matrix* logBeta;

  T4Matrix* logProbabilitiesStates;

  T4Matrix* partialInputs;
}


-initWithLogTransitions: (T4Matrix*) someInitialLogTransitions states: (T4Distribution**) someStates;
-logAlphaWithInputs: (T4Matrix*) someInputs;
-logBetaWithInputs: (T4Matrix*) someInputs;
-logProbabilitiesWithInputs: (T4Matrix*) someInputs;
-(int)numStates;
-setPriorOnTransitions: (real)aValue;

@end
