#import "T4ClassMeasurer.h"

@implementation T4ClassMeasurer

-initWithInputs: (T4Matrix*)someInputs classFormat: (T4ClassFormat*)aClassFormat dataset: (NSArray*)aDataset file: (T4File*)aFile
{
  if( (self = [super initWithDataset: aDataset file: aFile]) )
  {
    inputs = someInputs;
    classFormat = aClassFormat;
    confusionMatrix = nil;

    [self setPrintsConfusionMatrix: NO];
    [self reset];

    [allocator retainAndKeepObject: classFormat];
    [allocator retainAndKeepObject: inputs];
  }

  return self;
}

-measureExampleAtIndex: (int)anIndex
{
  T4Matrix *targets = [[dataset objectAtIndex: anIndex] objectAtIndex: 1];
  int numColumns = [inputs numberOfColumns];
  int c;

  for(c = 0; c < numColumns; c++)
  {
    int classInputs = [classFormat classFromRealData: [inputs columnAtIndex: c]];
    int classTargets = [classFormat classFromRealData: [targets columnAtIndex: c]];
    
    if(classInputs != classTargets)
      internalError += 1.;

    if(computeConfusionMatrix)
      [confusionMatrix columnAtIndex: classTargets][classInputs]++;    
  }
  
  totalNumColumns += numColumns;

  return self;
}

-measureAtIteration: (int)anIteration
{
  internalError /= (real)totalNumColumns;

  [file writeStringWithFormat: @"%g\n", internalError];
  if(computeConfusionMatrix)
    [file writeStringWithFormat: @"%@\n", confusionMatrix];
  [file synchronizeFile];

  [self reset];

  return self;
}

-reset
{
  internalError = 0;

  if(computeConfusionMatrix)
    [confusionMatrix zero];

  totalNumColumns = 0;

  return self;
}

-setPrintsConfusionMatrix: (BOOL)aFlag
{
  int numClasses = [classFormat numberOfClasses];

  computeConfusionMatrix = aFlag;

  if(computeConfusionMatrix)
  {
    confusionMatrix = [[T4Matrix alloc] initWithNumberOfRows: numClasses numberOfColumns: numClasses];
    [allocator keepObject: confusionMatrix];
  }
  else
  {
    [allocator freeObject: confusionMatrix];
    confusionMatrix = nil;
  }

  return self;
}

@end
