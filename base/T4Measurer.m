#import "T4Measurer.h"

@implementation T4Measurer

-initWithDataset: (NSArray*)aDataset file: (T4File*)aFile
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

-measureExampleAtIndex: (int)anIndex
{
  return self;
}

-measureAtIteration: (int)anIteration
{
  return self;
}

-measureAtEnd
{
  return self;
}

-reset
{
  return self;
}

-(NSArray*)dataset
{
  return dataset;
}

@end
