      SUBROUTINE IFP4        
C        
C     HYDROELASTIC PREFACE ROUTINE        
C        
C     THIS PREFACE MODULE OPERATES ON FLUID RELATED INPUT DATA WHICH    
C     EXISTS AT THIS POINT IN THE FORM OF CARD IMAGES ON THE AXIC DATA  
C     BLOCK.        
C        
C     7/12/73 NO AXIAL SYMMETRY FIRST FIVE WORDS OF BNDFL NO WRITTEN    
C        
C     THE FOLLOWING LIST GIVES THE CARD IMAGES IFP4 WILL LOOK FOR ON THE
C     AXIC DATA BLOCK, THE CARD IMAGES IFP4 WILL GENERATE OR MODIFY, AND
C     THE DATA BLOCKS ONTO WHICH THE GENERATED OR MODIFIED CARD IMAGES  
C     WILL BE PLACED.        
C        
C     IFP4 INPUT         IFP4 OUTPUT        DATA BLOCK        
C     CARD IMAGE         CARD IMAGE         EFFECTED        
C     -----------        -----------        ----------        
C       AXIF               -NONE-             -NONE-        
C       BDYLIST            -DATA-             MATPOOL        
C       CFLUID2            CFLUID2            GEOM2        
C       CFLUID3            CFLUID3            GEOM2        
C       CFLUID4            CFLUID4            GEOM2        
C       FLSYM              -DATA-             MATPOOL        
C       FREEPT             SPOINT             GEOM2        
C                          MPC                GEOM4        
C       FSLIST             CFSMASS            GEOM2        
C                          SPC                GEOM4        
C       GRIDB              GRID               GEOM1        
C       PRESPT             SPOINT             GEOM2        
C                          MPC                GEOM4        
C       RINGFL             GRID               GEOM1        
C                          SEQGP              GEOM1        
C       DMIAX              DMIG               MATPOOL        
C        
C     SOME OF THE ABOVE OUTPUT CARD IMAGES ARE A FUNCTION OF SEVERAL    
C     INPUT CARD IMAGES        
C        
      LOGICAL         HARMS    ,ANYGB    ,END      ,ANY      ,G1EOF    ,
     1                G2EOF    ,G4EOF    ,SET102   ,PRESS    ,BIT      ,
     2                NOGO     ,MATEOF   ,ANYGRD   ,BIT2        
      INTEGER         AXIF(2)  ,BDYLST(2),CFLUID(6),FLSYM(2) ,FREEPT(2),
     1                FSLST(2) ,GRIDB(2) ,PRESPT(2),RINGFL(2),CFSMAS(2),
     2                MPC(2)   ,MPCADD(2),TYPE(2)  ,SPOINT(2),CORD(8)  ,
     3                SPC(2)   ,SPCADD(2),SPC1(2)  ,NCORD(4) ,GEOM1    ,
     4                SUBR(2)  ,BUF(10)  ,LAST(10) ,AXIC     ,GEOM2    ,
     5                CARD(10) ,FILE     ,MATPOL   ,GEOM4    ,SEQGP(2) ,
     6                SCRT1    ,ENTRYS   ,CORSYS   ,SPACE    ,CORE     ,
     7                SCRT2    ,SYSBUF   ,OUTPUT   ,FLAG     ,EOR      ,
     8                CSF      ,RD       ,RDREW    ,WRT      ,WRTREW   ,
     9                CLS      ,CLSREW   ,SAVEID(5),MONES(4) ,DMIG(2)  ,
     O                BUF1     ,BUF2     ,BUF3     ,BUF4     ,BUF5     ,
     1                WORDS    ,BNDFL(2) ,TRAIL(7) ,Z        ,POINT    ,
     2                DMIAX(2) ,MSG1(2)  ,MSG2(2)  ,GRID(2)        
      REAL            RBUF(10) ,RCARD(10),RZ(4)        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /SYSTEM/ SYSBUF   ,OUTPUT   ,NOGO     ,DUM34(34),IAXIF     
      COMMON /NAMES / RD       ,RDREW    ,WRT      ,WRTREW   ,CLSREW   ,
     1                CLS        
CZZ   COMMON /ZZIFP4/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      EQUIVALENCE     (Z(1),RZ(1)), (BUF(1),RBUF(1)), (CARD(1),RCARD(1))
     1,               (CORE,ICORE), (RHOB,IRHOB), (BD,IBD)        
      DATA    AXIF  / 8815  ,88    /        
      DATA    BDYLST/ 8915  ,89    /        
      DATA    CFLUID/ 7815  ,78    , 7915  ,79   , 8015  ,80 /        
      DATA    FLSYM / 9115  ,91    /        
      DATA    FREEPT/ 9015  ,90    /        
      DATA    FSLST / 8215  ,82    /        
      DATA    GRIDB / 8115  ,81    /        
      DATA    PRESPT/ 8415  ,84    /        
      DATA    RINGFL/ 8315  ,83    /        
      DATA    CFSMAS/ 2508  ,25    /        
      DATA    BNDFL / 9614  ,96    /        
      DATA    MPC   / 4901  ,49    /        
      DATA    SPC   / 5501  ,55    /        
      DATA    SPC1  / 5481  ,58    /        
      DATA    MPCADD/ 4891  ,60    /        
      DATA    SPCADD/ 5491  ,59    /        
      DATA    SPOINT/ 5551  ,49    /        
      DATA    GRID  / 4501  ,45    /        
      DATA    SEQGP / 5301  ,53    /        
      DATA    DMIAX / 214   ,2     /        
      DATA    DMIG  / 114   ,1     /        
      DATA    CORD   /1701  ,17    , 1901  ,19   , 2001 ,20  ,2201 ,22 /
      DATA    NCORD / 6     ,6     , 13    ,13   /        
      DATA    MONES / -1    ,-1    , -1    ,-1   /        
      DATA    SUBR  / 4HIFP4,4H    /        
      DATA    DEGRAD/ 1.7453292519943E-02/, MINUS1/ -1 /        
      DATA    GEOM1 , GEOM2,GEOM4  / 201,208,210  /        
      DATA    AXIC  , MATPOL,EOR   / 215,214,1    /        
C        
C     NOTE  SCRATCH2 IN IFP4 IS EQUIVALENCED TO THE -FORCE- DATA BLOCK  
C        
      DATA    SCRT1 , SCRT2 , NOEOR /  301,213,0  /        
      DATA    MSG1  / 4HIFP4, 4HBEGN/, MSG2       / 4HIFP4, 4HEND  /    
C        
C     DEFINE CORE AND BUFFER POINTERS        
C        
      CALL CONMSG (MSG1,2,0)        
      ICORE = KORSZ(Z)        
      BUF1  = ICORE- SYSBUF - 2        
      BUF2  = BUF1 - SYSBUF - 2        
      BUF3  = BUF2 - SYSBUF - 2        
      BUF4  = BUF3 - SYSBUF - 2        
      BUF5  = BUF4 - SYSBUF - 2        
      ICORE = BUF5 - 1        
      ICRQ  = 100  - ICORE        
      IF (ICORE .LT. 100) GO TO 2370        
C        
C     OPEN AXIC DATA BLOCK (IF NAME NOT IN FIST RETURN - NO MESSAGE)    
C        
      CALL PRELOC (*2300,Z(BUF1),AXIC)        
C        
C     PICK UP AXIF CARD. (IF AXIF CARD NOT PRESENT - RETURN NO MESSAGE) 
C        
      CALL LOCATE (*2300,Z(BUF1),AXIF,FLAG)        
      CALL READ (*2320,*30,AXIC,Z(1),ICORE,EOR,WORDS)        
      WRITE  (OUTPUT,10) UFM        
   10 FORMAT (A23,' 4031, INSUFFICIENT CORE TO READ DATA ON AXIF CARD.')
      WRITE  (OUTPUT,20) ICORE        
   20 FORMAT (5X,'ADDITIONAL CORE NEEDED =',I8,' WORDS.')        
      GO TO 2310        
C        
C     DATA OF AXIF CARD IS NOW STORED        
C        
   30 CSF   = Z(1)        
      G     = RZ(2)        
      DRHO  = RZ(3)        
      J     = 3        
      IDRHO = Z(J)        
      BD    = RZ(4)        
      NOSYM = Z(J+2)        
      IN    = 6        
      NN    = WORDS - 1        
      NI    = NN        
      J     = NN - IN + 1        
      HARMS = .FALSE.        
      IF (J .GE. 1) HARMS =.TRUE.        
      IF (.NOT.HARMS) GO TO 100        
