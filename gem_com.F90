module gem_com

   !common data used for gem

   use mpi
   use gem_pputil

   implicit none

   INTERFACE
      real function revers(num,n)
         integer :: num, n !yjhu added
      end function revers

      real function ran2(i)
         integer :: i !yjhu added
      end function ran2

      real function en3(s)
         real :: s
      end function en3
   END INTERFACE

   integer :: imx,jmx,kmx,mmx,mmxe,nmx,nsmx,nsubd=8,&
      modemx,ntube=8,nxpp,ngdx=5,nb=6, &
      negrd=8,nlgrd=8
   integer :: micell, mecell, nonlin1, nonlin2
   integer:: ntube_checking !yjhu added, to check value of ntube in this module and in "gem.in" is equal to each other
   character(len=70) outname
   REAL :: endtm,begtm,pstm
   real :: time_unit_gem ! in SI, yjhu
   REAL :: starttm,lasttm,tottm
   real :: aux1(50000),aux2(20000)
   real,dimension(:),allocatable :: workx,worky,workz

   real :: tot_tm, accumulate_start_tm, accumulate_end_tm, accumulate_tot_tm
   real :: ampere_start_tm, ampere_end_tm, ampere_tot_tm
   real :: poisson_start_tm, poisson_end_tm, poisson_tot_tm
   real :: field_start_tm, field_end_tm, field_tot_tm
   real :: diagnose_start_tm, diagnose_end_tm, diagnose_tot_tm
   real :: reporter_start_tm, reporter_end_tm, reporter_tot_tm
   real :: push_start_tm, push_end_tm, push_tot_tm
   real :: ppush_start_tm, ppush_end_tm, ppush_tot_tm
   real :: cpush_start_tm, cpush_end_tm, cpush_tot_tm
   real :: pint_start_tm, pint_end_tm, pint_tot_tm
   real :: cint_start_tm, cint_end_tm, cint_tot_tm
   real :: lorentz_start_tm, lorentz_end_tm, lorentz_tot_tm
   real :: grid1_ion_start_tm, grid1_ion_end_tm, grid1_ion_tot_tm
   real :: grid1_electron_start_tm, grid1_electron_end_tm, grid1_electron_tot_tm
   real :: init_pmove_start_tm, init_pmove_end_tm, init_pmove_tot_tm
   real :: pmove_start_tm, pmove_end_tm, pmove_tot_tm
   complex,dimension(:),allocatable :: tmpx
   complex,dimension(:),allocatable :: tmpy
   complex,dimension(:),allocatable :: tmpz

   !          imx,jmx,kmx = max no. of grid pts in x,y,z
   !          mmx         = max no. of particles
   !          nmx         = max. no. of time steps
   !          nsmx        = max. no. of species (including tracer particles
   !                                             as a species)
   !          ntrmx       = max. no. of tracer particles
   !          modemx      = max. no. of mode history plots

   integer :: mme,mmb
   REAL, dimension(:,:),allocatable :: rwx,rwy
   INTEGER,dimension(:),allocatable :: mm,lr
   INTEGER*8,dimension(:),allocatable :: tmm
   REAL,dimension(:),allocatable :: tets,mims,q
   REAL,dimension(:),allocatable :: kapn, kapt
   INTEGER :: timestep,im,jm,km,mykm,iseed,nrst,nfreq,isft,mynf,ifskp,iphbf,iapbf,idpbf
   integer :: lr_e = 4 !yjhu
   logical :: electron_flr=.true. !yjhu
   real,dimension(:),allocatable :: time
   REAL :: dx,dy,dz,pi,pi2,dt,dte,totvol,n0,n0e,tcurr,rmpp,rmaa,eprs
   REAL :: lx,ly,lz,xshape,yshape,zshape,pzcrit(5),pzcrite,encrit,tot_field_e,tot_joule,tot_joule1
   INTEGER :: nm,nsm,kcnt,jcnt,ncurr,llk,mlk,onemd,iflr,iorb
   integer :: izonal,ineq0,iflut,nlow,ntor0,mstart
   REAL :: cut,amp,tor,amie,isg,rneu,rneui,emass,qel,mbeam,qbeam,teth,vexbsw,vparsw
   REAL :: c4,fradi,kxcut,kycut,bcut,ftrap,adwn,adwe,adwp,frmax
   INTEGER :: iput,iget,idg,kzlook,ision,isiap,peritr,iadi,ipred,icorr,jpred,jcorr
   REAL,DIMENSION(:,:),allocatable :: yyamp,yyre,yyim
   complex,dimension(:,:),allocatable :: camp,campf
   REAL :: br0,lr0,qp,width,e0,vwidth,vwidthe,vcut,vpp,vt0,yd0
   integer :: nonlin(5),nonline,ipara,isuni,ifluid,ishift,nopz,nopi(5),noen,nowe
   complex :: IU
   real,dimension(:),allocatable :: coefx,coefy,coefz
   complex,dimension(1:8) :: apk,ptk,dpdtk
   integer,dimension(1:8) :: lapa,mapa,napa
   real :: mrtio(0:1),aven,avptch
   integer :: icrs_sec,ipg,isphi
   integer,dimension(0:255) :: isgnft,jft

   !          im,jm,km = max no. of grid pts in x,y,z
   !          mm       = max no. of particles
   !          nm       = max. no. of time steps
   !          nsm      = max. no. of species (including the set of
   !                           tracer particles as a species)
   !          ntrm     = max. no. of tracer particles
   !          modem    = max. no. of mode history plots
   !          iput     = 1 save for restart into dump.b, =0 no save
   !          iget     = 1 restart from dump.b, =0 use loader

   !            field or grid quantities

   REAL,DIMENSION(:,:,:,:),allocatable :: den
   REAL,DIMENSION(:,:,:,:),allocatable :: dnidt,jpar,jpex,jpey,dti
   REAL,DIMENSION(:,:,:),allocatable :: rho,jion,jionx,jiony
   real,dimension(:,:,:),allocatable :: phi
   real,dimension(:,:,:),allocatable :: drhodt,dnedt,dphidt,drhoidt
   REAL,DIMENSION(:,:,:),allocatable :: ex
   REAL,DIMENSION(:,:,:),allocatable :: ey
   REAL,DIMENSION(:,:,:),allocatable :: ez
   REAL,DIMENSION(:,:,:),allocatable :: dpdz,dadz
   REAL,DIMENSION(:,:,:),allocatable :: delbx,delby
   REAL,DIMENSION(:),allocatable :: xg,yg,zg
   real,dimension(:,:,:),allocatable :: apar,dene
   real,dimension(:,:,:),allocatable :: upar,upart,delte
   real,dimension(:,:,:),allocatable :: upex,upey,upa0,den0,upazd,upa00,upa0t,den0apa
   real,dimension(:,:),allocatable :: cfx,cfy,jac,bmag,bdgxcgy,bdgrzn,ggxdgy,ggy2,ggx
   real,dimension(:),allocatable :: gn0e,gt0e,gt0i,avap
   real,dimension(:,:),allocatable :: gn0s

   !          particle array declarations
   REAL,DIMENSION(:,:),allocatable :: mu,xii,pzi,eki,z0i,u0i
   REAL,DIMENSION(:,:),allocatable :: x2,y2,z2,u2
   REAL,DIMENSION(:,:),allocatable :: x3,y3,z3,u3
   REAL,DIMENSION(:,:),allocatable :: w2,w3

   REAL,DIMENSION(:),allocatable :: mue,xie,pze,eke,z0e,u0e
   REAL,DIMENSION(:),allocatable :: x2e,y2e,z2e,u2e,mue2
   REAL,DIMENSION(:),allocatable :: x3e,y3e,z3e,u3e,mue3
   REAL,DIMENSION(:),allocatable :: w2e,w3e
   real,dimension(:),allocatable :: ipass, index
   REAL,DIMENSION(:),allocatable :: w000,w001,w010,w011,w100,w101,w110,w111

   !              Various diagnostic arrays and scalars
   !    plotting constants

   INTEGER :: nplot,xnplt,imovie=1000000,nzcrt,npze,npzi,npzc,npzb
   REAL :: contu,wmax

   !    energy diagnostic arrays

   REAL,DIMENSION(:,:),allocatable :: ke
   REAL,DIMENSION(:),allocatable :: fe,te
   REAL,DIMENSION(:),allocatable :: rmsphi,rmsapa,avewe
   REAL,DIMENSION(:,:),allocatable :: nos,avewi

   !    flux diagnostics
   REAL,DIMENSION(:),allocatable :: vol
   REAL,DIMENSION(:,:),allocatable :: efle_es,efle_em,pfle_es,pfle_em
   REAL,DIMENSION(:,:,:),allocatable :: pfl_es,pfl_em,efl_es,efl_em
   REAL,DIMENSION(:,:),allocatable :: chii, chie, ddi
   REAL,DIMENSION(:),allocatable :: achii, achie, addi

   !   mode diagnositics
   INTEGER :: modem
   INTEGER,dimension(:),allocatable :: lmode,mmode,nmode
   complex,dimension(:,:),allocatable :: pmodehis
   real,dimension(:),allocatable :: mdhis,mdhisa,mdhisb,mdhisc,mdhisd
   complex,dimension(:,:),allocatable :: aparhis,phihis

   !   kr, ktheta spectrum plots
   REAL,DIMENSION(:,:),allocatable :: phik

   !     weighty variables
   INTEGER,dimension(:),allocatable :: deljp,deljm
   INTEGER,dimension(:,:),allocatable :: jpl
   INTEGER,dimension(:,:),allocatable :: jpn
   INTEGER,dimension(:,:),allocatable :: jmi
   INTEGER,dimension(:,:),allocatable :: jmn
   REAL,DIMENSION(:),allocatable :: weightp,weightm
   REAL,DIMENSION(:),allocatable :: weightpn,weightmn

   !blending variable
   complex,dimension(:,:,:,:),allocatable :: pol,pmtrx,pmtrxi
   complex,dimension(:,:),allocatable :: pfac

   !      MPI variables
   !  include '/usr/include/mpif.h'

   integer,parameter :: Master=0
   integer :: numprocs
   INTEGER :: MyId,Last,cnt,ierr
   INTEGER :: GRID_COMM,TUBE_COMM
   INTEGER :: GCLR,TCLR,GLST,TLST
   INTEGER :: stat(MPI_STATUS_SIZE)
   INTEGER :: lngbr,rngbr,idprv,idnxt

   character(len=*) directory
   parameter(directory='./dump/')

   character(len=*) outdir
   parameter(outdir='./out/')

   !real :: ran2,revers
   !integer :: mod
   !real :: amod
   save

