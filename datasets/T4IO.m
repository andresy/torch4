#import "T4IOAscii.h"

int *T4IOElementSizes(T4Allocator *allocator, int aNumElements, int aSize, va_list args)
{
  int *elementSizes = [allocator allocIntArrayWithCapacity: aNumElements];
  int i;

  elementSizes[0] = aSize;
  for(i = 1; i < aNumElements; i++)
    elementSizes[i] = va_arg(args, int);

  return elementSizes;
}

void T4IOGuessElementSizes(int *elementSizes, int aNumElements, int aNumRows)
{
  int sumElementSizes;
  int defaultSize;
  int i;

  sumElementSizes = 0;
  for(i = 0; i < aNumElements; i++)
  {
    if(elementSizes[i] > 0)
      sumElementSizes += elementSizes[i];
  }

  if(sumElementSizes > aNumRows)
    T4Error(@"IO: mismatch between number of rows in the file and example size");

  defaultSize = aNumRows-sumElementSize;

  sumElementSizes = 0;
  for(i = 0; i < aNumElements; i++)
  {
    if(elementSizes[i] < 0)
      elementSizes[i] = defaultElementSize;
    sumElementSizes += elementSizes[i];
  }

  if(sumElementSizes != aNumRows)
    T4Error(@"IO: mismatch between number of rows in the file and example size");
}

@implementation T4IOAscii

-init
{
  if( (self = [super init]) )
  {

  }
  return self;
}

-(T4Matrix*)loadMatrixAtPath: (NSString*)aPath transpose: (BOOL)isTransposed
{
  T4Matrix *matrix;
  int numRows, numColumns;
  T4File *file;

  file = [[T4DiskFile alloc] initForReadingAtPath: aPath];

  if(hasHeader)
  {
    [file readStringWithFormat: @"%d" into: numRows];
    [file readStringWithFormat: @"%d" into: numColumns];
    T4Message(@"IOAscii: %d rows and %d columns detected", numRows, numColumns);
  }
  else
  {
    numRows = 0;
    numColumns = -1;

    
    T4Message(@"IOAscii: %d rows and %d columns detected", numRows, numColumns);
  }

  matrix = [[T4Matrix alloc] initWithNumberOfRows: numRows numberOfColumns: numColumns];
  [allocator keepObject: matrix];
  
  data = [matrix firstColumn];
  if(isTransposed)
  {
    for(i = 0; i < numRows*numColumns; i++)
    {
#ifdef USE_DOUBLE
      [file readStringWithFormat: @"%lg" into: data[i]];
#else
      [file readStringWithFormat: @"%g" into: data[i]];
#endif
    }
  }
  else
  {
    int stride = [matrix stride];
    int r, c;

    for(r = 0; r < numRows; r++)
    {
      for(c = 0; c < numColumns; c++)
      {
#ifdef USE_DOUBLE
        [file readStringWithFormat: @"%lg" into: data[c*stride+r]];
#else
        [file readStringWithFormat: @"%g" into: data[c*stride+r]];
#endif
      }
    }
  }

  [file release];
  return matrix;
}

-(T4Matrix*)loadMatrixAtPath: (NSString*)aPath
{
  return [self loadMatrixAtPath: aPath transpose: NO];
}

-(NSArray*)loadExampleAtPath: (NSString*)aPath numberOfElements: (int)aNumElements elementSizes: (int)aSize, ...
{
  NSMutableArray *example;
  T4Matrix *fullMatrix;
  int numRows;
  int numColumns;
  int offset, stride;
  int *elementSizes;
  real *data;
  int i;

  va_list args;
  va_start(args, aSize);

  fullMatrix = [self loadMatrixAtPath: aPath transpose: YES];
  numRows = [fullMatrix numberOfRows];
  numColumns = [fullMatrix numberOfColumns];
  data = [fullMatrix firstColumn];
  stride = [fullMatrix stride];
  
  elementSizes = T4IOElementSizes(allocator, aNumElements, aSize, args);
  T4IOGuessElementSizes(elementSizes, aNumElements, numRows);

  example = [[[NSMutableArray alloc] initWithCapacity: aNumElements] keepWithAllocator: allocator];
  
  offset = 0;
  for(i = 0; i < aNumElements; i++)
  {
    T4Matrix *element = [[T4Matrix alloc] initWithRealData: data+offset
                                          numberOfRows: elementSizes[i]
                                          numberOfColumns: numColumns
                                          stride: stride];
    
    [allocator keepObject: element];
    [example addObject: element];
    offset += elementSize;
  }

  va_end(args);
  [allocator freePointer: elementSizes];
  return example;
}

-(NSArray*)loadExamplesAtPath: (NSString*)aPath numberOfElements: (int)aNumElements elementSizes: (int)aSize, ...
{
  NSMutableArray *examples;
  int e, i;

  T4Matrix *fullMatrix;
  int numRows;
  int numColumns;
  int *elementSizes;

  va_list args;
  va_start(args, aSize);

  fullMatrix = [self loadMatrixAtPath: aPath transpose: YES];
  numRows = [fullMatrix numberOfRows];
  numColumns = [fullMatrix numberOfColumns];
  
  elementSizes = T4IOElementSizes(allocator, aNumElements, aSize, args);
  T4IOGuessElementSizes(elementSizes, aNumElements, numRows);

  examples = [[[NSMutableArray alloc] initWithCapacity: numColumns] keepWithAllocator: allocator];
  for(e = 0; e < numColumns; e++)
  {
    int offset = 0;
    real *data = [fullMatrix columnAtIndex: e];
    NSMutableArray *example = [[[NSMutableArray alloc] initWithCapacity: aNumElements] keepWithAllocator: allocator];
    for(i = 0; i < aNumElements; i++)
    {
      T4Matrix *element = [[T4Matrix alloc] initWithRealData: data+offset
                                            numberOfRows: elementSizes[i]
                                            numberOfColumns: 1
                                            stride: -1];
      
      [allocator keepObject: element];
      [example addObject: element];
      offset += elementSize;
    }

    [examples addObject: example];
  }

  va_end(args);
  [allocator freePointer: elementSizes];
  return example;

}

-(NSArray*)loadMatrixAtEachPath: (NSArray*)somePaths
{
  int numPaths = [somePaths count];
  NSMutableArray *matrices = 
}

-(NSArray*)loadMatricesAtEachPath: (NSArray*)somePathes;
-(NSArray*)loadExampleAtEachPath: (NSArray*)somePathes numberOfElements: (int)aNumElements elementSizes: (int)aSize, ...;
-(NSArray*)loadExamplesAtEachPath: (NSArray*)somePathes numberOfElements: (int)aNumElements elementSizes: (int)aSize, ...;

-(void)saveMatrix: (T4Matrix*)aMatrix atPath: (NSString*)aPath;
-(void)saveMatrices: (NSArray*)someMatrices atPath: (NSString*)aPath;
-(void)saveExample: (NSArray*)anExample atPath: (NSString*)aPath;
-(void)saveExamples: (NSArray*)someExamples atPath: (NSString*)aPath;

@end
