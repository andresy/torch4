#import "T4ClassFormat.h"

@implementation T4ClassFormat

-initWithNumberOfClasses: (int)aNumClasses encodingSize: (int)anEncodingSize
{
  if( (self = [super init]) )
  {
    classLabels = [[[T4Matrix alloc] initWithNumberOfRows: anEncodingSize numberOfColumns: aNumClasses]
                    keepWithAllocator: allocator];
  }

  return self;
}

-(int)encodingSize
{
  return [classLabels numberOfRows];
}

-(int)numberOfClasses
{
  return [classLabels numberOfColumns];
}

-(int)classFromRealArray: (real*)aVector
{
  [self subclassResponsibility: _cmd];
  return -1;
}

-(real*)encodingForClass: (int)aClass
{
  return [classLabels columnAtIndex: aClass];
}

-initWithCoder: (NSCoder*)aCoder
{
  self = [super initWithCoder: aCoder];
  classLabels = [[aCoder decodeObject] retainAndKeepWithAllocator: allocator];
  return self;
}

-(void)encodeWithCoder: (NSCoder*)aCoder
{
  [super encodeWithCoder: aCoder];
  [aCoder encodeObject: classLabels];
}

@end