C        
C     CONVERT USER INPUT LIST OF HARMONIC NUMBERS TO A LIST OF INDICES. 
C        
      IF (J .EQ. 1) GO TO 40        
      CALL SORT (0,0,1,1,Z(IN),J)        
   40 II = NN + 1        
      NI = NN        
      DO 70 I = IN,NN        
      ITEMP = 2*Z(I)        
      IF (NOSYM) 50,60,50        
   50 IF (Z(I) .EQ. 0) GO TO 60        
      NI = NI + 1        
      Z(NI) = ITEMP + 1        
   60 NI = NI + 1        
      Z(NI) = ITEMP + 2        
   70 CONTINUE        
      N  = NI - II + 1        
C        
C     SET MAXIMUM HARMONIC+1 FOR USE BY SDR2C AND VDRB        
C        
      IAXIF = Z(NN) + 1        
C        
C     BEGIN GEOM1 PROCESSING        
C     **********************        
C        
C     OPEN GEOM1 AND FIND CORD1C, CORD1S, CORD2C, OR CORD2S CARD IMAGE  
C     WITH COORDINATE SYSTEM ID = CSF OF AXIF CARD. THEN NOTE TYPE      
C     (CYLINDRICAL OR SPHERICAL, 2 OR 3 RESPECTIVELY)        
C        
  100 FILE = GEOM1        
C        
C     BEFORE CALLING PRELOC ON GEOM1 CHECK FOR DATA ON GEOM1        
C        
      TRAIL(1) = GEOM1        
      CALL RDTRL (TRAIL)        
      DO 110 I = 2,7        
      IF (TRAIL(I)) 120,110,120        
  110 CONTINUE        
      GO TO 150        
  120 CALL PRELOC (*2360,Z(BUF2),GEOM1)        
      DO 140 I = 1,4        
      I2 = 2*I        
      CALL LOCATE (*140,Z(BUF2),CORD(I2-1),FLAG)        
      NSIZE = NCORD(I)        
  130 CALL READ (*2340,*140,GEOM1,Z(NI+1),NSIZE,NOEOR,FLAG)        
      IF (Z(NI+1) .EQ. CSF) GO TO 170        
      GO TO 130        
  140 CONTINUE        
C        
C     FALL THROUGH LOOP IMPLIES COORDINATE SYSTEM WAS NOT FOUND        
C        
  150 NOGO = .TRUE.        
      WRITE  (OUTPUT,160) UFM,CSF        
  160 FORMAT (A23,' 4033, COORDINATE SYSTEM ID =',I20,' AS SPECIFIED ', 
     1       'ON AXIF CARD IS NOT PRESENT', /5X,' AMONG ANY OF CORD1C,',
     2       ' CORD1S, CORD2C, OR CORD2S CARD TYPES.', /5X,        
     3       ' CYLINDRICAL TYPE ASSUMED FOR CONTINUING DATA CHECK.')    
      CORSYS = 2        
      GO TO 180        
  170 CORSYS = Z(NI+2)        
  180 CALL CLOSE (GEOM1,CLSREW)        
C        
C     READ INTO CORE FROM AXIC ALL GRIDB CARD IMAGES (5 WORDS / IMAGE)  
C        
      ANYGB  = .FALSE.        
      IGRIDB = NI + 1        
      NGRIDB = NI        
      CALL LOCATE (*210,Z(BUF1),GRIDB,FLAG)        
      ANYGB = .TRUE.        
      SPACE = CORE- NI        
      CALL READ (*2320,*200,AXIC,Z(IGRIDB),SPACE,EOR,NWORDS)        
      NOGO = .TRUE.        
      WRITE  (OUTPUT,190) UFM        
  190 FORMAT (A23,' 4034, INSUFFICIENT CORE TO HOLD GRIDB CARD IMAGES.')
      WRITE (OUTPUT,20) SPACE        
      ANYGB = .FALSE.        
      GO TO 210        
  200 NGRIDB = NI + NWORDS        
C        
C     IF ANY GRIDB IMAGES ARE PRESENT A BOUNDARY LIST IS FORMED IN CORE.
C        
  210 IBDYL = NGRIDB + 1        
      NBDYL = NGRIDB        
      IF (.NOT.ANYGB) GO TO 520        
      CALL LOCATE (*520,Z(BUF1),BDYLST,FLAG)        
  220 CALL READ (*2320,*330,AXIC,RHOB,1,NOEOR,FLAG)        
      IF (IRHOB .NE. 1) GO TO 250        
      IF (IDRHO .NE. 1) GO TO 240        
      NOGO = .TRUE.        
      WRITE  (OUTPUT,230) UFM        
  230 FORMAT (A23,' 4035, THE FLUID DENSITY HAS NOT BEEN SPECIFIED ON ',
     1        'A BDYLIST CARD AND', /5X,'THERE IS NO DEFAULT FLUID ',   
     2        'DENSITY SPECIFIED ON THE AXIF CARD.')        
      RHOB = 1.0        
      GO TO 250        
  240 RHOB = DRHO        
  250 END  = .FALSE.        
      IDFPRE = 0        
  260 CALL READ (*2320,*2330,AXIC,IDF,1,NOEOR,FLAG)        
      IF (IDF .NE. 0) GO TO 270        
      IDFPRE = -1        
      GO TO 260        
  270 CALL READ (*2320,*2330,AXIC,IDFAFT,1,NOEOR,FLAG)        
C        
C     NOTE.......  ON INPUT   ID=0 IMPLIES AXIS        
C                             ID=-1 IMPLIES END OF CARD        
C        
C        
C     NOTE.......  ON OUTPUT  ID=0 IMPLIES UNDEFINED ID        
C                             ID=-1 IMPLIES AXIS        
C        
      IF (IDFAFT .EQ. -1) GO TO 280        
      IF (IDFAFT .EQ.  0) IDFAFT = -1        
      GO TO 290        
  280 IDFAFT = 0        
      END = .TRUE.        
C        
C     DO NOT PUT OUT ENTRY WHEN IDF = AXIS        
C        
  290 IF (IDF .EQ. -1) GO TO 320        
      IF (NBDYL+7 .LE. CORE) GO TO 310        
      WRITE  (OUTPUT,300) UFM        
  300 FORMAT (A23,' 4036, INSUFFICIENT CORE TO BUILD BOUNDARY LIST ',   
     1       'TABLE.')        
      ICRQ = NBDYL + 7 - CORE        
      GO TO 2370        
  310 Z(NBDYL +1) = IDF        
      Z(NBDYL +2) = 1        
      Z(NBDYL +3) = 1        
      Z(NBDYL +4) = 1        
      Z(NBDYL +5) = IDFPRE        
      Z(NBDYL +6) = IDFAFT        
      RZ(NBDYL+7) = RHOB        
      NBDYL = NBDYL + 7        
C        
C     ROTATE THE ID-S        
C        
  320 IDFPRE = IDF        
      IDF = IDFAFT        
      IF (.NOT.END) GO TO 270        
      GO TO 220        
C        
C     SORT ENTRIES ON FIRST WORD OF EACH ENTRY.        
C        
  330 CALL SORT (0,0,7,1,Z(IBDYL),NBDYL-IBDYL+1)        
      ENTRYS = (NBDYL-IBDYL+1)/7        
C        
C     PASS THE RINGFL IMAGES INSERTING X1, X2, AND X3 IN THE APPROPRIATE
C     BDYLIST ENTRY.        
C        
      CALL LOCATE (*490,Z(BUF1),RINGFL,FLAG)        
  340 CALL READ (*2320,*490,AXIC,BUF,4,NOEOR,FLAG)        
      IF (CORSYS  .NE.  3) GO TO 360        
      IF (RBUF(3) .NE. 0.) GO TO 360        
      NOGO = .TRUE.        
      WRITE  (OUTPUT,350) UFM,BUF(1)        
  350 FORMAT (A23,' 5003, ZERO X2 VALUE ON RINGFL CARD WITH SPHERICAL ',
     1       'COORDINATES.  FLUID POINT ID =',I10)        
  360 IF (BUF(CORSYS+1)) 370,410,370        
  370 NOGO = .TRUE.        
      IF (CORSYS .EQ. 3) GO TO 390        
      WRITE  (OUTPUT,380) UFM,BUF(1)        
  380 FORMAT (A23,'4042, COORDINATE SYSTEM IS CYLINDRICAL BUT RINGFL ', 
     1       'CARD ID =',I20,' HAS A NON-ZERO X2 VALUE.')        
      GO TO 410        
  390 WRITE  (OUTPUT,400) UFM,BUF(1)        
  400 FORMAT (A23,' 4043, COORDINATE SYSTEM IS SPHERICAL BUT RINGFL ',  
     1       'CARD ID =',I20,' HAS A NON-ZERO X3 VALUE.')        
  410 CALL BISLOC(*340,BUF(1),Z(IBDYL),7,ENTRYS,JPOINT)        
      NTEMP = IBDYL + JPOINT - 1        
      IF (Z(NTEMP+1) .EQ. 1) GO TO 430        
      NOGO = .TRUE.        
      WRITE  (OUTPUT,420) UFM,BUF(1)        
  420 FORMAT (A23,' 4038, RINGFL CARD HAS ID =',I20,' WHICH HAS BEEN ', 
     1       'USED.')        
      GO TO 340        
