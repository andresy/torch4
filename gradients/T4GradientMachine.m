#import "T4GradientMachine.h"
#import "T4ProgressBar.h"
#import "T4Random.h"

@implementation T4GradientMachine

-initWithNumberOfInputs: (int)aNumInputs numberOfOutputs: (int)aNumOutputs numberOfParameters: (int)aNumParams
{
  if( (self = [super init]) )
  {
    numInputs = aNumInputs;
    numOutputs = aNumOutputs;
    if(numOutputs > 0)
    {
      outputs = [[T4Matrix alloc] initWithNumberOfRows: numOutputs numberOfColumns: 1];
      [allocator keepObject: outputs];
    }
    else
      outputs = nil;
    
    if(numInputs > 0)
    {
      gradInputs = [[T4Matrix alloc] initWithNumberOfRows: numInputs numberOfColumns: 1];
      [allocator keepObject: gradInputs];
    }
    else
      gradInputs = nil;
    
    if(aNumParams > 0)
    {
      T4Matrix *aMatrix;
      
      parameters = [[NSMutableArray alloc] init];
      gradParameters = [[NSMutableArray alloc] init];

      aMatrix = [[T4Matrix alloc] initWithNumberOfRows: aNumParams numberOfColumns: 1];
      [allocator keepObject: aMatrix];
      [parameters addObject: aMatrix];
      [allocator keepObject: parameters];
      
      aMatrix = [[T4Matrix alloc] initWithNumberOfRows: aNumParams numberOfColumns: 1];
      [allocator keepObject: aMatrix];
      [gradParameters addObject: aMatrix];
      [allocator keepObject: gradParameters];
    }
    else
    {
      parameters = [[NSMutableArray alloc] init];
      gradParameters = [[NSMutableArray alloc] init];
      [allocator keepObject: parameters];
      [allocator keepObject: gradParameters];
    }

    criterion = nil;
    [self setPartialBackpropagation: NO];
    [self setEndAccuracy: 0.0001];
    [self setLearningRate: 0.01];
    [self setLearningRateDecay: 0.];
    [self setMaxNumberOfIterations: -1];
    [self setShufflesExamples: YES];
  }

  return self;
//  partial_backprop = false;
}

-(void)setCriterion: (T4Criterion*)aCriterion
{
  criterion = aCriterion;
}

// void GradientMachine::setPartialBackprop(bool flag)
// {
//   partial_backprop = flag;
// }
// -(void)iterInitialize
// {
// }

-(T4Matrix*)forwardMatrix: (T4Matrix*)someInputs
{
  return someInputs;
}

-(T4Matrix*)backwardMatrix: (T4Matrix*)someGradOutputs inputs: (T4Matrix*)someInputs
{
  return someGradOutputs;
}

