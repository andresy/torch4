#import "T4DiskFile.h"

#define T4FileStringChunkSizeForReading 32

BOOL T4FileUsesNativeEncoding = YES;

@implementation T4DiskFile

// Endian stuff ///////////////////////////////////////////////////////

void T4FileReverseMemory(void *data, int blockSize, int numBlocks)
{
  if(blockSize != 1)
  {
    int halfBlockSize = blockSize/2;
    char *charData = (char*)data;
    int i, b;

    for(b = 0; b < numBlocks; b++)
    {
      for(i = 0; i < halfBlockSize; i++)
      {
        char z = charData[i];
        charData[i] = charData[blockSize-1-i];
        charData[blockSize-1-i] = z;
      }
      charData += blockSize;
    }
  }
}

//-----

+(BOOL)isLittleEndianProcessor
{
  int x = 7;
  char *ptr = (char *)&x;

  if(ptr[0] == 0)
    return NO;
  else
    return YES;
}

+(BOOL)isBigEndianProcessor
{
  return(![self isLittleEndianProcessor]);
}

+(BOOL)isUsingNativeEncoding
{
  return T4FileUsesNativeEncoding;
}

+(void)setUsesNativeEncoding
{
  T4FileUsesNativeEncoding = YES;
}

+(void)setUsesLittleEndianEncoding
{
  if([self isLittleEndianProcessor])
    T4FileUsesNativeEncoding = YES;
  else
    T4FileUsesNativeEncoding = NO;
}

+(void)setUsesBigEndianEncoding
{
  if([self isBigEndianProcessor])
    T4FileUsesNativeEncoding = YES;
  else
    T4FileUsesNativeEncoding = NO;
}

// End of endian stuff ////////////////////////////////////////////////


-initWithStream: (FILE*)aFile attributes: (int)someAttributes
{
  if( (self = [super init]) )
  {
    fileAttributes = someAttributes;
    file = aFile;
  }

  return self;
}

-initForReadingAtPath: (NSString*)aPath
{
  FILE *aFile;

  if([aPath length] > 3)
  {
    const char *cPath = [aPath cString];
    if(!strcmp(cPath+strlen(cPath)-3, ".gz"))
    {
      NSMutableString *cmdLine = [[NSMutableString alloc] initWithString: @"zcat "];
      [cmdLine appendString: aPath];
      
      aFile = fopen([aPath cString], "r");
      if(!aFile)
        T4Error(@"DiskFile: cannot open the file <%@> for reading!!!", aPath);
      fclose(aFile);
      
      self = [self initForReadingWithPipe: cmdLine];
      [cmdLine release];   
      return self;
    }
  }

  aFile = fopen([aPath cString], "r");
  if(!aFile)
    T4Error(@"DiskFile: cannot open <%@> for reading!!!", aPath);
  
  return [self initWithStream: aFile attributes: T4FileIsReadable];
}

-initForWritingAtPath: (NSString*)aPath
{
  FILE *aFile = fopen([aPath cString], "w");
  if(!aFile)
    T4Error(@"DiskFile: cannot open <%s> for writing!!!", [aPath cString]);

  return [self initWithStream: aFile attributes: T4FileIsWritable];

}

-initForWritingWithPipe: (NSString*)aPipeCommand
{
  FILE *aFile = popen([aPipeCommand cString], "w");
  if(!aFile)
    T4Error(@"DiskFile: cannot open the pipe <%@> for writing!!!", aPipeCommand);

  return [self initWithStream: aFile attributes: T4FileIsWritable | T4FileIsAPipe];
}

-initForReadingWithPipe: (NSString*)aPipeCommand
{
  FILE *aFile = popen([aPipeCommand cString], "r");
  if(!aFile)
    T4Error(@"DiskFile: cannot open the pipe <%@> for reading!!!", aPipeCommand);

  return [self initWithStream: aFile attributes: T4FileIsReadable | T4FileIsAPipe];
}

-(int)read: (void*)someData blockSize: (int)aBlockSize numberOfBlocs: (int)aNumBlocks
{
  int result;

  if( !(fileAttributes & T4FileIsReadable) )
    T4Error(@"DiskFile: file not readable");

  result = fread(someData, aBlockSize, aNumBlocks, file);

  if(!T4FileUsesNativeEncoding)
    T4FileReverseMemory(someData, aBlockSize, aNumBlocks);
  
  return(result);
}

