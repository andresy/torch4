#import "T4MappedBinaryLoader.h"
#import <unistd.h>
#import <sys/mman.h>

@implementation T4MappedBinaryLoader

-init
{
  if( (self = [super init]) )
  {
    mappedAddresses = NULL;
    mappedSizes = NULL;
    numMapped = 0;
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

  mappedSizes = [allocator reallocIntArray: mappedSizes withCapacity: numMapped+1];
  mappedAddresses = (real**)[allocator reallocPointerArray: (void**)mappedAddresses withCapacity: numMapped+1];
  mappedSizes[numMapped] = numRows*numColumns;
  mappedAddresses[numMapped] = (real*)mmap(0, mappedSizes[numMapped], PROT_READ | PROT_WRITE, MAP_PRIVATE, [aFile fileDescriptor], 0);
  if(mappedAddresses[numMapped] == MAP_FAILED)
    T4Error(@"MappedBinaryLoader: cannot map the file. If it is a memory problem, buy a new processor!");

  matrix = [[T4Matrix alloc] initWithRealData: mappedAddresses[numMapped] numberOfRows: numRows numberOfColumns: numColumns stride: -1];
  [allocator keepObject: matrix];

  numMapped++;
 
  return matrix;
}

-(void)setMaxNumberOfColumns: (int)aMaxNumber
{
  maxNumColumns = aMaxNumber;
}

-(void)dealloc
{
  int i;
  T4Message(@"dealloc map");

  for(i = 0; i < numMapped; i++)
    munmap(mappedAddresses[i], mappedSizes[i]);

  [super dealloc];
}

@end
