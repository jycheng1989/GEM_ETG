SRCS = gem_fft_wrapper.F90 gem_equil.F90 gem_pputil.F90 gem_com.F90 gem_main.F90 gem_outd.F90 gem_fcnt.F90
OBJS = $(SRCS:.F90=.o)
DFFTPACK = /global/homes/j/jycheng/Software/dfftpack/libdfftpack.a
F90 = ftn

OPT = -O3 -r8 -Kieee -cpp -acc -Minfo=acc -DGPU -DOPENACC -I$(FFTW_INC) -llapack -lblas -mp
LDFLAGS = $(DFFTPACK) -L$(FFTW_DIR) -lfftw3 -lfftw3f -lfftw3_omp

.PHONY: all clean run
all: gem_main

gem_main: $(OBJS)
	$(F90) -o $@ $(OPT) $^ $(LDFLAGS)

%.o: %.F90
	$(F90) -c $(OPT) $< -o $@

clean:
	rm -f *.i *.o *.lst *.mod gem_main

