#import "T4ClassMeasurer.h"

@implementation T4ClassMeasurer

-initWithInputs: (T4Matrix*)someInputs classFormat: (T4ClassFormat*)aClassFormat dataset: (NSArray*)aDataset file: (T4File*)aFile
{
  return [self initWithInputs: someInputs classFormat: aClassFormat dataset: aDataset classFormat: aClassFormat file: (T4File*)aFile];

}

-initWithInputs: (T4Matrix*)someInputs classFormat: (T4ClassFormat*)aClassFormat dataset: (NSArray*)aDataset classFormat: (T4ClassFormat*)anotherClassFormat file: (T4File*)aFile
{
  if( (self = [super initWithDataset: aDataset file: aFile]) )
  {
    inputs = someInputs;
    inputClassFormat = aClassFormat;
    datasetClassFormat = anotherClassFormat;
    confusionMatrix = nil;

    [self setPrintsConfusionMatrix: NO];
    [self reset];

    [allocator retainAndKeepObject: inputClassFormat];
    [allocator retainAndKeepObject: datasetClassFormat];
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
    int classInputs = [inputClassFormat classFromRealData: [inputs columnAtIndex: c]];
    int classTargets = [inputClassFormat classFromRealData: [datasetClassFormat encodingForClass: (int)[targets firstValueAtColumn: c]]];
    
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
  int numClasses = [inputClassFormat numberOfClasses];

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
