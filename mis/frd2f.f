      SUBROUTINE FRD2F (MHH,BHH,KHH,FRL,FRQSET,NLOAD,NFREQ,PH,UHV)      
C        
C     ROUTINE  SOLVES DIRECTLY FOR UNCOUPLED MODAL FORMULATION        
C        
      INTEGER BHH,FRL,FRQSET,PH,UHV,SYSBUF,FILE,MCB(7)        
      INTEGER NAME(2)        
C        
      COMMON /SYSTEM/ SYSBUF        
      COMMON /ZBLPKX/ B(4),JJ        
      COMMON /ZNTPKX/A(4),II,IEOL,IEOR        
CZZ   COMMON  /ZZFRF1/ CORE(1)        
      COMMON  /ZZZZZZ/ CORE(1)        
C        
      DATA NAME /4HFRD2,4HF   /        
C        
C ----------------------------------------------------------------------
C        
      IBUF1 = KORSZ(CORE) -SYSBUF +1        
C        
C     PICK UP FREQUENCY LIST        
C        
      CALL GOPEN(FRL,CORE(IBUF1),0)        
      CALL SKPREC(FRL,FRQSET-1)        
      IF(IBUF1-1 .LT. NFREQ) GO TO 170        
      CALL FREAD(FRL,CORE,NFREQ,1)        
      CALL CLOSE( FRL, 1 )        
C        
C     BRING IN  MODAL MATRICES        
C        
      IMHH = NFREQ        
      MCB(1) = MHH        
      CALL RDTRL(MCB)        
      LHSET =MCB(2)        
      IF(IBUF1-1 .LT. NFREQ+3*LHSET) GO TO 170        
      IBHH = IMHH+LHSET        
      IKHH = IBHH+LHSET        
C        
C     BRING IN MHH        
C        
      MATNAM = MHH        
      ASSIGN 30 TO IRET        
      IPNT  = IMHH        
      GO TO 110        
C        
C     BRING  IN  BHH        
C        
   30 MATNAM = BHH        
      ASSIGN 40 TO IRET        
      IPNT  = IBHH        
      GO TO 110        
C        
C     BRING IN KHH        
C        
   40 MATNAM =  KHH        
      ASSIGN 50 TO IRET        
      IPNT = IKHH        
      GO TO 110        
C        
C     READY LOADS        
C        
   50 CALL GOPEN(PH,CORE(IBUF1),0)        
C        
C     READY SOLUTIONS        
C        
      IBUF2 = IBUF1-SYSBUF        
      CALL GOPEN(UHV,CORE(IBUF2),1)        
      CALL MAKMCB(MCB,UHV,LHSET,2,3)        
C        
C     COMPUTE  SOLUTIONS        
C        
      DO 100 I=1,NLOAD        
      DO 90 J=1,NFREQ        
C        
C     PICK  UP  FREQ        
C        
      W = CORE(J)        
      W2 = -W*W        
      CALL BLDPK(3,3,UHV,0,0)        
      CALL INTPK(*80,PH,0,3,0)        
   60 IF( IEOL)  80,70,80        
   70 CALL ZNTPKI        
C        
C     COMPUTE  REAL AND COMPLEX PARTS OF DENOMINATOR        
C        
      IK = IKHH +II        
      IB = IBHH +II        
      IM = IMHH +II        
      RDEM = W2*CORE(IM) + CORE(IK)        
      CDEM = CORE(IB)* W        
      DEM = RDEM*RDEM+CDEM*CDEM        
      IF(DEM .NE. 0.0) GO TO 71        
      CALL MESAGE(5,J,NAME)        
      B(1) = 0.0        
      B(2) = 0.0        
      GO TO 72        
   71 CONTINUE        
C        
C     COMPUTE REAL AND COMPLEX PHI-S        
C        
      B(1) = (A(1)*RDEM+A(2)*CDEM)/DEM        
      B(2) = (A(2)*RDEM-A(1)*CDEM)/DEM        
   72 JJ = II        
      CALL  ZBLPKI        
      GO TO 60        
C        
C     END  COLUMN        
C        
   80 CALL BLDPKN(UHV,0,MCB)        
   90 CONTINUE        
  100 CONTINUE        
      CALL CLOSE(UHV,1)        
      CALL CLOSE(PH,1)        
      CALL WRTTRL(MCB)        
      RETURN        
C        
C     INTERNAL SUBROUTINE TO BRING IN  H MATRICES        
C        
  110 FILE =MATNAM        
      CALL OPEN(*132,MATNAM,CORE(IBUF1),0)        
      CALL SKPREC(MATNAM,1)        
      DO 130 I=1,LHSET        
      IPNT =IPNT +1        
      CALL INTPK(*120,MATNAM,0,1,0)        
      CALL ZNTPKI        
      IF( II .NE. I  .OR. IEOL .NE. 1) GO TO 180        
      CORE(IPNT) = A(1)        
      GO TO 130        
C        
C     NULL COLUMN        
C        
  120 CORE(IPNT) = 0.0        
  130 CONTINUE        
      CALL CLOSE(MATNAM,1)        
  131 GO TO IRET,(30,40,50)        
C        
C      ZERO CORE FOR PURGED MATRIX        
C        
  132 DO 133 I = 1 , LHSET        
      IPNT = IPNT+1        
      CORE(IPNT) = 0.0        
  133 CONTINUE        
      GO TO 131        
C        
C     ERROR MESAGES        
C        
  150 CALL MESAGE(IP1,FILE,NAME)        
  170 IP1 = -8        
      GO TO 150        
  180 IP1 = -7        
      GO TO 150        
      END        