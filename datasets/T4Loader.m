#import "T4Loader.h"
#import "T4DiskFile.h"

@implementation T4Loader

-init
{
  if( (self = [super init]) )
  {
    [self setMaxNumberOfColumns: -1];
    [self setMaxNumberOfMatrices: -1];
    [self setTransposesMatrix: YES];
  }

  return self;

}

-(T4Matrix*)loadMatrixFromFile: (T4File*)aFile
{
  [self subclassResponsibility: _cmd];
  return nil;
}

-(T4Matrix*)loadMatrixAtPath: (NSString*)aPath
{
  T4DiskFile *file = [[T4DiskFile alloc] initForReadingAtPath: aPath];
  T4Matrix *matrix = [self loadMatrixFromFile: file];
  [file release];
  return matrix;
}

-(NSArray*)loadMatricesFromFiles: (NSArray*)someFiles
{
  int numFiles = [someFiles count];
  NSMutableArray *matrices = [[NSMutableArray alloc] initWithCapacity: numFiles];
  int i;

  if( (maxNumMatrices > 0) && (maxNumMatrices < numFiles) )
    numFiles = maxNumMatrices;

  for(i = 0; i < numFiles; i++)
    [matrices addObject: [self loadMatrixFromFile: [someFiles objectAtIndex: i]]];

  [allocator keepObject: matrices];
  return matrices;
}

-(NSArray*)loadMatricesAtPaths: (NSArray*)somePaths
{
  int numFiles = [somePaths count];
  NSMutableArray *matrices = [[NSMutableArray alloc] initWithCapacity: numFiles];
  int i;

  if( (maxNumMatrices > 0) && (maxNumMatrices < numFiles) )
    numFiles = maxNumMatrices;

  for(i = 0; i < numFiles; i++)
  {
    T4DiskFile *file = [[T4DiskFile alloc] initForReadingAtPath: [somePaths objectAtIndex: i]];
    [matrices addObject: [self loadMatrixFromFile: file]];
    [file release];
  }

  [allocator keepObject: matrices];
  return matrices;
}

-(void)setMaxNumberOfColumns: (int)aMaxNumber
{
  maxNumColumns = aMaxNumber;
}

-(void)setMaxNumberOfMatrices: (int)aMaxNumber
{
  maxNumMatrices = aMaxNumber;
}

-(void)setTransposesMatrix: (BOOL)aFlag
{
  transposesMatrix = aFlag;
}

@end
