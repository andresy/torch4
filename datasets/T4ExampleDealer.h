#import "T4Object.h"
#import "T4Matrix.h"

@interface T4ExampleDealer : T4Object

// \/ primitive \/ (only one method)
-(NSArray*)examplesWithArrayOfElements: (NSArray*)arrayOfMatrixArrays;
-(NSArray*)examplesWithElements: (NSArray*)someMatricesA elements: (NSArray*)someMatricesB;
-(NSArray*)examplesWithElements: (NSArray*)someMatricesA elements: (NSArray*)someMatricesB elements: (NSArray*)someMatricesC;

// \/ primitive \/ (only one method)
-(NSArray*)examplesWithMatrix:   (T4Matrix*)aMatrix      numberOfColumns: (int)aNumColumns columnStep: (int)aColumnStep elementSizes: (int*)someElementSizes numberOfElements: (int)aNumElements;
-(NSArray*)examplesWithMatrices:  (NSArray*)someMatrices numberOfColumns: (int)aNumColumns columnStep: (int)aColumnStep elementSizes: (int*)someElementSizes numberOfElements: (int)aNumElements;

-(NSArray*)columnExamplesWithMatrix:  (T4Matrix*)aMatrix;
-(NSArray*)columnExamplesWithMatrices: (NSArray*)someMatrices;

-(NSArray*)columnExamplesWithMatrix:  (T4Matrix*)aMatrix      elementSize: (int)anElementSize elementSize: (int)anotherElementSize;
-(NSArray*)columnExamplesWithMatrices: (NSArray*)someMatrices elementSize: (int)anElementSize elementSize: (int)anotherElementSize;

//
-(NSArray*)matricesWithMatrix: (T4Matrix*)aMatrix rowOffset: (int)aRowOffset numberOfRows: (int)aNumRows numberOfColumns: (int)aNumColumns columnStep: (int)aColumnStep;
-(NSArray*)matricesWithMatrices: (NSArray*)someMatrices rowOffset: (int)aRowOffset numberOfRows: (int)aNumRows numberOfColumns: (int)aNumColumns columnStep: (int)aColumnStep;
-(NSArray*)columnMatricesWithMatrix:  (T4Matrix*)aMatrix;
-(NSArray*)columnMatricesWithMatrices: (NSArray*)someMatrices;

@end
