#import "T4NSCategories.h"

size_t NSFileHandleScanChunkSize = 32;

@implementation NSScanner (T4NSScannerExtension)

-(BOOL)scanReal: (real*)aReal
{
#ifdef USE_DOUBLE
  return [self scanDouble: aReal];
#else
  return [self scanFloat: aReal];
#endif
}

@end

@implementation NSFileHandle (NSFileHandleExtension)

+(size_t)scanChunkSize
{
  return NSFileHandleScanChunkSize;
}

+(void)setScanChunkSize: (size_t)bytes
{
  if (bytes > 0)
    NSFileHandleScanChunkSize = bytes;
}

-(FILE*)cFileHandleWithMode: (const char*)mode
{
  return fdopen([self fileDescriptor], mode);
}

-(NSData*)readDataToCharacter: (char)c
{
  return [self readDataToCharacter: c includingCharacterInData: YES];
}
	
-(NSData*)readDataToCharacter: (char)c includingCharacterInData: (BOOL)incld
{
  unsigned long long		offset = [self offsetInFile];
  NSData*								readData = nil;
  NSMutableData*				result = nil;
  unsigned							len,i,dlen;
  const char*						data;
  BOOL									doneReading = NO;
  
  do
  {
    //  Read a single 
    readData = [self readDataOfLength:NSFileHandleScanChunkSize];

    if( (readData) && (len = [readData length]) )
    {
      data = (const char*)[readData bytes];


      //  search for the character:
      dlen = 1;
      for(i = 0; ((i < len) && (!doneReading)); i++)
      {
        if (data[i] == c)
          doneReading = YES;
        else
          dlen++;
      }

      //  append necessary data to the result:
      if(result == nil)
        result = [[NSMutableData alloc] init];

      if(i >= len)
      {
        [result appendBytes:data length:len];
        offset += len;
      }
      else
      {
        [result appendBytes:data length:(dlen - ((!incld)?(1):(0)))];
        offset += dlen;
      }
      //  if we've gone past the end of file, we're done:
      if (len < NSFileHandleScanChunkSize)
        doneReading = YES;
    }
    else
      doneReading = YES;
    
  } while(!doneReading);

  //  Reset the file position for the next line:
  [self seekToFileOffset:offset];
  //  Return the data:
  return [result autorelease];
}
	
-(NSString*)readStringToEndOfLine
{
  return [self readStringToEndOfLineAndIncludeNewline: NO];
}

//

-(NSString*)readStringToEndOfLineAndIncludeNewline: (BOOL)incld
{
  NSData*		line = [self readDataToCharacter:'\n'];
  NSString*	str = nil;
  
  if (line)
  {
    //  Change the \n to a null character:
    if (!incld)
      ((char*)([line bytes]))[ [line length] - 1 ] = '\0';
    str = [NSString stringWithCString:[line bytes]];
  }
  return str;
}

-(void)writeString: (NSString*)aString
{
  [self writeData: [aString dataUsingEncoding: NSISOLatin1StringEncoding]];
}

-(void)writeStringWithFormat: (NSString*)format, ...
{
  NSString *aString;
  va_list args;
  va_start(args, format);
  aString = [[NSString alloc] initWithFormat: format arguments: args];
  [self writeData: [aString dataUsingEncoding: NSISOLatin1StringEncoding]];
  [aString release];
}

@end
