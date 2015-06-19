      SUBROUTINE CMMCON (NCE)        
C        
C     THIS SUBROUTINE DETERMINES WHETHER MORE THAN ONE CONNECTION ENTRY 
C     HAS BEEN SPECIFIED FOR A GIVEN IP NUMBER.        
C        
      LOGICAL         MCON        
      INTEGER         SCCONN,BUF1,Z,SCORE,SCMCON,BUF3,AAA(2)        
      COMMON /CMB001/ SCR1,SCR2,SCBDAT,SCSFIL,SCCONN,SCMCON        
      COMMON /CMB002/ BUF1,BUF2,BUF3,JUNK(2),SCORE,LCORE,INPT,OUTT      
      COMMON /CMB003/ JUNK2(38),NPSUB,JUNK3(2),MCON        
CZZ   COMMON /ZZCOMB/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      DATA    AAA   / 4HCMMC,4HON   /        
C        
C     READ CONNECTION ENTRIES INTO OPEN CORE        
C        
      NWD   = 2 + NPSUB        
      MCON  = .TRUE.        
      IFILE = SCCONN        
      CALL OPEN (*700,SCCONN,Z(BUF1),0)        
      J   = 0        
      NCE = 0        
   90 CALL READ (*200,*100,SCCONN,Z(SCORE+J),10,1,NNN)        
  100 NCE = NCE + 1        
      Z(SCORE+J) = NCE        
      J = J + NWD        
      GO TO 90        
  200 CALL CLOSE (SCCONN,1)        
C        
C     SWEEP THROUGH CONNECTION ENTRIES AND DETERMINE THOSE THAT        
C     REPRESENT MULTIPLE CONNECTIONS.        
C        
      MCON  = .FALSE.        
      NCEM1 = NCE - 1        
C        
      DO 500 K = 1,NCEM1        
      DO 400 I = 1,NPSUB        
      IST = SCORE + I + (K-1)*NWD + 1        
      IF (Z(IST) .EQ. 0) GO TO 400        
      DO 300 J = 1,NCE        
      IF (K .EQ. J) GO TO 300        
      ISUB = SCORE + 1 + I + (J-1)*NWD        
      IF (Z(IST) .NE. Z(ISUB)) GO TO 300        
      ILOC = I + 1        
      Z(IST -ILOC) = -1*IABS(Z(IST -ILOC))        
      Z(ISUB-ILOC) = -1*IABS(Z(ISUB-ILOC))        
      MCON = .TRUE.        
  300 CONTINUE        
  400 CONTINUE        
  500 CONTINUE        
C        
      IF (.NOT.MCON) RETURN        
C        
C     GENERATE OUTPUT FILE OF CONNECTION ENTRY IDS        
C        
      IFILE = SCMCON        
      CALL OPEN (*700,SCMCON,Z(BUF1),1)        
      DO 600 I = 1,NCE        
      LOC = SCORE + (I-1)*NWD        
      IF (Z(LOC) .LT. 0) CALL WRITE (SCMCON,IABS(Z(LOC)),1,0)        
  600 CONTINUE        
      CALL WRITE (SCMCON,0,0,1)        
      CALL CLOSE (SCMCON,1)        
      RETURN        
C        
  700 CALL MESAGE (-1,IFILE,AAA)        
      RETURN        
      END        