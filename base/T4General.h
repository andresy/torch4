#ifdef USE_DOUBLE
#define INF DBL_MAX
#define REAL_EPSILON DBL_EPSILON
#define real double
#else
#define INF FLT_MAX
#define REAL_EPSILON FLT_EPSILON
#define real float
#endif

#import <Foundation/Foundation.h>
#import "T4NSCategories.h"
#import <stdio.h>
#import <stdlib.h>
#import <math.h>
#import <string.h>
#import <limits.h>
#import <stdarg.h>
#import <float.h>

// Old systems need that to define FLT_MAX and DBL_MAX
#ifndef DBL_MAX
#import <values.h>
#endif


/// Print an error message. The program will exit.
void T4Error(NSString* aMessage, ...);
/// Print a warning message.
void T4Warning(NSString* aMessage, ...);
/// Print a message.
void T4Message(NSString *aMessage, ...);
/// Like printf.
void T4Print(NSString *aMessage, ...);
