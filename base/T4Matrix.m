#import "T4Matrix.h"
#import "cblas.h"

inline void T4MatrixDotMatrix(real aValue1, real *destMat, int destStride,
                              real aValue2, real *srcMat1, int srcStride1,
                              real *srcMat2, int srcStride2,
                              int destNumRows, int destNumColumns, int srcNum)
{
  if(destNumColumns == 1)
  {
#ifdef USE_DOUBLE
    cblas_dgemv(CblasColMajor, CblasNoTrans, destNumRows, srcNum,
                aValue2, srcMat1, srcStride1, srcMat2, 1, aValue1, destMat, 1);
#else
    cblas_sgemv(CblasColMajor, CblasNoTrans, destNumRows, srcNum,
                aValue2, srcMat1, srcStride1, srcMat2, 1, aValue1, destMat, 1);
#endif
  }
  else
  {
#ifdef USE_DOUBLE
    cblas_dgemm(CblasColMajor, CblasNoTrans, CblasNoTrans, destNumRows, destNumColumns,
                srcNum, aValue2, srcMat1, srcStride1, srcMat2, srcStride2,
                aValue1, destMat, destStride);
#else
    cblas_sgemm(CblasColMajor, CblasNoTrans, CblasNoTrans, destNumRows, destNumColumns,
                srcNum, aValue2, srcMat1, srcStride1, srcMat2, srcStride2,
                aValue1, destMat, destStride);
#endif
  }
}

inline void T4CopyMatrix(real *destAddr, int destStride, real *sourceAddr, int sourceStride, int numRows, int numColumns)
{
  if( (sourceStride == numRows) && (destStride == numRows) )
    memmove(destAddr, sourceAddr, sizeof(real)*numRows*numColumns);
  else
  {
    int c;
    for(c = 0; c < numColumns; c++)
    {
      memmove(destAddr, sourceAddr, sizeof(real)*numRows);
      sourceAddr += sourceStride;
      destAddr += destStride;
    }
  }
}

inline void T4AddMatrix(real *destAddr, int destStride, real aValue, real *sourceAddr, int sourceStride, int numRows, int numColumns)
{
  if(numColumns == 1)
  {
#ifdef USE_DOUBLE
    cblas_daxpy(numRows, aValue, sourceAddr, 1, destAddr, 1);
#else
    cblas_saxpy(numRows, aValue, sourceAddr, 1, destAddr, 1);
#endif
  }
  else
  {
    if( (numRows == destStride) && (numRows == sourceStride) )
    {
#ifdef USE_DOUBLE
      cblas_daxpy(numRows*numColumns, aValue, sourceAddr, 1, destAddr, 1);
#else
      cblas_saxpy(numRows*numColumns, aValue, sourceAddr, 1, destAddr, 1);
#endif
    }
    else
    {
      int c;
      for(c = 0; c < numColumns; c++)
      {
#ifdef USE_DOUBLE
        cblas_daxpy(numRows, aValue, sourceAddr, 1, destAddr, 1);
#else
        cblas_saxpy(numRows, aValue, sourceAddr, 1, destAddr, 1);
#endif
        sourceAddr += sourceStride;
        destAddr += destStride;
      }
    }
  }
}

@implementation T4Matrix

-initWithData: (real*)aData numberOfRows: (int)aNumRows numberOfColumns: (int)aNumColumns stride: (int)aStride
{
  if( (self = [super init]) )
  {
    numRows = (aNumRows > 0 ? aNumRows : 0);
    numColumns = (aNumColumns > 0 ? aNumColumns : 0);
    stride = (aStride > 0 ? aStride : numRows);
    if( (aData == NULL) && (numRows > 0) && (numColumns > 0) )
    {
      data = [allocator allocRealArrayWithCapacity: numRows*numColumns];
      dataSize = numRows*numColumns;
    }
    else
    {
      data = aData;
      dataSize = 0;
    }
  }
  return self;
}

-init
{
  return [self initWithData: NULL numberOfRows: 0 numberOfColumns: 0 stride: 0];
}

-initWithNumberOfRows: (int)aNumRows numberOfColumns: (int)aNumColumns
{
  return [self initWithData: NULL numberOfRows: aNumRows numberOfColumns: aNumColumns stride: aNumRows];
}

-initWithNumberOfRows: (int)aNumRows
{
  return [self initWithData: NULL numberOfRows: aNumRows numberOfColumns: 1 stride: aNumRows];
}

-initWithSubMatrix: (T4Matrix*)aMatrix firstRowIndex: (int)aFirstRowIndex firstColumnIndex: (int)aFirstColumnIndex numberOfRows: (int)aNumRows numberOfColumns: (int)aNumColumns
{
  if(aFirstColumnIndex < 0)
    aFirstColumnIndex = 0;
  if(aFirstRowIndex < 0)
    aFirstRowIndex = 0;

  return [self initWithData: [aMatrix columnAtIndex: aFirstColumnIndex]+aFirstRowIndex
               numberOfRows: (aNumRows < 0 ? [aMatrix numberOfRows] : aNumRows-aFirstRowIndex)
               numberOfColumns: (aNumColumns < 0 ? [aMatrix numberOfColumns] : aNumColumns-aFirstColumnIndex)
               stride: [aMatrix stride]];
}

