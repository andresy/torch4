#import "T4Criterion.h"

@implementation T4Criterion

-initWithNumberOfInputs: (int)aNumInputs
{
  if( (self = [super init]) )
  {
    dataset = nil;
    output = 0;
    numInputs = aNumInputs;
    gradInputs = [[[T4Matrix alloc] initWithNumberOfRows: numInputs] keepWithAllocator: allocator];
  }

  return self;
}

-(real)forwardExampleAtIndex: (int)anIndex inputs: (T4Matrix*)someInputs
{
  return 0.;
}

-(T4Matrix*)backwardExampleAtIndex: (int)anIndex inputs: (T4Matrix*)someInputs
{
  return nil;
}

-setDataset: (NSArray*)aDataset
{
  dataset = aDataset;
  return self;
}

-(real)output
{
  return output;
}

-(T4Matrix*)gradInputs
{
  return gradInputs;
}

-(int)numberOfInputs
{
  return numInputs;
}

-initWithCoder: (NSCoder*)aCoder
{
  self = [super initWithCoder: aCoder];

  [aCoder decodeValueOfObjCType: @encode(int) at: &numInputs];  
  [aCoder decodeValueOfObjCType: @encode(real) at: &output];
  gradInputs = [[aCoder decodeObject] retainAndKeepWithAllocator: allocator];
  dataset = nil;
  return self;
}

-(void)encodeWithCoder: (NSCoder*)aCoder
{
  [super encodeWithCoder: aCoder];
  [aCoder encodeValueOfObjCType: @encode(int) at: &numInputs];  
  [aCoder encodeValueOfObjCType: @encode(real) at: &output];
  [aCoder encodeObject: gradInputs];
}

@end
