      SUBROUTINE CMRD2A        
C        
C     THIS SUBROUTINE PARTITIONS THE STIFFNESS MATRIX INTO BOUNDARY AND 
C     INTERIOR POINTS AND THEN SAVES THE PARTITIONING VECTOR ON THE SOF 
C     AS THE UPRT ITEM FOR THE CMRED2 MODULE.        
C        
C     INPUT DATA        
C     GINO - USETMR - USET TABLE FOR REDUCED SUBSTRUCTURE        
C            KAA    - SUBSTRUCTURE STIFFNESS MATRIX        
C        
C     OUTPUT DATA        
C     GINO - KBB  - KBB PARTITION MATRIX        
C            KIB  - KIB PARTITION MATRIX        
C            KII  - KII PARTITION MATRIX        
C     SOF  - UPRT - PARTITION VECTOR FOR ORIGINAL SUBSTRUCTURE        
C        
C     PARAMETERS        
C     INPUT  - GBUF   - GINO BUFFER        
C              INFILE - INPUT FILE NUMBERS        
C              ISCR   - SCRATCH FILE NUMBERS        
C              KORLEN - LENGTH OF OPEN CORE        
C              KORBGN - BEGINNING ADDRESS OF OPEN CORE        
C              OLDNAM - NAME OF SUBSTRUCTURE BEING REDUCED        
C     OTHERS - USETMR - USETMR INPUT FILE NUMBER        
C              KAA    - KAA INPUT FILE NUMBER        
C              KBB    - KBB OUTPUT FILE NUMBER        
C              KIB    - KIB OUTPUT FILE NUMBER        
C              KBI    - KBI OUTPUT FILE NUMBER        
C              KII    - KII OUTPUT FILE NUMBER        
C              UPRT   - KAA PARTITION VECTOR FILE NUMBER        
C        
      INTEGER         DRY,GBUF1,OTFILE,OLDNAM,Z,UN,UB,UI,FUSET,USETMR,  
     1                UPRT,MODNAM(2)        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /BLANK / IDUM1,DRY,IDUM6,GBUF1,IDUM2(5),INFILE(11),        
     1                OTFILE(6),ISCR(11),KORLEN,KORBGN,OLDNAM(2)        
CZZ   COMMON /ZZCMRD/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /BITPOS/ IDUM4(9),UN,IDUM5(10),UB,UI        
      COMMON /PATX  / LCORE,NSUB(3),FUSET        
      COMMON /SYSTEM/ IDUM3,IPRNTR        
      EQUIVALENCE     (USETMR,INFILE(6)),(KAA,INFILE(7)),        
     1                (KBB,ISCR(1)),(KIB,ISCR(2)),(KII,ISCR(4)),        
     2                (KBI,ISCR(3)),(UPRT,ISCR(5))        
      DATA    MODNAM/ 4HCMRD,4H2A  /        
      DATA    ITEM  / 4HUPRT       /        
C        
C     SET UP PARTITIONING VECTOR        
C        
      IF (DRY .EQ. -2) RETURN        
      LCORE = KORLEN        
      FUSET = USETMR        
      CALL CALCV(UPRT,UN,UI,UB,Z(KORBGN))        
C        
C     PARTITION STIFFNESS MATRIX        
C        
C                  **         **        
C                  *     .     *        
C        **   **   * KBB . KBI *        
C        *     *   *     .     *        
C        * KAA * = *...........*        
C        *     *   *     .     *        
C        **   **   * KIB . KII *        
C                  *     .     *        
C                  **         **        
C        
      CALL GMPRTN(KAA,KII,KBI,KIB,KBB,UPRT,UPRT,NSUB(1),NSUB(2),        
     1     Z(KORBGN),KORLEN)        
C        
C     SAVE PARTITIONING VECTOR        
C        
      CALL MTRXO(UPRT,OLDNAM,  ITEM,0,ITEST)        
      IF (ITEST .NE. 3) GO TO 30        
      RETURN        
C        
C     PROCESS MODULE FATAL ERRORS        
C        
   30 GO TO (40,40,40,50,60,80), ITEST        
   40 WRITE (IPRNTR,900) UFM,MODNAM,ITEM,OLDNAM        
      DRY = -2        
      RETURN        
   50 IMSG = -2        
      GO TO 70        
   60 IMSG = -3        
   70 CALL SMSG(IMSG,ITEM,OLDNAM)        
      RETURN        
C        
   80 WRITE (IPRNTR,901) UFM,MODNAM,ITEM,OLDNAM        
      DRY = -2        
      RETURN        
C        
  900 FORMAT (A23,' 3211, MODULE ',2A4,8H - ITEM ,A4,        
     1       ' OF SUBSTRUCTURE ',2A4,' HAS ALREADY BEEN WRITTEN.')      
  901 FORMAT (A23,' 6632, MODULE ',2A4,' - NASTRAN MATRIX FILE FOR ',   
     1       'I/O OF SOF ITEM ',A4,', SUBSTRUCTURE ',2A4,', IS PURGED.')
C        
      END        
