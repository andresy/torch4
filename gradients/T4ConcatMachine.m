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
  [machines addObject: aMachine];

  if([machines count] == 1)
  {
    numInputs = [aMachine numberOfInputs];
    [gradInputs resizeWithNumberOfRows: numInputs];
  }
  else
  {
    if([aMachine numberOfInputs] != numInputs)
      T4Error(@"ConcatMachine: all machines must have the same number of inputs!!!");
  }

  offsets = [allocator reallocIntArray: offsets withCapacity: [machines count]];
  offsets[[machines count]-1] = numOutputs;

  numOutputs += [aMachine numberOfOutputs];
  [outputs resizeWithNumberOfRows: numOutputs];

  [parameters addObjectsFromArray: [aMachine parameters]];
  [gradParameters addObjectsFromArray: [aMachine gradParameters]];

  return self;
}


-(T4Matrix*)forwardMatrix: (T4Matrix*)anInputMatrix
{
  int numMachines = [machines count];
  T4Matrix *currentOutputs;
  real *outputData = NULL;
  int outputStride = 0;
  int i;
  
  for(i = 0; i < numMachines; i++)
  {
    currentOutputs = [[machines objectAtIndex: i] forwardMatrix: anInputMatrix];

    if(i == 0)
    {
      [outputs resizeWithNumberOfColumns: [currentOutputs numberOfColumns]];
      outputData = [outputs realData];
      outputStride = [outputs stride];
    }

    [currentOutputs copyToRealData: outputData+offsets[i] stride: outputStride];
  }

  return outputs;
}

-(T4Matrix*)backwardMatrix: (T4Matrix*)gradOutputMatrix inputs: (T4Matrix*)anInputMatrix
{
  T4GradientMachine *currentMachine;
  int numMachines = [machines count];
  T4Matrix *currentGradInputs;
  real *gradOutputData = [gradOutputMatrix realData];
  int gradOutputNumColumns = [gradOutputMatrix numberOfColumns];
  int gradOutputStride = [gradOutputMatrix stride];
  int i;

  [gradInputs resizeWithNumberOfColumns: [anInputMatrix numberOfColumns]];

  for(i = 0; i < numMachines; i++)
  {
    currentMachine = [machines objectAtIndex: i];

    [gradOutputs setMatrixFromRealData: gradOutputData+offsets[i]
                 numberOfRows: [currentMachine numberOfOutputs]
                 numberOfColumns: gradOutputNumColumns
                 stride: gradOutputStride];

    currentGradInputs = [currentMachine backwardMatrix: gradOutputs inputs: anInputMatrix];

    if(i == 0)
      [gradInputs copyMatrix: currentGradInputs];
    else
      [gradInputs addMatrix: currentGradInputs];
  }
  
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

  for(i = 0; i < numMachines; i++)
    [[machines objectAtIndex: i] setPartialBackpropagation: aFlag];

  return self;
}

-(NSArray*)machines
{
  return machines;
}

@end
