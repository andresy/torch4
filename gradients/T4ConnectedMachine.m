#import "T4ConnectedMachine.h"

@implementation T4ConnectedNode

-initWithMachine: (T4GradientMachine*)aMachine
{
  if( (self = [super init]) )
  {
    machine = aMachine;
    inputMatrices = [[NSMutableArray alloc] init];
    gradOutputMatrices = [[NSMutableArray alloc] init];
    gradOutputMatrixOffsets = NULL;

    inputs = nil;
    gradOutputs = nil;
    directGradOutputs = nil;

    hasDirectInputConnection = YES;
    hasDirectOutputConnection = YES;
    hasAlmostDirectOutputConnection = YES;
  }
  
  return self;
}

-(void)setInputs: (T4Matrix*)aMatrix
{  
  if(hasDirectInputConnection)
    inputs = aMatrix;
  else
    T4Error(@"ConnectedMachine: internal error");
}

-(void)setGradOutputs: (T4Matrix*)aMatrix
{  
  if(hasDirectOutputConnection || hasAlmostDirectOutputConnection)
    directGradOutputs = aMatrix;
  else
    T4Error(@"ConnectedMachine: internal error");
}

-(int)currentNumberOfInputs
{
  T4Matrix *currentInputs;
  int numInputMatrices = [inputMatrices count];
  int numTotalInputs = 0;
  int i;

  for(i = 0; i < numInputMatrices; i++)
  {
    currentInputs = [inputMatrices objectAtIndex: i];
    numTotalInputs += [currentInputs numberOfRows];
  }

  return numTotalInputs;
}

-(void)check
{
  if([self currentNumberOfInputs] != [machine numberOfInputs])
    T4Error(@"ConnectedMachine: incorrect number of inputs for machine [%@] (%d instead of %d)", machine, [self currentNumberOfInputs], [machine numberOfInputs]);
}

-(void)addInputConnectionToMachine: (T4GradientMachine*)aMachine
{
  [inputMatrices addObject: [aMachine outputs]];
  
  if([inputMatrices count] == 1)
  {
    hasDirectInputConnection = YES;
    inputs = [aMachine outputs];
  }

  if([inputMatrices count] == 2)
  {
    hasDirectInputConnection = NO;
    inputs = [[T4Matrix alloc] initWithNumberOfRows: [machine numberOfInputs]];
  }
}

-(void)addOutputConnectionToMachine: (T4GradientMachine*)aMachine offset: (int)anOffset
{
  [gradOutputMatrices addObject: [aMachine gradInputs]];

  if([gradOutputMatrices count] == 1)
  {
    if([aMachine numberOfInputs] == [machine numberOfOutputs])
    {
      hasDirectOutputConnection = YES;
      hasAlmostDirectOutputConnection = NO;
      directGradOutputs = [aMachine gradInputs];
      gradOutputs = nil;
    }
    else
    {
      hasDirectOutputConnection = NO;
      hasAlmostDirectOutputConnection = YES;
      directGradOutputs = [aMachine gradInputs];
      gradOutputs = [[T4Matrix alloc] init];
    }    
  }
  
  if([gradOutputMatrices count] == 2)
  {
    hasDirectOutputConnection = NO;
    hasAlmostDirectOutputConnection = NO;
    directGradOutputs = nil;
    gradOutputs = [[T4Matrix alloc] initWithNumberOfRows: [machine numberOfOutputs]];
  }

  gradOutputMatrixOffsets = [allocator realloc: gradOutputMatrixOffsets intArrayWithCapacity: [gradOutputMatrices count]];
  gradOutputMatrixOffsets[[gradOutputMatrices count]-1] = anOffset;
}

-(void)directOutputConnectionWithOffset: (int)anOffset numberOfOutputs: (int)aNumOutputs
{
  if([gradOutputMatrices count])
    T4Error(@"ConnectedMachine: trying a direct output connection to a machine which has already output connections");

  if([machine numberOfOutputs] == aNumOutputs)
  {
    hasDirectOutputConnection = YES;
    hasAlmostDirectOutputConnection = NO;
    directGradOutputs = nil;
    gradOutputs = nil;
  }
  else
  {
    hasDirectOutputConnection = NO;
    hasAlmostDirectOutputConnection = YES;
    directGradOutputs = nil;
    gradOutputs = [[T4Matrix alloc] init];
  }

  gradOutputMatrixOffsets = [allocator realloc: gradOutputMatrixOffsets intArrayWithCapacity: 1];
  gradOutputMatrixOffsets[0] = anOffset;
}

