      SUBROUTINE FNXT (II,J)        
C        
C     FETCHES FROM THE RANDOM ACCESS STORAGE DEVICE THE BLOCK OF THE    
C     ARRAY NXT CONTAINING THE ENTRY FOR BLOCK I.  IT STORES THE FETCHED
C     BLOCK IN THE ARRAY BUF, STARTING AT LOCATION NXT.  THE OUTPUT J   
C     INDICATES THAT BLOCK I HAS THE JTH ENTRY IN THE ARRAY BUF.        
C        
      LOGICAL         DITUP,NXTUP        
      INTEGER         BUF,DIT,DITPBN,DITLBN,DITSIZ,DITNSB,DITBL,        
     1                BLKSIZ,DIRSIZ,SUPSIZ,FILSIZ,FILNUM,FILSUP        
      DIMENSION       NMSBR(2)        
CZZ   COMMON /SOFPTR/ BUF(1)        
      COMMON /ZZZZZZ/ BUF(1)        
      COMMON /SOF   / DIT,DITPBN,DITLBN,DITSIZ,DITNSB,DITBL,IODUM(8),   
     1                MDIDUM(4),NXT,NXTPBN,NXTLBN,NXTTSZ,NXTFSZ(10),    
     2                NXTCUR,DITUP,MDIUP,NXTUP,NXTRST        
      COMMON /SYS   / BLKSIZ,DIRSIZ,SUPSIZ        
      COMMON /SOFCOM/ NFILES,FILNAM(10),FILSIZ(10)        
      DATA    IRD   , IWRT,INDSBR  / 1,2, 9 /        
      DATA    NMSBR / 4HFNXT,4H    /        
C        
C     FILNUM IS THE NUMBER OF THE DEVICE TO WHICH BLOCK I BELONGS.      
C        
      CALL CHKOPN (NMSBR(1))        
      INDEX = II        
      DO 4 L = 1,NFILES        
      IF (INDEX .GT. FILSIZ(L)) GO TO 2        
      FILNUM = L        
      GO TO 10        
    2 INDEX = INDEX - FILSIZ(L)        
    4 CONTINUE        
      GO TO 500        
C        
C     INDEX IS THE INDEX OF BLOCK I WITHIN FILE FILNUM.        
C     FILSUP IS THE NUMBER OF THE SUPERBLOCK WITHIN FILE FILNUM TO WHICH
C     BLOCK I BELONGS, AND SUPSIZ IS THE SIZE OF A SUPERBLOCK.        
C        
   10 FILSUP = (INDEX-1)/SUPSIZ        
      IF (INDEX-1 .EQ. FILSUP*SUPSIZ) GO TO 20        
      FILSUP = FILSUP + 1        
C        
C     COMPUTE THE LOGICAL BLOCK NUMBER, WITHIN THE ARRAY NXT, IN WHICH  
C     THE ITH BLOCK HAS AN ENTRY, ALSO COMPUTE THE INDEX OF THIS ENTRY  
C     RELATIVE TO THE ARRAY BUF.  STORE THE BLOCK NUMBER IN IBLOCK, AND 
C     THE INDEX IN J.        
C        
   20 IBLOCK = 0        
      MAX = FILNUM - 1        
      IF (MAX .LT. 1) GO TO 26        
      DO 24 I = 1,MAX        
      IBLOCK = IBLOCK + NXTFSZ(I)        
   24 CONTINUE        
   26 IBLOCK = IBLOCK + FILSUP        
      J = (INDEX-(FILSUP-1)*SUPSIZ)/2 + 1 + NXT        
      IF (IBLOCK .EQ. NXTLBN) RETURN        
      IF (IBLOCK .GT. NXTTSZ) GO TO 500        
C        
C     THE DESIRED NXT BLOCK IS NOT PRESENTLY IN CORE, MUST THEREFORE    
C     FETCH IT.        
C        
      IF (DITPBN .EQ. 0) GO TO 40        
C        
C     THE IN CORE BLOCK SHARED BY THE DIT AND THE ARRAY NXT IS NOW      
C     OCCUPIED BY ONE BLOCK OF THE DIT.        
C        
      IF (.NOT.DITUP) GO TO 30        
C        
C     THE DIT BLOCK NOW IN CORE HAS BEEN UPDATED.  MUST THEREFORE WRITE 
C     IT OUT BEFORE READING IN THE DESIRED NXT BLOCK.        
C        
      CALL SOFIO (IWRT,DITPBN,BUF(DIT-2))        
      DITUP  = .FALSE.        
   30 DITPBN = 0        
      DITLBN = 0        
      GO TO 50        
   40 IF (NXTPBN .EQ. 0) GO TO 50        
C        
C     THE IN CORE BLOCK SHARED BY THE DIT AND THE ARRAY NXT IS NOW      
C     OCCUPIED BY ONE BLOCK OF NXT.        
C        
      IF (.NOT.NXTUP) GO TO 50        
C        
C     THE NEXT BLOCK CURRENTLY IN CORE HAS BEEN UPDATED.  MUST THEREFORE
C     WRITE IT OUT BEFORE READING IN A NEW BLOCK.        
C        
      CALL SOFIO (IWRT,NXTPBN,BUF(NXT-2))        
      NXTUP = .FALSE.        
C        
C     READ THE DESIRED NXT BLOCK INTO CORE.        
C        
   50 NXTLBN = IBLOCK        
      NXTPBN = 0        
      IF (MAX .LT. 1) GO TO 70        
      DO 60 I = 1,MAX        
      NXTPBN = NXTPBN+FILSIZ(I)        
   60 CONTINUE        
   70 NXTPBN = NXTPBN + (FILSUP-1)*SUPSIZ + 2        
      CALL SOFIO (IRD,NXTPBN,BUF(NXT-2))        
      RETURN        
C        
C     ERROR MESSAGES.        
C        
  500 CALL ERRMKN (INDSBR,1)        
      RETURN        
      END        
