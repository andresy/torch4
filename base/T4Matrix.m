#import "T4Matrix.h"
#include "cblas.h"


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
  if( (stride == numRows) && ([aMatrix stride] == [aMatrix numberOfRows]) )
    memmove(data, [aMatrix data], sizeof(real)*numRows*numColumns);
  else
  {
    real *columnSrc = [aMatrix data];
    real *columnDest = data;
    int strideSrc = [aMatrix stride];
    int c;
    for(c = 0; c < numColumns; c++)
    {
      memmove(columnDest, columnSrc, sizeof(real)*numRows);
      columnDest += stride;
      columnSrc += strideSrc;
    }
  }
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

-accumulateValue: (real)aValue dotMatrix: (T4Matrix*)aMatrix
{
  if(numColumns == 1)
  {
#ifdef USE_DOUBLE
    cblas_daxpy(numRows, aValue, [aMatrix data], 1, data, 1);
#else
    cblas_saxpy(numRows, aValue, [aMatrix data], 1, data, 1);
#endif    
  }
  else
  {   
    real *columnSrc = [aMatrix data];
    real *columnDest = data;
    int strideSrc = [aMatrix stride];
    int c;
    for(c = 0; c < numColumns; c++)
    {
#ifdef USE_DOUBLE
      cblas_daxpy(numRows, aValue, columnSrc, 1, columnDest, 1);
#else
      cblas_saxpy(numRows, aValue, columnSrc, 1, columnDest, 1);
#endif
      columnSrc += strideSrc;
      columnDest += stride;
    }
  }
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
