#import "T4CommandLine.h"
#import "T4Matrix.h"

#import "T4AsciiLoader.h"
#import "T4AsciiSaver.h"

#import "T4BinaryLoader.h"
#import "T4BinarySaver.h"

int main( int argc, char *argv[] )
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSString *inputFormat, *outputFormat, *inputFileName, *outputFileName;

  BOOL iatranspose, iaautodetect;
  int iamaxload;

  BOOL ibtranspose, ibfloat, ibdouble;
  int ibmaxload;

  BOOL oatranspose, oaheader;
  
  BOOL obtranspose, obfloat, obdouble;

  // command line ----------------------------------------------------------------------------------

  T4CommandLine *cmdLine = [[[T4CommandLine alloc] initWithArgv: argv argc: argc] autorelease];

  [cmdLine addStringArgument: @"input format" at: &inputFormat help: @"input format"];
  [cmdLine addStringArgument: @"output format" at: &outputFormat help: @"output format"];
  [cmdLine addStringArgument: @"input file" at: &inputFileName help: @"input file"];
  [cmdLine addStringArgument: @"output file" at: &outputFileName help: @"output file"];

  [cmdLine addText: @"\n where <format> can be <ascii> or <binary>\n"];
  [cmdLine addText: @"\nInput Options:"];
  [cmdLine addText: @"--------------\n"];
  [cmdLine addText: @" * ascii:\n"];
  [cmdLine addBoolOption: @"-iaNoTranspose" at: &iatranspose default: YES help: @"do not transpose"];
  [cmdLine addBoolOption: @"-iaNoAutodetect" at: &iaautodetect default: YES help: @"do not autodected size"];
  [cmdLine addIntOption: @"-iaMaxLoad" at: &iamaxload default: -1 help: @"maximum number of columns to load"];

  [cmdLine addText: @"\n * binary:\n"];
  [cmdLine addBoolOption: @"-ibNoTranspose" at: &ibtranspose default: YES help: @"do not transpose"];
  [cmdLine addBoolOption: @"-ibFloat" at: &ibfloat default: NO help: @"enforces float encoding"];
  [cmdLine addBoolOption: @"-ibDouble" at: &ibdouble default: NO help: @"enforces double encoding"];
  [cmdLine addIntOption: @"-ibMaxLoad" at: &ibmaxload default: -1 help: @"maximum number of columns to load"];

  [cmdLine addText: @"\nOuput Options:"];
  [cmdLine addText: @"--------------\n"];
  [cmdLine addText: @" * ascii:\n"];
  [cmdLine addBoolOption: @"-oaNoTranspose" at: &oatranspose default: YES help: @"do not transpose"];
  [cmdLine addBoolOption: @"-oaHeader" at: &oaheader default: NO help: @"add the header"];

  [cmdLine addText: @"\n * binary:\n"];
  [cmdLine addBoolOption: @"-obNoTranspose" at: &obtranspose default: YES help: @"do not transpose"];
  [cmdLine addBoolOption: @"-obFloat" at: &obfloat default: NO help: @"enforces float encoding"];
  [cmdLine addBoolOption: @"-obDouble" at: &obdouble default: NO help: @"enforces double encoding"];

  [cmdLine addText: @"\n"];
  [cmdLine read];

  // read the matrix -------------------------------------------------------------------------------

  T4Matrix *matrix = nil;

  if([inputFormat isEqualToString: @"ascii"])
  {
    T4AsciiLoader *loader = [[T4AsciiLoader alloc] init];
    [loader setTransposesMatrix: iatranspose];
    [loader setAutodetectsSize: iaautodetect];
    [loader setMaxNumberOfColumns: iamaxload];
    matrix = [loader loadMatrixAtPath: inputFileName];
    [loader release];
  }
  else if([inputFormat isEqualToString: @"binary"])
  {
    T4BinaryLoader *loader = [[T4BinaryLoader alloc] init];
    [loader setTransposesMatrix: ibtranspose];

    if(ibfloat && ibdouble)
      T4Error(@"Input binary format error: cannot select both float and double encoding");
    
    if(ibfloat)
      [loader setEnforcesFloatEncoding: ibfloat];
    if(ibdouble)
      [loader setEnforcesDoubleEncoding: ibdouble];

    [loader setMaxNumberOfColumns: iamaxload];
    matrix = [loader loadMatrixAtPath: inputFileName];
    [loader release];    
  }
  else
    T4Error(@"Wrong input format <%@>", inputFormat);

  // save the matrix -------------------------------------------------------------------------------

  T4Message(@"Saving the matrix...");

  if([outputFormat isEqualToString: @"ascii"])
  {
    T4AsciiSaver *saver = [[T4AsciiSaver alloc] init];
    [saver setTransposesMatrix: oatranspose];
    [saver setWritesHeader: oaheader];
    [saver saveMatrix: matrix atPath: outputFileName];
    [saver release];
  }
  else if([outputFormat isEqualToString: @"binary"])
  {
    T4BinarySaver *saver = [[T4BinarySaver alloc] init];
    [saver setTransposesMatrix: obtranspose];

    if(obfloat && obdouble)
      T4Error(@"Output binary format error: cannot select both float and double encoding");
    
    if(obfloat)
      [saver setEnforcesFloatEncoding: obfloat];
    if(obdouble)
      [saver setEnforcesDoubleEncoding: obdouble];

    [saver saveMatrix: matrix atPath: outputFileName];
    [saver release];    
  }
  else
    T4Error(@"Wrong output format <%@>", outputFormat);

  T4Message(@"...done.");

  [pool release];

  return 0;
}