contains

   subroutine new_gem_com()
      nxpp = imx !/ntube
      allocate(workx(4*imx),worky(4*jmx),workz(4*kmx))
      allocate(tmpx(0:imx-1))
      allocate(tmpy(0:jmx-1))
      allocate(tmpz(0:kmx-1))

      allocate(rwx(nsmx,4),rwy(nsmx,4))
      allocate(mm(nsmx),tmm(nsmx),lr(nsmx))
      allocate(tets(nsmx),mims(nsmx),q(nsmx))
!$acc enter data create(lr,mims,q)

      allocate(kapn(nsmx),kapt(nsmx))
      allocate(time(0:nmx))
      allocate(yyamp(jmx,0:4),yyre(jmx,0:4),yyim(jmx,0:4),camp(0:6,0:50000),campf(0:6,0:nfreq-1))
      allocate(aparhis(0:6,0:jcnt-1),phihis(0:6,0:jcnt-1))
      allocate(mdhis(0:100),mdhisa(0:100),mdhisb(0:100))
      allocate(mdhisc(0:100),mdhisd(0:100))
      allocate(coefx(100+8*imx),coefy(100+8*jmx),coefz(100+8*kmx))

      ALLOCATE( den(nsmx,0:nxpp,0:jmx,0:1),dti(nsmx,0:nxpp,0:jmx,0:1), &
         delte(0:nxpp,0:jmx,0:1))
      ALLOCATE( rho(0:nxpp,0:jmx,0:1),jion(0:nxpp,0:jmx,0:1))
      allocate( phi(0:nxpp,0:jmx,0:1))
      allocate( jpar(nsmx,0:nxpp,0:jmx,0:1))

      ALLOCATE( ex(0:nxpp,0:jmx,0:1))
      ALLOCATE( ey(0:nxpp,0:jmx,0:1))
      ALLOCATE( ez(0:nxpp,0:jmx,0:1))
      ALLOCATE( dadz(0:nxpp,0:jmx,0:1))

      ALLOCATE( delbx(0:nxpp,0:jmx,0:1),delby(0:nxpp,0:jmx,0:1))
      ALLOCATE( xg(0:nxpp),yg(0:jmx),zg(0:1))
      allocate( apar(0:nxpp,0:jmx,0:1),dene(0:nxpp,0:jmx,0:1))
      allocate( upar(0:nxpp,0:jmx,0:1))

      allocate( cfx(0:nxpp,0:1),cfy(0:nxpp,0:1),jac(0:nxpp,0:1))
      allocate( bmag(0:nxpp,0:1),bdgxcgy(0:nxpp,0:1),bdgrzn(0:nxpp,0:1))
      allocate( ggxdgy(0:nxpp,0:1),ggy2(0:nxpp,0:1),ggx(0:nxpp,0:1))
      allocate (gn0e(0:nxpp),gt0e(0:nxpp),gt0i(0:nxpp),avap(0:nxpp))
      allocate (gn0s(1:5,0:nxpp))
      !          particle array declarations
      allocate( mu(1:mmx,nsmx),eki(1:mmx,nsmx))
      allocate( x2(1:mmx,nsmx),y2(1:mmx,nsmx),z2(1:mmx,nsmx),u2(1:mmx,nsmx))
      allocate( x3(1:mmx,nsmx),y3(1:mmx,nsmx),z3(1:mmx,nsmx),u3(1:mmx,nsmx))
      allocate( w2(1:mmx,nsmx),w3(1:mmx,nsmx))

