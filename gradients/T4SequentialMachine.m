#import "T4SequentialMachine.h"

@implementation T4SequentialMachine

-init
{
  if( (self = [super initWithNumberOfInputs: 0 numberOfOutputs: 0
                     numberOfParameters: 0]) )
  {
    machines = [[[NSMutableArray alloc] init] keepWithAllocator: allocator];
  }

  return self;
}

-addMachine: (T4GradientMachine*)aMachine
{
  if([machines count] == 0)
  {
    gradInputs = [aMachine gradInputs];
    numInputs = [aMachine numberOfInputs];
  }
  else
  {
    if([aMachine numberOfInputs] != numOutputs)
      T4Error(@"SequentialMachine: machines <%@> and <%@> have incompatible number of outputs [%d] and inputs [%d]", 
              [[machines lastObject] class], [aMachine class], numOutputs, [aMachine numberOfInputs]);
  }

  [machines addObject: aMachine];

  outputs = [aMachine outputs];
  numOutputs = [aMachine numberOfOutputs];

  [parameters addObjectsFromArray: [aMachine parameters]];
  [gradParameters addObjectsFromArray: [aMachine gradParameters]];

  return self;
}


-(T4Matrix*)forwardMatrix: (T4Matrix*)someInputs
{
  int numMachines = [machines count];
  T4Matrix *currentOutputs;
  int i;
  
  currentOutputs = someInputs;
  for(i = 0; i < numMachines; i++)
    currentOutputs = [[machines objectAtIndex: i] forwardMatrix: currentOutputs];

  return currentOutputs;
}

-(T4Matrix*)backwardMatrix: (T4Matrix*)someGradOutputs inputs: (T4Matrix*)someInputs
{
  T4GradientMachine *currentMachine, *previousMachine;
  int numMachines = [machines count];
  T4Matrix *currentGradOutputs;
  int i;

  currentGradOutputs = someGradOutputs;
  currentMachine = [machines lastObject];

  for(i = numMachines-2; i >= 0; i--)
  {
    previousMachine = [machines objectAtIndex: i];
    currentGradOutputs = [currentMachine backwardMatrix: currentGradOutputs inputs: [previousMachine outputs]];
    currentMachine = previousMachine;
  }

  currentGradOutputs = [currentMachine backwardMatrix: currentGradOutputs inputs: someInputs];

  return currentGradOutputs;
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
  partialBackpropagation = aFlag;
  [[machines objectAtIndex: 0] setPartialBackpropagation: aFlag];
  return self;
}

-(NSArray*)machines
{
  return machines;
}

@end
