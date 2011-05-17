!------------------------------------------------------------------------------
!          Harvard University Atmospheric Chemistry Modeling Group            !
!------------------------------------------------------------------------------
!BOP
!
! !MODULE: depo_mercury_mod
!
! !DESCRIPTION: Module DEPO\_MERCURY\_MOD contains routines to handle
!  deposition fluxes for mercury. 
!
! !INTERFACE: 
!
      MODULE DEPO_MERCURY_MOD
!
! !USES:
! 
      IMPLICIT NONE
      PRIVATE
!
! !PUBLIC MEMBER FUNCTIONS:
!
      PUBLIC :: ADD_Hg2_DD
      PUBLIC :: ADD_Hg2_WD
      PUBLIC :: ADD_HgP_DD
      PUBLIC :: ADD_HgP_WD
      PUBLIC :: ADD_HG2_SNOWPACK
      PUBLIC :: RESET_HG_DEP_ARRAYS
      PUBLIC :: CHECK_DIMENSIONS
      PUBLIC :: READ_GTMM_RESTART
      PUBLIC :: MAKE_GTMM_RESTART
      PUBLIC :: UPDATE_DEP
      PUBLIC :: INIT_DEPO_MERCURY
      PUBLIC :: CLEANUP_DEPO_MERCURY
!
! !PUBLIC DATA MEMBERS:
!  
      PUBLIC :: DD_HG2, DD_HGP, WD_HG2, WD_HGP
      PUBLIC :: HG2mth_wd, HG0mth_dd, HG2mth_dd
      PUBLIC :: SNOW_HG
      PUBLIC :: LHGSNOW
      REAL*8,  ALLOCATABLE :: DD_Hg2(:,:,:)
      REAL*8,  ALLOCATABLE :: DD_HgP(:,:,:)
      REAL*8,  ALLOCATABLE :: WD_Hg2(:,:,:)
      REAL*8,  ALLOCATABLE :: WD_HgP(:,:,:)
      REAL*8,  ALLOCATABLE :: HG0mth_dd(:,:)
      REAL*8,  ALLOCATABLE :: HG2mth_dd(:,:)
      REAL*8,  ALLOCATABLE :: HG2mth_wd(:,:)
      REAL*8,  ALLOCATABLE :: SNOW_HG(:,:,:) !CDH Hg stored in snow+ice
      REAL*8,  ALLOCATABLE :: Hg0dryGEOS(:,:), HgIIdryGEOS(:,:), 
     &                        HgIIwetGEOS(:,:)
!
! !PRIVATE DATA MEMBERS:
!
      CHARACTER(LEN=255)   :: GTMM_RST_FILE
      LOGICAL              :: LHGSNOW
!
! !REVISION HISTORY:
! 23 Apr 2010 - C. Carouge  - Initial version
!
!EOP
!------------------------------------------------------------------------------
!BOC
      CONTAINS
!EOC
!------------------------------------------------------------------------------
!          Harvard University Atmospheric Chemistry Modeling Group            !
!------------------------------------------------------------------------------
!BOP
!
! !IROUTINE: add_Hg2_dd
!
! !DESCRIPTION: Subroutine ADD\_Hg2\_DD computes the amount of Hg(II) dry 
!  deposited out of the atmosphere into the column array DD\_Hg2. 
!\\
!\\
! !INTERFACE: 
!
      SUBROUTINE ADD_Hg2_DD( I, J, N, DRY_Hg2)
!
! !USES
!
      USE TRACERID_MOD, ONLY : GET_Hg2_CAT
!
! !INPUT PARAMETERS: 
!
      INTEGER, INTENT(IN)   :: I, J, N   ! GEOS-Chem long, lat and tracer index
      REAL*8,  INTENT(IN)   :: DRY_Hg2   ! Hg(II) dry deposited out of the 
                                         ! atmosphere [kg]
!
! !REVISION HISTORY:
!  19 Jan 2005 - S. Strode, C. Holmes - Initial version
!  (1 ) DD_Hg2 is now a 3-D array.  Also pass N via the argument list. Now 
!        call GET_Hg2_CAT to return the Hg category #. (cdh, bmy, 3/28/06)
!  23 Apr 2010 - C. Carouge  - Moved from ocean_mercury_mod.f to
!                              depo_mercury_mod.f
!EOP
!------------------------------------------------------------------------------
!BOC
!
! !LOCAL VARIABLES:
!
      INTEGER :: NN
      
      !=================================================================
      ! ADD_Hg2_DD begins here!
      !=================================================================

      ! Get the index for DD_Hg2 based on the tracer number
      NN = GET_Hg2_CAT( N )

      ! Store dry deposited Hg(II) into DD_Hg2 array
      IF ( NN > 0 ) THEN
         DD_Hg2(I,J,NN) = DD_Hg2(I,J,NN) + DRY_Hg2
        
      ENDIF
      
     
      END SUBROUTINE ADD_Hg2_DD
