#import "T4Object.h"
#import "T4Matrix.h"

@interface T4ExampleDealer : T4Object

// \/ primitive \/ (only one method)
-(NSArray*)examplesWithMatrix:   (T4Matrix*)aMatrix      numberOfColumns: (int)aNumColumns columnStep: (int)aColumnStep elementSizes: (int*)someElementSizes numberOfElements: (int)aNumElements;
-(NSArray*)examplesWithMatrices:  (NSArray*)someMatrices numberOfColumns: (int)aNumColumns columnStep: (int)aColumnStep elementSizes: (int*)someElementSizes numberOfElements: (int)aNumElements;

-(NSArray*)columnExamplesWithMatrix:  (T4Matrix*)aMatrix;
-(NSArray*)columnExamplesWithMatrices: (NSArray*)someMatrices;

-(NSArray*)columnExamplesWithMatrix:  (T4Matrix*)aMatrix      elementSize: (int)anElementSize elementSize: (int)anotherElementSize;
-(NSArray*)columnExamplesWithMatrices: (NSArray*)someMatrices elementSize: (int)anElementSize elementSize: (int)anotherElementSize;

@end