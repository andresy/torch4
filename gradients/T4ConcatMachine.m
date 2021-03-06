#import "T4ConcatMachine.h"

@implementation T4ConcatMachine

-init
{
  if( (self = [super initWithNumberOfInputs: 0 numberOfOutputs: 0
                     numberOfParameters: 0]) )
  {
    machines = [[[NSMutableArray alloc] init] keepWithAllocator: allocator];
    outputs = [[[T4Matrix alloc] init] keepWithAllocator: allocator];
    gradInputs = [[[T4Matrix alloc] init] keepWithAllocator: allocator];
    gradOutputs = [[[T4Matrix alloc] init] keepWithAllocator: allocator];
    numOutputs = 0;
    offsets = NULL;
  }

  return self;
}

-addMachine: (T4GradientMachine*)aMachine
{
  if([machines count] == 0)
  {
    numInputs = [aMachine numberOfInputs];
    [gradInputs resizeWithNumberOfRows: numInputs];
  }
  else
  {
    if([aMachine numberOfInputs] != numInputs)
      T4Error(@"ConcatMachine: machines <%@> and <%@> have incompatible number of inputs [%d] inputs [%d]", 
              [[machines lastObject] class], [aMachine class], numInputs, [aMachine numberOfInputs]);
  }

  [machines addObject: aMachine];

  offsets = [allocator reallocIntArray: offsets withCapacity: [machines count]];
  offsets[[machines count]-1] = numOutputs;

  numOutputs += [aMachine numberOfOutputs];
  [outputs resizeWithNumberOfRows: numOutputs];

  [parameters addObjectsFromArray: [aMachine parameters]];
  [gradParameters addObjectsFromArray: [aMachine gradParameters]];

  return self;
}


-(T4Matrix*)forwardInputs: (T4Matrix*)someInputs
{
  int numMachines = [machines count];
  T4Matrix *currentOutputs;
  real *outputData = NULL;
  int outputStride = 0;
  int i;
  
  for(i = 0; i < numMachines; i++)
  {
    currentOutputs = [[machines objectAtIndex: i] forwardInputs: someInputs];

    if(i == 0)
    {
      [outputs resizeWithNumberOfColumns: [currentOutputs numberOfColumns]];
      outputData = [outputs firstColumn];
      outputStride = [outputs stride];
    }

    [currentOutputs copyToRealArray: outputData+offsets[i] stride: outputStride];
  }

  return outputs;
}

-(T4Matrix*)backwardGradOutputs: (T4Matrix*)someGradOutputs inputs: (T4Matrix*)someInputs
{
  T4GradientMachine *currentMachine;
  int numMachines = [machines count];
  T4Matrix *currentGradInputs;
  real *gradOutputData = [someGradOutputs firstColumn];
  int gradOutputNumColumns = [someGradOutputs numberOfColumns];
  int gradOutputStride = [someGradOutputs stride];
  int i;

  if(!partialBackpropagation)
    [gradInputs resizeWithNumberOfColumns: [someInputs numberOfColumns]];

  for(i = 0; i < numMachines; i++)
  {
    currentMachine = [machines objectAtIndex: i];

    [gradOutputs setMatrixFromRealArray: gradOutputData+offsets[i]
                 numberOfRows: [currentMachine numberOfOutputs]
                 numberOfColumns: gradOutputNumColumns
                 stride: gradOutputStride];

    currentGradInputs = [currentMachine backwardGradOutputs: gradOutputs inputs: someInputs];

    if(!partialBackpropagation)
    {
      if(i == 0)
        [gradInputs copyMatrix: currentGradInputs];
      else
        [gradInputs addMatrix: currentGradInputs];
    }
  }
  
  if(partialBackpropagation)
    return nil;
  else
    return gradInputs;
}

-reset
{
  int numMachines = [machines count];
  int i;

  for(i = 0; i < numMachines; i++)
    [[machines objectAtIndex: i] reset];

  return self;
}

-setPartialBackpropagation: (BOOL)aFlag
{
  int numMachines = [machines count];
  int i;

  partialBackpropagation = aFlag;

  for(i = 0; i < numMachines; i++)
    [[machines objectAtIndex: i] setPartialBackpropagation: aFlag];

  return self;
}

-(NSArray*)machines
{
  return machines;
}

-initWithCoder: (NSCoder*)aCoder
{
  self = [super initWithCoder: aCoder];
  machines = [[aCoder decodeObject] retainAndKeepWithAllocator: allocator];
  offsets = [allocator allocIntArrayWithCapacity: [machines count]];
  [aCoder decodeArrayOfObjCType: @encode(int) count: [machines count] at: offsets];
  gradOutputs = [[[T4Matrix alloc] init] keepWithAllocator: allocator];
  return self;
}

-(void)encodeWithCoder: (NSCoder*)aCoder
{
  [super encodeWithCoder: aCoder];
  [aCoder encodeObject: machines];
  [aCoder encodeArrayOfObjCType: @encode(int) count: [machines count] at: offsets];
}

@end