!EOC
!------------------------------------------------------------------------------
!          Harvard University Atmospheric Chemistry Modeling Group            !
!------------------------------------------------------------------------------
!BOP
!
! !IROUTINE: add_Hg2_wd
!
! !DESCRIPTION: Subroutine ADD\_Hg2\_WD computes the amount of Hg(II) wet 
!  scavenged out of the atmosphere into the column array WD\_Hg2. 
!\\
!\\
! !INTERFACE: 
!
      SUBROUTINE ADD_Hg2_WD( I, J, N, WET_Hg2 )
!
! !USES
!
      USE TRACERID_MOD, ONLY : GET_Hg2_CAT
!
! !INPUT PARAMETERS: 
!
      INTEGER, INTENT(IN)   :: I, J, N   ! GEOS-Chem long, lat and tracer index
      REAL*8,  INTENT(IN)   :: WET_Hg2   ! Hg(II) scavenged out of the 
                                         ! atmosphere [kg]
!
! !REVISION HISTORY:
!  19 Jan 2005 - S. Strode, C. Holmes - Initial version
!  (1 ) WD_Hg2 is now a 3-D array.  Also pass N via the argument list. Now 
!        call GET_Hg2_CAT to return the Hg category #. (cdh, bmy, 3/28/06)
!  23 Apr 2010 - C. Carouge  - Moved from ocean_mercury_mod.f to
!                              depo_mercury_mod.f
!EOP
!------------------------------------------------------------------------------
!BOC
!
! !LOCAL VARIABLES:
!
      INTEGER :: NN

      !=================================================================
      ! ADD_Hg2_WD begins here!
      !=================================================================

      ! Get Hg2 category number
      NN = GET_Hg2_CAT( N ) 
     
      ! Store wet deposited Hg(II) into WD_Hg2 array
      IF ( NN > 0 ) THEN
         WD_Hg2(I,J,NN) = WD_Hg2(I,J,NN) + WET_Hg2
         
      ENDIF

      END SUBROUTINE ADD_Hg2_WD
!EOC
!------------------------------------------------------------------------------
!          Harvard University Atmospheric Chemistry Modeling Group            !
!------------------------------------------------------------------------------
!BOP
!
! !IROUTINE: add_HgP_dd
!
! !DESCRIPTION: Subroutine ADD\_HgP\_DD computes the amount of HgP dry 
!  deposited out of the atmosphere into the column array DD\_HgP. 
!\\
!\\
! !INTERFACE: 
!
      SUBROUTINE ADD_HgP_DD( I, J, N, DRY_HgP )
!
! !USES
!
      USE TRACERID_MOD, ONLY : GET_HgP_CAT
!
! !INPUT PARAMETERS: 
!
      INTEGER, INTENT(IN)   :: I, J, N   ! GEOS-Chem long, lat and tracer index
      REAL*8,  INTENT(IN)   :: DRY_HgP   ! HgP dry deposited out of the 
                                         ! atmosphere [kg]
!
! !REVISION HISTORY:
!  19 Jan 2005 - S. Strode, C. Holmes - Initial version
!  (1 ) DD_HgP is now a 3-D array.  Also pass N via the argument list. Now 
!        call GET_HgP_CAT to return the Hg category #. (cdh, bmy, 3/28/06)
!  23 Apr 2010 - C. Carouge  - Moved from ocean_mercury_mod.f to
!                              depo_mercury_mod.f
!EOP
!------------------------------------------------------------------------------
!BOC
!
! !LOCAL VARIABLES:
!
      INTEGER :: NN

      !=================================================================
      ! ADD_HgP_DD begins here!
      !=================================================================
      
      ! Get the index for DD_Hg2 based on the tracer number
      NN = GET_HgP_CAT( N )

      ! Store dry deposited Hg(II) into DD_Hg2 array
      IF ( NN > 0 ) THEN
         DD_HgP(I,J,NN) = DD_HgP(I,J,NN) + DRY_HgP
        
      ENDIF

      END SUBROUTINE ADD_HgP_DD
!EOC
!------------------------------------------------------------------------------
!          Harvard University Atmospheric Chemistry Modeling Group            !
!------------------------------------------------------------------------------
!BOP
!
! !IROUTINE: add_HgP_wd
!
! !DESCRIPTION: Subroutine ADD\_HgP\_WD computes the amount of HgP wet 
!  scavenged out of the atmosphere into the column array WD\_HgP. 
!\\
!\\
! !INTERFACE: 
!
      SUBROUTINE ADD_HgP_WD( I, J, N, WET_HgP )
!
! !USES
!
      USE TRACERID_MOD, ONLY : GET_HgP_CAT
!
! !INPUT PARAMETERS: 
!
      INTEGER, INTENT(IN)   :: I, J, N   ! GEOS-Chem long, lat and tracer index
      REAL*8,  INTENT(IN)   :: WET_HgP   ! HgP scavenged out of the 
                                         ! atmosphere [kg]
