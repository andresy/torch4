#import "T4Measurer.h"

@implementation T4Measurer
{
    NSFileHandle *file;
    NSArray *dataset;
}

-initWithDataset: (NSArray*)aDataset file: (NSFileHandle*)aFile
{
  if( (self = [super init]) )
  {
    dataset = aDataset;
    file = aFile;
    [allocator retainAndKeepObject: aDataset];
    [allocator retainAndKeepObject: aFile];
  }
  return self;
}

-initWithDataset: (NSArray*)aDataset path: (NSString*)aPath
{
  NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath: aPath];
  return [self initWithDataset: aDataset file: fileHandle];
}

-(void)measureExample: (int)anIndex
{
}

-(void)measureIteration: (int)anIteration
{
}

-(void)measureEnd
{
}

-(void)reset
{
}

-(NSArray*)dataset
{
  return dataset;
}

@end