-initWithColumn: (int)aColumnIndex fromMatrix: (T4Matrix*)aMatrix
{
  return [self initWithData: [aMatrix columnAtIndex: aColumnIndex]
               numberOfRows: [aMatrix numberOfRows]
               numberOfColumns: 1
               stride: [aMatrix stride]];
}


-setMatrixFromData: (real*)aData numberOfRows: (int)aNumRows numberOfColumns: (int)aNumColumns stride: (int)aStride
{
  numRows = aNumRows;
  numColumns = aNumColumns;
  if(aStride > 0)
    stride = aStride;
  else
    stride = numRows;
  data = aData;
  dataSize = 0;

  return self;
}

-(real*)columnAtIndex: (int)aColumnIndex
{
  return data+aColumnIndex*stride;
}

-resizeWithNumberOfRows: (int)aNumRows numberOfColumns: (int)aNumColumns
{
  numRows = (aNumRows > 0 ? aNumRows : numRows);
  numColumns = (aNumColumns > 0 ? aNumColumns : numColumns);
  stride = numRows;

  if([allocator isMyPointer: data])
  {
    if(numRows*numColumns > dataSize)
    {
      [allocator freePointer: data];
      data = [allocator allocRealArrayWithCapacity: numRows*numColumns];
      dataSize = numRows*numColumns;
    }
  }
  else
  {
    data = [allocator allocRealArrayWithCapacity: numRows*numColumns];
    dataSize = numRows*numColumns;
  }

  return self;
}

-resizeWithNumberOfColumns: (int)aNumColumns
{
  return [self resizeWithNumberOfRows: -1 numberOfColumns: aNumColumns];
}

-copyMatrix: (T4Matrix*)aMatrix;
{
//   if(numRows != aMatrix->numRows)
//     T4Error(@"Matrix: cannot copy a matrix of different size");

  T4CopyMatrix(data, stride, aMatrix->data, aMatrix->stride, numRows, numColumns);

  return self;
}

-copyFromAddress: (real*)anAddress stride: (int)aStride
{
  T4CopyMatrix(data, stride, anAddress, aStride, numRows, numColumns);
  return self;
}

-copyToAddress: (real*)anAddress stride: (int)aStride
{
  T4CopyMatrix(anAddress, aStride, data, stride, numRows, numColumns);
  return self;
}

-fillWithValue: (real)aValue
{
  if(stride == numRows)
  {
    int i;
    for(i = 0; i < numRows*numColumns; i++)
      data[i] = aValue;
  }
  else
  {
    int c, r;
    real *column = data;
    for(c = 0; c < numColumns; c++)
    {
      for(r = 0; r < numRows; r++)
        column[r] = aValue;
    }
    column += stride;
  }
  return self;
}

-zero
{
  if(stride == numRows)
    memset(data, 0, sizeof(real)*numRows*numColumns);
  else
  {
    real *column = data;
    int c;
    for(c = 0; c < numColumns; c++)
      memset(column, 0, sizeof(real)*numRows);
    column += stride;
  }
  return self;
}

-addValue: (real)aValue dotMatrix: (T4Matrix*)aMatrix
{
  T4AddMatrix(data, stride, aValue, aMatrix->data, aMatrix->stride, numRows, numColumns);
  return self;
}

-addMatrix: (T4Matrix*)aMatrix
{
  T4AddMatrix(data, stride, 1., aMatrix->data, aMatrix->stride, numRows, numColumns);
  return self;
}

-addFromAddress: (real*)anAddress stride: (int)aStride
{
  T4AddMatrix(data, stride, 1., anAddress, aStride, numRows, numColumns);
  return self;
}

-addToAddress: (real*)anAddress stride: (int)aStride
{
  T4AddMatrix(anAddress, aStride, 1., data, stride, numRows, numColumns);
  return self;
}

-(real)column: (int)aColumnIndex dotColumn: (int)aMatrixColumnIndex ofMatrix: (T4Matrix*)aMatrix
{
#ifdef USE_DOUBLE
    return cblas_ddot(numRows, [aMatrix columnAtIndex: aMatrixColumnIndex], 1, data+aColumnIndex*stride, 1);
#else
    return cblas_sdot(numRows, [aMatrix columnAtIndex: aMatrixColumnIndex], 1, data+aColumnIndex*stride, 1);
#endif
}

-(real)dotMatrix: (T4Matrix*)aMatrix
{
#ifdef USE_DOUBLE
    return cblas_ddot(numRows, [aMatrix columnAtIndex: 0], 1, data, 1);
#else
    return cblas_sdot(numRows, [aMatrix columnAtIndex: 0], 1, data, 1);
#endif
}

