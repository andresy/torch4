#import "T4MappedBinaryLoader.h"
#import <unistd.h>
#import <sys/mman.h>

@interface T4MappedBinaryLoaderMatrix : T4Matrix
{
    void *mappedAddress;
    int mappedSize;
}
-initWithRealArray: (real*)aRealArray numberOfRows: (int)aNumRows numberOfColumns: (int)aNumColumns stride: (int)aStride mappedAddress: (void*)aMappedAddress mappedSize: (int)aMappedSize;
-(void)dealloc;
@end

@implementation T4MappedBinaryLoaderMatrix

-initWithRealArray: (real*)aRealArray numberOfRows: (int)aNumRows numberOfColumns: (int)aNumColumns stride: (int)aStride mappedAddress: (void*)aMappedAddress mappedSize: (int)aMappedSize
{
  if( (self = [super initWithRealArray: aRealArray numberOfRows: aNumRows numberOfColumns: aNumColumns stride: aStride]) )
  {
    mappedAddress = aMappedAddress;
    mappedSize = aMappedSize;
  }

  return self;
}

-(void)dealloc
{
  munmap(mappedAddress, mappedSize);
  [super dealloc];
}

@end

@implementation T4MappedBinaryLoader

-init
{
  if( (self = [super init]) )
  {
    [self setMaxNumberOfColumns: -1];
  }

  return self;
}

-(T4Matrix*)loadMatrixFromFile: (T4File*)aFile
{
  T4Matrix *matrix;
  int numRows, numColumns;

  if([aFile read: &numColumns blockSize: sizeof(int) numberOfBlocks: 1] != 1)
    T4Error(@"BinaryLoader: file header corrupted");

  if([aFile read: &numRows blockSize: sizeof(int) numberOfBlocks: 1] != 1)
    T4Error(@"BinaryLoader: file header corrupted");

  if( (numRows <= 0) || (numColumns <= 0) )
    T4Error(@"MappedBinaryLoader: header seems corrupted");

  T4Message(@"MappedBinaryLoader: %d rows and %d columns detected", numRows, numColumns);

  if( (maxNumColumns > 0) && (maxNumColumns < numColumns) )
  {
    numColumns = maxNumColumns;
    T4Warning(@"MappedBinaryLoader: loading only %d columns", numColumns);
  }

//  mappedAddresses[numMapped] = (real*)mmap(0, mappedSizes[numMapped], PROT_READ | PROT_WRITE, MAP_PRIVATE, [aFile fileDescriptor], 0);
  int mappedSize = numRows*numColumns*sizeof(real)+sizeof(int)*2;
  char *mappedAddress = (char*)mmap(0, mappedSize, PROT_READ, MAP_SHARED, [aFile fileDescriptor], 0);
  if(mappedAddress == MAP_FAILED)
    T4Error(@"MappedBinaryLoader: cannot map the file. If it is a memory problem, buy a new processor!");

  matrix = [[T4MappedBinaryLoaderMatrix alloc] initWithRealArray: (real*)(mappedAddress+sizeof(int)*2)
                                               numberOfRows: numRows
                                               numberOfColumns: numColumns
                                               stride: -1
                                               mappedAddress: mappedAddress
                                               mappedSize: mappedSize];
  
  return [matrix autorelease];
}

-setMaxNumberOfColumns: (int)aMaxNumber
{
  maxNumColumns = aMaxNumber;
  return self;
}

@end