!
! !REVISION HISTORY:
!  19 Jan 2005 - S. Strode, C. Holmes - Initial version
!  (1 ) WD_HgP is now a 3-D array.  Also pass N via the argument list. Now 
!        call GET_HgP_CAT to return the Hg category #. (cdh, bmy, 3/28/06)
!  23 Apr 2010 - C. Carouge  - Moved from ocean_mercury_mod.f to
!                              depo_mercury_mod.f
!EOP
!------------------------------------------------------------------------------
!BOC
!
! !LOCAL VARIABLES:
!
      INTEGER :: NN

      !=================================================================
      ! ADD_Hg2_WD begins here!
      !=================================================================
      
      ! Get Hg2 category number
      NN = GET_HgP_CAT( N ) 

       ! Store wet deposited HgP into WD_HgP array
      IF ( NN > 0 ) THEN
         WD_HgP(I,J,NN) = WD_HgP(I,J,NN) + WET_HgP
        
      ENDIF
      
      END SUBROUTINE ADD_HgP_WD
!EOC
!------------------------------------------------------------------------------
!          Harvard University Atmospheric Chemistry Modeling Group            !
!------------------------------------------------------------------------------
!BOP
!
! !IROUTINE: add_hg2_snowpack
!
! !DESCRIPTION: Subroutine ADD\_Hg2\_SNOWPACKS adds Hg2 deposition to snowpack.
!\\
!\\
! !INTERFACE: 
!
      SUBROUTINE ADD_HG2_SNOWPACK( I, J, N, DEP_Hg2 )
!
! !USES:
!
      USE DAO_MOD,           ONLY : SNOW, SNOMAS 
      USE DAO_MOD,           ONLY : IS_ICE, IS_LAND ! cdh
      USE DAO_MOD,           ONLY : FRSNO, FRSEAICE, FRLANDIC ! jaf
      USE TRACERID_MOD,      ONLY : GET_Hg2_CAT, GET_HgP_CAT
      USE TRACERID_MOD,      ONLY : IS_Hg2, IS_HgP

#     include "define.h"
!
! !INPUT PARAMETERS:
!
      ! Arguments as input
      INTEGER, INTENT(IN)   :: I, J, N
      REAL*8,  INTENT(IN)   :: Dep_Hg2
!
! !REVISION HISTORY:
!  02 Sep 2008 - C. Holmes   - Initial version
!  23 Apr 2010 - C. Carouge  - Moved from mercury_mod.f to depo_mercury_mod.f
!  25 Aug 2010 - R. Yantosca - Treat MERRA in the same way as GEOS-5
!  26 Apr 2011 - J. Fisher   - Use MERRA land fraction information
!EOP
!------------------------------------------------------------------------------
!BOC
!
! !LOCAL VARIABLES:
!
      ! Local variables
      !REAL*8  :: SNOW_HT ! obsolete (jaf, 4/26/11)
      REAL*8  :: FRAC_SNOW_OR_ICE ! jaf
      LOGICAL :: IS_SNOW_OR_ICE ! jaf
      INTEGER :: NN

      !=================================================================
      ! ADD_HG2_SNOWPACK begins here!
      !=================================================================
      
      ! Return if snowpack model is disabled
      IF (.NOT. LHGSNOW) RETURN

      IF ( IS_Hg2( N ) ) THEN
         ! Get Hg2 category number
         NN = GET_Hg2_CAT( N ) 
      ELSE IF ( IS_HgP( N ) ) THEN
         ! Get HgP category number
         NN = GET_HgP_CAT( N ) 
      ENDIF

!--jaf.start
      ! Restructure to use fractional land type information in MERRA
      ! (jaf, 4/26/11)
!
!#if   defined( GEOS_5 ) || defined( MERRA )
!      ! GEOS5 snow height (water equivalent) in mm. (Docs wrongly say m)
!      SNOW_HT = SNOMAS(I,J)
!#else
!      ! GEOS1-4 snow heigt (water equivalent) in mm
!      SNOW_HT = SNOW(I,J)
!#endif 
!
!      ! Check if there is snow on the ground, or if this is sea ice
!      ! Update to Holmes et al. 2010 version (jaf, 4/11/11)
!      ! (cdh 2/28/09: There are several coastal boxes which are mainly
!      ! ocean, but have some land-based snow that exceeds the snow_HT 
!      ! criteria. This Hg should go to the ocean, not the snowpack )
!      !IF ( (SNOW_HT > 1d0) .OR. (IS_ICE(I,J)) ) THEN
!      IF ( (IS_ICE(I,J)) .OR. (IS_LAND(I,J) .AND. SNOW_HT > 10d0) ) THEN
!    
!         ! Remove unnecessary output (jaf, 4/11/11)
!         !IF (DEP_HG2<0d0) THEN
!         !   WRITE(6,'(3I6,2G12.4)') I,J,NN,DEP_HG2,SNOW_HG(I,J,NN)
!         !ENDIF
!
!         ! Update to Holmes et al. 2010 version (jaf, 4/11/11)
!         !SNOW_HG(I,J,NN) = SNOW_HG(I,J,NN) + MAX( DEP_HG2, 0D0 )
!         ! Add 60% of deposition to surface, i.e. assume 40% accumulates
!         ! in surface
!         SNOW_HG(I,J,NN) = SNOW_HG(I,J,NN) + MAX( 0.6D0*DEP_HG2, 0D0 )
!
!      ENDIF

      ! Except with MERRA, we can't distinguish land fractions, so we use a 
      ! land fraction of 1 and only use boxes that are mostly snow/ice. 
      ! For MERRA we use the actual fractions, so FRAC_SNOW_OR_ICE is overwritten
      ! (jaf, 4/25/11)
      FRAC_SNOW_OR_ICE = 1d0
