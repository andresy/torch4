#import "T4Matrix.h"
#import "cblas.h"

inline void T4MatrixDotMatrix(real aValue1, real *destMat, int destStride,
                              real aValue2, real *srcMat1, int srcStride1,
                              real *srcMat2, int srcStride2,
                              int destNumRows, int destNumColumns, int srcNum)
{
  // matrix-vector
  if(destNumColumns == 1)
  {
    // inner product
    if(destNumRows == 1)
    {
#ifdef USE_DOUBLE
      destMat[0] = aValue1*destMat[0] + aValue2*cblas_ddot(srcNum, srcMat1, srcStride1, srcMat2, 1);
#else
      destMat[0] = aValue1*destMat[0] + aValue2*cblas_sdot(srcNum, srcMat1, srcStride1, srcMat2, 1);
#endif      
    }
    else
    {
#ifdef USE_DOUBLE
      cblas_dgemv(CblasColMajor, CblasNoTrans, destNumRows, srcNum,
                  aValue2, srcMat1, srcStride1, srcMat2, 1, aValue1, destMat, 1);
#else
      cblas_sgemv(CblasColMajor, CblasNoTrans, destNumRows, srcNum,
                  aValue2, srcMat1, srcStride1, srcMat2, 1, aValue1, destMat, 1);
#endif
    }
  }
  else
  {
    // outer product
    if(srcNum == 1)
    {
      if(aValue1 != 1.)
      {        
        if(aValue1 == 0.)
        {
          if(destStride == destNumRows)
            memset(destMat, 0, sizeof(real)*destNumRows*destNumColumns);
          else
          {
            real *column = destMat;
            int c;
            for(c = 0; c < destNumColumns; c++)
              memset(column, 0, sizeof(real)*destNumRows);
            column += destStride;
          }
        }
        else
        {
          if(destStride == destNumRows)
          {
            int i;
            for(i = 0; i < destNumRows*destNumColumns; i++)
              destMat[i] *= aValue1;
          }
          else
          {
            real *column = destMat;
            int c, i;
            for(c = 0; c < destNumColumns; c++)
            {
              for(i = 0; i < destNumRows; i++)
                column[i] *= aValue1;
            }
            column += destStride;
          }          
        }        
      }
#ifdef USE_DOUBLE
      cblas_dger(CblasColMajor, destNumRows, destNumColumns, aValue2, srcMat1, 1, srcMat2, srcStride2, destMat, destStride);
#else
      cblas_sger(CblasColMajor, destNumRows, destNumColumns, aValue2, srcMat1, 1, srcMat2, srcStride2, destMat, destStride);
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
}

//===============================================================================================================================

inline void T4TrMatrixDotMatrix(real aValue1, real *destMat, int destStride,
                                real aValue2, real *srcMat1, int srcStride1,
                                real *srcMat2, int srcStride2,
                                int destNumRows, int destNumColumns, int srcNum)
{
  // matrix-vector
  if(destNumColumns == 1)
  {
    // inner product
    if(destNumRows == 1)
    {
#ifdef USE_DOUBLE
      destMat[0] = aValue1*destMat[0] + aValue2*cblas_ddot(srcNum, srcMat1, 1, srcMat2, 1);
#else
      destMat[0] = aValue1*destMat[0] + aValue2*cblas_sdot(srcNum, srcMat1, 1, srcMat2, 1);
#endif      
    }
    else
    {
#ifdef USE_DOUBLE
      cblas_dgemv(CblasColMajor, CblasTrans, srcNum, destNumRows,
                  aValue2, srcMat1, srcStride1, srcMat2, 1, aValue1, destMat, 1);
#else
      cblas_sgemv(CblasColMajor, CblasTrans, srcNum, destNumRows,
                  aValue2, srcMat1, srcStride1, srcMat2, 1, aValue1, destMat, 1);
#endif
    }
  }
  else
  {
    // outer product
    if(srcNum == 1)
    {
      if(aValue1 != 1.)
      {        
        if(aValue1 == 0.)
        {
          if(destStride == destNumRows)
            memset(destMat, 0, sizeof(real)*destNumRows*destNumColumns);
          else
          {
            real *column = destMat;
            int c;
            for(c = 0; c < destNumColumns; c++)
              memset(column, 0, sizeof(real)*destNumRows);
            column += destStride;
          }
        }
        else
        {
          if(destStride == destNumRows)
          {
            int i;
            for(i = 0; i < destNumRows*destNumColumns; i++)
              destMat[i] *= aValue1;
          }
          else
          {
            real *column = destMat;
            int c, i;
            for(c = 0; c < destNumColumns; c++)
            {
              for(i = 0; i < destNumRows; i++)
                column[i] *= aValue1;
            }
            column += destStride;
          }          
        }        
      }
#ifdef USE_DOUBLE
      cblas_dger(CblasColMajor, destNumRows, destNumColumns, aValue2, srcMat1, srcStride1, srcMat2, srcStride2, destMat, destStride);
#else
      cblas_sger(CblasColMajor, destNumRows, destNumColumns, aValue2, srcMat1, srcStride1, srcMat2, srcStride2, destMat, destStride);
#endif      
    }
    else
    {
#ifdef USE_DOUBLE
      cblas_dgemm(CblasColMajor, CblasTrans, CblasNoTrans, destNumRows, destNumColumns,
                  srcNum, aValue2, srcMat1, srcStride1, srcMat2, srcStride2,
                  aValue1, destMat, destStride);
#else
      cblas_sgemm(CblasColMajor, CblasTrans, CblasNoTrans, destNumRows, destNumColumns,
                    srcNum, aValue2, srcMat1, srcStride1, srcMat2, srcStride2,
                  aValue1, destMat, destStride);
#endif
    }
  }
}

//===============================================================================================================================

inline void T4MatrixDotTrMatrix(real aValue1, real *destMat, int destStride,
                                real aValue2, real *srcMat1, int srcStride1,
                                real *srcMat2, int srcStride2,
                                int destNumRows, int destNumColumns, int srcNum)
{
  // matrix-vector
  if(destNumColumns == 1)
  {
    // inner product
    if(destNumRows == 1)
    {
#ifdef USE_DOUBLE
      destMat[0] = aValue1*destMat[0] + aValue2*cblas_ddot(srcNum, srcMat1, srcStride1, srcMat2, srcStride2);
#else
      destMat[0] = aValue1*destMat[0] + aValue2*cblas_sdot(srcNum, srcMat1, srcStride1, srcMat2, srcStride2);
#endif      
    }
    else
    {
#ifdef USE_DOUBLE
      cblas_dgemv(CblasColMajor, CblasNoTrans, destNumRows, srcNum,
                  aValue2, srcMat1, srcStride1, srcMat2, srcStride2, aValue1, destMat, 1);
#else
      cblas_sgemv(CblasColMajor, CblasNoTrans, destNumRows, srcNum,
                  aValue2, srcMat1, srcStride1, srcMat2, srcStride2, aValue1, destMat, 1);
#endif
    }
  }
  else
  {
    // outer product
    if(srcNum == 1)
    {
      if(aValue1 != 1.)
      {        
        if(aValue1 == 0.)
        {
          if(destStride == destNumRows)
            memset(destMat, 0, sizeof(real)*destNumRows*destNumColumns);
          else
          {
            real *column = destMat;
            int c;
            for(c = 0; c < destNumColumns; c++)
              memset(column, 0, sizeof(real)*destNumRows);
            column += destStride;
          }
        }
        else
        {
          if(destStride == destNumRows)
          {
            int i;
            for(i = 0; i < destNumRows*destNumColumns; i++)
              destMat[i] *= aValue1;
          }
          else
          {
            real *column = destMat;
            int c, i;
            for(c = 0; c < destNumColumns; c++)
            {
              for(i = 0; i < destNumRows; i++)
                column[i] *= aValue1;
            }
            column += destStride;
          }          
        }        
      }
#ifdef USE_DOUBLE
      cblas_dger(CblasColMajor, destNumRows, destNumColumns, aValue2, srcMat1, 1, srcMat2, 1, destMat, destStride);
#else
      cblas_sger(CblasColMajor, destNumRows, destNumColumns, aValue2, srcMat1, 1, srcMat2, 1, destMat, destStride);
#endif      
    }
    else
    {
#ifdef USE_DOUBLE
      cblas_dgemm(CblasColMajor, CblasNoTrans, CblasTrans, destNumRows, destNumColumns,
                  srcNum, aValue2, srcMat1, srcStride1, srcMat2, srcStride2,
                  aValue1, destMat, destStride);
#else
      cblas_sgemm(CblasColMajor, CblasNoTrans, CblasTrans, destNumRows, destNumColumns,
                    srcNum, aValue2, srcMat1, srcStride1, srcMat2, srcStride2,
                  aValue1, destMat, destStride);
#endif
    }
  }
}

//===============================================================================================================================

inline void T4TrMatrixDotTrMatrix(real aValue1, real *destMat, int destStride,
                                  real aValue2, real *srcMat1, int srcStride1,
                                  real *srcMat2, int srcStride2,
                                  int destNumRows, int destNumColumns, int srcNum)
{
  // matrix-vector
  if(destNumColumns == 1)
  {
    // inner product
    if(destNumRows == 1)
    {
#ifdef USE_DOUBLE
      destMat[0] = aValue1*destMat[0] + aValue2*cblas_ddot(srcNum, srcMat1, 1, srcMat2, srcStride2);
#else
      destMat[0] = aValue1*destMat[0] + aValue2*cblas_sdot(srcNum, srcMat1, 1, srcMat2, srcStride2);
#endif      
    }
    else
    {
#ifdef USE_DOUBLE
      cblas_dgemv(CblasColMajor, CblasTrans, srcNum, destNumRows,
                  aValue2, srcMat1, srcStride1, srcMat2, srcStride2, aValue1, destMat, 1);
#else
      cblas_sgemv(CblasColMajor, CblasTrans, srcNum, destNumRows,
                  aValue2, srcMat1, srcStride1, srcMat2, srcStride2, aValue1, destMat, 1);
#endif
    }
  }
  else
  {
    // outer product
    if(srcNum == 1)
    {
      if(aValue1 != 1.)
      {        
        if(aValue1 == 0.)
        {
          if(destStride == destNumRows)
            memset(destMat, 0, sizeof(real)*destNumRows*destNumColumns);
          else
          {
            real *column = destMat;
            int c;
            for(c = 0; c < destNumColumns; c++)
              memset(column, 0, sizeof(real)*destNumRows);
            column += destStride;
          }
        }
        else
        {
          if(destStride == destNumRows)
          {
            int i;
            for(i = 0; i < destNumRows*destNumColumns; i++)
              destMat[i] *= aValue1;
          }
          else
          {
            real *column = destMat;
            int c, i;
            for(c = 0; c < destNumColumns; c++)
            {
              for(i = 0; i < destNumRows; i++)
                column[i] *= aValue1;
            }
            column += destStride;
          }          
        }        
      }
#ifdef USE_DOUBLE
      cblas_dger(CblasColMajor, destNumRows, destNumColumns, aValue2, srcMat1, srcStride1, srcMat2, 1, destMat, destStride);
#else
      cblas_sger(CblasColMajor, destNumRows, destNumColumns, aValue2, srcMat1, srcStride1, srcMat2, 1, destMat, destStride);
#endif      
    }
    else
    {
#ifdef USE_DOUBLE
      cblas_dgemm(CblasColMajor, CblasTrans, CblasTrans, destNumRows, destNumColumns,
                  srcNum, aValue2, srcMat1, srcStride1, srcMat2, srcStride2,
                  aValue1, destMat, destStride);
#else
      cblas_sgemm(CblasColMajor, CblasTrans, CblasTrans, destNumRows, destNumColumns,
                    srcNum, aValue2, srcMat1, srcStride1, srcMat2, srcStride2,
                  aValue1, destMat, destStride);
#endif
    }
  }
}


inline void T4CopyMatrix(real *destAddr, int destStride, real *sourceAddr, int sourceStride, int numRows, int numColumns)
{
  if( (sourceStride == numRows) && (destStride == numRows) )
//    memmove(destAddr, sourceAddr, sizeof(real)*numRows*numColumns);
#ifdef USE_DOUBLE
    cblas_dcopy(numRows*numColumns, sourceAddr, 1, destAddr, 1);
#else
    cblas_scopy(numRows*numColumns, sourceAddr, 1, destAddr, 1);
#endif
  else
  {
    int c;
    for(c = 0; c < numColumns; c++)
    {
//      memmove(destAddr, sourceAddr, sizeof(real)*numRows);
#ifdef USE_DOUBLE
      cblas_dcopy(numRows, sourceAddr, 1, destAddr, 1);
#else
      cblas_scopy(numRows, sourceAddr, 1, destAddr, 1);
#endif
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

-initWithRealArray: (real*)aRealArray numberOfRows: (int)aNumRows numberOfColumns: (int)aNumColumns stride: (int)aStride
{
  if( (self = [super init]) )
  {
    numRows = (aNumRows > 0 ? aNumRows : 0);
    numColumns = (aNumColumns > 0 ? aNumColumns : 0);
    stride = (aStride > 0 ? aStride : numRows);
    if( (aRealArray == NULL) && (numRows > 0) && (numColumns > 0) )
    {
      data = [allocator allocRealArrayWithCapacity: numRows*numColumns];
      dataSize = numRows*numColumns;
    }
    else
    {
      data = aRealArray;
      dataSize = 0;
    }
  }
  return self;
}

-init
{
  return [self initWithRealArray: NULL numberOfRows: 0 numberOfColumns: 0 stride: 0];
}

-initWithNumberOfRows: (int)aNumRows numberOfColumns: (int)aNumColumns
{
  return [self initWithRealArray: NULL numberOfRows: aNumRows numberOfColumns: aNumColumns stride: aNumRows];
}

-initWithNumberOfRows: (int)aNumRows
{
  return [self initWithRealArray: NULL numberOfRows: aNumRows numberOfColumns: 1 stride: aNumRows];
}

-initWithSubMatrix: (T4Matrix*)aMatrix firstRowIndex: (int)aFirstRowIndex firstColumnIndex: (int)aFirstColumnIndex numberOfRows: (int)aNumRows numberOfColumns: (int)aNumColumns
{
  if(aFirstColumnIndex < 0)
    aFirstColumnIndex = 0;
  if(aFirstRowIndex < 0)
    aFirstRowIndex = 0;

  return [self initWithRealArray: [aMatrix columnAtIndex: aFirstColumnIndex]+aFirstRowIndex
               numberOfRows: (aNumRows < 0 ? [aMatrix numberOfRows] : aNumRows-aFirstRowIndex)
               numberOfColumns: (aNumColumns < 0 ? [aMatrix numberOfColumns] : aNumColumns-aFirstColumnIndex)
               stride: [aMatrix stride]];
}

-initWithColumn: (int)aColumnIndex fromMatrix: (T4Matrix*)aMatrix
{
  return [self initWithRealArray: [aMatrix columnAtIndex: aColumnIndex]
               numberOfRows: [aMatrix numberOfRows]
               numberOfColumns: 1
               stride: [aMatrix stride]];
}


-setMatrixFromRealArray: (real*)aRealArray numberOfRows: (int)aNumRows numberOfColumns: (int)aNumColumns stride: (int)aStride
{
  numRows = aNumRows;
  numColumns = aNumColumns;
  if(aStride > 0)
    stride = aStride;
  else
    stride = numRows;
  data = aRealArray;
  dataSize = 0;

  return self;
}

-(real*)columnAtIndex: (int)aColumnIndex
{
  return data+aColumnIndex*stride;
}

-resizeWithNumberOfRows: (int)aNumRows numberOfColumns: (int)aNumColumns
{
  aNumRows = (aNumRows > 0 ? aNumRows : numRows);
  aNumColumns = (aNumColumns > 0 ? aNumColumns : numColumns);

  if( (aNumRows == numRows) && (aNumColumns == numColumns) )
    return self;
  else
  {
    numRows = aNumRows;
    numColumns = aNumColumns;
    stride = numRows;
  }

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

-resizeWithNumberOfRows: (int)aNumRows
{
  return [self resizeWithNumberOfRows: aNumRows numberOfColumns: -1];
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

-copyFromRealArray: (real*)aRealArray stride: (int)aStride
{
  T4CopyMatrix(data, stride, aRealArray, aStride, numRows, numColumns);
  return self;
}

-copyToRealArray: (real*)aRealArray stride: (int)aStride
{
  T4CopyMatrix(aRealArray, aStride, data, stride, numRows, numColumns);
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

-addValue: (real)aValue dotSumMatrixColumns: (T4Matrix*)aMatrix
{
  int c;
  for(c = 0; c < aMatrix->numColumns; c++)
    T4AddMatrix(data, stride, aValue, aMatrix->data+aMatrix->stride*c, aMatrix->stride, numRows, 1);
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

-addFromRealArray: (real*)aRealArray stride: (int)aStride
{
  T4AddMatrix(data, stride, 1., aRealArray, aStride, numRows, numColumns);
  return self;
}

-addToRealArray: (real*)aRealArray stride: (int)aStride
{
  T4AddMatrix(aRealArray, aStride, 1., data, stride, numRows, numColumns);
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

-dotValue: (real)aValue1 addValue: (real)aValue2 dotMatrix: (T4Matrix*)aMatrix1 dotMatrix: (T4Matrix*)aMatrix2
{
  T4MatrixDotMatrix(aValue1, data, stride,
                    aValue2, aMatrix1->data, aMatrix1->stride,
                    aMatrix2->data, aMatrix2->stride,
                    numRows, numColumns, aMatrix1->numColumns);

  return self;
}

-dotValue: (real)aValue1 addValue: (real)aValue2 dotTrMatrix: (T4Matrix*)aMatrix1 dotMatrix: (T4Matrix*)aMatrix2
{
  T4TrMatrixDotMatrix(aValue1, data, stride,
                      aValue2, aMatrix1->data, aMatrix1->stride,
                      aMatrix2->data, aMatrix2->stride,
                      numRows, numColumns, aMatrix2->numRows);

  return self;
}

-dotValue: (real)aValue1 addValue: (real)aValue2 dotMatrix: (T4Matrix*)aMatrix1 dotTrMatrix: (T4Matrix*)aMatrix2
{
  T4MatrixDotTrMatrix(aValue1, data, stride,
                      aValue2, aMatrix1->data, aMatrix1->stride,
                      aMatrix2->data, aMatrix2->stride,
                      numRows, numColumns, aMatrix1->numColumns);

  return self;
}

-dotValue: (real)aValue1 addValue: (real)aValue2 dotTrMatrix: (T4Matrix*)aMatrix1 dotTrMatrix: (T4Matrix*)aMatrix2
{
  T4TrMatrixDotTrMatrix(aValue1, data, stride,
                        aValue2, aMatrix1->data, aMatrix1->stride,
                        aMatrix2->data, aMatrix2->stride,
                        numRows, numColumns, aMatrix1->numRows);

  return self;
}

-(real)getMinRowIndex: (int*)aRowIndex columnIndex: (int*)aColumnIndex
{
  real minValue = T4Inf;
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
  real maxValue = T4Inf;
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

-(real*)firstColumn
{
  return data;
}

-(real)firstValue
{
  return *data;
}

-(real)firstValueAtColumn: (int)aColumnIndex
{
  return data[aColumnIndex*stride];
}

-(NSString*)description
{
  NSMutableString *text = [[NSMutableString alloc] init];
  int r, c;
  
  for(r = 0; r < numRows; r++)
  {
    if(r == 0)
      [text appendString: @"[["];
    else
      [text appendString: @" ["];
    for(c = 0; c < numColumns; c++)
      [text appendFormat: @" %12g", data[c*stride+r]];
    if(r != (numRows-1))
      [text appendString: @" ]\n"];
    else
      [text appendString: @" ]]"];
  }

  return [text autorelease];
}

@end
