      SUBROUTINE SOFINT (IB1,IB2,NUMB,IBL1)        
C        
C     CALLED ONCE BY EVERY RUN USING THE SOF UTILITY SUBROUTINES.       
C     SHOULD BE CALLED BEFORE ANY OF THEM IS CALLED.  IF THE SOF IS     
C     NOT EMPTY, SOME SECURITY CHECKS WILL BE TAKEN CARE OF, AND THE    
C     SOF COMMON BLOCKS WILL BE UPDATED AND WRITTEN OUT ON THE FIRST    
C     BLOCK OF EACH OF THE SOF FILES.  IF THE SOF IS EMPTY, THE DIT     
C     MDI, AND ARRAY NXT WILL BE INITIALIZED AND WRITTEN OUT ON THE     
C     THIRD, FOURTH, AND SECOND BLOCKS OF THE FIRST FILE OF THE SOF,    
C     AND THE SOF COMMON BLOCKS WILL BE INITIALIZED AND WRITTEN OUT     
C     ON THE FIRST BLOCK OF EACH OF THE SOF FILES.        
C        
C     THE FIRST BLOCK OF EACH OF THE SOF FILES CONTAINS THE FOLLOWING   
C     INFORMATION        
C       WORD                   WORD                   WORD        
C      NUMBER  CONTENTS       NUMBER  CONTENTS       NUMBER  CONTENTS   
C      ------  --------       ------  --------       ------  --------   
C       1- 2   PASSWORD          26   DIRSIZ            32   MDIBL      
C          3   FILE NUMBER       27   SUPSIZ            33   NXTTSZ     
C          4   NFILES            28   AVBLKS         34-43   NXTFSZ     
C       5-14   FILNAM            29   DITSIZ            44   NXTCUR     
C      15-24   FILSIZ            30   DITNSB            45   NXTRST     
C         25   BLKSIZ            31   DITBL             46   HIBLK      
C                                                       47   IFRST      
C        
C     STARTING AT LOCATION 100 THE CONTENTS OF THE ITEMDT COMMON BLOCK  
C     ARE STORED        
C        
C        
      EXTERNAL        LSHIFT,RSHIFT,ORF        
      LOGICAL         FIRST        
      INTEGER         FILNAM,FILSIZ,STATUS,FILE,PSSWRD,ORF,HIBLK,       
     1                BUF,RSHIFT,NAME(2)        
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25,SWM*27,SIM*31        
      COMMON /XMSSG / UFM,UWM,UIM,SFM,SWM,SIM        
      COMMON /MACHIN/ MAC,IHALF        
CZZ   COMMON /SOFPTR/ BUF(1)        
      COMMON /ZZZZZZ/ BUF(1)        
      COMMON /SOFCOM/ NFILES,FILNAM(10),FILSIZ(10),STATUS,PSSWRD(2),    
     1                FIRST        
      COMMON /SYSTEM/ NBUFF,NOUT,X1(36),NBPC,NBPW,NCPW        
      COMMON /SYS   / NSBUFF,X4(3),HIBLK,IFRST        
      COMMON /ITEMDT/ NITEM,ITEM(7,1)        
      DATA    IRD,IWRT    /1, 2  /        
      DATA    IEMPTY,NAME /4H    ,4HSOFI,4HNT  /        
C        
      IF (NCPW .LE. 4) GO TO 5        
      N = NBPW - NBPC*4        
      DO 3 I = 1,10        
      FILNAM(I) = LSHIFT(RSHIFT(FILNAM(I),N),N)        
    3 CONTINUE        
    5 IF (NFILES .LE. 0) GO TO 1000        
      IF (STATUS .EQ. 0) GO TO 250        
C        
C     THE SOF IS NOT EMPTY.  READ THE FIRST BLOCK OF THE FIRST SOF FILE 
C     AND VERIFY THE SECURITY VARIABLES.        
C        
      FILE = FILNAM(1)        
      CALL SOFIO (IRD,1,BUF(IB1-2))        
      IF ((BUF(IB1+1).NE.PSSWRD(1)) .OR. (BUF(IB1+2).NE.PSSWRD(2)))     
     1     GO TO 1050        
      IF (BUF(IB1+3) .NE. 1) GO TO 1060        
      IF (BUF(IB1+25) .NE. NSBUFF) GO TO 1040        
C        
C     CHECK IF THE SPECIFIED NUMBER OF FILES AND THEIR SIZES IS ADEQUATE
C        
      IF (BUF(IB1+4) .GE. NFILES) GO TO 10        
      MAX = BUF(IB1+4) - 1        
      GO TO 20        
   10 MAX = NFILES - 1        
   20 IF (MAX .LT. 1) GO TO 50        
      DO 30 I = 1,MAX        
      IF (BUF(IB1+14+I) .EQ. FILSIZ(I)) GO TO 30        
      FILE = FILNAM(I)        
      GO TO 1070        
   30 CONTINUE        
