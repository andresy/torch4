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
-copyMatrix: (T4Matrix*)aMatrix;
-fillWithValue: (real)aValue;
-zero;

-accumulateValue: (real)aValue dotMatrix: (T4Matrix*)aMatrix;
-(real)column: (int)aColumnIndex dotColumn: (int)aMatrixColumnIndex ofMatrix: (T4Matrix*)aMatrix;
-(real)dotMatrix: (T4Matrix*)aMatrix;
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
