#import "T4ObjectMeasurer.h"

@implementation T4ObjectMeasurer

-initWithObject: (id)anObject dataset: (NSArray*)aDataset file: (T4File*)aFile
{
 if( (self = [super initWithDataset: aDataset file: aFile]) )
  {
    object = anObject;

    [self setMeasuresAtEachExample];
    [allocator retainAndKeepObject: object];
  }

  return self;
}

-setMeasuresAtEachIteration
{
  measuresAtEachExample = NO;
  measuresAtEachIteration = YES;
  measuresAtEnd = NO;
  return self;
}

-setMeasuresAtEachExample
{
  measuresAtEachExample = YES;
  measuresAtEachIteration = NO;
  measuresAtEnd = NO;
  return self;
}

-setMeasuresAtEnd
{
  measuresAtEachExample = NO;
  measuresAtEachIteration = NO;
  measuresAtEnd = YES;
  return self;
}

-measureExampleAtIndex: (int)anIndex
{
  if(measuresAtEachExample)
    [file writeStringWithFormat: @"%@\n", object];
  return self;
}
-measureAtIteration: (int)anIteration
{
  if(measuresAtEachIteration)
    [file writeStringWithFormat: @"%@\n", object];
  return self;
}

-measureAtEnd
{
  if(measuresAtEnd)
    [file writeStringWithFormat: @"%@\n", object];
  return self;
}

@end
