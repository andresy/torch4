#import "T4File.h"

@implementation T4File

-(int)readBlocksInto: (void*)someData blockSize: (int)aBlockSize numberOfBlocks: (int)aNumBlocks
{
  [self subclassResponsibility: _cmd];
  return 0;
}

-(int)writeBlocksFrom: (void*)someData blockSize: (int)aBlockSize numberOfBlocks: (int)aNumBlocks
{
  [self subclassResponsibility: _cmd];
  return 0;
}

-(BOOL)isEndOfFile
{
  [self subclassResponsibility: _cmd];
  return NO;
}

-synchronizeFile
{
  return [self subclassResponsibility: _cmd];
}

-seekToFileOffset: (unsigned long long)anOffset
{
  return [self subclassResponsibility: _cmd];
}

-(unsigned long long)offsetInFile
{
  [self subclassResponsibility: _cmd];
  return 0L;
}

-(unsigned long long)seekToEndOfFile
{
  [self subclassResponsibility: _cmd];
  return 0L;
}

-seekToBeginningOfFile
{
  return [self subclassResponsibility: _cmd];
}

-writeStringWithFormat: (NSString*)aFormat, ...
{
  return [self subclassResponsibility: _cmd];
}


-(BOOL)readStringWithFormat: (NSString*)aFormat into: (void*)aPtr
{
  [self subclassResponsibility: _cmd];
  return NO;
}

-(NSString*)stringToEndOfLine
{
  [self subclassResponsibility: _cmd];
  return nil;
}

-(int)fileDescriptor
{
  [self subclassResponsibility: _cmd];
  return -1;
}

@end
