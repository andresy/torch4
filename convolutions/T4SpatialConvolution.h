#import "T4GradientMachine.h"

/** Class for doing convolution over images.
    
    Suppose you put #n_input_planes# images in each input frame.
    The images are in one big vector: each input frame has a size of
    #n_input_planes*input_height*input_width#. (image after image).
    Thus, #n_inputs = n_input_planes*input_height*input_width#.

    Then, for each output planes, it computes the convolution
    of \emph{all} input image planes with a kernel of size #k_w*k_w*n_input_planes#.

    The output image size is computed in the constructor and
    put in #output_height# and #output_width#.
    #n_outputs = n_output_planes*output_height*output_width#.

    Note that, depending of the size of your kernel, several (last) columns
    or rows of the input image could be lost.

    Note also that \emph{no} non-linearity is applied in this layer.

    @author Ronan Collobert (collober@idiap.ch)
*/
@interface T4SpatialConvolution : T4GradientMachine
{
    /// Kernel size (height and width).
    int kW;
    
    /// 'x' translation \emph{in the input image} after each application of the kernel.
    int dX;

    /// 'y' translation \emph{in the input image} after each application of the kernel.
    int dY;

    /// Number of input images.
    int numInputPlanes;

    /// Number of output images.
    int numOutputPlanes;

    /// Height of each input image.
    int inputHeight;

    /// Width of each input image.
    int inputWidth;

    /// Height of each output image.
    int outputHeight;

    /// Width of each output image.
    int outputWidth;
    
    /** #weights[i]# means kernel-weights for output plane #i#.
        #weights[i]# contains #n_input_planes# times #k_w*k_w# weights.
    */
    real **weights;

    /// Derivatives associated to #weights#.
    real **gradWeights;

    /// #biases[i]# is the bias for output plane #i#.
    real *biases;

    /// Derivatives associated to #biases#.
    real *gradBiases;
}
 
/// Create a convolution layer...
-initWithNumberOfInputPlanes: (int)aNumInputPlanes
        numberOfOutputPlanes: (int)aNumOutputPlanes
                  inputWidth: (int)anInputWidth
                 inputHeight: (int)anInputHeight
                  kernelSize: (int)aKW
                          dX: (int)aDX
                          dY: (int)aDY;

-(int)numberOfOutputPlanes;
-(int)outputWidth;
-(int)outputHeight;

@end