!$acc enter data create(x2,y2,z2,u2,u3,x3,y3,z3,w2,w3,mu,eki)

      allocate( mue(1:mmxe),eke(1:mmxe))
      allocate( x2e(1:mmxe),y2e(1:mmxe),z2e(1:mmxe),u2e(1:mmxe),mue2(1:mmxe))
      allocate( x3e(1:mmxe),y3e(1:mmxe),z3e(1:mmxe),u3e(1:mmxe),mue3(1:mmxe))
      allocate( w2e(1:mmxe),w3e(1:mmxe))
      allocate( ipass(1:mmxe), index(1:mmxe))

!$acc enter data create(x2e,y2e,z2e,u2e,u3e,x3e,y3e,z3e,w2e,w3e,mue,eke,mue2,mue3,ipass,index)


      !              Various diagnostic arrays and scalars
      !    plotting constants

      !    energy diagnostic arrays

      ALLOCATE( ke(nsmx,0:nmx),fe(0:nmx),te(0:nmx))
      ALLOCATE( rmsphi(0:nmx),rmsapa(0:nmx),avewi(1:3,0:nmx),avewe(0:nmx))
      ALLOCATE( nos(nsmx,0:nmx))

      !    flux diagnostics
      ALLOCATE( vol(1:nsubd),efle_es(1:nsubd,0:nmx),pfle_es(1:nsubd,0:nmx), &
         pfl_es(1:3,1:nsubd,0:nmx),efl_es(1:3,1:nsubd,0:nmx), &
         pfle_em(1:nsubd,0:nmx),efle_em(1:nsubd,0:nmx), &
         pfl_em(1:3,1:nsubd,0:nmx),efl_em(1:3,1:nsubd,0:nmx))
      ALLOCATE( chii(1:nsubd,0:nmx),chie(1:nsubd,0:nmx),ddi(1:nsubd,0:nmx), &
         achii(1:nsubd),achie(1:nsubd),addi(1:nsubd))

      !   mode diagnositics
      allocate(lmode(modemx),mmode(modemx),nmode(modemx))
      allocate(pmodehis(modemx,0:nmx))

      !   kr, ktheta spectrum plots
      ALLOCATE( phik(imx,jmx))

      !     weighty variables
      ALLOCATE( deljp(0:nxpp),deljm(0:nxpp))
      ALLOCATE( jpl(0:nxpp,0:jmx))
      ALLOCATE( jpn(0:nxpp,0:jmx))
      ALLOCATE( jmi(0:nxpp,0:jmx))
      ALLOCATE( jmn(0:nxpp,0:jmx))
      ALLOCATE( weightp(0:nxpp),weightm(0:nxpp))
      ALLOCATE( weightpn(0:nxpp),weightmn(0:nxpp))

      !Blending variable