C        
C     CHECK TO GET RANGE OF BDYLIST HAVING THIS SAME ID.        
C     THEN FILL IN X1, X2, AND X3 IN THOSE ENTRIES.        
C        
  430 NLIST = NTEMP        
  440 NTEMP = NTEMP - 7        
      IF (NTEMP .LT. IBDYL) GO TO 450        
      IF (Z(NTEMP) .EQ. Z(NTEMP+7)) GO TO 440        
  450 ILIST = NTEMP + 7        
      NTEMP = NLIST        
  460 NTEMP = NTEMP + 7        
      IF (NTEMP .GT. NBDYL) GO TO 470        
      IF (Z(NTEMP) .EQ. Z(NTEMP-7)) GO TO 460        
  470 NLIST = NTEMP - 1        
      DO 480 I = ILIST,NLIST,7        
      Z(I+1) = BUF(2)        
      Z(I+2) = BUF(3)        
      Z(I+3) = BUF(4)        
  480 CONTINUE        
      GO TO 340        
C        
C     CHECK TO SEE THAT X1, X2, AND X3 WERE FOUND FOR ALL ENTRIES.      
C        
  490 DO 510 I = IBDYL,NBDYL,7        
      IF (Z(I+1) .NE. 1) GO TO 510        
      NOGO = .TRUE.        
      WRITE  (OUTPUT,500) UFM,Z(I)        
  500 FORMAT (A23,' 4040, ID =',I20,' APPEARS ON A BDYLIST CARD, BUT ', 
     1       'NO RINGFL CARD IS PRESENT WITH THE SAME ID.')        
  510 CONTINUE        
C        
C     OPEN GEOM1, OPEN SCRATCH1, COPY HEADER REC FROM GEOM1 TO SCRATCH1 
C        
  520 CALL IFP4C (GEOM1,SCRT1,Z(BUF2),Z(BUF3),G1EOF)        
C        
C     COPY ALL DATA UP TO FIRST GRID CARD IMAGE.        
C        
      CALL IFP4B (GEOM1,SCRT1,ANY,Z(NBDYL+1),CORE-NBDYL,GRID,G1EOF)     
      ANYGRD = ANY        
      IF (.NOT.ANYGB) GO TO 1040        
      IF (NBDYL .LT. IBDYL) GO TO 1040        
C        
C     CREATE AND MERGE WITH GRIDS FROM GEOM1, GRIDS FROM GRIDB IMAGES.  
C        
      FILE = GEOM1        
      IF (.NOT.ANY) GO TO 540        
      CALL READ (*2340,*530,GEOM1,LAST,8,NOEOR,FLAG)        
      CALL IFP4E (LAST(1))        
      GO TO 540        
  530 ANY = .FALSE.        
  540 DO 600 I = IGRIDB,NGRIDB,5        
      CARD(1) = Z(I)        
      CALL IFP4E (CARD(1))        
      CARD(2) = CSF        
      KID = Z(I+4)        
      CALL BISLOC (*560,KID,Z(IBDYL),7,ENTRYS,POINT)        
      NTEMP   = IBDYL + POINT - 1        
      CARD(3) = Z(NTEMP+1)        
      CARD(4) = Z(NTEMP+2)        
      CARD(5) = Z(NTEMP+3)        
      CARD(CORSYS+2) = Z(I+1)        
      CARD(6) = Z(I+2)        
      CARD(7) = Z(I+3)        
      CARD(8) = 0        
C        
C     MERGE CARD IN        
C        
      IF (.NOT.ANY) GO TO 590        
  550 IF (LAST(1) .GT. CARD(1)) GO TO 590        
      CALL WRITE (SCRT1, LAST, 8, NOEOR)        
      CALL READ (*2340,*580,GEOM1,LAST,8,NOEOR,FLAG)        
      CALL IFP4E (LAST(1))        
      GO TO 550        
  560 NOGO = .TRUE.        
      WRITE  (OUTPUT,570) UFM,Z(I),Z(I+4)        
  570 FORMAT (A23,' 4057, GRIDB CARD WITH ID =',I10,' HAS A REFERENCE ',
     1       'IDF =',I10,/5X,'WHICH DOES NOT APPEAR IN A BOUNDARY LIST')
      GO TO 600        
  580 ANY = .FALSE.        
  590 CALL WRITE (SCRT1,CARD,8,NOEOR)        
  600 CONTINUE        
C        
      IF (.NOT.ANY) GO TO 620        
  610 CALL WRITE (SCRT1,LAST,8,NOEOR)        
      CALL READ (*2340,*620,GEOM1,LAST,8,NOEOR,FLAG)        
      CALL IFP4E (LAST(1))        
      GO TO 610        
C        
C     FURTHER ALTERATIONS TO BOUNDARY LIST TABLE AT THIS TIME.        
C     RADIAL LOCATION (RJ) AND VERTICAL LOCATION (ZJ)        
C        
  620 NRING = NGRIDB        
      IF (.NOT.HARMS) GO TO 1200        
      DO 640 I = IBDYL,NBDYL,7        
      IF (CORSYS .EQ. 3) GO TO 630        
      Z(I+2) = Z(I+3)        
      GO TO 640        
C        
  630 ANGLE = RZ(I+2)*DEGRAD        
      TEMP  = RZ(I+1)        
      RZ(I+1) = TEMP*SIN(ANGLE)        
      RZ(I+2) = TEMP*COS(ANGLE)        
  640 CONTINUE        
C        
C     LENGTH AND ASSOCIATED ANGLE COMPONENTS OF A CONICAL SECTION. L,C,S
C        
      IF (NOGO) GO TO 780        
      DO 770 I = IBDYL,NBDYL,7        
      RJ = RZ(I+1)        
      ZJ = RZ(I+2)        
C        
C     FIND R   , Z     AND  R   , Z     (RJL1,ZJL1,RJP1,ZJP1)        
C           J-1   J-1        J+1   J+1        
C        
      IF (Z(I+4)) 650,660,670        
C        
C     SECONDARY ID IS AXIS        
C        
  650 RJL1 = 0        
      ZJL1 = ZJ        
      GO TO 680        
C        
C     SECONDARY ID IS NOT AVAILABLE        
C        
  660 RJL1 = RJ        
      ZJL1 = ZJ        
      GO TO 680        
C        
C     FIND SECONDARY ID ENTRY        
C        
  670 KID = Z(I+4)        
      CALL BISLOC (*2380,KID,Z(IBDYL),7,ENTRYS,POINT)        
      NTEMP = IBDYL + POINT - 1        
      RJL1  = RZ(NTEMP+1)        
      ZJL1  = RZ(NTEMP+2)        
C        
C     SECONDARY ID ON PLUS SIDE        
C        
  680 IF (Z(I+5)) 690,700,710        
C        
C     SECONDARY ID IS AXIS        
C        
  690 RJP1 = 0        
      ZJP1 = ZJ        
      GO TO 720        
C        
C     SECONDARY ID IS NOT AVAILABLE        
C        
  700 RJP1 = RJ        
      ZJP1 = ZJ        
      GO TO 720        
C        
C     FIND SECONDARY ID ENTRY        
C        
  710 KID = Z(I+5)        
      CALL BISLOC (*2380,KID,Z(IBDYL),7,ENTRYS,POINT)        
      NTEMP = IBDYL + POINT - 1        
      RJP1  = RZ(NTEMP+1)        
      ZJP1  = RZ(NTEMP+2)        
C        
C     COMPUTE AND INSERT L,C,S.        
C        
  720 IF (RJ .NE. 0.0) GO TO 740        
      NOGO = .TRUE.        
      WRITE  (OUTPUT,730) UFM,Z(I)        
  730 FORMAT (A23,' 4044, RINGFL CARD ID =',I20,' HAS SPECIFIED A ',    
     1       'ZERO RADIAL LOCATION.')        
      GO TO 770        
C        
  740 TEMP1 = RJP1 - RJ        
      TEMP2 = 0.25/RJ        
      R = 0.5*(RJP1-RJL1+TEMP2*(TEMP1*TEMP1-(RJL1-RJ)**2))        
      ZZ= 0.5*(ZJL1-ZJP1+TEMP2*(TEMP1*(ZJ-ZJP1)-(RJ-RJL1)*(ZJL1-ZJ)))   
      RZ(I+3) = SQRT(R*R + ZZ*ZZ)        
      IF (RZ(I+3) .NE. 0.0) GO TO 760        
      NOGO = .TRUE.        
      WRITE  (OUTPUT,750) UFM,Z(I)        
  750 FORMAT (A23,' 4045, THE BOUNDARY LIST ENTRY FOR ID =',I9,        
     1       ' HAS A ZERO CROSS-SECTION LENGTH.')        
      GO TO 770        
