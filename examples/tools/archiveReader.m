#import "T4CommandLine.h"

int main( int argc, char *argv[] )
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSString *modelFileName;

  // command line ----------------------------------------------------------------------------------

  T4CommandLine *cmdLine = [[[T4CommandLine alloc] initWithArgv: argv argc: argc] autorelease];

  [cmdLine addStringArgument: @"file" at: &modelFileName help: @"a model file"];

  [cmdLine addText: @"\n"];
  [cmdLine read];

  // archive ---------------------------------------------------------------------------------------

  NSMutableData *modelData = [[NSData alloc] initWithContentsOfFile: modelFileName];
  NSUnarchiver *archiver = [[[NSUnarchiver alloc] initForReadingWithData: modelData] autorelease];
  [modelData release];

  while(![archiver isAtEnd])
  {
    T4Print(@"%@\n", [archiver decodeObject]);
  }

  [pool release];

  return 0;
}
