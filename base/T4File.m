#import "T4File.h"

@implementation T4File

-(int)read: (void*)someData blockSize: (int)aBlockSize numberOfBlocs: (int)aNumBlocks
{
  [self subclassResponsibility: _cmd];
  return 0;
}

-(int)write: (void*)someData blockSize: (int)aBlockSize numberOfBlocs: (int)aNumBlocks
{
  [self subclassResponsibility: _cmd];
  return 0;
}

-(BOOL)isEndOfFile
{
  [self subclassResponsibility: _cmd];
  return NO;
}

-(void)synchronizeFile
{
  [self subclassResponsibility: _cmd];
}

-(void)seekToFileOffset: (unsigned long long)anOffset
{
  [self subclassResponsibility: _cmd];
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

-(void)seekToBeginningOfFile
{
  [self subclassResponsibility: _cmd];
}

-(void)writeStringWithFormat: (NSString*)aFormat, ...
{
  [self subclassResponsibility: _cmd];
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

@end