-dotValue: (real)aValue1 plusValue: (real)aValue2 dotMatrix: (T4Matrix*)aMatrix1 dotMatrix: (T4Matrix*)aMatrix2
{
  T4MatrixDotMatrix(aValue1, data, stride,
                    aValue2, aMatrix1->data, aMatrix1->stride,
                    aMatrix2->data, aMatrix2->stride,
                    numRows, numColumns, aMatrix1->numColumns);

  return self;
}
/*
void Matrix::dotSaccSdotMdotM(real scalar1, real scalar2, Matrix *matrix1, Matrix *matrix2)
{
  if(nColumns == 1)
  {
#ifdef USE_DOUBLE
    cblas_dgemv(CblasColMajor, CblasNoTrans, nRows, matrix1->nColumns,
                scalar2, matrix1->data, matrix1->stride, matrix2->data, 1, scalar1, data, 1);
#else
    cblas_sgemv(CblasColMajor, CblasNoTrans, nRows, matrix1->nColumns,
                scalar2, matrix1->data, matrix1->stride, matrix2->data, 1, scalar1, data, 1);
#endif
  }
  else
  {
#ifdef USE_DOUBLE
    cblas_dgemm(CblasColMajor, CblasNoTrans, CblasNoTrans, nRows, nColumns,
                matrix1->nColumns, scalar2, matrix1->data, matrix1->stride, matrix2->data, matrix2->stride,
                scalar1, data, stride);
#else
    cblas_sgemm(CblasColMajor, CblasNoTrans, CblasNoTrans, nRows, nColumns,
                matrix1->nColumns, scalar2, matrix1->data, matrix1->stride, matrix2->data, matrix2->stride,
                scalar1, data, stride);
#endif
  }
}

void Matrix::dotSaccSdotTMdotM(real scalar1, real scalar2, Matrix *matrix1, Matrix *matrix2)
{
  if(nColumns == 1)
  {
#ifdef USE_DOUBLE
    cblas_dgemv(CblasColMajor, CblasTrans, nRows, matrix1->nColumns,
                scalar2, matrix1->data, matrix1->stride, matrix2->data, 1, scalar1, data, 1);
#else
    cblas_sgemv(CblasColMajor, CblasTrans, nRows, matrix1->nColumns,
                scalar2, matrix1->data, matrix1->stride, matrix2->data, 1, scalar1, data, 1);
#endif
  }
  else
  {
#ifdef USE_DOUBLE
    cblas_dgemm(CblasColMajor, CblasTrans, CblasNoTrans, nRows, nColumns,
                matrix1->nColumns, scalar2, matrix1->data, matrix1->stride, matrix2->data, matrix2->stride,
                scalar1, data, stride);
#else
    cblas_sgemm(CblasColMajor, CblasTrans, CblasNoTrans, nRows, nColumns,
                matrix1->nColumns, scalar2, matrix1->data, matrix1->stride, matrix2->data, matrix2->stride,
                scalar1, data, stride);
#endif
  }
}

void Matrix::accSdotMextM(real scalar, Matrix *matrix1, Matrix *matrix2, int column_index1, int column_index2)
{
#ifdef USE_DOUBLE
  cblas_dger(CblasColMajor, nRows, nColumns, scalar, matrix1->columnAtIndex(column_index1), 1, matrix2->columnAtIndex(column_index2), 1, data, stride);
#else
  cblas_sger(CblasColMajor, nRows, nColumns, scalar, matrix1->columnAtIndex(column_index1), 1, matrix2->columnAtIndex(column_index2), 1, data, stride);
#endif
}

*/

-(real)getMinRowIndex: (int*)aRowIndex columnIndex: (int*)aColumnIndex
{
  real minValue = INF;
  int columnIndex = 0;
  int rowIndex = 0;
  real *column = data;
  int c, r;
  for(c = 0; c < numColumns; c++)
  {
    for(r = 0; r < numRows; r++)
    {
      if(column[r] < minValue)
      {
        minValue = column[r];
        columnIndex = c;
        rowIndex = r;
      }
    }
  }

  if(aRowIndex)
    *aRowIndex = rowIndex;
  if(aColumnIndex)
    *aColumnIndex = columnIndex;

  return minValue;
}

-(real)getMaxRowIndex: (int*)aRowIndex columnIndex: (int*)aColumnIndex
{
  real maxValue = INF;
  int columnIndex = 0;
  int rowIndex = 0;
  real *column = data;
  int c, r;
  for(c = 0; c < numColumns; c++)
  {
    for(r = 0; r < numRows; r++)
    {
      if(column[r] > maxValue)
      {
        maxValue = column[r];
        columnIndex = c;
        rowIndex = r;
      }
    }
  }

  if(aRowIndex)
    *aRowIndex = rowIndex;
  if(aColumnIndex)
    *aColumnIndex = columnIndex;

  return maxValue;
}

-(int)numberOfColumns
{
  return numColumns;
}

-(int)numberOfRows
{
  return numRows;
}

-(int)stride
{
  return stride;
}

-(real*)data
{
  return data;
}

@end
