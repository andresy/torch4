#import "T4Object.h"
#import "T4Matrix.h"
#import "T4File.h"

@interface T4Saver : T4Object

-init;

//primitive
-saveMatrix: (T4Matrix*)aMatrix intoFile: (T4File*)aFile;

-saveMatrix: (T4Matrix*)aMatrix atPath: (NSString*)aPath;
-saveMatrices: (NSArray*)someMatrices intoFiles: (NSArray*)someFiles;
-saveMatrices: (NSArray*)someMatrices atPaths: (NSArray*)somePaths;

@end
