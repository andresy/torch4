#import "T4File.h"

#define T4FileIsReadable 1
#define T4FileIsWritable 2
#define T4FileIsAPipe 4

@interface T4DiskFile : T4File
{
    FILE *file;
    int fileAttributes;
}

-initWithStream: (FILE*)aFile attributes: (int)someAttributes;
-initForReadingAtPath: (NSString*)aPath;
-initForWritingAtPath: (NSString*)aPath;
-initForReadingAndWritingAtPath: (NSString*)aPath;
-initForWritingWithPipe: (NSString*)aPipeCommand;
-initForReadingWithPipe: (NSString*)aPipeCommand;
-initForReadingAndWritingWithPipe: (NSString*)aPipeCommand;

-(FILE*)fileStream;

+(BOOL)isLittleEndianProcessor;
+(BOOL)isBigEndianProcessor;
+(BOOL)isNativeEncoding;
+(void)setNativeEncoding;
+(void)setLittleEndianEncoding;
+(void)setBigEndianEncoding;

-(int)fileAttributes;

@end