C        
  760 RZ(I+4) = ZZ/RZ(I+3)        
      RZ(I+5) =  R/RZ(I+3)        
  770 CONTINUE        
C        
C     SORT GRIDB IMAGES TO BE IN SORT ON RID AND PHI WITHIN EACH RID    
C        
  780 NTEMP = NGRIDB - IGRIDB + 1        
      CALL SORT (0,0,5,-2,Z(IGRIDB),NTEMP)        
      CALL SORT (0,0,5,-5,Z(IGRIDB),NTEMP)        
C        
C     THE BOUNDARY FLUID DATA IS ADDED TO THE MATPOOL DATA BLOCK AS 1   
C     LOCATE RECORD CONTAINING THE FOLLOWING.        
C        
C     1-3   LOCATE CODE  9614,96,0        
C     4     CDF        
C     5     G        
C     6     DRHO        
C     7     BD        
C     8     NOSYM        
C     9     M        
C     10    S1        
C     11    S2        
C     12    N = NUMBER OF INDICES FOLLOWING        
C     12+1  THRU  12+N  THE INDICES        
C     13+N TO THE EOR IS THE BOUNDARY FLUID DATA        
C        
C        
      FILE  = MATPOL        
      INAME = NBDYL + 1        
      NNAME = NBDYL        
      CALL IFP4C (MATPOL,SCRT2,Z(BUF4),Z(BUF5),MATEOF)        
      IF (MATEOF) GO TO 930        
C        
C     IF ANY DMIAX CARDS ARE PRESENT THEN THEY ARE MERGED IN FRONT OF   
C     DMIG CARDS IN THE DMIG RECORD.  FILE NAMES MAY NOT BE THE SAME ON 
C     BOTH DMIG AND DMIAX CARDS.        
C        
      CALL IFP4F (DMIAX(2),MATPOL,BIT)        
      CALL IFP4F (DMIG(2) ,MATPOL,BIT2)        
C        
C     LOCATE DMIAX CARDS, COPY THEM TO SCRT2 AS DMIG CARDS AND KEEP     
C     LIST OF THEIR FILE NAMES.        
C        
      IF (.NOT.BIT .AND. .NOT.BIT2) GO TO 900        
      CALL CLOSE (MATPOL,CLSREW)        
      CALL PRELOC (*2360,Z(BUF4),MATPOL)        
C        
C     WRITE DMIG HEADER.        
C        
      BUF(1) = DMIG(1)        
      BUF(2) = DMIG(2)        
      BUF(3) = 120        
      CALL WRITE (SCRT2,BUF,3,NOEOR)        
      IF (.NOT.BIT) GO TO 850        
      CALL LOCATE (*850,Z(BUF4),DMIAX,FLAG)        
      ASSIGN 800 TO IRETRN        
C        
C     READ 9 WORD HEADER        
C        
  790 GO TO IRETRN(800,860)        
  800 CALL READ (*2340,*850,MATPOL,BUF,9,NOEOR,FLAG)        
C        
C     SAVE NAME        
C        
      Z(INAME  ) = BUF(1)        
      Z(INAME+1) = BUF(2)        
      NNAME = NNAME + 2        
      ICRQ  = NNAME + 2 - ICORE        
      IF (ICRQ .GT. 0) GO TO 2370        
  810 CALL WRITE (SCRT2,BUF,9,NOEOR)        
C        
C     COPY THE COLUMN DATA.  FIRST THE COLUMN INDEX.        
C        
  820 CALL READ (*2340,*2350,MATPOL,BUF,2,NOEOR,FLAG)        
      CALL WRITE (SCRT2,BUF,2,NOEOR)        
      IF (BUF(1)) 790,830,830        
C        
C     TERMS OF COLUMN        
C        
  830 CALL READ (*2340,*2350,MATPOL,BUF,2,NOEOR,FLAG)        
      CALL WRITE (SCRT2,BUF,2,NOEOR)        
      IF (BUF(1)) 820,840,840        
  840 CALL READ (*2340,*2350,MATPOL,BUF,1,NOEOR,FLAG)        
      CALL WRITE (SCRT2,BUF,1,NOEOR)        
      GO TO 830        
C        
C     DMIAX-S ALL COPIED.  NOW COPY ANY DMIG-S.        
C        
  850 IF (.NOT.BIT2) GO TO 890        
      CALL LOCATE (*890,Z(BUF4),DMIG,FLAG)        
      ASSIGN 860 TO IRETRN        
C        
C     READ HEADER        
C        
  860 CALL READ (*2320,*890,MATPOL,BUF,9,NOEOR,FLAG)        
C        
C     CHECK THE NAME FOR BEING THE SAME AS ONE ON A DMIAX CARD        
C        
      DO 880 I = INAME,NNAME,2        
      IF (BUF(1) .NE. Z(I  )) GO TO 880        
      IF (BUF(2) .NE. Z(I+1)) GO TO 880        
C        
C     ERROR FOR NAME DOES MATCH THAT OF A DMIAX NAME        
C        
      NOGO = .TRUE.        
      WRITE  (OUTPUT,870) UFM,BUF(1),BUF(2)        
  870 FORMAT (A23,' 4062, DMIG BULK DATA CARD SPECIFIES DATA BLOCK ',   
     1       2A4,' WHICH ALSO APPEARS ON A DMIAX CARD.')        
  880 CONTINUE        
C        
C     COPY THE COLUMN DATA        
C        
      GO TO 810        
C        
C     WRITE THE END OF RECORD FOR DMIG CARDS        
C        
  890 CALL WRITE (SCRT2,0,0,EOR)        
C        
C     TURN ON BIT FOR DMIG CARD TYPE        
C        
      CALL IFP4G  (DMIG(2),MATPOL)        
      CALL REWIND (MATPOL)        
      CALL FWDREC (*2340,MATPOL)        
C        
C     COPY EVERYTHING ON MATPOL TO SCRT2, EXCEPT FOR DMIG, DMIAX, AND   
C     THE 65535 RECORD.        
C        
  900 CALL READ (*930,*2350,MATPOL,BUF,3,NOEOR,FLAG)        
      IF (BUF(1).NE.65535 .AND.(BUF(1).NE.DMIG(1).OR.BUF(2).NE.DMIG(2)) 
     1   .AND.(BUF(1).NE.DMIAX(1).OR.BUF(2).NE.DMIAX(2))) GO TO 910     
      CALL FWDREC (*2340,MATPOL)        
      GO TO 900        
  910 CALL READ  (*2340,*920,MATPOL,Z(NBDYL+1),CORE-NBDYL,NOEOR,FLAG)   
      CALL WRITE (SCRT2,Z(NBDYL+1),CORE-NBDYL,NOEOR)        
      GO TO 900        
  920 CALL WRITE (SCRT2,Z(NBDYL+1),FLAG,EOR)        
      GO TO 900        
  930 MATEOF = .TRUE.        
      CALL IFP4B (MATPOL,SCRT2,ANY,Z(NBDYL+1),CORE-NBDYL,BNDFL,MATEOF)  
      CARD(1) = 0        
      CARD(2) = 0        
      CARD(3) = 0        
      CARD(4) = N        
      CALL LOCATE (*940,Z(BUF1),FLSYM,FLAG)        
      CALL READ (*2320,*2330,AXIC,CARD,3,EOR,FLAG)        
  940 CONTINUE        
      CALL WRITE (SCRT2,Z(1),5,NOEOR)        
      CALL WRITE (SCRT2,CARD,4,NOEOR)        
      CALL WRITE (SCRT2,Z(II),N,NOEOR)        
C        
C     OUTPUT ENTRIES TO MATPOOL DATA BLOCK.(TEMPORARILY ON SCRT2)       
C        
      JGRIDB = IGRIDB        
      JSAVE  = 0        
      DO 1030 I = IBDYL,NBDYL,7        
C        
C     POSSIBILITY OF 2 FLUID ID-S HAVING SAME VALUE        
C        
      IF (JSAVE .NE. 0) JGRIDB = JSAVE        
      JSAVE = 0        
      IF (Z(I) .EQ. Z(I+7)) JSAVE = JGRIDB        
C        
C     IF RHO FOR A FLUID POINT IS ZERO WE DO NOT PUT OUT FLUID        
C     DATA AND CONNECTED POINTS.        
C        
      IF (RZ(I+6)) 950,960,950        
  950 CALL WRITE (SCRT2,Z(I),7,NOEOR)        
C        
C     APPEND GRIDB POINTS WITH THEIR ANGLES.        
C        
  960 IF (JGRIDB .GT. NGRIDB) GO TO 1010        
      IF (Z(JGRIDB+4) - Z(I)) 970,980,1010        
  970 JGRIDB = JGRIDB + 5        
      GO TO 960        
