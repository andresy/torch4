#import "T4Loader.h"
#import "T4DiskFile.h"

@implementation T4Loader

-init
{
  if( (self = [super init]) )
  {
    [self setMaxNumberOfMatrices: -1];
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

  return [matrices autorelease];
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

  return [matrices autorelease];
}

-setMaxNumberOfMatrices: (int)aMaxNumber
{
  maxNumMatrices = aMaxNumber;
  return self;
}

@end