!    ALLOCATE(pol(1:nb,0:imx-1,0:jmx-1,0:kmx),pfac(0:imx-1,0:jmx-1), &
!         pmtrx(0:imx-1,0:jmx-1,1:nb,1:nb), &
!         pmtrxi(0:imx-1,0:jmx-1,1:nb,1:nb))

   end subroutine new_gem_com

end module gem_com

module evolution_mod !yjhu added
contains
   subroutine write_evolution_file(tmp3d)
      use gem_com,only: imx,jmx,im, nlow
      use gem_com,only:myid,numprocs, kstart=>ncurr, kend=>nm, tcurr, tclr, gclr
      implicit none
!    integer,intent(in)::n
      COMPLEX,intent(in) :: tmp3d(0:imx-1,0:jmx-1,0:1-1)
      integer,save       :: u_evolution
      character(len=64)  :: filename2
      logical, save      :: is_first=.true.
!    integer            :: lfs_id, hfs_id

!    lfs_id = numprocs/2  !process on the low-field-side (lfs)
!    hfs_id = 0           !process on the high-field-side (hfs)

      if ((is_first.eqv..true.).and. (tclr==0)) then
         filename2 = 'evolutionxxxxxx_xxxxxx_gclr_xxxx'
         write(filename2(10:32),'(i6.6,a1,i6.6, a6, i4.4)') kstart,'_',kend, '_gclr_', gclr
         open(newunit=u_evolution, file=filename2)
         is_first=.false.
      endif

      if(tclr==0)  write(u_evolution,*) tcurr, real(tmp3d(im/2,nlow,0)), imag(tmp3d(im/2,nlow,0)) !first index is radial location, second index is the toroidal mode number (starting from zero), the third index indicating the two boundaries  of the interval [z_i:z_i+1] ==>(0 corresponds to the left boundary, 1 corresponds to the right boundary)

   end subroutine write_evolution_file

end module evolution_mod
