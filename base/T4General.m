#import "T4General.h"

void T4Error(NSString* msg, ...)
{
  NSString *message;
  va_list args;
  va_start(args,msg);
  message = [[NSString alloc] initWithFormat: msg arguments: args];
  printf("$ Error: %s\n", [message cString]);
  fflush(stdout);
  [message release];
  va_end(args);
  exit(-1);
}

void T4Warning(NSString* msg, ...)
{
  NSString *message;
  va_list args;
  va_start(args,msg);
  message = [[NSString alloc] initWithFormat: msg arguments: args];
  printf("! Warning: %s\n", [message cString]);
  fflush(stdout);
  [message release];
  va_end(args);
}

void T4Message(NSString* msg, ...)
{
  NSString *message;
  va_list args;
  va_start(args,msg);
  message = [[NSString alloc] initWithFormat: msg arguments: args];
  printf("# %s\n", [message cString]);
  fflush(stdout);
  [message release];
  va_end(args);
}

void T4Print(NSString* msg, ...)
{
  NSString *message;
  va_list args;
  va_start(args,msg);
  message = [[NSString alloc] initWithFormat: msg arguments: args];
  printf("%s", [message cString]);
  fflush(stdout);
  [message release];
  va_end(args);
}
