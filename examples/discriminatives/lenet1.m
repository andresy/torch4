#import "T4Timer.h"
#import "T4Matrix.h"
#import "T4ClassNLLCriterion.h"
#import "T4Random.h"
#import "T4CommandLine.h"
#import "T4DatasetClassFormat.h"
#import "T4OneHotClassFormat.h"
#import "T4ClassMeasurer.h"
#import "T4DiskFile.h"
#import "T4ArrayFile.h"
#import "T4StandardNormalizer.h"
#import "T4ExampleDealer.h"
#import "T4BinaryLoader.h"

#import "T4SequentialMachine.h"
#import "T4Linear.h"
#import "T4SpatialConvolution.h"
#import "T4SpatialSubSampling.h"
#import "T4HardTanh.h"
#import "T4LogSoftMax.h"

#define trainMode 0
#define testMode 1

int main( int argc, char *argv[] )
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  int trainingClass;
  real learningRate;
  real endAccuracy;
  int maxIter;
  NSString *trainFileName;
  NSString *validFileName;
  NSString *modelFileName;
  int seed;
  int maxLoad, maxLoadValid;

  int inputWidth, inputHeight;
  int convNumPlanes, convKW, convKH, convDW, convDH;
  int subKW, subKH, subDW, subDH;
  int numHU;

  // command line ----------------------------------------------------------------------------------

  T4CommandLine *cmdLine = [[[T4CommandLine alloc] initWithArgv: argv argc: argc] autorelease];

  [cmdLine addStringArgument: @"file" at: &trainFileName help: @"training file"];
  [cmdLine addIntArgument: @"width" at: &inputWidth help: @"image input width"];
  [cmdLine addIntArgument: @"height" at: &inputHeight help: @"image input height"];

  [cmdLine addText: @"\nModel options:\n"];
  [cmdLine addIntOption: @"-cnp" at: &convNumPlanes default: 10 help: @"number of planes"];
  [cmdLine addIntOption: @"-ckw" at: &convKW default: 3 help: @"kernel size X"];
  [cmdLine addIntOption: @"-ckh" at: &convKH default: 3 help: @"kernel size Y"];
  [cmdLine addIntOption: @"-cdw" at: &convDW default: 1 help: @"kernel step X"];
  [cmdLine addIntOption: @"-cdh" at: &convDH default: 1 help: @"kernel step Y"];
  [cmdLine addText: @"-------------"];
  [cmdLine addIntOption: @"-skw" at: &subKW default: 3 help: @"kernel size X"];
  [cmdLine addIntOption: @"-skh" at: &subKH default: 3 help: @"kernel size Y"];
  [cmdLine addIntOption: @"-sdw" at: &subDW default: 1 help: @"kernel step X"];
  [cmdLine addIntOption: @"-sdh" at: &subDH default: 1 help: @"kernel step Y"];
  [cmdLine addText: @"-------------"];
  [cmdLine addIntOption: @"-nhu" at: &numHU default: 10 help: @"number of hidden units"];

  [cmdLine addText: @"\nTraining options:\n"];
  [cmdLine addIntOption: @"-class" at: &trainingClass default: -1 help: @"class to train against the others"];
  [cmdLine addRealOption: @"-lr" at: &learningRate default: 0.01 help: @"learning rate"];
  [cmdLine addRealOption: @"-e" at: &endAccuracy default: 0.00001 help: @"end accuracy"];
  [cmdLine addIntOption: @"-iter" at: &maxIter default: 25 help: @"maximum number of iterations"];

  [cmdLine addText: @"\nMisc options:\n"];
  [cmdLine addIntOption: @"-seed" at: &seed default: 5776 help: @"the random seed"];
  [cmdLine addStringOption: @"-valid" at: &validFileName default: @"" help: @"validation file"];
  [cmdLine addStringOption: @"-save" at: &modelFileName default: @"" help: @"save into a model file"];
  [cmdLine addIntOption: @"-load" at: &maxLoad default: -1 help: @"max number of examples to load"];
  [cmdLine addIntOption: @"-loadValid" at: &maxLoadValid default: -1 help: @"max number of examples to load for validation"];

  [cmdLine addMasterSwitch: @"--test"];
  [cmdLine addStringArgument: @"model" at: &modelFileName help: @"model file"];
  [cmdLine addStringArgument: @"file" at: &trainFileName help: @"testing file"];
  [cmdLine addText: @"\nTesting options:\n"];
  [cmdLine addIntOption: @"-class" at: &trainingClass default: -1 help: @"class to train against the others"];

  [cmdLine addText: @"\nMisc options:\n"];
  [cmdLine addIntOption: @"-load" at: &maxLoad default: -1 help: @"max number of examples to load"];
                                                         
  [cmdLine addText: @"\n"];
  int cmdLineMode = [cmdLine read];

  // random ----------------------------------------------------------------------------------------

  [T4Random setSeed: (long)seed];

  // archive ---------------------------------------------------------------------------------------

  NSUnarchiver *archiver = nil;
  if(cmdLineMode == testMode)
  {
    NSMutableData *modelData = [[NSData alloc] initWithContentsOfFile: modelFileName];
    archiver = [[[NSUnarchiver alloc] initForReadingWithData: modelData] autorelease];
    [modelData release];
  }

  // datasets --------------------------------------------------------------------------------------

  T4BinaryLoader *loader = [[[T4BinaryLoader alloc] init] autorelease];
  T4ExampleDealer *dealer = [[[T4ExampleDealer alloc] init] autorelease];
  [T4DiskFile setLittleEndianEncoding];
  [loader setEnforcesFloatEncoding: YES];
  [loader setMaxNumberOfColumns: maxLoad];

  NSArray *examples = [dealer columnExamplesWithMatrix: [loader loadMatrixAtPath: trainFileName] elementSize: -1 elementSize: 1];
  
  T4StandardNormalizer *normalizer;

  if(cmdLineMode == trainMode)
    normalizer = [[T4StandardNormalizer alloc] initWithDataset: examples];
  else
    normalizer = [archiver decodeObject];

  [normalizer normalizeDataset: examples];

  NSArray *validExamples = nil;
  if(cmdLineMode == trainMode)
  {
    if(![validFileName isEqualToString: @""])
    {
      [loader setMaxNumberOfColumns: maxLoadValid];
      validExamples = [dealer columnExamplesWithMatrix: [loader loadMatrixAtPath: validFileName] elementSize: -1 elementSize: 1];
      [normalizer normalizeDataset: validExamples];
    }
  }

  // class formats ---------------------------------------------------------------------------------

  T4ClassFormat *inputClassFormat, *datasetClassFormat;

  if(trainingClass > 0)
  {
    datasetClassFormat = [[[T4DatasetClassFormat alloc] initWithDataset: examples classAgainstOthers: trainingClass] autorelease];
    inputClassFormat = [[[T4OneHotClassFormat alloc] initWithNumberOfClasses: 2] autorelease];
  }
  else
  {
    datasetClassFormat = [[[T4DatasetClassFormat alloc] initWithDataset: examples] autorelease];
    inputClassFormat = [[[T4OneHotClassFormat alloc] initWithNumberOfClasses: [datasetClassFormat numberOfClasses]] autorelease];
  }

  // model -----------------------------------------------------------------------------------------

  T4SequentialMachine *mlp;

  if(cmdLineMode == trainMode)
  {
    T4ClassNLLCriterion *criterion;
    id c1, c2, c3, c4, c5, c6, c7, c8;
    int numOutputs = [datasetClassFormat numberOfClasses];
    
    T4Message(@"Building mlp... [%d inputs, %d outputs]", [[[examples objectAtIndex: 0] objectAtIndex: 0] numberOfRows], numOutputs);
  
    mlp = [[[T4SequentialMachine alloc] init] autorelease];
  
    c1 = [[[T4SpatialConvolution alloc] initWithNumberOfInputPlanes: 1
                                        numberOfOutputPlanes: convNumPlanes
                                        inputWidth: inputWidth
                                        inputHeight: inputHeight
                                        kernelWidth: convKW
                                        kernelHeight: convKH
                                        kernelWidthStep: convDW
                                        kernelHeightStep: convDH] autorelease];

    c2 = [[[T4HardTanh alloc] initWithNumberOfUnits: [c1 numberOfOutputs]] autorelease];
    
    c3 = [[[T4SpatialSubSampling alloc] initWithNumberOfInputPlanes: [c1 numberOfOutputPlanes]
                                        inputWidth: [c1 outputWidth]
                                        outputHeight: [c1 outputHeight]
                                        kernelWidth: subKW
                                        kernelHeight: subKH
                                        kernelWidthStep: subDW
                                        kernelHeightStep: subDH] autorelease];


    c4 = [[[T4HardTanh alloc] initWithNumberOfUnits: [c3 numberOfOutputs]] autorelease];

    c5 = [[[T4Linear alloc] initWithNumberOfInputs: [c4 numberOfOutputs] numberOfOutputs: numHU] autorelease];

    c6 = [[[T4HardTanh alloc] initWithNumberOfUnits: [c5 numberOfOutputs]] autorelease];

    c7 = [[[T4Linear alloc] initWithNumberOfInputs: [c6 numberOfOutputs] numberOfOutputs: numOutputs] autorelease];

    c8 = [[[T4LogSoftMax alloc] initWithNumberOfUnits: numOutputs] autorelease];

    [mlp addMachine: c1];
    [mlp addMachine: c2];
    [mlp addMachine: c3];
    [mlp addMachine: c4];
    [mlp addMachine: c5];
    [mlp addMachine: c6];
    [mlp addMachine: c7];
    [mlp addMachine: c8];

    // criterion
    criterion = [[[T4ClassNLLCriterion alloc] initWithDatasetClassFormat: datasetClassFormat] autorelease];

    [mlp setCriterion: criterion];
    [mlp setPartialBackpropagation: YES];
    [mlp setMaxNumberOfIterations: maxIter];
    [mlp setLearningRate: learningRate];
    [mlp setEndAccuracy: endAccuracy];
  }
  else
  {
    mlp = [archiver decodeObject];
  }

  // measurer --------------------------------------------------------------------------------------

  T4Message(@"Measurers...");

  NSMutableArray *measurers = [[[NSMutableArray alloc] init] autorelease];

  T4DiskFile *classFile = [[[T4DiskFile alloc] initForWritingAtPath: @"the_class_err"] autorelease];
  T4ClassMeasurer *classMeas = [[[T4ClassMeasurer alloc] initWithInputs: [mlp outputs] classFormat: inputClassFormat
                                                         dataset: examples classFormat: datasetClassFormat
                                                         file: classFile] autorelease];    
  [measurers addObject: [classMeas setPrintsConfusionMatrix: YES]];
  
  if(cmdLineMode == trainMode)
  {
    if(![validFileName isEqualToString: @""])
    {
      T4DiskFile *validClassFile = [[[T4DiskFile alloc] initForWritingAtPath: @"the_valid_class_err"] autorelease];
      T4ClassMeasurer *validClassMeas = [[[T4ClassMeasurer alloc] initWithInputs: [mlp outputs] classFormat: inputClassFormat
                                                                  dataset: validExamples classFormat: datasetClassFormat
                                                                  file: validClassFile] autorelease];    
      [measurers addObject: validClassMeas];
    }
  }

  // train or test ---------------------------------------------------------------------------------

  T4Message(@"The MLP has %d parameters...", [mlp numberOfParameters], modelFileName);

  T4Timer *timer = [[[T4Timer alloc] init] autorelease];
  if(cmdLineMode == trainMode)
  {
    [mlp trainWithDataset: examples measurers: measurers];
    
    if(![modelFileName isEqualToString: @""])
    {
      NSMutableData *data = [NSMutableData data];
      archiver = [[[NSArchiver alloc] initForWritingWithMutableData: data] autorelease];
      [archiver encodeObject: normalizer];
      [archiver encodeObject: mlp];
      [data writeToFile: modelFileName atomically: NO];
    }
  }
  else
    [mlp testWithMeasurers: measurers];
  T4Message(@"Time = <%g> seconds", [timer time]);

  [pool release];

  return 0;
}