-(void)forward
{
  // Connected to several machines
  if(!hasDirectInputConnection)
  {
    T4Matrix *currentInputs = [inputMatrices objectAtIndex: 0];    
    int numInputMatrices = [inputMatrices count];
    int offset = 0;
    int i;
    
    [inputs resizeWithNumberOfColumns: [currentInputs numberOfColumns]];
    for(i = 0; i < numInputMatrices; i++)
    {
      currentInputs = [inputMatrices objectAtIndex: i];
      [currentInputs copyToRealData: [inputs realData]+offset stride: [inputs stride]];
      offset += [currentInputs numberOfRows];
    }      
  }

  [machine forwardMatrix: inputs];
}

-(void)backward
{
  // If direct connection
  if(hasDirectOutputConnection)
    gradOutputs = directGradOutputs;
  else
  {
    // Connected to one machine, with a different number of rows
    if(hasAlmostDirectOutputConnection)
    {
//      T4Matrix *currentGradOutputs = [gradOutputMatrices objectAtIndex: 0];
//       [gradOutputs setMatrixFromData: [currentGradOutputs data]+gradOutputMatrixOffsets[0]
//                    numberOfRows: [[machine outputs] numberOfRows]
//                    numberOfColumns: [currentGradOutputs numberOfColumns]
//                    stride: [currentGradOutputs stride]];

      [gradOutputs setMatrixFromRealData: [directGradOutputs realData]+gradOutputMatrixOffsets[0]
                   numberOfRows: [[machine outputs] numberOfRows]
                   numberOfColumns: [directGradOutputs numberOfColumns]
                   stride: [directGradOutputs stride]];
    }
    
    // Connected to several machines
    else
    {
      T4Matrix *currentGradOutputs = [gradOutputMatrices objectAtIndex: 0];
      int numGradOutputMatrices = [gradOutputMatrices count];
      int i;

      [gradOutputs resizeWithNumberOfColumns: [currentGradOutputs numberOfColumns]];
      [gradOutputs copyFromRealData: [currentGradOutputs realData]+gradOutputMatrixOffsets[0] stride: [currentGradOutputs stride]];
      
      for(i = 1; i < numGradOutputMatrices; i++)
      {
        currentGradOutputs = [gradOutputMatrices objectAtIndex: i];
        [gradOutputs addFromRealData: [currentGradOutputs realData]+gradOutputMatrixOffsets[i] stride: [currentGradOutputs stride]];
      }
    }
  }

  [machine backwardMatrix: gradOutputs inputs: inputs];
}

-(T4GradientMachine*)machine
{
  return machine;
}

@end

@implementation T4ConnectedMachine

-init
{
  if( (self = [super initWithNumberOfInputs: 0 numberOfOutputs: 0 numberOfParameters: 0]) )
  {
    layers = [[NSMutableArray alloc] init];
    [self addLayer];
  }

  return self;
}

-build
{
  T4GradientMachine *machine;
  T4ConnectedNode *node = nil;
  NSArray *layer;
  int numLayers = [layers count];
  int numNodes;
  int i, j, offset;

  // check the nodes
  for(i = 1; i < numLayers; i++)
  {
    layer = [layers objectAtIndex: i];
    numNodes = [layer count];

    for(j = 0; j < numNodes; j++)
    {
      node = [layer objectAtIndex: j];
      [node check];
    }
  }

  // compute number of outputs and establish direct output connection
  numOutputs = 0;
  layer = [layers lastObject];
  numNodes = [layer count];
  for(i = 0; i < numNodes; i++)
  {
    node = [layer objectAtIndex: i];
    numOutputs += [[node machine] numberOfOutputs];
  }

  offset = 0;
  for(i = 0; i < numNodes; i++)
  {
    node = [layer objectAtIndex: i];
    [node directOutputConnectionWithOffset: offset numberOfOutputs: numOutputs];
    offset += [[node machine] numberOfOutputs];
  }

  if(![[layers lastObject] count])
    T4Error(@"ConnectedMachine: last layer does not contain any machines!");

  // check outputs
  if(numNodes > 1)
  {
    outputs = [[T4Matrix alloc] initWithNumberOfRows: numOutputs];
  }
  else
    outputs = [[node machine] outputs];

  // compute number of inputs
  numInputs = 0;
  layer = [layers objectAtIndex: 0];
  numNodes = [layer count];
  for(i = 0; i < numNodes; i++)
  {
    node = [layer objectAtIndex: i];
    numInputs += [[node machine] numberOfInputs];
  }

  // check gradInputs
  if(numNodes > 1)
    gradInputs = [[T4Matrix alloc] initWithNumberOfRows: numInputs];
  else
    gradInputs = [[node machine] gradInputs];

  // check the parameters
  for(i = 0; i < numLayers; i++)
  {
    layer = [layers objectAtIndex: i];
    numNodes = [layer count];

    for(j = 0; j < numNodes; j++)
    {
      node = [layer objectAtIndex: j];
      machine = [node machine];
      [parameters addObjectsFromArray: [machine parameters]];
      [gradParameters addObjectsFromArray: [machine gradParameters]];
    }
  }

  return self;
}

