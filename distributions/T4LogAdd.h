#import "T4General.h"


/** Some simple functions for log operations.

    @author Samy Bengio (bengio@idiap.ch)
*/
//@{
#define LOG_2_PI 1.83787706640934548355
#define LOG_ZERO -INF
#define LOG_ONE 0

/** logAdd(log_a,log_b) = log(a+b) = log(exp(log_a)+exp(log_b))
    but done in a smart way so that if log_a or log_b are large
    but not their difference the computation works correctly.
*/
real T4LogAdd(real log_a,real log_b);

/// logSub(log_a,log_b) = log(a-b)
real T4LogSub(real log_a,real log_b);
//@}


