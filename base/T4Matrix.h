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
-initWithData: (real*)aData numberOfRows: (int)aNumRows numberOfColumns: (int)aNumColumns stride: (int)aStride;
-initWithSubMatrix: (T4Matrix*)aMatrix firstRowIndex: (int)aFirstRowIndex firstColumnIndex: (int)aFirstColumnIndex numberOfRows: (int)aNumRows numberOfColumns: (int)aNumColumns;
-initWithColumn: (int)aColumnIndex fromMatrix: (T4Matrix*)aMatrix;

-setMatrixFromData: (real*)aData numberOfRows: (int)aNumRows numberOfColumns: (int)aNumColumns stride: (int)aStride;

-(real*)columnAtIndex: (int)aColumnIndex;

-resizeWithNumberOfRows: (int)aNumRows numberOfColumns: (int)aNumColumns;
-resizeWithNumberOfColumns: (int)aNumColumns;

-fillWithValue: (real)aValue;
-zero;

-copyMatrix: (T4Matrix*)aMatrix;
-copyFromAddress: (real*)anAddress stride: (int)aStride;
-copyToAddress: (real*)anAddress stride: (int)aStride;

-addMatrix: (T4Matrix*)aMatrix;
-addValue: (real)aValue dotMatrix: (T4Matrix*)aMatrix;
-addFromAddress: (real*)anAddress stride: (int)aStride;
-addToAddress: (real*)anAddress stride: (int)aStride;

-(real)column: (int)aColumnIndex dotColumn: (int)aMatrixColumnIndex ofMatrix: (T4Matrix*)aMatrix;
-(real)dotMatrix: (T4Matrix*)aMatrix;

-dotValue: (real)aValue1 plusValue: (real)aValue2 dotMatrix: (T4Matrix*)aMatrix1 dotMatrix: (T4Matrix*)aMatrix2;

//    real innerProduct(Matrix *matrix, int column_index=0, int column_index_matrix=0);

// -dotValue: (real)aValue1 
// void dotSaccSdotMdotM(real scalar1, real scalar2, Matrix *matrix1, Matrix *matrix2);
//     void dotSaccSdotTMdotM(real scalar1, real scalar2, Matrix *matrix1, Matrix *matrix2);
//     void accSdotMextM(real scalar, Matrix *matrix1, Matrix *matrix2, int column_index1=0, int column_index2=0);

-(real)getMinRowIndex: (int*)aRowIndex columnIndex: (int*)aColumnIndex;
-(real)getMaxRowIndex: (int*)aRowIndex columnIndex: (int*)aColumnIndex;

-(int)numberOfColumns;
-(int)numberOfRows;
-(int)stride;
-(real*)data;

@end
