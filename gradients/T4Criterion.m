#import "T4Criterion.h"

@implementation T4Criterion

-initWithNumberOfInputs: (int)aNumInputs
{
  if( (self = [super init]) )
  {
    dataset = nil;
    output = 0;
    numInputs = aNumInputs;
    gradInputs = [[T4Matrix alloc] initWithNumberOfRows: numInputs];
  }

  return self;
}

-(real)forwardMatrix: (T4Matrix*)aMatrix
{
  return 0.;
}

-(T4Matrix*)backwardExampleAtIndex: (int)anIndex inputs: (T4Matrix*)anInputMatrix
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

@end
