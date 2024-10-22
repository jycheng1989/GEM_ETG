SRCS =	gem_fft_wrapper.F90 gem_com.F90  gem_equil.F90 gem_main.F90 gem_outd.F90 gem_fcnt.F90 
OBJS = $(SRCS:.F90=.o)

LIBS = $(DFFTPACK)
PLIB = gem_pputil.o

DFFTPACK=/global/homes/u/u10198/installed/dfftpack_cray/libdfftpack.a
F90 = ftn

OPT =  -f free -O3 -s real64 -hvector0 -hlist=a -e Z
#OPT = -f free -eD -s real64 -hvector0 -hlist=a -e Z


LDFLAGS = 
LIBS = $(DFFTPACK)

#all : gem

gem_main: $(OBJS)
	$(F90)  -o gem_main $(OPT) $(OBJS) $(PLIB) $(LIBS) 

gem_pputil.o: gem_pputil.F90
	$(F90) -c $(OPT) gem_pputil.F90

gem_com.o: gem_com.F90 gem_pputil.o
	$(F90) -c $(OPT) gem_com.F90

gem_equil.o: gem_equil.F90 gem_pputil.o
	$(F90) -c $(OPT) gem_equil.F90

gem_main.o: gem_main.F90 gem_fft_wrapper.o gem_pputil.o gem_com.o gem_equil.o
	$(F90) -c $(OPT) $< -o $@

gem_outd.o: gem_outd.F90 gem_fft_wrapper.o gem_pputil.o gem_com.o gem_equil.o
	$(F90) -c $(OPT) $< -o $@

gem_fcnt.o: gem_fcnt.F90
	$(F90) -c $(OPT) gem_fcnt.F90

gem_fft_wrapper.o: gem_fft_wrapper.F90
	$(F90) -c $(OPT) gem_fft_wrapper.F90


.PHONY : clean run
clean:
	rm -f *.o *.lst *.mod gem_main

