      ******************************************************************
      * Program:     INTCALC
      * Purpose:     Batch interest calculation job, modelled on a
      *              typical mainframe end-of-day account processing
      *              run. Reads a fixed-width account file, applies
      *              simple interest based on account type, and
      *              produces a summary report.
      * Author:      [Your Name]
      * Notes:       Designed to compile under GnuCOBOL 3.x and to be
      *              representative of real-world COBOL batch jobs
      *              (sequential file I/O, 88-level condition names,
      *              edited numeric output, control totals).
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. INTCALC.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ACCOUNT-FILE ASSIGN TO "ACCTIN"
               ORGANIZATION IS LINE SEQUENTIAL.

           SELECT REPORT-FILE ASSIGN TO "ACCTRPT"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  ACCOUNT-FILE.
       01  ACCOUNT-RECORD.
           05  ACC-ID            PIC X(6).
           05  ACC-TYPE          PIC X(1).
               88  TYPE-SAVINGS  VALUE "S".
               88  TYPE-CURRENT  VALUE "C".
               88  TYPE-DEPOSIT  VALUE "D".
           05  ACC-BALANCE       PIC 9(7)V99.

       FD  REPORT-FILE.
       01  REPORT-LINE           PIC X(80).

       WORKING-STORAGE SECTION.
       01  WS-EOF                PIC X(1) VALUE "N".
           88  END-OF-FILE       VALUE "Y".

       01  WS-RATE               PIC 9V999.
       01  WS-INTEREST           PIC 9(7)V99.
       01  WS-NEW-BALANCE        PIC 9(7)V99.

       01  WS-TOTAL-ACCOUNTS     PIC 9(5)  VALUE 0.
       01  WS-TOTAL-INTEREST     PIC 9(9)V99 VALUE 0.

       01  WS-REPORT-DETAIL.
           05  FILLER            PIC X(2)  VALUE SPACES.
           05  RD-ID             PIC X(6).
           05  FILLER            PIC X(2)  VALUE SPACES.
           05  RD-TYPE           PIC X(1).
           05  FILLER            PIC X(2)  VALUE SPACES.
           05  RD-BALANCE        PIC ZZZ,ZZZ.99.
           05  FILLER            PIC X(2)  VALUE SPACES.
           05  RD-INTEREST       PIC ZZZ,ZZZ.99.
           05  FILLER            PIC X(2)  VALUE SPACES.
           05  RD-NEWBAL         PIC Z,ZZZ,ZZZ.99.

       01  WS-REPORT-HEADER1     PIC X(80) VALUE
           "  ACCID  TYPE  BALANCE       INTEREST      NEW BALANCE".

       01  WS-REPORT-TOTALS.
           05  FILLER            PIC X(20) VALUE
               "  TOTAL ACCOUNTS: ".
           05  RT-COUNT           PIC ZZZZ9.
           05  FILLER            PIC X(20) VALUE
               "   TOTAL INTEREST: ".
           05  RT-INTEREST        PIC ZZZ,ZZZ,ZZZ.99.

       PROCEDURE DIVISION.
       000-MAIN.
           OPEN INPUT  ACCOUNT-FILE
           OPEN OUTPUT REPORT-FILE

           WRITE REPORT-LINE FROM WS-REPORT-HEADER1

           PERFORM 100-READ-ACCOUNT
           PERFORM UNTIL END-OF-FILE
               PERFORM 200-CALCULATE-INTEREST
               PERFORM 300-WRITE-DETAIL
               PERFORM 100-READ-ACCOUNT
           END-PERFORM

           PERFORM 400-WRITE-TOTALS

           CLOSE ACCOUNT-FILE
           CLOSE REPORT-FILE

           STOP RUN.

       100-READ-ACCOUNT.
           READ ACCOUNT-FILE
               AT END
                   SET END-OF-FILE TO TRUE
               NOT AT END
                   ADD 1 TO WS-TOTAL-ACCOUNTS
           END-READ.

       200-CALCULATE-INTEREST.
           EVALUATE TRUE
               WHEN TYPE-SAVINGS
                   MOVE 0.045 TO WS-RATE
               WHEN TYPE-CURRENT
                   MOVE 0.005 TO WS-RATE
               WHEN TYPE-DEPOSIT
                   MOVE 0.065 TO WS-RATE
               WHEN OTHER
                   MOVE 0.000 TO WS-RATE
           END-EVALUATE

           COMPUTE WS-INTEREST ROUNDED =
               ACC-BALANCE * WS-RATE

           COMPUTE WS-NEW-BALANCE =
               ACC-BALANCE + WS-INTEREST

           ADD WS-INTEREST TO WS-TOTAL-INTEREST.

       300-WRITE-DETAIL.
           MOVE ACC-ID        TO RD-ID
           MOVE ACC-TYPE      TO RD-TYPE
           MOVE ACC-BALANCE   TO RD-BALANCE
           MOVE WS-INTEREST   TO RD-INTEREST
           MOVE WS-NEW-BALANCE TO RD-NEWBAL

           WRITE REPORT-LINE FROM WS-REPORT-DETAIL.

       400-WRITE-TOTALS.
           MOVE WS-TOTAL-ACCOUNTS TO RT-COUNT
           MOVE WS-TOTAL-INTEREST TO RT-INTEREST
           WRITE REPORT-LINE FROM WS-REPORT-TOTALS.
