#import "T4Matrix.h"
#include "cblas.h"


@implementation T4Matrix

-initWithData: (real*)aData nRows: (int)aNRows nColumns: (int)aNColumns stride: (int)aStride
{
  if( (self = [super init]) )
  {
    nRows = (aNRows > 0 ? aNRows : 0);
    nColumns = (aNColumns > 0 ? aNColumns : 0);
    stride = (aStride > 0 ? aStride : nRows);
    if( (aData == NULL) && (nRows > 0) && (nColumns > 0) )
    {
      data = [allocator allocRealArrayOfSize: nRows*nColumns];
      dataSize = nRows*nColumns;
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
  return [self initWithData: NULL nRows: 0 nColumns: 0 stride: 0];
}

-initWithNRows: (int)aNRows nColumns: (int)aNColumns
{
  return [self initWithData: NULL nRows: aNRows nColumns: aNColumns stride: aNRows];
}

-initWithNRows: (int)aNRows
{
  return [self initWithData: NULL nRows: aNRows nColumns: 1 stride: aNRows];
}

-initWithSubMatrix: (T4Matrix*)aMatrix startingRow: (int)aStartingRow startingColumn: (int)aStartingColumn nRows: (int)aNRows nColumns: (int)aNColumns
{
  if(aStartingColumn < 0)
    aStartingColumn = 0;
  if(aStartingRow < 0)
    aStartingRow = 0;

  return [self initWithData: [aMatrix getColumn: aStartingColumn]+aStartingRow
               nRows: (aNRows < 0 ? [aMatrix nRows] : aNRows-aStartingRow)
               nColumns: (aNColumns < 0 ? [aMatrix nColumns] : aNColumns-aStartingColumn)
               stride: [aMatrix stride]];
}

-initWithColumn: (int)aColumnIndex fromMatrix: (T4Matrix*)aMatrix
{
  return [self initWithData: [aMatrix getColumn: aColumnIndex]
               nRows: [aMatrix nRows]
               nColumns: 1
               stride: [aMatrix stride]];
}


-setMatrixFromData: (real*)aData nRows: (int)aNRows nColumns: (int)aNColumns stride: (int)aStride
{
  nRows = aNRows;
  nColumns = aNColumns;
  if(aStride > 0)
    stride = aStride;
  else
    stride = nRows;
  data = aData;
  dataSize = 0;

  return self;
}

-(real*)getColumn: (int)aColumnIndex
{
  return data+aColumnIndex*stride;
}

-resizeWithNRows: (int)aNRows nColumns: (int)aNColumns
{
  nRows = (aNRows > 0 ? aNRows : nRows);
  nColumns = (aNColumns > 0 ? aNColumns : nColumns);
  stride = nRows;

  if([allocator isMyPointer: data])
  {
    if(nRows*nColumns > dataSize)
    {
      [allocator freePointer: data];
      data = [allocator allocRealArrayOfSize: nRows*nColumns];
      dataSize = nRows*nColumns;
    }
  }
  else
  {
    data = [allocator allocRealArrayOfSize: nRows*nColumns];
    dataSize = nRows*nColumns;
  }

  return self;
}

-resizeWithNColumns: (int)aNColumns
{
  return [self resizeWithNRows: -1 nColumns: aNColumns];
}

-copyMatrix: (T4Matrix*)aMatrix;
{
  if( (stride == nRows) && ([aMatrix stride] == [aMatrix nRows]) )
    memmove(data, [aMatrix data], sizeof(real)*nRows*nColumns);
  else
  {
    real *columnSrc = [aMatrix data];
    real *columnDest = data;
    int strideSrc = [aMatrix stride];
    int c;
    for(c = 0; c < nColumns; c++)
    {
      memmove(columnDest, columnSrc, sizeof(real)*nRows);
      columnDest += stride;
      columnSrc += strideSrc;
    }
  }
  return self;
}

-fillWithValue: (real)aValue
{
  if(stride == nRows)
  {
    int i;
    for(i = 0; i < nRows*nColumns; i++)
      data[i] = aValue;
  }
  else
  {
    int c, r;
    real *column = data;
    for(c = 0; c < nColumns; c++)
    {
      for(r = 0; r < nRows; r++)
        column[r] = aValue;
    }
    column += stride;
  }
  return self;
}

-zero
{
  if(stride == nRows)
    memset(data, 0, sizeof(real)*nRows*nColumns);
  else
  {
    real *column = data;
    int c;
    for(c = 0; c < nColumns; c++)
      memset(column, 0, sizeof(real)*nRows);
    column += stride;
  }
  return self;
}

-accumulateValue: (real)aValue dotMatrix: (T4Matrix*)aMatrix
{
  if(nColumns == 1)
  {
#ifdef USE_DOUBLE
    cblas_daxpy(nRows, aValue, [aMatrix data], 1, data, 1);
#else
    cblas_saxpy(nRows, aValue, [aMatrix data], 1, data, 1);
#endif    
  }
  else
  {   
    real *columnSrc = [aMatrix data];
    real *columnDest = data;
    int strideSrc = [aMatrix stride];
    int c;
    for(c = 0; c < nColumns; c++)
    {
#ifdef USE_DOUBLE
      cblas_daxpy(nRows, aValue, columnSrc, 1, columnDest, 1);
#else
      cblas_saxpy(nRows, aValue, columnSrc, 1, columnDest, 1);
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
    return cblas_ddot(nRows, [aMatrix getColumn: aMatrixColumnIndex], 1, data+aColumnIndex*stride, 1);
#else
    return cblas_sdot(nRows, [aMatrix getColumn: aMatrixColumnIndex], 1, data+aColumnIndex*stride, 1);
#endif
}

-(real)dotMatrix: (T4Matrix*)aMatrix
{
#ifdef USE_DOUBLE
    return cblas_ddot(nRows, [aMatrix getColumn: 0], 1, data, 1);
#else
    return cblas_sdot(nRows, [aMatrix getColumn: 0], 1, data, 1);
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
  cblas_dger(CblasColMajor, nRows, nColumns, scalar, matrix1->getColumn(column_index1), 1, matrix2->getColumn(column_index2), 1, data, stride);
#else
  cblas_sger(CblasColMajor, nRows, nColumns, scalar, matrix1->getColumn(column_index1), 1, matrix2->getColumn(column_index2), 1, data, stride);
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
  for(c = 0; c < nColumns; c++)
  {
    for(r = 0; r < nRows; r++)
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
  for(c = 0; c < nColumns; c++)
  {
    for(r = 0; r < nRows; r++)
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

-(int)nColumns
{
  return nColumns;
}

-(int)nRows
{
  return nRows;
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
