#include "Machine.h"

@interface GradientMachine : T4Object <T4Machine>
{
    bool partial_backprop;
    int n_inputs;
    int n_outputs;
    Parameters *params;
    Parameters *der_params;
    Sequence *beta;

    GradientMachine(int n_inputs_, int n_outputs_, int n_params_=0);

    virtual void iterInitialize();

    virtual void forward(Sequence *inputs);
    virtual void backward(Sequence *inputs, Sequence *alpha);
    virtual void setPartialBackprop(bool flag=true);
    virtual void frameForward(int t, real *f_inputs, real *f_outputs);
    virtual void frameBackward(int t, real *f_inputs, real *beta_, real *f_outputs, real *alpha_);

    virtual void loadXFile(XFile *file);
    virtual void saveXFile(XFile *file);
};

}

#endif
