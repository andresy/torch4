#import "T4GradientMachine.h"

/** Class for doing sub-sampling over a sequence.
    
    Then, for each component of output frames, it takes its associated input component
    and it computes the convolution of the input sequence with a kernel
    of size #k_w#, over the time, where the weights of the kernel are equals.

    Note that, depending of the size of your kernel, several (last) frames
    of the input seqience could be lost.

    Note also that \emph{no} non-linearity is applied in this layer.

    @author Ronan Collobert (collober@idiap.ch)
*/
@interface T4TemporalSubSampling : T4GradientMachine
{
    /// Kernel size.
    int kW;

    /// Time translation after one application of the kernel.
    int dT;
    
    /** #weights[i]# means kernel-weights for the #i#-th component of output frames.
        #weights[i]# contains only one weight.
    */
    real *weights;

    /// Derivatives associated to #weights#.
    real *gradWeights;

    /// #biases[i]# is the bias for the #i#-th component of output frames.
    real *biases;

    /// Derivatives associated to #biases#.
    real *gradBiases;
}

-initWithNumberOfRows: (int)aNumInputRows
           kernelSize: (int)aKW
                   dT: (int)aDT;

@end