C        
C     CHECK IF ALL SOF FILES HAVE THE CORRECT PASSWORD AND SEQUENCE     
C     NUMBER        
C        
      MAX = MAX + 1        
      IBL = 1        
      DO 40 I = 2,MAX        
      FILE = FILNAM(I)        
      IBL  = IBL + FILSIZ(I-1)        
      CALL SOFIO (IRD,IBL,BUF(IB1-2))        
      IF ((BUF(IB1+1).NE.PSSWRD(1)) .OR. (BUF(IB1+2).NE.PSSWRD(2)))     
     1     GO TO 1050        
      IF (BUF(IB1+3) .NE. I) GO TO 1060        
   40 CONTINUE        
      CALL SOFIO (IRD,1,BUF(IB1-2))        
      MAX = MAX - 1        
   50 IF (BUF(IB1+14+MAX+1) .EQ. FILSIZ(MAX+1)) GO TO 130        
      MAXNXT = 0        
      IF (MAX .LT. 1) GO TO 70        
      DO 60 I = 1,MAX        
      MAXNXT = MAXNXT+BUF(IB1+33+I)        
   60 CONTINUE        
   70 LASTSZ = (FILSIZ(MAX+1)-1)/BUF(IB1+27)        
      IF (FILSIZ(MAX+1)-1 .EQ. LASTSZ*BUF(IB1+27)) GO TO 80        
      LASTSZ = LASTSZ + 1        
   80 MAXNXT = MAXNXT + LASTSZ        
      IF (BUF(IB1+33) .GT. MAXNXT) GO TO 1080        
      MAXOLD = MAXNXT - LASTSZ + BUF(IB1+33+MAX+1)        
      IF (BUF(IB1+33) .NE. MAXOLD) GO TO 130        
      IF (BUF(IB1+14+MAX+1) .GT. FILSIZ(MAX+1)) GO TO 1080        
      LSTSIZ = MOD(BUF(IB1+14+MAX+1)-2,BUF(IB1+27)) + 1        
      IF (LSTSIZ .EQ. BUF(IB1+27)) GO TO 130        
C        
C     THE SIZE OF THE LAST SUPERBLOCK THAT WAS USED ON FILE (MAX+1)     
C     SHOULD BE INCREASED.        
C        
      IF (FILSIZ(MAX+1)-BUF(IB1+14+MAX+1) .GE. BUF(IB1+27)-LSTSIZ)      
     1    GO TO 90        
      NUMB = FILSIZ(MAX+1) - BUF(IB1+14+MAX+1)        
      GO TO 100        
   90 NUMB = BUF(IB1+27) - LSTSIZ        
  100 IBL1 = 0        
      IF (MAX .LT. 1) GO TO 120        
      DO 110 I = 1,MAX        
      IBL1 = IBL1 + FILSIZ(I)        
  110 CONTINUE        
  120 IBL1 = IBL1 + BUF(IB1+14+MAX+1) + 1        
      GO TO 135        
  130 NUMB = 0        
C        
C     UPDATE THE VARIABLE WHICH INDICATES THE NUMBER OF FREE BLOCKS ON  
C     THE SOF.        
C        
  135 IF (NFILES-BUF(IB1+4)) 140,160,170        
  140 IDIFF = BUF(IB1+14+NFILES) - FILSIZ(NFILES)        
      MIN   = NFILES + 1        
      LAST  = BUF(IB1+4)        
      DO 150 I = MIN,LAST        
      IDIFF = IDIFF + BUF(IB1+14+I)        
  150 CONTINUE        
      GO TO 190        
  160 IDIFF = BUF(IB1+14+NFILES) - FILSIZ(NFILES)        
      GO TO 190        
  170 IHERE1 = BUF(IB1+4)        
      IDIFF  = BUF(IB1+14+IHERE1) - FILSIZ(IHERE1)        
      MIN    = BUF(IB1+4) + 1        
      DO 180 I = MIN,NFILES        
      IDIFF = IDIFF - FILSIZ(I)        
  180 CONTINUE        
  190 BUF(IB1+28) = BUF(IB1+28) - IDIFF        
