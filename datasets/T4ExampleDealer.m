#import "T4ExampleDealer.h"

@implementation T4ExampleDealer

// Examples by composition of several matrices given in different arrays ////////////////////////////////////////////////////////

-(NSArray*)examplesWithArrayOfElements: (NSArray*)arrayOfMatrixArray
{
  int numElements = [arrayOfMatrixArray count];
  int numExamples = -1;
  int i, e;
  T4Matrix **exampleArray;
  NSArray **examplesArray;
  NSArray *examples;

  for(i = 0; i < numElements; i++)
  {
    int currentNumExamples = [[arrayOfMatrixArray objectAtIndex: i] count];
    if(numExamples < 0)
      numExamples = currentNumExamples;
    else
    {
      if(currentNumExamples != numExamples)
        T4Error(@"ExampleDealer: element columns do not have the the same size!!!");
    }
  }

  if(numExamples < 0)
    T4Error(@"ExampleDealer: no examples proposed!!!");

  examplesArray = [T4Allocator sysAllocIdArrayWithCapacity: numExamples];
  exampleArray = [T4Allocator sysAllocIdArrayWithCapacity: numElements];

  for(e = 0; e < numExamples; e++)
  {
    for(i = 0; i < numElements; i++)
      exampleArray[i] = [[arrayOfMatrixArray objectAtIndex: i] objectAtIndex: e];

    examplesArray[e] = [[NSArray alloc] initWithObjects: exampleArray count: numElements];
  }

  examples = [[NSArray alloc] initWithObjects: examplesArray count: numExamples];

  for(e = 0; e < numExamples; e++)
    [examplesArray[e] release];

  [allocator keepObject: examples];

  return examples;
}

-(NSArray*)examplesWithElements: (NSArray*)someMatricesA elements: (NSArray*)someMatricesB
{
  NSArray *arrayOfMatrixArray = [[NSArray alloc] initWithObjects: someMatricesA, someMatricesB, nil];
  NSArray *examples;

  examples = [self examplesWithArrayOfElements: arrayOfMatrixArray];

  [arrayOfMatrixArray release];

  return examples;
}

-(NSArray*)examplesWithElements: (NSArray*)someMatricesA elements: (NSArray*)someMatricesB elements: (NSArray*)someMatricesC
{
  NSArray *arrayOfMatrixArray = [[NSArray alloc] initWithObjects: someMatricesA, someMatricesB, someMatricesC, nil];
  NSArray *examples;

  examples = [self examplesWithArrayOfElements: arrayOfMatrixArray];

  [arrayOfMatrixArray release];

  return examples;
}

// Examples by decomposing a matrix in several columns //////////////////////////////////////////////////////////////////////////

-(NSArray*)examplesWithMatrix:   (T4Matrix*)aMatrix      numberOfColumns: (int)aNumColumns columnStep: (int)aColumnStep elementSizes: (int*)someElementSizes numberOfElements: (int)aNumElements
{
  int numRows = [aMatrix numberOfRows];
  int numColumns = (aNumColumns > 0 ? aNumColumns : [aMatrix numberOfColumns]);
  int stride = [aMatrix stride];
  int numExamples = [aMatrix numberOfColumns]/aNumColumns;
  NSArray **examplesArray = [T4Allocator sysAllocIdArrayWithCapacity: numExamples];
  T4Matrix **exampleArray = [T4Allocator sysAllocIdArrayWithCapacity: aNumElements];
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

      exampleArray[i] = [[T4Matrix alloc] initWithRealArray: currentColumn+offset
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
  [T4Allocator sysFree: examplesArray];
  [T4Allocator sysFree: exampleArray];

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

//

-(NSArray*)matricesWithMatrix: (T4Matrix*)aMatrix rowOffset: (int)aRowOffset numberOfRows: (int)aNumRows numberOfColumns: (int)aNumColumns columnStep: (int)aColumnStep
{
  int stride = [aMatrix stride];
  int numMatrices;
  T4Matrix **matricesArray;
  NSArray *matrices;
  int currentColumnIndex = 0;
  int m;

  if(aRowOffset < 0)
    aRowOffset = 0;

  if(aNumRows < 0)
    aNumRows = [aMatrix numberOfRows] - aRowOffset;

  if(aNumRows < aRowOffset+[aMatrix numberOfRows])
    T4Error(@"ExampleDealer: number of rows required does not fit in the provided matrix");

  if(aNumColumns < 0)
    aNumColumns = [aMatrix numberOfColumns];

  if(aNumColumns > [aMatrix numberOfColumns])
    T4Error(@"ExampleDealer: number of columns required does not fit in the provided matrix");

  numMatrices = [aMatrix numberOfColumns]/aNumColumns;
  matricesArray = [T4Allocator sysAllocIdArrayWithCapacity: numMatrices];

  for(m = 0; m < numMatrices; m++)
  {
    T4Matrix *matrix = [[T4Matrix alloc] initWithRealArray: [aMatrix columnAtIndex: currentColumnIndex]+aRowOffset
                                         numberOfRows: aNumRows
                                         numberOfColumns: aNumColumns
                                         stride: stride];

    matricesArray[m] = matrix;
    currentColumnIndex += aColumnStep;
  }

  matrices = [[NSArray alloc] initWithObjects: matricesArray count: numMatrices];

  for(m = 0; m < numMatrices; m++)
    [matricesArray[m] release];

  [allocator keepObject: matrices];
  [T4Allocator sysFree: matricesArray];

  return matrices;
}

-(NSArray*)matricesWithMatrices: (NSArray*)someMatrices rowOffset: (int)aRowOffset numberOfRows: (int)aNumRows numberOfColumns: (int)aNumColumns columnStep: (int)aColumnStep
{
  NSMutableArray *matrices = [[[NSMutableArray alloc] init] keepWithAllocator: allocator];
  int numMatrices = [someMatrices count];
  int m;

  for(m = 0; m < numMatrices; m++)
  {
    NSArray *currentMatrices = [self matricesWithMatrix: [someMatrices objectAtIndex: m]
                                  rowOffset: aRowOffset
                                  numberOfRows: aNumRows
                                  numberOfColumns: aNumColumns
                                  columnStep: aColumnStep];

    [matrices addObjectsFromArray: currentMatrices];
  }

  return matrices;
}

-(NSArray*)columnMatricesWithMatrix:  (T4Matrix*)aMatrix
{
  return [self matricesWithMatrix: aMatrix rowOffset: 0 numberOfRows: -1 numberOfColumns: 1 columnStep: 1];
}

-(NSArray*)columnMatricesWithMatrices: (NSArray*)someMatrices
{
  return [self matricesWithMatrices: someMatrices rowOffset: 0 numberOfRows: -1 numberOfColumns: 1 columnStep: 1];  
}

@end
