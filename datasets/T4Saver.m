#import "T4Saver.h"
#import "T4DiskFile.h"

@implementation T4Saver

-init
{
  if( (self = [super init]) )
  {
  }

  return self;

}

-saveMatrix: (T4Matrix*)aMatrix intoFile: (T4File*)aFile
{
  return [self subclassResponsibility: _cmd];
}

-saveMatrix: (T4Matrix*)aMatrix atPath: (NSString*)aPath;
{
  T4DiskFile *file = [[T4DiskFile alloc] initForWritingAtPath: aPath];
  [self saveMatrix: aMatrix intoFile: file];
  [file release];

  return self;
}

-saveMatrices: (NSArray*)someMatrices intoFiles: (NSArray*)someFiles
{
  int numFiles = [someFiles count];
  int numMatrices = [someMatrices count];
  int i;

  if(numFiles != numMatrices)
    T4Error(@"Saver: incompatible number of files and matrices");
 
  for(i = 0; i < numFiles; i++)
    [self saveMatrix: [someMatrices objectAtIndex: i] intoFile: [someFiles objectAtIndex: i]];

  return self;
}

-saveMatrices: (NSArray*)someMatrices atPaths: (NSArray*)somePaths
{
  int numPaths = [somePaths count];
  int numMatrices = [someMatrices count];
  int i;

  if(numPaths != numMatrices)
    T4Error(@"Saver: incompatible number of paths and matrices");
 
  for(i = 0; i < numPaths; i++)
  {
    T4DiskFile *file = [[T4DiskFile alloc] initForReadingAtPath: [somePaths objectAtIndex: i]];
    [self saveMatrix: [someMatrices objectAtIndex: i] intoFile: file];
    [file release];
  }

  return self;
}

@end
