#import "T4Object.h"

@interface T4File : T4Object
{
}

-(int)read: (void*)someData blockSize: (int)aBlockSize numberOfBlocks: (int)aNumBlocks;
-(int)write: (void*)someData blockSize: (int)aBlockSize numberOfBlocks: (int)aNumBlocks;
-(BOOL)isEndOfFile;
-(void)synchronizeFile;
-(void)seekToFileOffset: (unsigned long long)anOffset;
-(unsigned long long)offsetInFile;
-(unsigned long long)seekToEndOfFile;
-(void)seekToBeginningOfFile;
-(void)writeStringWithFormat: (NSString*)aFormat, ...;
-(BOOL)readStringWithFormat: (NSString*)aFormat into: (void*)aPtr;
-(NSString*)stringToEndOfLine;
-(int)fileDescriptor;

@end