-addFullConnectedMachine: (T4GradientMachine*)aMachine
{
  T4ConnectedNode *node;
  NSArray *previousLayer;
  int numNodes;
  int i;

  if([[layers lastObject] count] > 0)
    [self addLayer];

  [self addMachine: aMachine];
  
  if([layers count] > 1)
  {
    previousLayer = [layers objectAtIndex: [layers count]-2];
    numNodes = [previousLayer count];

    for(i = 0; i < numNodes; i++)
    {
      node = [previousLayer objectAtIndex: i];
      [self connectMachine: aMachine toMachine: [node machine]];
    }
  }

  return self;
}

-addLayer
{
  NSMutableArray *layer;

  if([layers count] > 0)
  {
    if(![[layers lastObject] count])
      T4Error(@"ConnectedMachine: one layer without any machine! Gasp!");
  }

  layer = [[NSMutableArray alloc] init];
  [layers addObject: layer];

  return self;
}

-addMachine: (T4GradientMachine*) aMachine
{
  NSMutableArray *layer = [layers lastObject];
  T4ConnectedNode *node = [[T4ConnectedNode alloc] initWithMachine: aMachine];

  [layer addObject: node];

  return self;
}

-connectMachine: (T4GradientMachine*)firstMachine toMachine: (T4GradientMachine*)secondMachine
{
  T4ConnectedNode *firstNode, *secondNode;
  int firstLayerIndex, secondLayerIndex;

  if(![self getNode: &firstNode andLayerIndex: &firstLayerIndex forMachine: firstMachine])
    T4Error(@"ConnectedMachine: cannot find machine <%@>", firstMachine);

  if(![self getNode: &secondNode andLayerIndex: &secondLayerIndex forMachine: secondMachine])
    T4Error(@"ConnectedMachine: cannot find machine <%@>", secondMachine);
  
  if(firstLayerIndex <= secondLayerIndex)
    T4Error(@"ConnectedMachine: try to connect a machine <%@> to an other machine <%@> which is not in a previous layer", firstMachine, secondMachine);

  [firstNode addInputConnectionToMachine: secondMachine];
  [secondNode addOutputConnectionToMachine: firstMachine offset: [firstNode currentNumberOfInputs]];

  return self;
//  printf("[%d %d on %d %d] machine %d outputs. = machine mere: %d outputs. machine fils: %d inputs\n", l, m, current_layer, current_machine, machine->n_outputs, machines[l][m]->n_outputs, machines[current_layer][current_machine]->n_inputs);
}

