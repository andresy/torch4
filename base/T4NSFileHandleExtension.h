#import "T4General.h"

@interface NSFileHandle (T4NSFileHandleExtension)

+(size_t)scanChunkSize;
+(void)setScanChunkSize: (size_t)bytes;
-(FILE*)cFileHandleWithMode: (const char*)mode;
-(NSData*)readDataToCharacter: (char)c;
-(NSData*)readDataToCharacter: (char)c includingCharacterInData: (BOOL)incld;
-(NSString*)readStringToEndOfLine;
-(NSString*)readStringToEndOfLineAndIncludeNewline: (BOOL)incld;
-(void)writeString: (NSString*)aString;
-(void)writeStringWithFormat: (NSString*)format, ...;

@end
