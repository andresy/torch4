#import "T4ExampleDealer.h"

@implementation T4ExampleDealer

-(NSArray*)examplesWithMatrix:   (T4Matrix*)aMatrix      numberOfColumns: (int)aNumColumns columnStep: (int)aColumnStep elementSizes: (int*)someElementSizes numberOfElements: (int)aNumElements
{
  int numRows = [aMatrix numberOfRows];
  int numColumns = (aNumColumns > 0 ? aNumColumns : [aMatrix numberOfColumns]);
  int stride = [aMatrix stride];
  int numExamples = [aMatrix numberOfColumns]/aNumColumns;
  NSArray **examplesArray = [allocator allocIdArrayWithCapacity: numExamples];
  T4Matrix **exampleArray = [allocator allocIdArrayWithCapacity: aNumElements];
  NSArray *examples;
  int currentColumnIndex = 0;
  int e, i;
  real sumElementSizes = 0;
  int defaultElementSize;
  BOOL hasToGuess = NO;

  for(i = 0; i < aNumElements; i++)
  {
    if(someElementSizes[i] < 0)
    {
      if(hasToGuess)
        T4Error(@"ExampleDealer: cannot guess more than one element size!!!");
      hasToGuess = YES;
    }
    else
      sumElementSizes += someElementSizes[i];
  }

  if(sumElementSizes > numRows)
    T4Error(@"ExampleDealer: element sizes do not match matrix size...");

  defaultElementSize = numRows - sumElementSizes;
  
  for(e = 0; e < numExamples; e++)
  {
    real *currentColumn = [aMatrix columnAtIndex: currentColumnIndex];
    NSArray *example;
    int offset = 0;

    for(i = 0; i < aNumElements; i++)
    {
      int elementSize = (someElementSizes[i] < 0 ? defaultElementSize : someElementSizes[i]);

      exampleArray[i] = [[T4Matrix alloc] initWithRealData: currentColumn+offset
                                          numberOfRows: elementSize
                                          numberOfColumns: numColumns
                                          stride: stride];

      offset += elementSize;
    }

    example = [[NSArray alloc] initWithObjects: exampleArray count: aNumElements];

    for(i = 0; i < aNumElements; i++)
      [exampleArray[i] release];

    examplesArray[e] = example;
    currentColumnIndex += aColumnStep;
  }

  examples = [[NSArray alloc] initWithObjects: examplesArray count: numExamples];

  for(e = 0; e < numExamples; e++)
    [examplesArray[e] release];

  [allocator keepObject: examples];
  [allocator freePointer: examplesArray];
  [allocator freePointer: exampleArray];

  return examples;
}

-(NSArray*)examplesWithMatrices:  (NSArray*)someMatrices numberOfColumns: (int)aNumColumns columnStep: (int)aColumnStep elementSizes: (int*)someElementSizes numberOfElements: (int)aNumElements
{
  NSMutableArray *examples = [[[NSMutableArray alloc] init] keepWithAllocator: allocator];
  int numMatrices = [someMatrices count];
  int i;

  for(i = 0; i < numMatrices; i++)
  {
    NSArray *someExamples = [self examplesWithMatrix: [someMatrices objectAtIndex: i]
                                  numberOfColumns: aNumColumns
                                  columnStep: aColumnStep
                                  elementSizes: someElementSizes
                                  numberOfElements: aNumElements];

    [examples addObjectsFromArray: someExamples];
  }

  return examples;
}

-(NSArray*)columnExamplesWithMatrix:  (T4Matrix*)aMatrix
{
  int numRows = -1;
  return [self examplesWithMatrix: aMatrix
               numberOfColumns: 1
               columnStep: 1
               elementSizes: &numRows
               numberOfElements: 1];
}

-(NSArray*)columnExamplesWithMatrices: (NSArray*)someMatrices
{
  int numRows = -1;
  return [self examplesWithMatrices: someMatrices
               numberOfColumns: 1
               columnStep: 1
               elementSizes: &numRows
               numberOfElements: 1];
}

-(NSArray*)columnExamplesWithMatrix:  (T4Matrix*)aMatrix      elementSize: (int)anElementSize elementSize: (int)anotherElementSize
{
  int elementSizes[2];

  elementSizes[0] = anElementSize;
  elementSizes[1] = anotherElementSize;

  return [self examplesWithMatrix: aMatrix
               numberOfColumns: 1
               columnStep: 1
               elementSizes: elementSizes
               numberOfElements: 2];
}

-(NSArray*)columnExamplesWithMatrices: (NSArray*)someMatrices elementSize: (int)anElementSize elementSize: (int)anotherElementSize
{
  int elementSizes[2];

  elementSizes[0] = anElementSize;
  elementSizes[1] = anotherElementSize;

  return [self examplesWithMatrices: someMatrices
               numberOfColumns: 1
               columnStep: 1
               elementSizes: elementSizes
               numberOfElements: 2];
}

@end
