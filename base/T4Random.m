#import <time.h>
#import "T4Random.h"
#import "T4Allocator.h"

#define T4RandomN 624
#define T4RandomM 397

unsigned long T4RandomState[T4RandomN];
unsigned long T4RandomInitialSeed;
unsigned long *T4RandomNext;
int T4RandomLeft = 1;
int T4RandomInitf = 0;
real T4RandomNormalX;
real T4RandomNormalY;
real T4RandomNormalRho;
BOOL T4RandomNormalIsValid = NO;

@implementation T4Random

+(void)setRandomSeed
{
  time_t ltime;
  struct tm *today;
  time(&ltime);
  today = localtime(&ltime);
  [self setSeed: ((unsigned long)today->tm_sec)];
}

///////////// The next 4 methods are taken from http://www.math.keio.ac.jp/matumoto/emt.html
///////////// Here is the copyright:
///////////// Some minor modifications have been made to adapt to Objective C...

/*
   A C-program for MT19937, with initialization improved 2002/2/10.
   Coded by Takuji Nishimura and Makoto Matsumoto.
   This is a faster version by taking Shawn Cokus's optimization,
   Matthe Bellew's simplification, Isaku Wada's real version.

   Before using, initialize the state by using init_genrand(seed)
   or init_by_array(init_key, key_length).

   Copyright (C) 1997 - 2002, Makoto Matsumoto and Takuji Nishimura,
   All rights reserved.

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions
   are met:

     1. Redistributions of source code must retain the above copyright
        notice, this list of conditions and the following disclaimer.

     2. Redistributions in binary form must reproduce the above copyright
        notice, this list of conditions and the following disclaimer in the
        documentation and/or other materials provided with the distribution.

     3. The names of its contributors may not be used to endorse or promote
        products derived from this software without specific prior written
        permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
   A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


   Any feedback is very welcome.
   http://www.math.keio.ac.jp/matumoto/emt.html
   email: matumoto@math.keio.ac.jp
*/

////////////////// Macros for the Mersenne Twister random generator...
/* Period parameters */  
#define MATRIX_A 0x9908b0dfUL   /* constant vector a */
#define UMASK 0x80000000UL /* most significant w-r bits */
#define LMASK 0x7fffffffUL /* least significant r bits */
#define MIXBITS(u,v) ( ((u) & UMASK) | ((v) & LMASK) )
#define TWIST(u,v) ((MIXBITS(u,v) >> 1) ^ ((v)&1UL ? MATRIX_A : 0UL))
/////////////////////////////////////////////////////////// That's it.

+(void)setSeed: (unsigned long)aSeed
{
  int j;

  T4RandomInitialSeed = aSeed;
  T4RandomState[0]= T4RandomInitialSeed & 0xffffffffUL;
  for(j = 1; j < T4RandomN; j++)
  {
    T4RandomState[j] = (1812433253UL * (T4RandomState[j-1] ^ (T4RandomState[j-1] >> 30)) + j); 
    /* See Knuth TAOCP Vol2. 3rd Ed. P.106 for multiplier. */
    /* In the previous versions, mSBs of the seed affect   */
    /* only mSBs of the array state[].                        */
    /* 2002/01/09 modified by makoto matsumoto             */
    T4RandomState[j] &= 0xffffffffUL;  /* for >32 bit machines */
  }
  T4RandomLeft = 1;
  T4RandomInitf = 1;
}

+(unsigned long)initialSeed
{
  if(T4RandomInitf == 0)
  {
    T4Warning(@"Random: initializing the random generator");
    [self setRandomSeed];
  }

  return T4RandomInitialSeed;
}

+(void)nextState
{
  unsigned long *p = T4RandomState;
  int j;

  /* if init_genrand() has not been called, */
  /* a default initial seed is used         */
  if(T4RandomInitf == 0)
    [self setRandomSeed];
//    manualSeed(5489UL);

  T4RandomLeft = T4RandomN;
  T4RandomNext = T4RandomState;
    
  for(j = T4RandomN-T4RandomM+1; --j; p++) 
    *p = p[T4RandomM] ^ TWIST(p[0], p[1]);

  for(j = T4RandomM; --j; p++) 
    *p = p[T4RandomM-T4RandomN] ^ TWIST(p[0], p[1]);

  *p = p[T4RandomM-T4RandomN] ^ TWIST(p[0], T4RandomState[0]);
}

