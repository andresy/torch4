#import "T4MLP.h"
#import "T4Linear.h"
#import "T4Tanh.h"
#import "T4Sigmoid.h"
#import "T4SoftMax.h"
#import "T4LogSoftMax.h"
#import "T4Exp.h"
#import "T4SoftPlus.h"

@implementation T4MLP

-initWithNumberOfLayers: (int)aNumLayers layers: (int)aNumInputs, ...
{
  if( (self = [super init]) )
  {
    int l;
    va_list args;

    isLinear = [allocator allocBoolArrayWithCapacity: aNumLayers];
    for(l = 0; l < aNumLayers; l++)
      isLinear[l] = NO;

    va_start(args, aNumInputs);
    for(l = 0; l < aNumLayers; l++)
    {
      NSString *layerType = va_arg(args, NSString *);
      T4GradientMachine *aMachine = nil;
      int aNumOutputs = va_arg(args, int);

      if([layerType isEqualToString: @"linear"])
      {
        aMachine = [[[T4Linear alloc] initWithNumberOfInputs: aNumInputs numberOfOutputs: aNumOutputs]
                     keepWithAllocator: allocator];

        isLinear[l] = YES;
      }

      if([layerType isEqualToString: @"tanh"])
        aMachine = [[[T4Tanh alloc] initWithNumberOfUnits: aNumOutputs] keepWithAllocator: allocator];

      if([layerType isEqualToString: @"sigmoid"])
        aMachine = [[[T4Sigmoid alloc] initWithNumberOfUnits: aNumOutputs] keepWithAllocator: allocator];

      if([layerType isEqualToString: @"softmax"])
        aMachine = [[[T4SoftMax alloc] initWithNumberOfUnits: aNumOutputs] keepWithAllocator: allocator];

      if([layerType isEqualToString: @"softplus"])
        aMachine = [[[T4SoftPlus alloc] initWithNumberOfUnits: aNumOutputs] keepWithAllocator: allocator];

      if([layerType isEqualToString: @"logsoftmax"])
        aMachine = [[[T4LogSoftMax alloc] initWithNumberOfUnits: aNumOutputs] keepWithAllocator: allocator];

      if([layerType isEqualToString: @"exp"])
        aMachine = [[[T4Exp alloc] initWithNumberOfUnits: aNumOutputs] keepWithAllocator: allocator];

      if(!aMachine)
        T4Error(@"MLP: unknow layer type <%@>", layerType);
    
      [self addFullConnectedMachine: aMachine];
      aNumInputs = aNumOutputs;
    }

    [self build];
    va_end(args);
  }

  return self;
}

-setWeightDecay: (real)aWeightDecay
{
  int l;

  for(l = 0; l < [layers count]; l++)
  {
    if(isLinear[l])
      [[[[layers objectAtIndex: l] objectAtIndex: 0] machine]
        setRealOption: @"weight decay" value: aWeightDecay];
  }
  return self;
}

@end
