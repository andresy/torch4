#import "T4GradientMachine.h"

/** Class for doing a convolution over a sequence.
    
    For each component of output frames, it computes the convolution
    of the input sequence with a kernel of size #k_w# (over the time).

    Note that, depending of the size of your kernel, several (last) frames
    of the input sequence could be lost.

    Note also that \emph{no} non-linearity is applied in this layer.

    @author Ronan Collobert (collober@idiap.ch)
*/
@interface T4TemporalConvolution : T4GradientMachine
{
    /// Kernel size.
    int kW;

    /// Time translation after one application of the kernel.
    int dT;
    
    /** #weights[i]# means kernel-weights for the #i#-th component of output frames.
        #weights[i]# contains #input_frame_size# times #k_w# weights.
    */
    real **weights;

    /// Derivatives associated to #weights#.
    real **gradWeights;

    /// #biases[i]# is the bias for the #i#-th component of output frames.
    real *biases;

    /// Derivatives associated to #biases#.
    real *gradBiases;
}

/// Create a convolution layer...
-initWithNumberOfInputRows: (int)aNumInputRows
        numberOfOutputRows: (int)aNumOutputRows
                kernelSize: (int)aKW
                        dT: (int)aDT;

@end
