#import "T4MultiCriterion.h"

@implementation T4MultiCriterion

-initWithCriterions: (NSArray*)someCriterions weights: (real*)someWeights
{
  int numCriterions = [someCriterions count];
  int aNumInputs = -1;
  int i;

  for(i = 0; i < numCriterions; i++)
  {
    int currentNumInputs = [[criterions objectAtIndex: i] numberOfInputs];

    if(aNumInputs > 0)
    {
      if(aNumInputs != currentNumInputs)
        T4Error(@"MultiCriterion: criteria do not have the same input size!!!");
    }
    else
      aNumInputs = currentNumInputs;
  }
  
  if( (self = [super initWithNumberOfInputs: aNumInputs]) )
  {
    criterions = someCriterions;
    weights = [allocator allocRealArrayWithCapacity: numCriterions];

    if(someWeights)
    {
      for(i = 0; i < numCriterions; i++)
        weights[i] = someWeights[i];
    }
    else
    {
      for(i = 0; i < numCriterions; i++)
        weights[i] = 1.;
    }

    [allocator retainAndKeepObject: criterions];
  }

  return self;
}

-setDataset: (NSArray*)aDataset
{
  int numCriterions = [criterions count];
  int i;

  dataset = aDataset;
  for(i = 0; i < numCriterions; i++)
    [[criterions objectAtIndex: i] setDataset: aDataset];

  return self;
}


-(real)forwardExampleAtIndex: (int)anIndex inputs: (T4Matrix*)someInputs
{
  int numCriterions = [criterions count];
  int i;

  output = 0;
  for(i = 0; i < numCriterions; i++)
    output += weights[i] * [[criterions objectAtIndex: i] forwardExampleAtIndex: anIndex inputs: someInputs];

  return output;
}

-(T4Matrix*)backwardExampleAtIndex: (int)anIndex inputs: (T4Matrix*)someInputs
{
  int numColumns = [someInputs numberOfColumns];
  int numCriterions = [criterions count];
  int i;

  [gradInputs resizeWithNumberOfColumns: numColumns];
  [gradInputs zero];

  for(i = 0; i < numCriterions; i++)
  {
    T4Criterion *criterion = [criterions objectAtIndex: i];
    [criterion backwardExampleAtIndex: anIndex inputs: someInputs];
    [gradInputs addValue: weights[i] dotMatrix: [criterion gradInputs]];
  }

  return gradInputs;
}

-initWithCoder: (NSCoder*)aCoder
{
  self = [super initWithCoder: aCoder];

  criterions = [[aCoder decodeObject] retainAndKeepWithAllocator: allocator];
  weights = [allocator allocRealArrayWithCapacity: [criterions count]];
  [aCoder decodeArrayOfObjCType: @encode(real) count: [criterions count] at: weights];

  return self;
}

-(void)encodeWithCoder: (NSCoder*)aCoder
{
  [super encodeWithCoder: aCoder];
  [aCoder encodeObject: criterions];
  [aCoder encodeArrayOfObjCType: @encode(real) count: [criterions count] at: weights];
}


@end
