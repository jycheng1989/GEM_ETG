SRCS = gem_fft_wrapper.F90 gem_equil.F90 gem_pputil.F90 gem_com.F90 gem_main.F90 gem_outd.F90 gem_fcnt.F90
OBJS = $(SRCS:.F90=.o)
DFFTPACK = /global/homes/j/jycheng/Software/dfftpack/libdfftpack.a
F90 = ftn

OPT = -O3 -r8 -Kieee -llapack -lblas -cpp -acc -Minfo=acc 
LDFLAGS = $(DFFTPACK)

.PHONY: all clean run
all: gem_main

gem_main: $(OBJS)
	$(F90) -o $@ $(OPT) $^ $(PLIB) $(LDFLAGS)

%.o: %.F90
	$(F90) -c $(OPT) $< -o $@

clean:
	rm -f *.i *.o *.lst *.mod gem_main