#if   defined( MERRA )
      ! Don't let fraction be greater than 1
      FRAC_SNOW_OR_ICE = 
     &    MIN(FRSNO(I,J) + FRSEAICE(I,J) + FRLANDIC(I,J), 1d0)
      IS_SNOW_OR_ICE = ( FRAC_SNOW_OR_ICE > 0d0 )
#elif defined( GEOS_5 )
      ! Use GEOS5 snow height (water equivalent) in mm. (Docs wrongly say m)
      IS_SNOW_OR_ICE = ( (IS_ICE(I,J)) .OR. 
     &                   (IS_LAND(I,J) .AND. SNOMAS(I,J) > 10d0) )
#else
      ! Use GEOS1-4 snow height (water equivalent) in mm
      IS_SNOW_OR_ICE = ( (IS_ICE(I,J)) .OR. 
     &                   (IS_LAND(I,J) .AND. SNOW(I,J) > 10d0) )
#endif 

      ! Check if there is snow on the ground, or if this is sea ice
      IF ( IS_SNOW_OR_ICE ) THEN
    
         ! Add 60% of deposition to surface (i.e. assume 40% accumulates
         ! in surface) multiplied by the fraction of the box that is 
         ! snow or ice (i.e. 1 for all met fields but MERRA)
         SNOW_HG(I,J,NN) = SNOW_HG(I,J,NN) + 
     &                     FRAC_SNOW_OR_ICE * MAX( 0.6D0*DEP_HG2, 0D0 )

      ENDIF
!--jaf.end

      END SUBROUTINE ADD_HG2_SNOWPACK
!EOC
!------------------------------------------------------------------------------
!          Harvard University Atmospheric Chemistry Modeling Group            !
!------------------------------------------------------------------------------
!BOP
!
! !IROUTINE: reset_hg_dep_arrays
!
! !DESCRIPTION: Subroutine RESET\_Hg\_DEP\_ARRAYS resets the wet and dry 
!  deposition arrays for Hg(II) and Hg(p) to zero. This allows us to call 
!  OCEAN\_MERCURY\_FLUX and LAND\_MERCURY\_FLUX in any order in MERCURY\_MOD. 
!\\
!\\
! !INTERFACE: 
!
      SUBROUTINE RESET_HG_DEP_ARRAYS
!
! !REVISION HISTORY:
!  02 Sep 2008 - C. Holmes   - Initial version
!  23 Apr 2010 - C. Carouge  - Moved from ocean_mercury_mod.f to
!                              depo_mercury_mod.f
!EOP
!------------------------------------------------------------------------------
!BOC
!
      ! Reset deposition arrays.
      DD_Hg2 = 0d0
      WD_Hg2 = 0d0
      DD_HgP = 0d0
      WD_HgP = 0d0

      END SUBROUTINE RESET_HG_DEP_ARRAYS
!EOC
!------------------------------------------------------------------------------
!          Harvard University Atmospheric Chemistry Modeling Group            !
!------------------------------------------------------------------------------
!BOP
!
! !IROUTINE: make_gtmm_restart
!
! !DESCRIPTION: MAKE\_GTMM\_RESTART writes a GTMM restart file with deposition
!  fluxes and store deposition fluxes for continuous runs.
!\\
!\\
! !INTERFACE: 
!
      SUBROUTINE MAKE_GTMM_RESTART( NYMD, NHMS, TAU )
! 
! !USES:
!
      USE BPCH2_MOD
      USE DIAG_MOD,      ONLY : AD39, AD44, AD38
      USE DIRECTORY_MOD, ONLY : RUN_DIR
      USE FILE_MOD,      ONLY : IU_FILE
      USE GRID_MOD,      ONLY : GET_XOFFSET, GET_YOFFSET
      USE TIME_MOD,      ONLY : EXPAND_DATE
      USE TRACERID_MOD,  ONLY : ID_Hg0, ID_Hg2, ID_Hg_tot
      USE TIME_MOD,      ONLY : GET_CT_DYN, GET_CT_CHEM
    
#     include "CMN_SIZE"          ! Size parameters
!
! !INPUT PARAMETERS: 
!
      INTEGER, INTENT(IN)   :: NYMD    ! Year-Month-Date
      INTEGER, INTENT(IN)   :: NHMS    ! and Hour-Min-Sec for which to create 
                                       ! a restart file 
      REAL*8,  INTENT(IN)   :: TAU     ! GEOS-CHEM TAU value corresponding to 
                                       ! NYMD, NHMS
