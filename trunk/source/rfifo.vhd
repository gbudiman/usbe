-- $Id: $
-- File name:   rfifo.vhd
-- Created:     11/27/2010
-- Author:      Gloria Budiman
-- Lab Section: 337-02
-- Version:     1.0  Initial Design Entry
-- Description: FIFO on host-to-slave.


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY RFIFO IS
  PORT( CLK, RST: IN STD_LOGIC;
    W_ENABLE: IN STD_LOGIC;
    R_ENABLE: IN STD_LOGIC;
    RCV_DATA: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    RCV_OPCODE: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    DATA: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    OUT_OPCODE: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    BYTE_COUNT: OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
    EMPTY, FULL: OUT STD_LOGIC);
END RFIFO;

ARCHITECTURE BRFIFO OF RFIFO IS
  TYPE fState IS (IDLE, D_WRITE, D_READ);
  TYPE ma IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR (7 DOWNTO 0);
  TYPE mo IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR (1 DOWNTO 0);
  SIGNAL state, nextState: fState;
  SIGNAL memory, nextMemory: ma;
  SIGNAL opcode, nextOpCode: mo;
  SIGNAL readptr, nextreadptr, writeptr, nextwriteptr: STD_LOGIC_VECTOR (4 DOWNTO 0);
  SIGNAL nextData: STD_LOGIC_VECTOR (7 DOWNTO 0);
  SIGNAL nextout_opcode: STD_LOGIC_VECTOR (1 DOWNTO 0);
BEGIN
  TLA: PROCESS(CLK, RST, nextState, nextWritePtr, nextReadPtr, nextMemory, nextData, nextout_opcode, nextOpCode)
  BEGIN
    IF (RST = '1') THEN
      state <= IDLE;
      readptr <= "00000";
      writeptr <= "00000";
    ELSIF (RISING_EDGE(clk)) THEN
      state <= nextState;
      readptr <= nextReadPtr;
      writePtr <= nextWritePtr;
      memory <= nextMemory;
      opcode <= nextOpCode;
      DATA <= nextData;
      OUT_OPCODE <= nextout_opcode;
      BYTE_COUNT <= writePtr - readPtr;
    END IF;
  END PROCESS TLA;
  
  NSL: PROCESS(state, W_ENABLE, R_ENABLE)
  BEGIN
    nextState <= state;
    CASE state IS
      WHEN IDLE =>
        IF (W_ENABLE = '1') THEN
          nextState <= D_WRITE;
        ELSIF (R_ENABLE = '1') THEN
          nextState <= D_READ;
        END IF;
      WHEN D_WRITE =>
        nextState <= IDLE;
      WHEN D_READ =>
        nextState <= IDLE;
    END CASE;
  END PROCESS NSL;
  
  RPL: PROCESS(state, readptr, writeptr, RCV_DATA, RCV_OPCODE, memory, opcode)
  BEGIN
    EMPTY <= '0';
    FULL <= '0';
    nextReadPtr <= readPtr;
    nextWritePtr <= writePtr;
    nextMemory <= memory;
    CASE state IS
      WHEN IDLE =>
      WHEN D_READ =>
        IF (readptr = writeptr) THEN
          nextReadPtr <= readPtr;
          EMPTY <= '1';
        ELSE
          nextData <= memory(CONV_INTEGER(readptr));
          nextout_opcode <= opcode(CONV_INTEGER(readptr));
          nextReadPtr <= readPtr + 1;
          EMPTY <= '0';
        END IF;
      WHEN D_WRITE =>
        IF ((writeptr + 1) = readptr) THEN
          nextWritePtr <= writePtr;
          FULL <= '1';
        ELSE
          nextMemory(CONV_INTEGER(writeptr)) <= RCV_DATA;
          nextOpCode(CONV_INTEGER(writeptr)) <= RCV_OPCODE;
          nextWritePtr <= writePtr + 1;
          FULL <= '0';
        END IF;
    END CASE;
  END PROCESS RPL;
END BRFIFO;