-(void)trainWithDataset: (NSArray*)aDataset measurers: (NSArray*)someMeasurers
{
  int iteration = 0;
  real currentError = 0;
  real previousError = INF;
  real currentLearningRate = learningRate;
  int numTrain = [aDataset count];
  int *shuffledIndices = [allocator allocIntArrayWithCapacity: numTrain];  
  NSArray *datasets;
  NSArray  *currentMeasurers, *measurers;
  T4Measurer*measurer;
  T4Allocator *localAllocator;
  int t, i, julie;
  int numMeasurers;

  if(!criterion)
    T4Error(@"StochasticGradient: no criterion defined. Va te faire mettre.");

  T4Message(@"StochasticGradient: training");

  [criterion setDataset: aDataset];

  numMeasurers = [someMeasurers count];
  for(i = 0; i < numMeasurers; i++)
  {
    measurer = [someMeasurers objectAtIndex: i];
    [measurer reset];
  }
/*
  enumerator = [someMeasurers objectEnumerator];
  while( (measurer = [enumerator nextObject]) )
    [measurer reset];
*/

  localAllocator = T4ExtractMeasurers(someMeasurers, aDataset, &datasets, &measurers);

  if(shufflesExamples)
    [T4Random getArrayOfShuffledIndices: shuffledIndices capacity: numTrain];
  else
  {
    for(i = 0; i < numTrain; i++)
      shuffledIndices[i] = i;
  }
  
  while(1)
  {
//    [self iterInitialize];
//    [criterion iterInitialize];

    currentError = 0;
    for(t = 0; t < numTrain; t++)
    {
      int numParameters = [parameters count];
      NSArray *example = [aDataset objectAtIndex: shuffledIndices[t]];
      T4Matrix *inputs = [example objectAtIndex: 0];

      for(i = 0; i < numParameters; i++)
      {
        T4Matrix *gradParameter = [gradParameters objectAtIndex: i];
        [gradParameter zero];
      }

      [criterion forwardExampleAtIndex: shuffledIndices[t] inputs: [self forwardMatrix: inputs]];
//      T4Message(@"criterion = %g [out mlp = %g] for example <%d> = [%@]", [criterion output], [[self outputs] realData][0], shuffledIndices[t], inputs);
      [self backwardMatrix:
              [criterion backwardExampleAtIndex: shuffledIndices[t] inputs: [self outputs]]
            inputs: inputs];

//       T4Message(@"gradients = %@", gradInputs);
//       exit(0);

//      T4Message(@"gradients = %@", gradParameters);

      currentMeasurers = [measurers objectAtIndex: 0];
      numMeasurers = [currentMeasurers count];
      for(i = 0; i < numMeasurers; i++)
      {
        measurer = [currentMeasurers objectAtIndex: i];
        [measurer measureExampleAtIndex: shuffledIndices[t]];
      }
/*      
      enumerator = [[measurers objectAtIndex: 0] objectEnumerator];
      while( (measurer = [enumerator nextObject]) )
        [measurer measureExample: shuffledIndices[t]];
*/      
      for(i = 0; i < numParameters; i++)
      {
        T4Matrix *parameter = [parameters objectAtIndex: i];
        T4Matrix *gradParameter = [gradParameters objectAtIndex: i];
        [parameter addValue: -currentLearningRate dotMatrix: gradParameter];
//         real *ptrParams = [parameter realData];
//         real *ptrDParams = [gradParameter realData];
//         int size = [parameter numberOfRows];
        
//         for(j = 0; j < size; j++)
//           ptrParams[j] -= currentLearningRate * ptrDParams[j];
      }

      currentError += [criterion output];
    }

    currentMeasurers = [measurers objectAtIndex: 0];
    numMeasurers = [currentMeasurers count];
    for(i = 0; i < numMeasurers; i++)
    {
      measurer = [currentMeasurers objectAtIndex: i];
      [measurer measureAtIteration: iteration];
    }

    // le data 0 est le train dans tous les cas...
    for(julie = 1; julie < [datasets count]; julie++)
    {
      NSArray *aTestDataset = [datasets objectAtIndex: julie];
      int numTest = [aTestDataset count];

      currentMeasurers = [measurers objectAtIndex: julie];
      numMeasurers = [currentMeasurers count];

      for(t = 0; t < numTest; t++)
      {
        [self forwardMatrix: [[aTestDataset objectAtIndex: t] objectAtIndex: 0]];

        for(i = 0; i < numMeasurers; i++)
        {
          measurer = [currentMeasurers objectAtIndex: i];
          [measurer measureExampleAtIndex: t];
        }
      }

      for(i = 0; i < numMeasurers; i++)
      {
        measurer = [currentMeasurers objectAtIndex: i];
        [measurer measureAtIteration: iteration];
      }
    }

/*
    enumerator = [[measurers objectAtIndex: 0] objectEnumerator];
    while( (measurer = [enumerator nextObject]) )
      [measurer measureIteration: iteration];

    // le data 0 est le train dans tous les cas...
    for(julie = 1; julie < [datasets count]; julie++)
    {
      NSArray *aTestDataset = [datasets objectAtIndex: julie];
      int numTest = [aTestDataset count];

      for(t = 0; t < numTest; t++)
      {
        [self forwardMatrix: [[aTestDataset objectAtIndex: t] objectAtIndex: 0]];

        enumerator = [[measurers objectAtIndex: julie] objectEnumerator];
        while( (measurer = [enumerator nextObject]) )
          [measurer measureExample: t];
      }

      enumerator = [[measurers objectAtIndex: julie] objectEnumerator];
      while( (measurer = [enumerator nextObject]) )
        [measurer measureIteration: iteration];
    }
*/
    T4Print(@".");
    currentError /= (real)(numTrain);
    T4Message(@"current error = %g", currentError);
    if(fabs(previousError - currentError) < endAccuracy)
    {
      T4Print(@"\n");
      break;
    }
    previousError = currentError;

    iteration++;
    currentLearningRate = learningRate/(1.+((real)(iteration))*learningRateDecay);
    if( (iteration >= maxIteration) && (maxIteration > 0) )
    {
      T4Print(@"\n");
      T4Warning(@"StochasticGradient: you have reached the maximum number of iterations");
      break;
    }
  }

/*
  enumerator = [someMeasurers objectEnumerator];
  while( (measurer = [enumerator nextObject]) )
    [measurer measureEnd];
*/

  [allocator freePointer: shuffledIndices];
}