-(T4Matrix*)forwardMatrix: (T4Matrix*)aMatrix
{
  T4ConnectedNode *node;
  T4Matrix *currentOutputs;
  NSArray *layer;
  int numLayers = [layers count];
  int numNodes;
  int offset;
  int i, j;

  layer = [layers objectAtIndex: 0];
  numNodes = [layer count];
  for(i = 0; i < numNodes; i++)
  {
    node = [layer objectAtIndex: i];
    [node setInputs: aMatrix];
    [node forward];
  }

  for(i = 1; i < numLayers; i++)
  {
    layer = [layers objectAtIndex: i];
    numNodes = [layer count];
    for(j = 0; j < numNodes; j++)
    {
      node = [layer objectAtIndex: j];
      [node forward];
    }
  }

  // NOTE: if not direct output connection, updates output.
  if([[layers lastObject] count] > 1)
  {
    layer = [layers lastObject];
    numNodes = [layer count];
    node = [layer objectAtIndex: 0];
    currentOutputs = [[node machine] outputs];
    
    [outputs resizeWithNumberOfColumns: [currentOutputs numberOfColumns]];
    [currentOutputs copyToRealData: [outputs realData] stride: [outputs stride]];
    offset = [currentOutputs numberOfRows];

    for(i = 1; i < numNodes; i++)
    {
      node = [layer objectAtIndex: i];
      currentOutputs = [[node machine] outputs];
      [currentOutputs copyToRealData: [outputs realData]+offset stride: [outputs stride]];
      offset += [currentOutputs numberOfRows];
    }
  }

  return outputs;
}

-(T4Matrix*)backwardMatrix: (T4Matrix*)aGradOutputs inputs: (T4Matrix*)anInputMatrix
{
  T4ConnectedNode *node;
  T4Matrix *currentGradInputs;
  NSArray *layer;
  int numLayers = [layers count];
  int numNodes;
  int i, j;

  layer = [layers lastObject];
  numNodes = [layer count];
  for(i = 0; i < numNodes; i++)
  {
    node = [layer objectAtIndex: i];
    [node setGradOutputs: aGradOutputs];
    [node backward];
  }

  for(i = numLayers-2; i >= 0; i--)
  {
    layer = [layers objectAtIndex: i];
    numNodes = [layer count];
    for(j = 0; j < numNodes; j++)
    {
      node = [layer objectAtIndex: j];
      [node backward];
    }
  }

  // NOTE: if not direct output connection, updates output.
  if([[layers objectAtIndex: 0] count] > 1)
  {
    layer = [layers objectAtIndex: 0];
    numNodes = [layer count];
    node = [layer objectAtIndex: 0];
    currentGradInputs = [[node machine] gradInputs];
    
    [gradInputs resizeWithNumberOfColumns: [currentGradInputs numberOfColumns]];
    [gradInputs copyMatrix: currentGradInputs];

    for(i = 1; i < numNodes; i++)
    {
      node = [layer objectAtIndex: i];
      currentGradInputs = [[node machine] gradInputs];
      [gradInputs addMatrix: currentGradInputs];
    }
  }

  return gradInputs;
}

-(BOOL)getNode: (T4ConnectedNode**)aNode andLayerIndex: (int*)aLayerIndex forMachine: (T4GradientMachine*)aMachine
{
  T4ConnectedNode *node;
  NSArray *layer;
  int numLayers = [layers count];
  int numNodes;
  int i, j;

  for(i = 0; i < numLayers; i++)
  {
    layer = [layers objectAtIndex: i];
    numNodes = [layer count];

    for(j = 0; j < numNodes; j++)
    {
      node = [layer objectAtIndex: j];
      if([node machine] == aMachine)
      {
        *aNode = node;
        *aLayerIndex = i;
        return YES;
      }
    }
  }

  return NO;
}

-(void)reset
{
  T4ConnectedNode *node;
  NSArray *layer;
  int numLayers = [layers count];
  int numNodes;
  int i, j;

  for(i = 0; i < numLayers; i++)
  {
    layer = [layers objectAtIndex: i];
    numNodes = [layer count];

    for(j = 0; j < numNodes; j++)
    {
      node = [layer objectAtIndex: j];
      [[node machine] reset];
    }
  }
}

// void ConnectedMachine::iterInitialize()
// {
//   for(int i = 0; i < n_layers; i++)
//   {
//     for(int m = 0; m < n_machines_on_layer[i]; m++)
//       machines[i][m]->machine->iterInitialize();
//   }  
// }


// void ConnectedMachine::setPartialBackprop(bool flag)
// {
//   partial_backprop = flag;
//   for(int i = 0; i < n_machines_on_layer[0]; i++)
//     machines[0][i]->machine->setPartialBackprop(flag);
// }

// void ConnectedMachine::setDataSet(DataSet *dataset_)
// {
//   for(int i = 0; i < n_layers; i++)
//   {
//     for(int m = 0; m < n_machines_on_layer[i]; m++)
//       machines[i][m]->machine->setDataSet(dataset_);
//   }
// }

@end
