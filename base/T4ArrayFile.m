#import "T4ArrayFile.h"

@implementation T4ArrayFile

-init
{
  if( (self = [super init]) )
  {
    contents = [[NSMutableArray alloc] init];
    [allocator keepObject: contents];
  }

  return self;
}

-(int)write: (void*)someData blockSize: (int)aBlockSize numberOfBlocs: (int)aNumBlocks
{
  NSData *dataToWrite = [[NSData alloc] initWithBytes: someData length: aBlockSize*aNumBlocks];
  [contents addObject: dataToWrite];
  [dataToWrite release];
  return aNumBlocks;
}

-writeStringWithFormat: (NSString*)aFormat, ...
{
  NSString *stringToWrite;
  va_list arguments;

  va_start(arguments, aFormat);
  stringToWrite = [[NSString alloc] initWithFormat: aFormat arguments: arguments];

  [contents addObject: stringToWrite];
  [stringToWrite release];
  return self;
}

-synchronizeFile
{
  return self;
}

-(NSArray*)arrayOfContents
{
  return contents;
}

@end
