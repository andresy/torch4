#import "T4Object.h"
#import "T4Matrix.h"
#import "T4File.h"

@interface T4Loader : T4Object
{
    int maxNumMatrices;
}

-init;

//primitive
-(T4Matrix*)loadMatrixFromFile: (T4File*)aFile;

-(T4Matrix*)loadMatrixAtPath: (NSString*)aPath;
-(NSArray*)loadMatricesFromFiles: (NSArray*)someFiles;
-(NSArray*)loadMatricesAtPaths: (NSArray*)somePaths;

-setMaxNumberOfMatrices: (int)aMaxNumber;

@end
