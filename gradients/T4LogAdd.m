#import "T4LogAdd.h"

#ifdef USE_DOUBLE
#define MINUS_LOG_THRESHOLD -39.14
#else
#define MINUS_LOG_THRESHOLD -18.42
#endif

real T4LogAdd(real log_a, real log_b)
{
  real minusdif;

  if (log_a < log_b)
  {
    real tmp = log_a;
    log_a = log_b;
    log_b = tmp;
  }

  minusdif = log_b - log_a;
#ifdef DEBUG
  if (isnan(minusdif))
    T4Error(@"LogAdd: minusdif (%f) log_b (%f) or log_a (%f) is nan", minusdif, log_b, log_a);
#endif
  if (minusdif < MINUS_LOG_THRESHOLD)
    return log_a;
  else
    return log_a + log1p(exp(minusdif));
}

real T4LogSub(real log_a, real log_b)
{
  real minusdif;

  if (log_a < log_b)
    T4Error(@"LogSub: log_a (%f) should be greater than log_b (%f)", log_a, log_b);

  minusdif = log_b - log_a;
#ifdef DEBUG
  if (isnan(minusdif))
    T4Error(@"LogSub: minusdif (%f) log_b (%f) or log_a (%f) is nan", minusdif, log_b, log_a);
#endif
  if (log_a == log_b)
    return LOG_ZERO;
  else if (minusdif < MINUS_LOG_THRESHOLD)
    return log_a;
  else
    return log_a + log1p(-exp(minusdif));
}
