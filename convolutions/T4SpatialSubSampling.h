#import "T4GradientMachine.h"

/** Class for doing sub-sampling over images.
    
    Suppose you put #n_input_planes# images in each input frame.
    The images are in one big vector: each input frame has a size of
    #n_input_planes*input_height*input_width#. (image after image).
    Thus, #n_inputs = n_input_planes*input_height*input_width#.

    Then, for each output planes, it takes its associated input plane
    and it computes the convolution of the input image with a kernel
    of size #k_w*k_w#, where the weights of the kernel are equals.

    The output image size is computed in the constructor and
    put in #output_height# and #output_width#.
    #n_outputs = n_input_planes*output_height*output_width#.

    Note that, depending of the size of your kernel, several (last) input columns
    or rows of the image could be lost.

    Note also that \emph{no} non-linearity is applied in this layer.

    @author Ronan Collobert (collober@idiap.ch)
*/
@interface T4SpatialSubSampling : T4GradientMachine
{
    /// Kernel size (height and width).
    int kW;

    /// 'x' translation \emph{in the input image} after each application of the kernel.
    int dX;

    /// 'y' translation \emph{in the input image} after each application of the kernel.
    int dY;

    /// Number of input images. The number of output images in sub-sampling is the same.
    int numInputPlanes;

    /// Height of each input image.
    int inputHeight;

    /// Width of each input image.
    int inputWidth;

    /// Height of each output image.
    int outputHeight;

    /// Width of each output image.
    int outputWidth;

    /** #weights[i]# means kernel-weight for output plane #i#.
        #weights[i]# contains only one weight.
    */
    real *weights;

    /// Derivatives associated to #weights#.
    real *gradWeights;

    /// #biases[i]# is the bias for output plane #i#.
    real *biases;

    /// Derivatives associated to #biases#.
    real *gradBiases;
}

-initWithNumberOfInputPlanes: (int)aNumInputPlanes
                  inputWidth: (int)anInputWidth
                intputHeight: (int)anInputHeight
                  kernelSize: (int)aKW
                          dX: (int)aDX
                          dY: (int)aDY;

@end