-(int)write: (void*)someData blockSize: (int)aBlockSize numberOfBlocs: (int)aNumBlocks
{
  int result;

  if( !(fileAttributes & T4FileIsWritable) )
    T4Error(@"DiskFile: file not writable");

  if(!T4FileUsesNativeEncoding)
    T4FileReverseMemory(someData, aBlockSize, aNumBlocks);

  result = fwrite(someData, aBlockSize, aNumBlocks, file);

  if(!T4FileUsesNativeEncoding)
    T4FileReverseMemory(someData, aBlockSize, aNumBlocks);
  
  return(result);
}

-(BOOL)isEndOfFile
{
  if( !(fileAttributes & T4FileIsReadable) )
    T4Error(@"DiskFile: file is non-readable");

  if(feof(file))
    return YES;
  else
    return NO;
}

-(void)synchronizeFile
{
  if( !(fileAttributes & T4FileIsWritable) )
    T4Error(@"DiskFile: cannot synchronize a non-writable file");

  if(fflush(file))
    T4Error(@"DiskFile: cannot flush file");
}

-(void)seekToFileOffset: (unsigned long long)anOffset
{
  if(fseek(file, (long)anOffset, SEEK_SET))
    T4Error(@"DiskFile: cannot seek in the file");
}

-(unsigned long long)offsetInFile
{
  return((unsigned long long)ftell(file));
}

-(unsigned long long)seekToEndOfFile
{
  if(fseek(file, 0L, SEEK_END))
    T4Error(@"DiskFile: cannot seek in the file");

  return [self offsetInFile];
}

-(void)seekToBeginningOfFile
{
  if(fseek(file, 0L, SEEK_SET))
    T4Error(@"DiskFile: cannot seek in the file");
}

-(void)writeStringWithFormat: (NSString*)aFormat, ...
{
  NSString *stringToWrite;
  va_list arguments;
  const char *theCharString;
  int theCharStringLength;
  int result;

  if( !(fileAttributes & T4FileIsWritable) )
    T4Error(@"DiskFile: attempt to write in a non-writable file");

  va_start(arguments, aFormat);
  stringToWrite = [[NSString alloc] initWithFormat: aFormat arguments: arguments];

  theCharString = [stringToWrite cString];
  theCharStringLength = strlen(theCharString);

  result = fwrite(theCharString, 1, theCharStringLength, file);

  if(result != theCharStringLength)
    T4Error(@"DiskFile: error while writing");

  [stringToWrite release];
}

-(BOOL)readStringWithFormat: (NSString*)aFormat into: (void*)aPtr
{
  int result;

  if( !(fileAttributes & T4FileIsReadable) )
    T4Error(@"DiskFile: attempt to read a non-readable file");

  result = fscanf(file, [aFormat cString], aPtr);
  
  return(result == 1);
}

-(NSString*)stringToEndOfLine
{
  long startingPosition = ftell(file);
  int stringSize = 0;
  BOOL endOfReading = NO;
  char *stringBuffer = NULL;

  if( !(fileAttributes & T4FileIsReadable) )
    T4Error(@"DiskFile: attempt to read a non-readable file");

  while(!endOfReading)
  {
    int numByteRead;
    int i;

    stringBuffer = [T4Allocator sysReallocCharArray: stringBuffer
                                withCapacity: stringSize + T4FileStringChunkSizeForReading/* + 1*/];

    numByteRead = fread(stringBuffer+stringSize, 1, T4FileStringChunkSizeForReading, file);

    for(i = 0; i < numByteRead; i++)
    {
      if(stringBuffer[stringSize++] == '\n')
      {
        endOfReading = YES;
        break;
      }
    }

    if(numByteRead < T4FileStringChunkSizeForReading)
      endOfReading = YES;
  }

  if(stringSize > 0)
  {
    if(fseek(file, startingPosition+(long)stringSize, SEEK_SET))
      T4Error(@"DiskFile: cannot seek in the file");
//  stringBuffer[stringSize] = '\0';

    return [[[NSString alloc] initWithCStringNoCopy: stringBuffer length: stringSize freeWhenDone: YES] autorelease];
  }
  else
    return nil;
}

-(int)fileDescriptor
{
  return(fileno(file));
}

-(FILE*)fileStream
{
  return(file);
}

-(void)dealloc
{
  if(fileAttributes & T4FileIsAPipe)
    pclose(file);
  else
    fclose(file);

  [super dealloc];
}

@end
