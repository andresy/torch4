#import "T4Object.h"

@interface T4IO : T4Object
{
}

//primitive
-(T4Matrix*)loadMatrixFromFile: (T4File*)aFile transpose: (BOOL)isTransposed;
-(T4Matrix*)loadMatrixAtPath: (NSString*)aPath transpose: (BOOL)isTransposed;

-(T4Matrix*)loadMatrixFromFile: (T4File*)aFile;
-(T4Matrix*)loadMatrixAtPath: (NSString*)aPath;

-(NSArray*)loadExampleAtPath: (NSString*)aPath numberOfElements: (int)aNumElements elementSizes: (int)aSize, ...;
-(NSArray*)loadExamplesAtPath: (NSString*)aPath numberOfElements: (int)aNumElements elementSizes: (int)aSize, ...;
-(NSArray*)loadExampleAtEachPath: (NSArray*)somePathes numberOfElements: (int)aNumElements elementSizes: (int)aSize, ...;
-(NSArray*)loadExamplesAtEachPath: (NSArray*)somePathes numberOfElements: (int)aNumElements elementSizes: (int)aSize, ...;

//primitive [default uses loadMatrixAtPath: transpose:]
-(NSArray*)loadExampleWithElementsAtPaths: (NSArray*)somePathes;
-(NSArray*)loadExamplesWithElementsAtPaths: (NSArray*)somePathes;

-(void)saveMatrix: (T4Matrix*)aMatrix atPath: (NSString*)aPath;
-(void)saveExample: (NSArray*)anExample atPath: (NSString*)aPath;
-(void)saveExamples: (NSArray*)someExamples atPath: (NSString*)aPath;

//internal
-(NSArray*)loadExampleAtPath: (T4File*)aFile elementSizes: (int*)someElementSizes numberOfElements: (int)aNumElements;

@end