C        
C     APPEND THE POINT        
C        
  980 IF (RZ(I+6)) 990,1000,990        
  990 CALL WRITE (SCRT2,Z(JGRIDB),2,NOEOR)        
 1000 JGRIDB = JGRIDB + 5        
      GO TO 960        
C        
C     COMPLETE THE ENTRY        
C        
 1010 IF (RZ(I+6)) 1020,1030,1020        
 1020 CALL WRITE (SCRT2,MONES,2,NOEOR)        
 1030 CONTINUE        
C        
C     COMPLETE RECORD.        
C        
      CALL WRITE (SCRT2,0,0,EOR)        
      CALL IFP4B (MATPOL,SCRT2,ANY,Z(NGRIDB+1),CORE-NGRIDB,MONES,MATEOF)
C        
C  READ ALL RINGFL CARD IMAGES INTO CORE        
C        
 1040 IF (ANYGB) GO TO 1060        
      IF (.NOT.ANYGRD) GO TO 1060        
C        
C     COPY GRID CARDS NOT COPIED AS A RESULT OF THE ABSENCE OF GRIDB    
C     CARDS.        
C        
      FILE = GEOM1        
 1050 CALL READ (*2340,*1060,GEOM1,CARD,8,NOEOR,FLAG)        
      CALL WRITE (SCRT1,CARD,8,NOEOR)        
      GO TO 1050        
 1060 IRING = NGRIDB + 1        
      NRING = NGRIDB        
      CALL LOCATE (*1090,Z(BUF1),RINGFL,FLAG)        
      CALL READ (*2320,*1080,AXIC,Z(IRING),CORE-IRING,NOEOR,FLAG)       
      WRITE  (OUTPUT,1070) UFM        
 1070 FORMAT (A23,' 4047, INSUFFICIENT CORE TO HOLD RINGFL IMAGES.')    
      ICRQ = CORE - IRING        
      WRITE (OUTPUT,20) ICRQ        
      GO TO 2310        
 1080 NRING = IRING + FLAG - 1        
C        
C     OUTPUT HARMONIC GRID CARDS.        
C        
 1090 IF (NRING .LT. IRING) GO TO 1150        
C        
C     SORT RINGFL IDS        
C        
      CALL SORT (0,0,4,1,Z(IRING),FLAG)        
      CARD(2)  = 0        
      RCARD(5) = 0.0        
C        
C     CARD(6) = -1 AS A FLAG TO TELL GP1 THIS IS A ONE DEGREE OF        
C     FREEDOM POINT.        
C        
      CARD(6) = -1        
      CARD(7) = 0        
      CARD(8) = 0        
      DO 1140 I = II,NI        
      INDEX = Z(I)*500000        
      DO 1130 K = IRING,NRING,4        
C        
C     CALL IFP4E TO CHECK ID RANGE 1 TO 99999        
C        
      CALL IFP4E (Z(K))        
      IF (K .EQ. IRING) GO TO 1100        
      IF (Z(K) .NE. ZTEMP) GO TO 1100        
      NOGO = .TRUE.        
      WRITE (OUTPUT,420) UFM,Z(K)        
 1100 ZTEMP   = Z(K)        
      CARD(1) = Z(K) + INDEX        
      IF (CORSYS .EQ. 3) GO TO 1110        
      CARD(3) = Z(K+1)        
      CARD(4) = Z(K+3)        
      GO TO 1120        
 1110 ANGLE = RZ(K+2)*DEGRAD        
      RCARD(3) = RZ(K+1)*SIN(ANGLE)        
      RCARD(4) = RZ(K+1)*COS(ANGLE)        
      IF (RCARD(3) .NE. 0.0) GO TO 1120        
      NOGO = .TRUE.        
      WRITE (OUTPUT,350) UFM,Z(K)        
      GO TO 1140        
 1120 CALL WRITE (SCRT1,CARD,8,NOEOR)        
 1130 CONTINUE        
 1140 CONTINUE        
C        
C     COMPLETE GRID CARD RECORD.        
C        
 1150 CALL WRITE (SCRT1,0,0,EOR)        
C        
C     CREATE AND OUTPUT SEQGP CARDS ONTO SCRT1.  COPY GEOM1 TO SCRT1 UP 
C     TO AND INCLUDING SEQGP 3-WORD HEADER.        
C        
      IF (NRING .LT. IRING) GO TO 1210        
      CALL IFP4B (GEOM1,SCRT1,ANY,Z(NRING+1),CORE-NRING,SEQGP,G1EOF)    
C        
C     COPY ALL SEQGP CARDS OVER ALSO (ID-S MUST BE OF CORRECT VALUE).   
C        
      FILE = GEOM1        
      IF (.NOT.ANY) GO TO 1170        
 1160 CALL READ (*2340,*1170,GEOM1,CARD,2,NOEOR,FLAG)        
      CALL IFP4E (CARD(1))        
      CALL WRITE (SCRT1,CARD,2,NOEOR)        
      GO TO 1160        
C        
C     NOW OUTPUT SEQGP CARDS FOR HARMONICS OF EACH RINGFL.        
C        
 1170 DO 1190 I = II,NI        
      INDEX = Z(I)*500000        
      NTEMP = Z(I) - 1        
      DO 1180 K = IRING,NRING,4        
      CARD(1) = Z(K) + INDEX        
      CARD(2) = Z(K)*1000 + NTEMP        
      CALL WRITE (SCRT1,CARD,2,NOEOR)        
 1180 CONTINUE        
 1190 CONTINUE        
 1200 CALL WRITE (SCRT1,0,0,EOR)        
C        
C     COPY BALANCE OF GEOM1 TO SCRT1 (IF ANY MORE, WRAP UP, AND COPY    
C     BACK)        
C        
 1210 CALL IFP4B(GEOM1,SCRT1,ANY,Z(NRING+1),CORE-NRING,MONES,G1EOF)     
C        
C     IF THERE ARE NO HARMONICS THEN ONLY GRID CARDS ARE CREATED FROM   
C     GRIDB CARDS.        
C        
C     IF (.NOT. HARMS) GO TO 2300        
C === IF (.NOT. HARMS) SHOULD NOT GO TO 2300 HERE === G.CHAN/UNISYS 86  
C        
C     END OF GEOM1 PROCESSING        
C        
C     BEGIN GEOM2 PROCESSING        
C     **********************        
C        
C     OPEN GEOM2, AND SCRT1. COPY HEADER FROM GEOM2 TO SCRT1.        
C        
      CALL IFP4C (GEOM2,SCRT1,Z(BUF2),Z(BUF3),G2EOF)        
C        
C     PROCESS CFLUID2, CFLUID3, AND CFLUID4 CARDS.        
C        
      DO 1410 I = 1,3        
      I2 = 2*I        
      CALL LOCATE (*1410,Z(BUF1),CFLUID(I2-1),FLAG)        
C        
C     COPY DATA FROM GEOM2 TO SCRT1 UP TO POINT WHERE CFLUID CARDS GO   
C     AND WRITE 3-WORD RECORD ID.        
C        
      CALL IFP4B (GEOM2,SCRT1,ANY,Z(NI+1),CORE-NI,CFLUID(2*I-1),G2EOF)  
 1300 CALL READ (*2320,*1400,AXIC,CARD,I+4,NOEOR,FLAG)        
      IF (CARD(I+3) .NE. 1) GO TO 1330        
      IF (IDRHO     .NE. 1) GO TO 1320        
      NOGO = .TRUE.        
      WRITE  (OUTPUT,1310) UFM,CARD(1)        
 1310 FORMAT (A23,' 4058, THE FLUID DENSITY HAS NOT BEEN SPECIFIED ON ',
     1       'A CFLUID CARD WITH ID =',I10, /5X,        
     2       'AND THERE IS NO DEFAULT ON THE AXIF CARD.')        
 1320 RCARD(I+3) = DRHO        
 1330 IF (CARD(I+4) .NE. 1) GO TO 1360        
      IF (IBD .NE. 1) GO TO 1350        
      NOGO = .TRUE.        
      WRITE  (OUTPUT,1340) UFM,CARD(1)        
 1340 FORMAT (A23,' 4059, THE FLUID BULK MODULUS HAS NOT BEEN SPECIFIED'
     1,      ' ON A CFLUID CARD WITH ID =',I10, /5X,'AND THERE IS NO ', 
     2       'DEFAULT ON THE AXIF CARD.')        
 1350 RCARD(I+4) = BD        
C        
C     OUTPUT N IMAGES.        
C        
 1360 NTEMP = I+2        
      DO 1370 K = 1,NTEMP        
 1370 SAVEID(K) = CARD(K)        
C        
      DO 1390 K = II,NI        
      CARD(1) = SAVEID(1)*1000 + Z(K)        
      INDEX   = 500000*Z(K)        
      DO 1380 L = 2,NTEMP        
      CARD(L) = SAVEID(L) + INDEX        
 1380 CONTINUE        
      CARD(NTEMP+3) = (Z(K)-1)/2        
      CALL WRITE (SCRT1,CARD,NTEMP+3,NOEOR)        
 1390 CONTINUE        
      GO TO 1300        
