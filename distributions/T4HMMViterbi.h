#import "T4HMM.h"

@interface T4HMMViterbi : T4HMM
{
  T4Matrix* argViterbi;
  T4Matrix* viterbiStates;
  BOOL viterbi;
}

-logViterbiWithInputs: (T4Matrix*) someInputs;
-setViterbi: (BOOL)aValue;

@end
