#import "T4Distribution.h"
#import "T4ProgressBar.h"

@implementation T4Distribution

-initWithNumberOfInputs: (int)aNumInputs numberOfParameters: (int)aNumParams
{
	if( (self = [super init]) )
	{
		numInputs = aNumInputs;
		logProbability = -INF;

		if(aNumParams > 0)
		{
			T4Matrix *aMatrix;

			parameters = [[NSMutableArray alloc] init];

			aMatrix = [[T4Matrix alloc] initWithNumberOfRows: aNumParams numberOfColumns: 1];
			[allocator keepObject: aMatrix];
			[parameters addObject: aMatrix];
			[allocator keepObject: parameters];

			accumulators = [[NSMutableArray alloc] init];

			aMatrix = [[T4Matrix alloc] initWithNumberOfRows: aNumParams numberOfColumns: 1];
			[allocator keepObject: aMatrix];
			[accumulators addObject: aMatrix];
			[allocator keepObject: accumulators];

		}
		else
		{
			parameters = [[NSMutableArray alloc] init];
			[allocator keepObject: parameters];


			accumulators = [[NSMutableArray alloc] init];
			[allocator keepObject: accumulators];
		}

		[self setEndAccuracy: 0.0001];
		[self setMaxNumberOfIterations: -1];
	}

	return self;
}


-setEndAccuracy: (real)aValue
{
  endAccuracy = aValue;
  return self;
}

-setMaxNumberOfIterations: (int)aValue;
{
  maxIteration = aValue;
  return self;
}

-(real)forwardInputs: (T4Matrix*)someInputs
{
  return -INF;
}

-backwardLogPosterior: (real) aLogPosterior inputs: (T4Matrix*)someInputs;
{
	return self;	
}

-update
{
  return self;
}

-reset
{
  return self;
}

-(NSArray*)parameters
{
  return parameters;
}

-(int)numberOfInputs
{
  return numInputs;
}

-testWithMeasurers: (NSArray*)someMeasurers
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
      [self forwardInputs: inputs];

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
  return self;
}

-resetAccumulators
{
	int i;
	int numAccumulators = [accumulators count];
	for(i = 0; i < numAccumulators; i++)
	{
		T4Matrix *accumulator = [accumulators objectAtIndex: i];
		[accumulator zero];
	}
	return self;
}
-resetWithDataset: (NSArray*)aDataset
{
	return self;
}

-trainWithDataset: (NSArray*)aDataset measurers: (NSArray*)someMeasurers
{
  int iteration = 0;
  real currentError = 0;
  real previousError = INF;
  int numTrain = [aDataset count];
  NSArray *datasets;
  NSArray  *currentMeasurers, *measurers;
  T4Measurer*measurer;
  T4Allocator *localAllocator;
  int t, i, julie;
  int numMeasurers;


  T4Message(@"Distribution: training");
  T4Message(@"Distribution: number of examples",numTrain);


  numMeasurers = [someMeasurers count];
  for(i = 0; i < numMeasurers; i++)
  {
    measurer = [someMeasurers objectAtIndex: i];
    [measurer reset];
  }

  localAllocator = T4ExtractMeasurers(someMeasurers, aDataset, &datasets, &measurers);

  
	//[self resetWithDataset: aDataset];
  while(1)
  {
//    [self iterInitialize];
//    [criterion iterInitialize];

		[self resetAccumulators];
    currentError = 0;
    for(t = 0; t < numTrain; t++)
    {
      NSArray *example = [aDataset objectAtIndex: t];
      T4Matrix *inputs = [example objectAtIndex: 0];
      
			
			currentError -= [self forwardInputs: inputs];
			[self backwardLogPosterior: 0 inputs: inputs];

      currentMeasurers = [measurers objectAtIndex: 0];
      numMeasurers = [currentMeasurers count];
			currentError /= [inputs numberOfColumns];
      for(i = 0; i < numMeasurers; i++)
      {
        measurer = [currentMeasurers objectAtIndex: i];
        [measurer measureExampleAtIndex: t];
      }
      
    }
		[self update];

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
        [self forwardInputs: [[aTestDataset objectAtIndex: t] objectAtIndex: 0]];

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
    if( (iteration >= maxIteration) && (maxIteration > 0) )
    {
      T4Print(@"\n");
      T4Warning(@"Distribution: you have reached the maximum number of iterations");
      break;
    }
  }
  return self;
}

@end