C        
C     IF NO ITEM STRUCTURE IS ON THE SOF (THE SOF WAS CREATED BEFORE    
C     LEVEL 17.0) THEN USE THE LEVEL 16.0 ITEM STRUCTURE.        
C        
      IF (BUF(IB1+100).GT.0 .AND. BUF(IB1+100).LE.100) GO TO 198        
      WRITE (NOUT,6235) UWM        
      BUF(IB1+ 47) = 3        
      BUF(IB1+100) = 18        
      K = 100        
      DO 194 I = 1,18        
      DO 192 J = 1,7        
  192 BUF(IB1+K+J) = ITEM(J,I)        
  194 K = K + 7        
      GO TO 200        
C        
C     CHECK IF THE DIRECTORY SIZE HAS BEEN CHANGED        
C        
  198 IF (NITEM .EQ. BUF(IB1+100)) GO TO 200        
      WRITE (NOUT,6233) UWM        
C        
C     UPDATE THE COMMON BLOCKS USED BY THE SOF UTILITY SUBROUTINES.     
C        
  200 BUF(IB1+4) = NFILES        
      DO 210 I = 1,NFILES        
      BUF(IB1+4 +I) = FILNAM(I)        
      BUF(IB1+14+I) = FILSIZ(I)        
      BUF(IB1+33+I) = (FILSIZ(I)-1)/BUF(IB1+27)        
      IF (FILSIZ(I)-1 .EQ. BUF(IB1+33+I)*BUF(IB1+27)) GO TO 210        
      BUF(IB1+33+I) = BUF(IB1+33+I) + 1        
  210 CONTINUE        
C        
C     WRITE THE UPDATED ARRAY A ON THE FIRST BLOCK OF EACH OF THE SOF   
C     FILES.        
C        
      IBL = 1        
      DO 220 I = 1,NFILES        
      BUF(IB1+3) = I        
      CALL SOFIO (IWRT,IBL,BUF(IB1-2))        
      IBL = IBL + FILSIZ(I)        
  220 CONTINUE        
      GO TO 340        
C        
C     THE SOF IS EMPTY.  INITIALIZE THE SOF COMMON BLOCKS WHICH ARE     
C     STORED IN THE ARRAY A.        
C     CHECK IF THE NASTRAN BUFFER SIZE IS LARGE ENOUGH        
C        
  250 MIN = 100 + 7*NITEM + (NBUFF-NSBUFF)        
      IF (NBUFF .LT. MIN) GO TO 1090        
      LAST  = NBUFF - 4        
      HIBLK = 0        
      IFRST = 3        
      DO 255 I = 1,LAST        
  255 BUF(IB1+ I) = 0        
      BUF(IB1+ 1) = PSSWRD(1)        
      BUF(IB1+ 2) = PSSWRD(2)        
      BUF(IB1+25) = NSBUFF        
      BUF(IB1+26) = NITEM + IFRST - 1        
      BUF(IB1+27) = 2*(BUF(IB1+25)-1)        
      BUF(IB1+28) = -4        
      DO 260 I = 1,NFILES        
      BUF(IB1+28) = BUF(IB1+28) + FILSIZ(I)        
  260 CONTINUE        
      BUF(IB1+29) = 0        
      BUF(IB1+30) = 0        
      BUF(IB1+31) = 3        
      BUF(IB1+32) = 4        
      BUF(IB1+33) = 1        
      BUF(IB1+44) = 1        
      BUF(IB1+45) = 0        
      BUF(IB1+46) = 4        
      BUF(IB1+47) = IFRST        
C        
      BUF(IB1+100) = NITEM        
      K = 100        
      DO 280 I = 1,NITEM        
      DO 270 J = 1,7        
  270 BUF(IB1+K+J) = ITEM(J,I)        
  280 K = K + 7        
C        
C     INITIALIZE THE ARRAY NXT AND WRITE IT ON THE SECOND BLOCK OF THE  
C     FIRST SOF FILE.        
C        
      DO 300 I = 1,LAST        
      BUF(IB2+I) = 0        
  300 CONTINUE        
      IF (BUF(IB1+27)+1 .GT. FILSIZ(1)) GO TO 302        
      MAX = BUF(IB1+25) - 1        
      BUF(IB2+MAX+1) = LSHIFT(BUF(IB1+27)+1,IHALF)        
      BUF(IB2+1) = BUF(IB1+27) + 1        
      GO TO 308        
  302 IF (MOD(FILSIZ(1),2) .EQ. 1) GO TO 304        
      MAX = FILSIZ(1)/2        
      GO TO 306        
  304 MAX = (FILSIZ(1)-1)/2        
      BUF(IB2+MAX+1) = LSHIFT(FILSIZ(1),IHALF)        
  306 BUF(IB2+1) = FILSIZ(1)        
  308 BUF(IB2+1) = ORF(BUF(IB2+1),LSHIFT(5,IHALF))        
      BUF(IB2+2) = 0        
      BUF(IB2+3) = 6        
      DO 310 I = 4,MAX        
      BUF(IB2+I) = 2*I        
      BUF(IB2+I) = ORF(BUF(IB2+I),LSHIFT(2*I-1,IHALF))        
  310 CONTINUE        
      CALL SOFIO (IWRT,1,BUF(IB2-2))        
      CALL SOFIO (IWRT,2,BUF(IB2-2))        
