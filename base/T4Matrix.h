#import "T4Object.h"

@interface T4Matrix : T4Object
{
    real *data;
    int dataSize;
    int numRows;
    int numColumns;
    int stride;
}

-init;
-initWithNumberOfRows: (int)aNumRows numberOfColumns: (int)aNumColumns;
-initWithNumberOfRows: (int)aNumRows;
-initWithRealData: (real*)aData numberOfRows: (int)aNumRows numberOfColumns: (int)aNumColumns stride: (int)aStride;
-initWithSubMatrix: (T4Matrix*)aMatrix firstRowIndex: (int)aFirstRowIndex firstColumnIndex: (int)aFirstColumnIndex numberOfRows: (int)aNumRows numberOfColumns: (int)aNumColumns;
-initWithColumn: (int)aColumnIndex fromMatrix: (T4Matrix*)aMatrix;

-setMatrixFromRealData: (real*)aData numberOfRows: (int)aNumRows numberOfColumns: (int)aNumColumns stride: (int)aStride;

-(real*)columnAtIndex: (int)aColumnIndex;

-resizeWithNumberOfRows: (int)aNumRows numberOfColumns: (int)aNumColumns;
-resizeWithNumberOfRows: (int)aNumRows;
-resizeWithNumberOfColumns: (int)aNumColumns;

-fillWithValue: (real)aValue;
-zero;

-copyMatrix: (T4Matrix*)aMatrix;
-copyFromRealData: (real*)aRealData stride: (int)aStride;
-copyToRealData: (real*)aRealData stride: (int)aStride;

-addMatrix: (T4Matrix*)aMatrix;
-addValue: (real)aValue dotSumMatrixColumns: (T4Matrix*)aMatrix;
-addValue: (real)aValue dotMatrix: (T4Matrix*)aMatrix;
-addFromRealData: (real*)aRealData stride: (int)aStride;
-addToRealData: (real*)aRealData stride: (int)aStride;

-(real)column: (int)aColumnIndex dotColumn: (int)aMatrixColumnIndex ofMatrix: (T4Matrix*)aMatrix;
-(real)dotMatrix: (T4Matrix*)aMatrix;

-dotValue: (real)aValue1 addValue: (real)aValue2 dotMatrix:   (T4Matrix*)aMatrix1 dotMatrix:   (T4Matrix*)aMatrix2;
-dotValue: (real)aValue1 addValue: (real)aValue2 dotTrMatrix: (T4Matrix*)aMatrix1 dotMatrix:   (T4Matrix*)aMatrix2;
-dotValue: (real)aValue1 addValue: (real)aValue2 dotMatrix:   (T4Matrix*)aMatrix1 dotTrMatrix: (T4Matrix*)aMatrix2;
-dotValue: (real)aValue1 addValue: (real)aValue2 dotTrMatrix: (T4Matrix*)aMatrix1 dotTrMatrix: (T4Matrix*)aMatrix2;

-(real)getMinRowIndex: (int*)aRowIndex columnIndex: (int*)aColumnIndex;
-(real)getMaxRowIndex: (int*)aRowIndex columnIndex: (int*)aColumnIndex;

-(int)numberOfColumns;
-(int)numberOfRows;
-(int)stride;
-(real*)realData;

-(NSString*)description;

@end