! !REVISION HISTORY:
!  15 Sep 2009 - C. Carouge - Initial version
!EOP
!------------------------------------------------------------------------------
!BOC
!
! !LOCAL VARIABLES:
!
      INTEGER               :: HALFPOLAR, CENTER180
      INTEGER               :: IFIRST,    JFIRST,   LFIRST
      INTEGER               :: N,         NN
      REAL*8                :: TS_DYN,    TS_CHEM
      REAL*4                :: LONRES,    LATRES,   ARRAY(IGLOB,JGLOB,1)
      CHARACTER(LEN=20)     :: MODELNAME
      CHARACTER(LEN=40)     :: CATEGORY,  UNIT,     RESERVED
      CHARACTER(LEN=255)    :: FILENAME

      !=================================================================
      ! MAKE_GTMM_RESTART begins here!
      !=================================================================
    
      ! Initialize values
      IFIRST    = GET_XOFFSET( GLOBAL=.TRUE. ) + 1
      JFIRST    = GET_YOFFSET( GLOBAL=.TRUE. ) + 1
      LFIRST    = 1
      HALFPOLAR = GET_HALFPOLAR()
      CENTER180 = 1
      LONRES    = DISIZE
      LATRES    = DJSIZE
      MODELNAME = GET_MODELNAME()
      CATEGORY  = 'DRYD-FLX'
      RESERVED  = ''
      UNIT      = 'molec/cm2/s'

      ! Expand date in filename
      FILENAME  = TRIM( RUN_DIR ) // TRIM( GTMM_RST_FILE )
      CALL EXPAND_DATE( FILENAME, NYMD, NHMS )

      ! Echo info
      WRITE( 6, 100 ) TRIM( FILENAME )
 100  FORMAT( '     - MAKE_RESTART_FILE: Writing ', a )

      ! Open BPCH file for output
      CALL OPEN_BPCH2_FOR_WRITE( IU_FILE, FILENAME )

      !---------------------------
      ! Total Hg(0) dry deposition
      !---------------------------
      ARRAY(:,:,1) = HG0mth_dd
    
      CALL BPCH2( IU_FILE,   MODELNAME, LONRES,   LATRES,         
     &     HALFPOLAR, CENTER180, CATEGORY, N,                     
     &     UNIT,      TAU,       TAU,      RESERVED,              
     &     IIPAR,     JJPAR,     1,        IFIRST,                
     &     JFIRST,    LFIRST,    ARRAY(:,:,1) )

      !---------------------------
      ! Hg(II) dry deposition
      !---------------------------
      ARRAY(:,:,1) = HG2mth_dd

      CALL BPCH2( IU_FILE,   MODELNAME, LONRES,   LATRES,         
     &     HALFPOLAR, CENTER180, CATEGORY, N,                     
     &     UNIT,      TAU,       TAU,      RESERVED,              
     &     IIPAR,     JJPAR,     1,        IFIRST,                
     &    JFIRST,    LFIRST,    ARRAY(:,:,1) )

      !---------------------------
      ! Hg(II) wet deposition
      !---------------------------
      CATEGORY  = 'WETDLS-$'
      ARRAY(:,:,1) = HG2mth_wd

      CALL BPCH2( IU_FILE,   MODELNAME, LONRES,   LATRES,        
     &     HALFPOLAR, CENTER180, CATEGORY, N,                    
     &     UNIT,      TAU,       TAU,      RESERVED,             
     &     IIPAR,     JJPAR,     1,        IFIRST,               
     &     JFIRST,    LFIRST,    ARRAY(:,:,1) )
    
      ! Close file
      CLOSE( IU_FILE )
    
      END SUBROUTINE MAKE_GTMM_RESTART
!EOC
!------------------------------------------------------------------------------
!          Harvard University Atmospheric Chemistry Modeling Group            !
!------------------------------------------------------------------------------
!BOP
!
! !IROUTINE: read_gtmm_restart
!
! !DESCRIPTION: Subroutine READ\_GTMM\_RESTART reads dry and wet deposition 
!  for mercury from GTMM restart.
!\\
!\\
! !INTERFACE: 
!
      SUBROUTINE READ_GTMM_RESTART( YYYYMMDD, HHMMSS, 
     &                            Hg0dryGEOS, HgIIdryGEOS, HgIIwetGEOS )
! 
! !USES:
!
      USE BPCH2_MOD,     ONLY : OPEN_BPCH2_FOR_READ
      USE DIRECTORY_MOD, ONLY : RUN_DIR
      USE ERROR_MOD,     ONLY : DEBUG_MSG
      USE FILE_MOD,      ONLY : IU_FILE,     IOERROR
      USE TIME_MOD,      ONLY : EXPAND_DATE
      USE TRACER_MOD,    ONLY : STT,         TRACER_NAME, TRACER_MW_G
      USE TRACERID_MOD,  ONLY : GET_Hg0_CAT, GET_Hg2_CAT, N_Hg_CATS
      USE TRACERID_MOD,  ONLY : ID_Hg0,      ID_Hg2

#     include "CMN_SIZE"
!
! !INPUT PARAMETERS:
!
      INTEGER, INTENT(IN)   :: YYYYMMDD, HHMMSS
!
! !OUTPUT PARAMETERS:
!
      REAL*8, DIMENSION(IIPAR, JJPAR)   :: Hg0dryGEOS
      REAL*8, DIMENSION(IIPAR, JJPAR)   :: HgIIdryGEOS
      REAL*8, DIMENSION(IIPAR, JJPAR)   :: HgIIwetGEOS     
