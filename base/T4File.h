#import "T4Object.h"

@interface T4File : T4Object
{
}

-(int)read: (void*)someData blockSize: (int)aBlockSize numberOfBlocs: (int)aNumBlocks;
-(int)write: (void*)someData blockSize: (int)aBlockSize numberOfBlocs: (int)aNumBlocks;
-(BOOL)isEndOfFile;
-(void)synchronizeFile;
-(void)seekToFileOffset: (unsigned long long)anOffset;
-(unsigned long long)offsetInFile;
-(unsigned long long)seekToEndOfFile;
-(void)seekToBeginningOfFile;
-(void)writeStringWithFormat: (NSString*)aFormat, ...;
-(void)readStringWithFormat: (NSString*)aFormat into: (void*)aPtr;
-(NSString*)stringToEndOfLine;

@end