C        
C     END OF CFLUID DATA        
C        
 1400 CALL WRITE (SCRT1,0,0,EOR)        
 1410 CONTINUE        
C        
C     CONSTRUCTION OF FSLIST TABLE IN CORE 3-WORDS/ENTRY        
C        
      IFSLST = NI + 1        
      NFSLST = NI        
      CALL LOCATE (*1600,Z(BUF1),FSLST,FLAG)        
 1420 CALL READ (*2320,*1490,AXIC,RHOB,1,NOEOR,FLAG)        
      IF (IRHOB .NE. 1) GO TO 1450        
      IF (IDRHO .NE. 1) GO TO 1440        
      NOGO = .TRUE.        
      WRITE  (OUTPUT,1430) UFM        
 1430 FORMAT (A23,' 4048, THE FLUID DENSITY HAS NOT BEEN SPECIFIED ON ',
     1       'AN FSLIST CARD AND', /5X,'THERE IS NO DEFAULT FLUID ',    
     2       'DENSITY SPECIFIED ON THE AXIF CARD.')        
      RHOB = 1.0        
      GO TO 1450        
 1440 RHOB = DRHO        
 1450 CALL READ (*2320,*2330,AXIC,IDF,1,NOEOR,FLAG)        
      IF (IDF .EQ. 0) IDF = -1        
 1460 CALL READ (*2320,*2330,AXIC,IDFAFT,1,NOEOR,FLAG)        
      IF (IDFAFT .EQ. -1) IDFAFT = -2        
      IF (IDFAFT .EQ.  0) IDFAFT = -1        
      IF (NFSLST+3 .LE. CORE) GO TO 1480        
      WRITE  (OUTPUT,1470) UFM        
 1470 FORMAT (A23,' 4049, INSUFFICIENT CORE TO BUILD FREE SURFACE ',    
     1       'LIST TABLE.')        
      ICRQ = NFSLST + 3 - CORE        
      WRITE (OUTPUT,20) ICRQ        
      GO TO 2310        
 1480 Z(NFSLST+1) = IDF        
      Z(NFSLST+2) = IDFAFT        
      RZ(NFSLST+3)= RHOB        
      NFSLST = NFSLST + 3        
      IF (IDFAFT .EQ. -2) GO TO 1420        
      IDF = IDFAFT        
      GO TO 1460        
C        
C     TABLE IS COMPLETE. COPY GEOM2 DATA TO SCRT1 UP TO CFSMASS RECORD  
C     SLOT        
C        
 1490 IF (NFSLST .GT. IFSLST) GO TO 1510        
      NOGO = .TRUE.        
      WRITE  (OUTPUT,1500) UFM        
 1500 FORMAT (A23,' 4050, FSLIST CARD HAS INSUFFICIENT IDF DATA, OR ',  
     1       'FSLIST DATA MISSING.')        
      GO TO 1600        
 1510 CALL IFP4B(GEOM2,SCRT1,ANY,Z(NFSLST+1),CORE-NFSLST,CFSMAS,G2EOF)  
      ENTRYS =(NFSLST-IFSLST+1)/3        
      K = 0        
      DO 1530 I = IFSLST,NFSLST,3        
      IF (Z(I+1) .EQ. -2) GO TO 1530        
      K = K + 1000000        
      RCARD(4) = RZ(I+2)*G        
      DO 1520 L = II,NI        
      INDEX = 500000*Z(L)        
      CARD(1) = K + Z(L)        
      CARD(2) = Z(I) + INDEX        
      IF (Z(I) .LE. 0) CARD(2) = Z(I+1) + INDEX        
      CARD(3) = Z(I+1) + INDEX        
      IF (Z(I+1) .LE. 0) CARD(3) = Z(I) + INDEX        
      CARD(5) = (Z(L)-1)/2        
      CALL WRITE (SCRT1,CARD,5,NOEOR)        
 1520 CONTINUE        
 1530 CONTINUE        
      CALL WRITE (SCRT1,0,0,EOR)        
C        
C     BEGIN GEOM4 PROCESSING        
C     **********************        
C        
C     OPEN GEOM4 AND SCRT2 AND COPY HEADER RECORD FROM GEOM4 TO SCRT2.  
C        
 1600 CALL IFP4C (GEOM4,SCRT2,Z(BUF4),Z(BUF5),G4EOF)        
C        
C     COPY ALL DATA ON GEOM4 TO SCRT2 UP TO AND INCLUDING 3-WORD RECORD 
C     HEADER OF MPC-RECORD.        
C        
      CALL IFP4B (GEOM4,SCRT2,ANY,Z(NFSLST+1),CORE-NFSLST,MPC,G4EOF)    
C        
C     COPY ANY MPC IMAGES HAVING A SET ID .LT. 103 TO SCRT2. ERROR      
C     MESSAGE IF ANY HAVE ID = 102.  MAINTAIN A LIST OF SETID-S LESS    
C     THAN 102.        
C        
      IMPC = NFSLST + 1        
      NMPC = NFSLST        
      IDLAST = 0        
      FILE = GEOM4        
      SET 102 = .FALSE.        
      IF (.NOT.ANY) GO TO 1650        
C        
C     PICK UP SET ID        
C        
 1610 CALL READ (*2340,*1650,GEOM4,ID,1,NOEOR,FLAG)        
      IF (ID .GT. 102) GO TO 1660        
      IF (ID .NE. 102) GO TO 1630        
      NOGO = .TRUE.        
      WRITE  (OUTPUT,1620) UFM        
 1620 FORMAT (A23,' 4051, AN MPC CARD HAS A SET ID SPECIFIED = 102. ',  
     1       ' SET 102 IS ILLEGAL WHEN FLUID DATA IS PRESENT.')        
 1630 CALL WRITE (SCRT2,ID,1,NOEOR)        
C        
C     ADD ID TO LIST IF NOT IN LIST        
C        
      IF (ID .EQ. IDLAST) GO TO 1640        
      NMPC = NMPC + 1        
      Z(NMPC) = ID        
C        
C     3 WORD GROUPS        
C        
 1640 CALL READ (*2340,*2350,GEOM4,CARD,3,NOEOR,FLAG)        
      CALL WRITE (SCRT2,CARD,3,NOEOR)        
      IF (CARD(1) .EQ. -1) GO TO 1610        
      GO TO 1640        
C        
C     NOW POSITIONED TO OUTPUT MPC CARDS FOR SET 102        
C        
 1650 ID = 0        
C        
C     IF G FROM AXIF CARD IS NON-ZERO FREEPT DATA IS NOW PROCESSED.     
C        
 1660 ISPNT = NMPC + 1        
      NSPNT = NMPC        
      PRESS = .FALSE.        
      IF (G .EQ. 0.0) GO TO 1780        
C        
C     IF THERE IS NO FREE SURFACE LIST, FREEPT CARDS ARE NOT USED.      
C        
      IF (NFSLST .LT. IFSLST) GO TO 1780        
      CALL SORT (0,0,3,1,Z(IFSLST),NFSLST-IFSLST+1)        
      CALL LOCATE (*1780,Z(BUF1),FREEPT,FLAG)        
C        
C     PICK UP A 3-WORD FREEPT OR PRESPT IMAGE (IDF,IDP,PHI)        
C        
 1670 CALL READ (*2320,*1770,AXIC,CARD,3,NOEOR,FLAG)        
C        
C     START MPC CARD        
C        
      ANGLE = RCARD(3)*DEGRAD        
      IDF   = CARD(1)        
      CARD(1) = 102        
      CARD(3) = 0        
      IF (PRESS) GO TO 1700        
C        
C     LOOK UP RHOB IN FSLIST TABLE        
C        
      CALL BISLOC (*1680,IDF,Z(IFSLST),3,ENTRYS,POINT)        
      NTEMP = IFSLST + POINT + 1        
      RCARD(4) = -ABS(RZ(NTEMP)*G)        
      GO TO 1710        
 1680 NOGO = .TRUE.        
      WRITE  (OUTPUT,1690) UFM,IDF        
 1690 FORMAT (A23,' 4052, IDF =',I10,' ON A FREEPT CARD DOES NOT ',     
     1       'APPEAR ON ANY FSLIST CARD.')        
      GO TO 1710        
 1700 RCARD(4) = -1.0        
 1710 CALL WRITE (SCRT2,CARD,4,NOEOR)        
      SET102 = .TRUE.        