!
! !REVISION HISTORY:
!  15 Sep 2009 - C. Carouge - Initial version
!EOP
!------------------------------------------------------------------------------
!BOC
!
! !LOCAL VARIABLES:
!
      INTEGER               :: IOS, I, J, L, NN, N_gtmm
      INTEGER               :: NCOUNT(NNPAR) 
      REAL*4                :: FLUX(IIPAR,JJPAR)
      CHARACTER(LEN=255)    :: FILENAME

      ! For binary punch file, version 2.0
      INTEGER               :: NI,        NJ,      NL
      INTEGER               :: IFIRST,    JFIRST,  LFIRST
      INTEGER               :: NTRACER,   NSKIP
      INTEGER               :: HALFPOLAR, CENTER180
      REAL*4                :: LONRES,    LATRES
      REAL*8                :: ZTAU0,     ZTAU1
      CHARACTER(LEN=20)     :: MODELNAME
      CHARACTER(LEN=40)     :: CATEGORY
      CHARACTER(LEN=40)     :: UNIT     
      CHARACTER(LEN=40)     :: RESERVED
  
      !=================================================================
      ! READ_GTMM_RESTART begins here!
      !=================================================================

      ! Copy input file name to a local variable
      FILENAME = TRIM( RUN_DIR ) // TRIM( GTMM_RST_FILE )
    
      ! Replace YYYY, MM, DD, HH tokens in FILENAME w/ actual values
      CALL EXPAND_DATE( FILENAME, YYYYMMDD, HHMMSS )
    
      ! Echo some input to the screen
      WRITE( 6, '(a)' ) REPEAT( '=', 79 )
      WRITE( 6, 100   ) 
      WRITE( 6, 110   ) TRIM( FILENAME )
 100  FORMAT( 'G T M M  H g   R E S T A R T   F I L E   I N P U T' )
 110  FORMAT( /, 'READ_GTMM_RESTART: Reading ', a )

      ! Open the binary punch file for input
      CALL OPEN_BPCH2_FOR_READ( IU_FILE, FILENAME )
    
      !=================================================================
      ! Read concentrations -- store in the TRACER array
      !=================================================================
      DO 
         READ( IU_FILE, IOSTAT=IOS )                              
     &        MODELNAME, LONRES, LATRES, HALFPOLAR, CENTER180
       
         ! IOS < 0 is end-of-file, so exit
         IF ( IOS < 0 ) EXIT
       
         ! IOS > 0 is a real I/O error -- print error message
         IF ( IOS > 0 ) CALL IOERROR( IOS, IU_FILE, 'rd_gtmm_rst:1' )
       
         READ( IU_FILE, IOSTAT=IOS )                               
     &        CATEGORY, NTRACER,  UNIT, ZTAU0,  ZTAU1,  RESERVED,  
     &        NI,       NJ,       NL,   IFIRST, JFIRST, LFIRST,    
     &        NSKIP
       
         IF ( IOS /= 0 ) CALL IOERROR( IOS, IU_FILE, 'rd_gtmm_rst:2' )
       
         READ( IU_FILE, IOSTAT=IOS )                               
     &        ( ( FLUX(I,J), I=1,NI ), J=1,NJ )
       
         IF ( IOS /= 0 ) CALL IOERROR( IOS, IU_FILE, 'rd_gtmm_rst:3' )
       
         !==============================================================
         ! Assign data from the TRACER array to the STT array.
         !==============================================================
       
         ! Process dry deposition data 
         IF ( CATEGORY(1:8) == 'DRYD-FLX' ) THEN 
          
            ! Make sure array dimensions are of global size
            ! (NI=IIPAR; NJ=JJPAR, NL=LLPAR), or stop the run
            CALL CHECK_DIMENSIONS( NI, NJ, NL )
          
            ! Save into arrays
            IF ( ANY( ID_Hg0 == NTRACER ) ) THEN
             
               !----------
               ! Hg(0)
               !----------
             
               ! Get the Hg category #
               NN              = GET_Hg0_CAT( NTRACER )
             
               ! Store ocean Hg(0) in Hg0aq array
               Hg0dryGEOS(:,:)   = FLUX(:,:)
             
               ! Increment NCOUNT
               NCOUNT(NTRACER) = NCOUNT(NTRACER) + 1
             
            ELSE IF ( ANY( ID_Hg2 == NTRACER ) ) THEN
             
               !----------
               ! Hg(II)
               !----------
             
               ! Get the Hg category #
               NN              = GET_Hg2_CAT( NTRACER )
             
               ! Store ocean Hg(II) in Hg2_aq array
               HgIIdryGEOS(:,:)   = FLUX(:,:)
             
               ! Increment NCOUNT
               NCOUNT(NTRACER) = NCOUNT(NTRACER) + 1
             
            ENDIF
         ENDIF
       
         ! Process wet deposition data
         IF ( CATEGORY(1:8) == 'WETDLS-$' ) THEN 

            ! Make sure array dimensions are of global size
            ! (NI=IIPAR; NJ=JJPAR, NL=LLPAR), or stop the run
            ! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            ! %%%% KLUDGE: CHECK_DIMENSIONS only works for NL=1 !!!!
            ! And we are only interested by the surface flux...
            NL = 1
            ! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            CALL CHECK_DIMENSIONS( NI, NJ, NL )
          
            IF ( ANY( ID_Hg2 == NTRACER ) ) THEN
             
               !----------
               ! Hg(II)
               !----------
             
               ! Get the Hg category #
               NN              = GET_Hg2_CAT( NTRACER )
             
               ! Store ocean Hg(II) in Hg2_aq array
               HgIIwetGEOS(:,:)   = FLUX(:,:)
             
               ! Increment NCOUNT
               NCOUNT(NTRACER) = NCOUNT(NTRACER) + 1
             
            ENDIF
         ENDIF
      ENDDO
    
      ! Close file
      CLOSE( IU_FILE )      
    
      END SUBROUTINE READ_GTMM_RESTART
