#import "T4Object.h"

@interface T4File : T4Object
{
}

-(int)readBlocksInto: (void*)someData blockSize: (int)aBlockSize numberOfBlocks: (int)aNumBlocks;
-(int)writeBlocksFrom: (void*)someData blockSize: (int)aBlockSize numberOfBlocks: (int)aNumBlocks;
-(BOOL)isEndOfFile;
-synchronizeFile;
-seekToFileOffset: (unsigned long long)anOffset;
-(unsigned long long)offsetInFile;
-(unsigned long long)seekToEndOfFile;
-seekToBeginningOfFile;
-writeStringWithFormat: (NSString*)aFormat, ...;
-(BOOL)readStringWithFormat: (NSString*)aFormat into: (void*)aPtr;
-(NSString*)stringToEndOfLine;
-(int)fileDescriptor;

@end