+(unsigned long)random
{
  unsigned long y;

  if (--T4RandomLeft == 0)
    [self nextState];

  y = *T4RandomNext++;
  
  /* Tempering */
  y ^= (y >> 11);
  y ^= (y << 7) & 0x9d2c5680UL;
  y ^= (y << 15) & 0xefc60000UL;
  y ^= (y >> 18);

  return y;
}

/* generates a random number on [0,1)-real-interval */
+(real)uniform
{
  unsigned long y;

  if(--T4RandomLeft == 0)
    [self nextState];
  y = *T4RandomNext++;

  /* Tempering */
  y ^= (y >> 11);
  y ^= (y << 7) & 0x9d2c5680UL;
  y ^= (y << 15) & 0xefc60000UL;
  y ^= (y >> 18);
  
  return (real)y * (1.0/4294967296.0); 
  /* divided by 2^32 */
}

///
/// Thanks *a lot* Takuji Nishimura and Makoto Matsumoto!
///
/////////////////////////////////////////////////////////////////////
//// Now my own code...

+(void)getArrayOfShuffledIndices: (int*)indices capacity: (int)aCapacity
{
  int i;

  for(i = 0; i < aCapacity; i++)
    indices[i] = i;
  
  [self shuffleArray: indices capacity: aCapacity elementCapacity: sizeof(int)];
}

+(void)shuffleArray: (void*)anArray capacity: (int)aCapacity elementCapacity: (int)anElementCapacity
{
  void *save = [T4Allocator sysAllocWithCapacity: anElementCapacity];
  char *tab = (char *)anArray;
  int i;

  for(i = 0; i < aCapacity-1; i++)
  {
    int z = [self random] % (aCapacity-i);
    memcpy(save, tab+i*anElementCapacity, anElementCapacity);
    memmove(tab+i*anElementCapacity, tab+(z+i)*anElementCapacity, anElementCapacity);
    memcpy(tab+(z+i)*anElementCapacity, save, anElementCapacity);
  }
  
  [T4Allocator sysFree: save];
}

+(real)uniformBoundedWith: (real)a and: (real)b
{
  return([self uniform] * (b - a) + a);
}

+(real)normalWithMean: (real)mean deviation: (real)stdv
{
  if(!T4RandomNormalIsValid)
  {
    T4RandomNormalX = [self uniform];
    T4RandomNormalY = [self uniform];
    T4RandomNormalRho = sqrt(-2. * log(1.0-T4RandomNormalY));
    T4RandomNormalIsValid = YES;
  }
  else
    T4RandomNormalIsValid = NO;
  
  if(T4RandomNormalIsValid)
    return T4RandomNormalRho*cos(2.*M_PI*T4RandomNormalX)*stdv+mean;
  else
    return T4RandomNormalRho*sin(2.*M_PI*T4RandomNormalX)*stdv+mean;
}

+(real)normal
{
  return [self normalWithMean: 0 deviation: 1];
}

+(real)exponential: (real)lambda
{
  return(-1. / lambda * log(1-[self uniform]));
}

+(real)cauchyWithMedian: (real)median sigma: (real)sigma
{
  return(median + sigma * tan(M_PI*([self uniform]-0.5)));
}

// Faut etre malade pour utiliser ca.
// M'enfin.
+(real)logNormalWithMean: (real)mean deviation: (real)stdv
{
  real zm = mean*mean;
  real zs = stdv*stdv;
  return(exp([self normalWithMean: log(zm/sqrt(zs + zm)) deviation: sqrt(log(zs/zm+1))]));
}

+(int)geometric: (real)p
{
  return((int)(log(1-[self uniform]) / log(p)) + 1);
}

+(BOOL)bernoulli: (real)p
{
  return([self uniform] <= p);
}

@end