!EOC
!------------------------------------------------------------------------------
!          Harvard University Atmospheric Chemistry Modeling Group            !
!------------------------------------------------------------------------------
!BOP
!
! !IROUTINE: update_dep
!
! !DESCRIPTION: Subroutine UPDATE\_DEP update the monthly average for wet and 
!  dry deposition of Hg0 and Hg2 for mercury from GTMM restart.
!\\
!\\
! !INTERFACE: 
!
      SUBROUTINE UPDATE_DEP( NN )
! 
! !USES:
!
      USE DIAG_MOD,     ONLY : AD38,   AD39,   AD44
      USE LOGICAL_MOD,  ONLY : LGTMM
      USE TIME_MOD,     ONLY : GET_CT_DYN,  GET_CT_CHEM 
      USE TRACERID_MOD, ONLY : IDTHg0, IDTHg2
!
! !INPUT PARAMETERS:
!
      INTEGER :: NN    ! Hg2 ID for wet deposition
!
! !REVISION HISTORY:
!  04 June 2010  - C. Carouge  - Initial version
!EOP
!------------------------------------------------------------------------------
!BOC
!
! !LOCAL VARIABLES:
!
      INTEGER :: N
      REAL*8  :: SCALEDYN, SCALECHEM

      !=================================================================
      ! UPDATE_DEP begins here!
      !=================================================================

      ! counter variables 
      SCALEDYN   = DBLE( GET_CT_DYN()  ) + 1d-32
      SCALECHEM  = DBLE( GET_CT_CHEM() ) + 1d-32

      ! Hg2 total wet deposition at the surface
      HG2mth_wd = HG2mth_wd + ( SUM(AD38(:,:,:,NN), DIM=3) + 
     &                          SUM(AD39(:,:,:,NN), DIM=3) )
     &                      / SCALEDYN

      ! Hg0 total dry deposition at the surface
      N = IDTHg0
      HG0mth_dd = HG0mth_dd + AD44(:,:,N,1) / SCALECHEM

      ! Hg2 total dry deposition at the surface
      N = IDTHg2
      HG2mth_dd = HG2mth_dd + AD44(:,:,N,1) / SCALECHEM

      END SUBROUTINE UPDATE_DEP
!EOC
!------------------------------------------------------------------------------
!          Harvard University Atmospheric Chemistry Modeling Group            !
!------------------------------------------------------------------------------
!BOP
!
! !IROUTINE: check_dimensions
!
! !DESCRIPTION: Subroutine CHECK\_DIMENSIONS makes sure that the dimensions of 
!  the Hg restart file extend to cover the entire grid.
!\\
!\\
! !INTERFACE: 
!
      SUBROUTINE CHECK_DIMENSIONS( NI, NJ, NL ) 
!
! !USES:
!
      USE ERROR_MOD, ONLY : GEOS_CHEM_STOP
#     include "CMN_SIZE"
!
! !INPUT PARAMETERS:
!
      INTEGER, INTENT(IN) :: NI, NJ, NL
!
! !REVISION HISTORY:
!  30 Aug 2010 - S. Strode, C. Holmes - Initial version
!EOP
!------------------------------------------------------------------------------
!BOC
!
      !=================================================================
      ! CHECK_DIMENSIONS begins here!
      !=================================================================

      ! Error check longitude dimension: NI must equal IIPAR
      IF ( NI /= IIPAR ) THEN
         WRITE( 6, 100 ) 
 100     FORMAT( 'ERROR reading in Hg restart file', /
     &           'Wrong number of longitudes encountered', /
     &           'STOP in CHECK_DIMENSIONS ("ocean_mercury_mod.f")' )
         WRITE( 6, '(a)' ) REPEAT( '=', 79 )
         CALL GEOS_CHEM_STOP
      ENDIF

      ! Error check latitude dimension: NJ must equal JJPAR
      IF ( NJ /= JJPAR ) THEN
         WRITE( 6, 110 ) 
 110     FORMAT( 'ERROR reading in Hg restart file', /
     &           'Wrong number of longitudes encountered', /
     &           'STOP in CHECK_DIMENSIONS ("ocean_mercury_mod.f")' )
         WRITE( 6, '(a)' ) REPEAT( '=', 79 )
         CALL GEOS_CHEM_STOP
      ENDIF
      
      ! Error check vertical dimension: NL must equal LLPAR
      IF ( NL /= 1 ) THEN
         WRITE( 6, 120 ) 
 120     FORMAT( 'ERROR reading in Hg restart file', /
     &           'Wrong number of longitudes encountered', /
     &           'STOP in CHECK_DIMENSIONS ("ocean_mercury_mod.f")' )
         WRITE( 6, '(a)' ) REPEAT( '=', 79 )
         CALL GEOS_CHEM_STOP
      ENDIF

      END SUBROUTINE CHECK_DIMENSIONS
