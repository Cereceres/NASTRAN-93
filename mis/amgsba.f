      SUBROUTINE AMGSBA(AJJL,A0,AR,NSBE,A,YB,ZB)        
C        
C     BUILD AJJL FOR DOUBLET LATTICE WITH BODIES        
C        
      INTEGER SYSBUF,ECORE,AJJL,NAME(2),SCR1,SCR2,SCR5        
      DIMENSION A(1),A0(1),AR(1),NSBE(1)        
      DIMENSION YB(1),ZB(1)        
      COMMON /DLBDY/ NJ1,NK1,NP,NB,NTP,NBZ,NBY,NTZ,NTY,NT0,NTZS,NTYS,   
     *   INC,INS,INB,INAS,IZIN,IYIN,INBEA1,INBEA2,INSBEA,IZB,IYB,       
     *   IAVR,IARB,INFL,IXLE,IXTE,INT121,INT122,IZS,IYS,ICS,IEE,ISG,    
     *   ICG,IXIJ,IX,IDELX,IXIC,IXLAM,IA0,IXIS1,IXIS2,IA0P,IRIA        
     *  ,INASB,IFLA1,IFLA2,ITH1A,ITH2A,        
     *   ECORE,NEXT,SCR1,SCR2,SCR3,SCR4,SCR5        
      COMMON /AMGMN / MCB(7),NROW,ND,NE,REFC,FMACH,RFK,TSKJ(7),ISK,NSK  
      COMMON /SYSTEM/ SYSBUF        
CZZ   COMMON /ZZDAMB / Z(1)        
      COMMON /ZZZZZZ / Z(1)        
      COMMON /PACKX/ ITI,ITO,II,NN,INCR        
      COMMON /CONDAS/ PI,TWOPI        
      DATA NAME /4HAMGS,4HBA  /        
      II = NROW +1        
      NN = NROW + NJ1        
      IF(NEXT+2*NJ1.GT.ECORE) CALL MESAGE(-8,0,NAME)        
      INCR = 1        
      ITI = 3        
      ITO = 3        
      IF(NT0.EQ.0) GO TO 100        
      NBUF = 1        
      IF(NTZS.NE.0) NBUF = NBUF +1        
      IF(NTYS.NE.0) NBUF = NBUF +1        
      IBUF1 = ECORE - NBUF*SYSBUF        
      IBUF2 = IBUF1        
      IF(NTZS.NE.0) IBUF2 = IBUF1+SYSBUF        
      IBUF3 = IBUF2        
      IF(NTYS.NE.0) IBUF3 = IBUF2+SYSBUF        
      NS5 = NT0*2        
      NS1 = NTZS*2        
      NS2 = NTYS*2        
      NTOT = NS5+NS1+NS2        
      IF(NEXT+NTOT.GT.IBUF3) CALL MESAGE(-8,0,NAME)        
C        
C     BUILD PANEL AND BODY PART OF AJJL        
C        
      CALL GOPEN(SCR5,Z(IBUF1),0)        
      IF(NTZS.NE.0) CALL GOPEN(SCR1,Z(IBUF2),0)        
      IF(NTYS.NE.0) CALL GOPEN(SCR2,Z(IBUF3),0)        
      DO 50 I=1,NT0        
      CALL FREAD(SCR5,A,NS5,0)        
      IF(NTZS.NE.0) CALL FREAD(SCR1,A(NS5+1),NS1,0)        
      IF(NTYS.NE.0) CALL FREAD(SCR2,A(NS5+NS1+1),NS2,0)        
      CALL PACK(A,AJJL,MCB)        
   50 CONTINUE        
      CALL CLOSE(SCR5,1)        
      CALL CLOSE(SCR1,1)        
      CALL CLOSE(SCR2,1)        
  100 CALL ZEROC(A,2*NJ1)        
C        
C     ADD DIAGIONAL TERMS OF AJJL FOR SLENDER BODIES        
C        
      IF(NTZS.EQ.0.AND.NTYS.EQ.0) GO TO 1000        
      I = NT0*2+1        
      DEN=TWOPI*2.0        
      IF(NTZS.EQ.0) GO TO 200        
      NFSBEB = 1        
      NLSBEB = 0        
      DO 150 IB = 1,NBZ        
      NLSBEB = NLSBEB + NSBE(IB)        
      DO 140 IT = NFSBEB,NLSBEB        
      A(I) = 1.0 / (DEN*A0(IT)**2)        
      IF(ABS(YB(IB)).LT..00001) A(I) = (1.0+FLOAT(ND))*A(I)        
      IF(ABS(ZB(IB)).LT..00001) A(I) = (1.0+FLOAT(NE))*A(I)        
      CALL PACK(A,AJJL,MCB)        
      A(I) = 0.0        
      I = I+2        
  140 CONTINUE        
      NFSBEB = NFSBEB + NSBE(IB)        
  150 CONTINUE        
  200 IF(NTYS.EQ.0) GO TO 1000        
      NFYB = NB+1-NBY        
      NFSBEB = 1        
      NLSBEB = 0        
      NL = NFYB-1        
      IF(NL.EQ.0) GO TO 220        
      DO 210 J=1,NL        
      NLSBEB = NLSBEB+NSBE(J)        
      NFSBEB = NFSBEB+NSBE(J)        
  210 CONTINUE        
  220 DO 250 IB = NFYB,NB        
      NLSBEB = NLSBEB+NSBE(IB)        
      DO 240 IT = NFSBEB,NLSBEB        
      A(I) = 1.0 / (DEN*A0(IT)**2)        
      IF(ABS(YB(IB)).LT..00001) A(I) = (1.0-FLOAT(ND))*A(I)        
      IF(ABS(ZB(IB)).LT..00001) A(I) = (1.0-FLOAT(NE))*A(I)        
      CALL PACK(A,AJJL,MCB)        
      A(I) = 0.0        
      I = I+2        
  240 CONTINUE        
      NFSBEB = NFSBEB+NSBE(IB)        
  250 CONTINUE        
 1000 RETURN        
      END        