C        
C     ADD SPOINT TO CORE LIST        
C        
      IF (NSPNT+1 .LE. CORE) GO TO 1730        
      WRITE  (OUTPUT,1720) UFM        
 1720 FORMAT (A23,' 4053, INSUFFICIENT CORE TO PERFORM OPERATIONS ',    
     1       'REQUIRED AS A RESULT OF FREEPT OR PRESPT DATA CARDS')     
      ICRQ = NSPNT + 1 - CORE        
      WRITE (OUTPUT,20) ICRQ        
      GO TO 2310        
 1730 NSPNT = NSPNT + 1        
      Z(NSPNT) = CARD(2)        
      CARD(2)  = 0        
C        
C     HARMONIC COEFFICIENT DATA        
C        
      DO 1760 I = II,NI        
      CARD(1) = 500000*Z(I) + IDF        
      NN = (Z(I)-1)/2        
      IF (MOD(Z(I),2) .EQ. 0) GO TO 1740        
      RCARD(3) = SIN(FLOAT(NN)*ANGLE)        
      GO TO 1750        
 1740 RCARD(3) = COS(FLOAT(NN)*ANGLE)        
 1750 CALL WRITE (SCRT2,CARD,3,NOEOR)        
 1760 CONTINUE        
      CALL WRITE (SCRT2,MONES,3,NOEOR)        
      GO TO 1670        
C        
C     CREATE MPC CARDS AND SPOINTS AS A RESULT OF PRESPT DATA.        
C        
 1770 IF (PRESS) GO TO 1790        
 1780 CALL LOCATE (*1790,Z(BUF1),PRESPT,FLAG)        
      PRESS = .TRUE.        
      GO TO 1670        
C        
C     ANY SPOINTS IN CORE ARE AT THIS TIME OUTPUT TO GEOM2.        
C        
 1790 IF (NSPNT .LT. ISPNT) GO TO 1830        
C        
C     COPY DATA FROM GEOM2 TO SCRT1 UP TO AND INCLUDING THE 3-WORD      
C     RECORD HEADER FOR SPOINTS        
C        
      FILE = GEOM2        
      CALL IFP4B (GEOM2,SCRT1,ANY,Z(NSPNT+1),CORE-NSPNT,SPOINT,G2EOF)   
      IF (.NOT.ANY) GO TO 1820        
 1800 CALL READ (*2340,*1810,GEOM2,Z(NSPNT+1),CORE-NSPNT,NOEOR,FLAG)    
      CALL WRITE (SCRT1,Z(NSPNT+1),CORE-NSPNT,NOEOR)        
      GO TO 1800        
 1810 CALL WRITE (SCRT1,Z(NSPNT+1),FLAG,NOEOR)        
 1820 CALL WRITE (SCRT1,Z(ISPNT),NSPNT-ISPNT+1,EOR)        
C        
C     COPY BALANCE OF GEOM2 TO SCRT1,CLOSE THEM, AND SWITCH DESIGNATIONS
C        
 1830 CALL IFP4B (GEOM2,SCRT1,ANY,Z(NMPC+1),CORE-NMPC,-1,G2EOF)        
C        
C     END OF GEOM2 PROCESSING        
C     ***********************        
C        
C     COPY BALANCE OF MPC IMAGES ON GEOM4 TO SCRT2, COMPLETE LIST OF MPC
C     SETS.        
C        
      FILE = GEOM4        
      IF (ID .EQ. 0) GO TO 1930        
      GO TO 1910        
C        
C     3-WORD GROUPS        
C        
 1900 CALL READ (*2340,*2350,GEOM4,CARD,3,NOEOR,FLAG)        
      CALL WRITE (SCRT2,CARD,3,NOEOR)        
      IF (CARD(1) .NE. -1) GO TO 1900        
      CALL READ (*2340,*1930,GEOM4,ID,1,NOEOR,FLAG)        
 1910 IF (ID .EQ. IDLAST) GO TO 1920        
C        
C     ADD ID TO LIST        
C        
      IDLAST = ID        
      NMPC   = NMPC + 1        
      Z(NMPC)= ID        
 1920 CALL WRITE (SCRT2,ID,1,NOEOR)        
      GO TO 1900        
 1930 CALL WRITE (SCRT2,0,0,EOR)        
      TYPE(1) = MPCADD(1)        
      TYPE(2) = MPCADD(2)        
C        
C     GENERATION OF MPCADD OR SPCADD CARDS FROM USER ID-S.  FIRST       
C     OUTPUT MANDATORY MPCADD OR SPCADD.        
C        
 1940 CALL IFP4F (TYPE(2),GEOM4,BIT)        
      IF (.NOT.SET102 .AND. NMPC.LT.IMPC .AND. .NOT.BIT) GO TO 2020     
      CALL IFP4B (GEOM4,SCRT2,ANY,Z(NMPC+1),CORE-NMPC,TYPE,G4EOF)       
      IF (.NOT. SET102) GO TO 1950        
      CARD(1) = 200000000        
      CARD(2) = 102        
      CARD(3) = -1        
      CALL WRITE (SCRT2,CARD,3,NOEOR)        
C        
C     NOW FROM USER ID-S        
C        
 1950 IF (NMPC .LT. IMPC) GO TO 1980        
      DO 1970 I = IMPC,NMPC        
      CARD(1) = Z(I) + 200000000        
      CARD(2) = Z(I)        
      NN = 3        
      IF (.NOT.SET102) GO TO 1960        
      CARD(3) = 102        
      NN = 4        
 1960 CARD(NN) = -1        
      CALL WRITE (SCRT2,CARD,NN,NOEOR)        
 1970 CONTINUE        
C        
C     IF USER MPCADD OR SPCADD CARDS ARE PRESENT, NOW CHANGE THEIR ID-S 
C     AND ADD THE 102 SET IF IT EXISTS.        
C        
 1980 IF (.NOT.ANY) GO TO 2010        
 1990 CALL READ (*2340,*2010,GEOM4,ID,1,NOEOR,FLAG)        
      ID = ID + 200000000        
      CALL WRITE (SCRT2,ID,1,NOEOR)        
      IF (SET102) CALL WRITE (SCRT2,102,1,NOEOR)        
 2000 CALL READ  (*2340,*2350,GEOM4,ID,1,NOEOR,FLAG)        
      CALL WRITE (SCRT2,ID,1,NOEOR)        
      IF (ID .EQ. -1) GO TO 1990        
      GO TO 2000        
C        
 2010 CALL WRITE (SCRT2,0,0,EOR)        
 2020 IF (TYPE(1) .EQ. SPCADD(1)) GO TO 2270        
C        
C     START LIST OF SPC AND SPC1 ID-S        
C        
      ISPC = NFSLST + 1        
      NSPC = NFSLST        
      SET102 = .FALSE.        
      IDLAST = 0        
C        
C     CHECK BIT FOR SPC CARDS        
C        
      CALL IFP4F (SPC(2),GEOM4,BIT)        
      IF (.NOT.BIT) GO TO 2080        
C        
C     COPY GEOM4 TO SCRT2 UP TO SPC CARDS        
C        
      CALL IFP4B (GEOM4,SCRT2,ANY,Z(ISPC),CORE-ISPC,SPC,G4EOF)        
C        
C     COPY SPC IMAGES KEEPING LIST OF ID-S.        
C        
 2030 CALL READ (*2340,*2070,GEOM4,ID,1,NOEOR,FLAG)        
      IF (ID .EQ. IDLAST) GO TO 2060        
      IF (ID .NE.    102) GO TO 2050        
      NOGO = .TRUE.        
      WRITE  (OUTPUT,2040) UFM        
 2040 FORMAT (A23,' 4055, SET ID = 102 MAY NOT BE USED FOR SPC CARDS ', 
     1       'WHEN USING THE HYDROELASTIC-FLUID ELEMENTS.')        
      GO TO 2060        
 2050 NSPC = NSPC + 1        
      Z(NSPC) = ID        
      IDLAST  = ID        
 2060 CALL WRITE (SCRT2,ID,1,NOEOR)        
      CALL READ  (*2340,*2350,GEOM4,CARD,3,NOEOR,FLAG)        
      CALL WRITE (SCRT2,CARD,3,NOEOR)        
      GO TO 2030        
 2070 CALL WRITE (SCRT2,0,0,EOR)        
C        
C     CHECK FOR ANY SPC1 IMAGES        
C        
 2080 CALL IFP4F (SPC1(2),GEOM4,BIT)        
      IF (.NOT.BIT .AND. G.NE.0.0) GO TO 2260        
C        
C     COPY FROM GEOM4 TO SCRT2 UP TO SPC1 DATA.        
C        
      CALL IFP4B(GEOM4,SCRT2,ANY,Z(NSPC+1),CORE-NSPC-2,SPC1,G4EOF)      
C        
C     COPY SPC1-S UP TO SETID .GE. 103.  SET 102 IS ILLEGAL FOR USER.   
C        
      IF (.NOT.BIT) GO TO 2150        
 2090 CALL READ (*2340,*2150,GEOM4,ID,1,NOEOR,FLAG)        
      IF (ID. LT. 102) GO TO 2100        
      IF (ID .NE. 102) GO TO 2160        
      NOGO = .TRUE.        
      WRITE (OUTPUT,2040) UFM        
