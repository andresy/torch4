#import "T4ExampleDealer.h"

@implementation T4ExampleDealer

-(NSArray*)examplesWithMatrix:   (T4Matrix*)aMatrix      numberOfColumns: (int)aNumColumns columnStep: (int)aColumnStep elementSizes: (int*)someElementSizes numberOfElements: (int)aNumElements
{
  NSMutableArray *examples = [[[NSMutableArray alloc] init] keepWithAllocator: allocator];

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
