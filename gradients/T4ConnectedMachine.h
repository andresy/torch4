#import "T4GradientMachine.h"

@interface T4ConnectedNode : T4Object
{
    T4GradientMachine *machine;
    NSMutableArray *inputMatrices;    
    NSMutableArray *gradOutputMatrices;
    int *gradOutputMatrixOffsets;
    
    T4Matrix *inputs;
    T4Matrix *gradOutputs;
    T4Matrix *directGradOutputs;

    BOOL hasDirectInputConnection;
    BOOL hasDirectOutputConnection;
    BOOL hasAlmostDirectOutputConnection;
}

-initWithMachine: (T4GradientMachine*)aMachine;
-(void)addInputConnectionToMachine: (T4GradientMachine*)aMachine;
-(void)addOutputConnectionToMachine: (T4GradientMachine*)aMachine offset: (int)anOffset;
-(void)directOutputConnectionWithOffset: (int)anOffset;
-(void)forward;
-(void)backward;
-(void)setInputs: (T4Matrix*)aMatrix;
-(int)currentNumberOfInputs;
-(T4GradientMachine*)machine;
-(void)check;
-(void)setGradOutputs: (T4Matrix*)aMatrix;

@end

@interface T4ConnectedMachine : T4GradientMachine
{
    NSMutableArray *layers;
}

-init;
-build;
-addFullConnectedMachine: (T4GradientMachine*)aMachine;
-addLayer;
-addMachine: (T4GradientMachine*) aMachine;
-connectMachine: (T4GradientMachine*)firstMachine toMachine: (T4GradientMachine*)secondMachine;
-(T4Matrix*)forwardMatrix: (T4Matrix*)aMatrix;
-(T4Matrix*)backwardMatrix: (T4Matrix*)aGradOutputs inputs: (T4Matrix*)anInputMatrix;
-(void)reset;

// private
-(BOOL)getNode: (T4ConnectedNode**)aNode andLayerIndex: (int*)aLayerIndex forMachine: (T4GradientMachine*)aMachine;

@end