C        
C     ADD ID TO LIST IF NOT YET IN LIST        
C        
 2100 IF (NSPC .LT. ISPC) GO TO 2120        
      DO 2110 I = ISPC,NSPC        
      IF (ID .EQ. Z(I)) GO TO 2130        
 2110 CONTINUE        
C        
C     ADD ID TO LIST        
C        
 2120 NSPC = NSPC + 1        
      Z(NSPC) = ID        
 2130 CALL WRITE (SCRT2,ID,1,NOEOR)        
      CALL READ  (*2340,*2350,GEOM4,ID,1,NOEOR,FLAG)        
      CALL WRITE (SCRT2,ID,1,NOEOR)        
 2140 CALL READ  (*2340,*2350,GEOM4,ID,1,NOEOR,FLAG)        
      CALL WRITE (SCRT2,ID,1,NOEOR)        
      IF (ID .EQ. -1) GO TO 2090        
      GO TO 2140        
C        
C     IF G IS ZERO AND THERE ARE FSLST ENTRIES, GENERATE SPC1-S NOW.    
C        
 2150 ID = 0        
 2160 IF (G.NE.0.0 .OR. NFSLST.LT.IFSLST) GO TO 2190        
C        
C     GENERATION OF HARMONIC SPC1-S        
C        
      DO 2180 I = IFSLST,NFSLST,3        
      IF (Z(I) .EQ. -1) GO TO 2180        
      CARD(1) = 102        
      CARD(2) = 0        
      CALL WRITE (SCRT2,CARD,2,NOEOR)        
      DO 2170 J = II,NI        
      CALL WRITE (SCRT2,Z(I)+500000*Z(J),1,NOEOR)        
 2170 CONTINUE        
      CALL WRITE (SCRT2,MINUS1,1,NOEOR)        
 2180 CONTINUE        
      SET102 = .TRUE.        
C        
C     COMPLETE COPYING OF SPC1 CARDS TO SCRT2 WITH SETID-S .GE. 103     
C        
 2190 IF (ID .EQ. 0) GO TO 2250        
C        
C     ADD ID TO LIST IF NOT YET IN        
C        
      IF (NSPC .LT. ISPC) GO TO 2220        
 2200 DO 2210 I = ISPC,NSPC        
      IF (ID .EQ. Z(I)) GO TO 2230        
 2210 CONTINUE        
C        
C     ID NOT IN LIST, THUS ADD IT.        
C        
 2220 NSPC = NSPC + 1        
      Z(NSPC) = ID        
C        
C     CONTINUE COPYING DATA TO NEXT ID        
C        
 2230 CALL WRITE (SCRT2,ID,1,NOEOR)        
 2240 CALL READ  (*2340,*2350,GEOM4,ID,1,NOEOR,FLAG)        
      CALL WRITE (SCRT2,ID,1,NOEOR)        
      IF (ID .NE. -1) GO TO 2240        
      CALL READ  (*2340,*2250,GEOM4,ID,1,NOEOR,FLAG)        
      GO TO 2200        
C        
C     END OF SPC1 CARD IMAGES.        
C        
 2250 CALL WRITE (SCRT2,0,0,EOR)        
C        
C     SORT LIST OF SPC AND SPC1 ID-S        
C        
      CALL SORT (0,0,1,1,Z(ISPC),NSPC-ISPC+1)        
C        
C     SPCADD WORK (USE MPCADD LOGIC)        
C        
 2260 TYPE(1) = SPCADD(1)        
      TYPE(2) = SPCADD(2)        
      IMPC = ISPC        
      NMPC = NSPC        
      GO TO 1940        
C        
C     ALL PROCESSING COMPLETE ON GEOM4        
C        
 2270 CALL IFP4B (GEOM4,SCRT2,ANY,Z(1),CORE,MONES,G4EOF)        
C        
C     END OF GEOM4 PROCESSING        
C     ***********************        
C        
C     AXIC FILE NOT IN FIST OR AXIF CARD IS MISSING, THUS DO NOTHING.   
C        
 2300 CALL CLOSE  (AXIC,CLSREW)        
      CALL CONMSG (MSG2,2,0)        
      RETURN        
C        
C     FATAL ERROR NO MORE PROCESSING POSSIBLE        
C        
 2310 NOGO = .TRUE.        
      GO TO 2300        
C        
C     END OF FILE ON AXIC        
C        
 2320 FILE = AXIC        
      GO TO 2340        
C        
C     END OF RECORD ON AXIC        
C        
 2330 FILE = AXIC        
      GO TO 2350        
C        
C     END OF FILE OR END OF RECORD ON -FILE-, OR FILE NOT IN FIST.      
C        
 2340 IER = -2        
      GO TO 2390        
 2350 IER = -3        
      GO TO 2390        
 2360 IER = -1        
      GO TO 2390        
 2370 IER = -8        
      FILE = ICRQ        
      GO TO 2390        
 2380 IER = -37        
 2390 CALL MESAGE (IER,FILE,SUBR)        
      RETURN        
      END        
C        
C     THIS ROUTINE WAS RENUMBERED BY G.CHAN/UNISYS   8/92        
C        
C                    TABLE OF OLD vs. NEW STATEMENT NUMBERS        
C        
C     OLD NO.    NEW NO.      OLD NO.    NEW NO.      OLD NO.    NEW NO.
C    --------------------    --------------------    -------------------
C         90         10         1460        750         3935       1610 
C         91         20         1470        760         3940       1620 
C        100         30         1500        770         3950       1630 
C        205         40         1501        780         3960       1640 
C        208         50         1520        790         3970       1650 
C        210         60         1521        800         3971       1660 
C        220         70         1525        810         3972       1670 
C        240        100         1530        820         3974       1680 
C        241        110         1540        830         3973       1690 
C        243        120         1542        840         3976       1700 
C        250        130         1550        850         3977       1710 
C        300        140         1551        860         3975       1720 
C        310        150         1553        870         3980       1730 
C        320        160         1552        880         3990       1740 
C        500        170         1580        890         3995       1750 
C        520        180         1590        900         4100       1760 
C        530        190         1591        910         4999       1770 
C        550        200         1610        920         5000       1780 
C        600        210         1611        930         5900       1790 
C        560        220         1600        940         6150       1800 
C        562        230         1670        950         6200       1810 
C        563        240         1690        960         6300       1820 
C        564        250         1700        970         7000       1830 
C        565        260         1710        980         6000       1900 
C        570        270         1720        990         6005       1910 
C        590        280         1730       1000         6010       1920 
C        610        290         1790       1010         6100       1930 
C        612        300         1791       1020         7050       1940 
C        615        310         1800       1030         7100       1950 
C        620        320         1810       1040         7150       1960 
C        650        330         1812       1050         7200       1970 
C        670        340         1814       1060         7500       1980 
C        674        350         1815       1070         7550       1990 
C        675        360         1820       1080         7570       2000 
C        621        370         1830       1090         7800       2010 
C       1020        380         1900       1100         8000       2020 
C        624        390         1940       1110         8010       2030 
C       1120        400         1945       1120         8013       2040 
C        625        410         1950       1130         8015       2050 
C        730        420         2000       1140         8020       2060 
C        740        430         2010       1150         8030       2070 
C        741        440         2040       1160         8035       2080 
C        742        450         2060       1170         8040       2090 
C        743        460         2080       1180         8200       2100 
C        744        470         2090       1190         8210       2110 
C        748        480         2091       1200         8230       2120 
C        750        490         2092       1210         8239       2130 
C        760        500         2150       1300         8240       2140 
C        790        510         2157       1310         8245       2150 
C        805        520         2152       1320         8250       2160 
C        810        530         2153       1330         8270       2170 
C        820        540         2156       1340         8280       2180 
C        850        550         2155       1350         8300       2190 
C        855        560         2154       1360         8305       2200 
C        856        570         2200       1370         8310       2210 
C        860        580         2300       1380         8330       2220 
C        880        590         2400       1390         8340       2230 
C        900        600         2800       1400         8335       2240 
C        910        610         3000       1410         8380       2250 
C        970        620         3560       1420         8400       2260 
C       1150        630         3562       1430         8500       2270 
C       1200        640         3563       1440        10000       2300 
C       1210        650         3564       1450        15000       2310 
C       1220        660         3566       1460        10001       2320 
C       1230        670         3580       1470        10002       2330 
C       1300        680         3600       1480        10003       2340 
C       1310        690         3700       1490        10004       2350 
C       1320        700         3701       1500        10005       2360 
C       1330        710         3710       1510        10008       2370 
C       1400        720         3800       1520        10037       2380 
C       1410        730         3900       1530        11000       2390 
C       1450        740         3925       1600        