C        
C     INITIALIZE THE DIT AND WRITE IT ON THE THIRD BLOCK OF THE FIRST   
C     SOF FILE.        
C        
      DO 320 I = 1,LAST        
      BUF(IB2+I) = IEMPTY        
  320 CONTINUE        
      CALL SOFIO (IWRT,3,BUF(IB2-2))        
C        
C     INITIALIZE THE MDI AND WRITE IT ON THE FOURTH BLOCK OF THE FIRST  
C     SOF FILE.        
C        
      DO 330 I = 1,LAST        
      BUF(IB2+I) = 0        
  330 CONTINUE        
      CALL SOFIO (IWRT,4,BUF(IB2-2))        
      NUMB = 0        
      GO TO 200        
C        
C     PRINT MESSAGE INDICATING THE STATUS OF THE CURRENT SOF FILES.     
C        
  340 WRITE (NOUT,360) SIM,NFILES        
      DO 350 I = 1,NFILES        
      WRITE (NOUT,370) I,FILSIZ(I)        
  350 CONTINUE        
      WRITE  (NOUT,380) BUF(IB1+25)        
  360 FORMAT (A31,' 6201,',I3,' FILES HAVE BEEN ALLOCATED TO THE SOF ', 
     1       'WHERE --')        
  370 FORMAT (18H     SIZE OF FILE ,I2,3H = ,I10,7H BLOCKS)        
  380 FORMAT (32H     AND WHERE A BLOCK CONTAINS ,I4,6H WORDS)        
      RETURN        
C        
C     ERROR MESSAGES.        
C        
 1000 WRITE  (NOUT,1001) SFM        
 1001 FORMAT (A25,' 6202.  THE REQUESTED NO. OF FILES IS NON POSITIVE.')
      CALL MESAGE (-37,0,NAME(1))        
      RETURN        
C        
 1040 I = (NBUFF-NSBUFF) + BUF(IB1+25)        
      WRITE  (NOUT,1041) UFM,I        
 1041 FORMAT (A23,' 6205, SUBROUTINE SOFINT - THE BUFFER SIZE HAS BEEN',
     1       ' MODIFIED.', /30X,        
     2       'THE CORRECT NASTRAN PARAMETER IS BUFFSIZE = ',I6)        
      GO TO 1082        
C        
 1050 WRITE  (NOUT,1051) UFM,FILE        
 1051 FORMAT (A23,' 6206, SUBROUTINE SOFINT - WRONG PASSWORD ON SOF ',  
     1       'FILE ',A4,1H.)        
      GO TO 1082        
C        
 1060 WRITE  (NOUT,1061) UFM,FILE        
 1061 FORMAT (A23,' 6207, SUBROUTINE SOFINT - THE SOF FILE ',A4,        
     1       ' IS OUT OF SEQUENCE.')        
      GO TO 1082        
C        
 1070 WRITE  (NOUT,1071) UFM,FILE        
 1071 FORMAT (A23,' 6208, SUBROUTINE SOFINT - THE SIZE OF THE SOF FILE '
     1,       A4,' HAS BEEN MODIFIED.')        
      GO TO 1082        
C        
 1080 WRITE  (NOUT,1081) UFM,FILE        
 1081 FORMAT (A23,' 6209, SUBROUTINE SOFINT - THE NEW SIZE OF FILE ',A4,
     1       ' IS TOO SMALL.')        
 1082 CALL MESAGE (-61,0,0)        
C        
 1090 WRITE  (NOUT,1091) UFM,MIN        
 1091 FORMAT (A23,' 6234, THE NASTRAN BUFFER SIZE IS TO SMALL FOR THE', 
     1       ' SOF FILE.', /30X,'MINIMUM BUFFER SIZE IS ',I10)        
      GO TO 1082        
C        
 6233 FORMAT (A25,' 6233, THE ITEM STRUCTURE HAS BEEN CHANGED FOR THE ',
     1       'SOF.', /32X,'NEW CAPABILITIES USING THESE ITEMS MAY NOT ',
     2       'BE USED WITH THIS SOF.')        
C        
 6235 FORMAT (A25,'6235, THE OLD SOF CONTAINS NO ITEM STRUCTURE ',      
     1       'INFORMATION.', /27X,'THE LEVEL 16.0 ITEM STRUCTURE WILL ',
     2       'BE USED.')        
C        
      END        
