#include "T4Object.h"

@interface T4Matrix : T4Object
{
    real *data;
    int dataSize;
    int nRows;
    int nColumns;
    int stride;
}

-init;
-initWithNRows: (int)aNRows nColumns: (int)aNColumns;
-initWithNRows: (int)aNRows;
-initWithData: (real*)aData nRows: (int)aNRows nColumns: (int)aNColumns stride: (int)aStride;
-initWithSubMatrix: (T4Matrix*)aMatrix startingRow: (int)aStartingRow startingColumn: (int)aStartingColumn nRows: (int)aNRows nColumns: (int)aNColumns;
-initWithColumn: (int)aColumnIndex fromMatrix: (T4Matrix*)aMatrix;

-setMatrixFromData: (real*)aData nRows: (int)aNRows nColumns: (int)aNColumns stride: (int)aStride;

-(real*)getColumn: (int)aColumnIndex;

-resizeWithNRows: (int)aNRows nColumns: (int)aNColumns;
-resizeWithNColumns: (int)aNColumns;
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

-(int)nColumns;
-(int)nRows;
-(int)stride;    
-(real*)data;

@end
