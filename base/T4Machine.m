#import "T4Machine.h"

T4Allocator *T4ExtractMeasurers(NSArray *someMeasurers, NSArray *aTrainingSet,
                                 NSArray **someSortedDatasets, NSArray **someSortedMeasurers)
{
  T4Allocator *allocator = [[T4Allocator alloc] init];
  int numSomeMeasurers = [someMeasurers count];
  int numSortedDatasets;
  int i, j;

  NSMutableArray *sortedDatasets = [[NSMutableArray alloc] init];
  NSMutableArray *sortedMeasurers = [[NSMutableArray alloc] init];
  [allocator keepObject: sortedDatasets];
  [allocator keepObject: sortedMeasurers];

  if(aTrainingSet)
    [sortedDatasets addObject: aTrainingSet];
  
  for(i = 0; i < numSomeMeasurers; i++)
  {
    T4Measurer *measurer = [someMeasurers objectAtIndex: i];
    NSArray *dataset = [measurer dataset];

    if([sortedDatasets indexOfObjectIdenticalTo: dataset] == NSNotFound)
      [sortedDatasets addObject: dataset];
  }

  numSortedDatasets = [sortedDatasets count];
  for(i = 0; i < numSortedDatasets; i++)
  {
    NSArray *dataset = [sortedDatasets objectAtIndex: i];
    NSMutableArray *currentMeasurers = [[NSMutableArray alloc] init];
    for(j = 0; j < numSomeMeasurers; j++)
    {
      T4Measurer *measurer = [someMeasurers objectAtIndex: j];
      if(dataset == [measurer dataset])
        [currentMeasurers addObject: measurer];
    }
    [sortedMeasurers addObject: currentMeasurers];
  }

  *someSortedDatasets = sortedDatasets;
  *someSortedMeasurers = sortedMeasurers;

  return [allocator autorelease];
}
