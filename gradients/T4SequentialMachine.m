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
  [machines addObject: aMachine];

  if([machines count] == 1)
  {
    gradInputs = [aMachine gradInputs];
    numInputs = [aMachine numberOfInputs];
  }

  outputs = [aMachine outputs];
  numOutputs = [aMachine numberOfOutputs];

  [parameters addObjectsFromArray: [aMachine parameters]];
  [gradParameters addObjectsFromArray: [aMachine gradParameters]];

  return self;
}


-(T4Matrix*)forwardMatrix: (T4Matrix*)anInputMatrix
{
  int numMachines = [machines count];
  T4Matrix *currentOutputs;
  int i;
  
  currentOutputs = anInputMatrix;
  for(i = 0; i < numMachines; i++)
    currentOutputs = [[machines objectAtIndex: i] forwardMatrix: currentOutputs];

  return currentOutputs;
}

-(T4Matrix*)backwardMatrix: (T4Matrix*)gradOutputMatrix inputs: (T4Matrix*)anInputMatrix
{
  T4GradientMachine *currentMachine, *previousMachine;
  int numMachines = [machines count];
  T4Matrix *currentGradOutputs;
  int i;

  currentGradOutputs = gradOutputMatrix;
  currentMachine = [machines lastObject];

  for(i = numMachines-2; i >= 0; i--)
  {
    previousMachine = [machines objectAtIndex: i];
    currentGradOutputs = [currentMachine backwardMatrix: currentGradOutputs inputs: [previousMachine outputs]];
    currentMachine = previousMachine;
  }

  currentGradOutputs = [currentMachine backwardMatrix: currentGradOutputs inputs: anInputMatrix];

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

@end