!EOC
!------------------------------------------------------------------------------
!          Harvard University Atmospheric Chemistry Modeling Group            !
!------------------------------------------------------------------------------
!BOP
!
! !IROUTINE: init_depo_mercury
!
! !DESCRIPTION: Subroutine INIT\_DEPO\_MERCURY initialize deposition arrays 
!  for mercury.
!\\
!\\
! !INTERFACE: 
!
      SUBROUTINE INIT_DEPO_MERCURY( THIS_Hg_RST_FILE )
!
! !USES
!
      USE ERROR_MOD,    ONLY : ALLOC_ERR
      USE LOGICAL_MOD,  ONLY : LGTMM
      USE TRACERID_MOD, ONLY : N_Hg_CATS

#     include "CMN_SIZE"     ! Size parameters
!
! !INPUT PARAMETERS:
!
      ! Name of the GTMM restart file
      CHARACTER(LEN=*), INTENT(IN) :: THIS_Hg_RST_FILE
!
! !REVISION HISTORY:
!  23 Apr 2010 - C. Carouge   - Moved arrays allocation from 
!                               ocean_mercury_mod.f
!EOP
!------------------------------------------------------------------------------
!BOC
!
! !LOCAL VARIABLES:
!
      INTEGER                      :: AS

      ! GTMM restart file name
      GTMM_RST_FILE = THIS_Hg_RST_FILE

      ! Allocate arrays
      ALLOCATE( DD_Hg2( IIPAR, JJPAR, N_Hg_CATS ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'DD_Hg2' )
      DD_Hg2 = 0d0

      ALLOCATE( DD_HgP( IIPAR, JJPAR, N_Hg_CATS ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'DD_HgP' )
      DD_HgP = 0d0

      ALLOCATE( WD_Hg2( IIPAR, JJPAR, N_Hg_CATS ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'WD_Hg2' )
      WD_Hg2 = 0d0

      ALLOCATE( WD_HgP( IIPAR, JJPAR, N_Hg_CATS ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'WD_HgP' )
      WD_HgP = 0d0

      ! CDH for snowpack
      ALLOCATE( SNOW_HG( IIPAR, JJPAR, N_Hg_CATS ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'SNOW_HG' )
      SNOW_HG = 0d0

      IF ( LGTMM ) THEN
         ALLOCATE( HG0mth_dd( IIPAR, JJPAR ), STAT=AS )
         IF ( AS /= 0 ) CALL ALLOC_ERR( 'HG0mth_dd' )
         HG0mth_dd = 0d0
         
         ALLOCATE( HG2mth_dd( IIPAR, JJPAR ), STAT=AS )
         IF ( AS /= 0 ) CALL ALLOC_ERR( 'HG2mth_dd' )
         HG2mth_dd = 0d0
         
         ALLOCATE( HG2mth_wd( IIPAR, JJPAR ), STAT=AS )
         IF ( AS /= 0 ) CALL ALLOC_ERR( 'HG2mth_wd' )
         HG2mth_wd = 0d0
      ENDIF

      END SUBROUTINE INIT_DEPO_MERCURY
!EOC
!------------------------------------------------------------------------------
!          Harvard University Atmospheric Chemistry Modeling Group            !
!------------------------------------------------------------------------------
!BOP
!
! !IROUTINE: cleanup_depo_mercury
!
! !DESCRIPTION: Subroutine CLEANUP\_DEPO\_MERCURY deallocate all arrays
!\\
!\\
! !INTERFACE: 
!
      SUBROUTINE CLEANUP_DEPO_MERCURY
!
! !REVISION HISTORY:
!  23 Apr 2010 - C. Carouge - Moved from ocean_mercury_mod.f
!EOP
!------------------------------------------------------------------------------
!BOC
!
      IF ( ALLOCATED( DD_Hg2      ) ) DEALLOCATE( DD_Hg2      )
      IF ( ALLOCATED( DD_HgP      ) ) DEALLOCATE( DD_HgP      )
      IF ( ALLOCATED( WD_Hg2      ) ) DEALLOCATE( WD_Hg2      )
      IF ( ALLOCATED( WD_HgP      ) ) DEALLOCATE( WD_HgP      )
      IF ( ALLOCATED( SNOW_HG     ) ) DEALLOCATE( SNOW_HG     )!CDH for snowpack
      IF ( ALLOCATED( HG0mth_dd   ) ) DEALLOCATE( HG0mth_dd   )
      IF ( ALLOCATED( HG2mth_dd   ) ) DEALLOCATE( HG2mth_dd   )
      IF ( ALLOCATED( HG2mth_wd   ) ) DEALLOCATE( HG2mth_wd   )
      
      END SUBROUTINE CLEANUP_DEPO_MERCURY

      END MODULE DEPO_MERCURY_MOD
!EOC