-(void)testWithMeasurers: (NSArray*)someMeasurers
{
  NSArray *datasets;
  NSArray *measurers;
  T4Allocator *localAllocator;
  T4Measurer *measurer;
  T4ProgressBar *progressBar;
  int numTotalExamples;
  int i, j, k;

  T4Print(@"# Trainer: testing ");
  localAllocator = T4ExtractMeasurers(someMeasurers, nil, &datasets, &measurers);

  ////
  numTotalExamples = 0;
  for(i = 0; i < [datasets count]; i++)
    numTotalExamples += [[datasets objectAtIndex: i] count];

  progressBar = [[T4ProgressBar alloc] initWithMaxValue: numTotalExamples];

  numTotalExamples = 0;
  for(i = 0; i < [datasets count]; i++)
  {
    NSArray *currentDataset = [datasets objectAtIndex: i];
    NSArray *currentMeasurers = [measurers objectAtIndex: i];
    int numCurrentMeasurers = [currentMeasurers count];
    int numCurrentDataset = [currentDataset count];

    for(j = 0; j < numCurrentMeasurers; j++)      
    {
      measurer = [currentMeasurers objectAtIndex: j];
      [measurer reset];
    }

    for(j = 0; j < numCurrentDataset; j++)
    {
      T4Matrix *inputs = [[currentDataset objectAtIndex: j] objectAtIndex: 0];
      [self forwardMatrix: inputs];

      for(k = 0; k < numCurrentMeasurers; k++)
      {
        measurer = [currentMeasurers objectAtIndex: k];
        [measurer measureExampleAtIndex: j];
      }

      [progressBar setProgress: ++numTotalExamples];
    }

    for(j = 0; j < numCurrentMeasurers; j++)      
    {
      measurer = [currentMeasurers objectAtIndex: j];
      [measurer measureAtIteration: 0];
      [measurer measureAtEnd];
    }
  }
  
  T4Print(@"\n");
  [progressBar release];
}

-reset
{
  return self;
}

-(int)numberOfInputs
{
  return numInputs;
}

-(int)numberOfOutputs
{
  return numOutputs;
}

-(T4Matrix*)outputs
{
  return outputs;
}

-(T4Matrix*)gradInputs
{
  return gradInputs;
}

-(NSArray*)parameters
{
  return parameters;
}

-(NSArray*)gradParameters
{
  return gradParameters;
}

-setPartialBackpropagation: (BOOL)aFlag
{
  partialBackpropagation = aFlag;
  return self;
}

-setEndAccuracy: (real)aValue
{
  endAccuracy = aValue;
  return self;
}

-setLearningRate: (real)aValue
{
  learningRate = aValue;
  return self;
}

-setLearningRateDecay: (real)aValue
{
  learningRateDecay = aValue;
  return self;
}

-setMaxNumberOfIterations: (int)aValue
{
  maxIteration = aValue;
  return self;
}

-setShufflesExamples: (BOOL)aFlag
{
  shufflesExamples = aFlag;
  return self;
}

@end
