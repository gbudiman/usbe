-- $Id: $
-- File name:   rbuffer.vhd
-- Created:     11/27/2010
-- Author:      Gloria Budiman
-- Lab Section: 337-02
-- Version:     1.0  Initial Design Entry
-- Description: Host-to-bus buffer block.


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.std_logic_arith.ALL;

ENTITY RBUFFER IS
  PORT( CLK, RST, NEXT_BYTE: IN STD_LOGIC;
    DATA: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
    OPCODE: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
    BYTE_COUNT: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
    EOP: IN STD_LOGIC;
    B_READY, R_ENABLE: OUT STD_LOGIC;
    PRGA_IN: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
    PRGA_OPCODE: OUT STD_LOGIC_VECTOR (1 DOWNTO 0));
END RBUFFER;

ARCHITECTURE brbuffer OF RBUFFER IS
  TYPE myState IS (IDLE, P1, P2, P3, P4, PWAIT, DECS);
  SIGNAL state, nextState: myState;
  SIGNAL tempData, nextTempData: STD_LOGIC_VECTOR (7 DOWNTO 0);
  SIGNAL tempOpcode, nextTempOpcode: STD_LOGIC_VECTOR (1 DOWNTO 0);
  SIGNAL nextB_READY, nextR_ENABLE: STD_LOGIC;
BEGIN
  TLB: PROCESS(CLK, RST, nextState, nextB_READY, nextTempData, nextTempOpcode, nextR_ENABLE)
  BEGIN
    IF (RST = '1') THEN
      state <= IDLE;
    ELSIF (RISING_EDGE(CLK)) THEN
      state <= nextState;
      B_READY <= nextB_READY;
      tempData <= nextTempData;
      tempOpcode <= nextTempopcode;
      R_ENABLE <= nextR_ENABLE;
      PRGA_IN <= nextTempData;
      PRGA_OPCODE <= nextTempOpcode;
    END IF;
  END PROCESS TLB;
  
  NSL: PROCESS(state, NEXT_BYTE, BYTE_COUNT, OPCODE, EOP)
  BEGIN
    nextState <= state;
    CASE STATE IS
      WHEN IDLE =>
        nextState <= IDLE;
        IF ((BYTE_COUNT > 15 AND NEXT_BYTE = '1') OR (EOP = '1' AND NEXT_BYTE = '1')) THEN
          nextState <= P1;
        ELSE
          nextState <= IDLE;
        END IF;
      WHEN P1 =>
        nextState <= P2;
      WHEN P2 =>
        nextState <= P3;
      WHEN P3 =>
        nextState <= P4;
      WHEN P4 =>
        nextState <= PWAIT;
      WHEN PWAIT =>
        IF (NEXT_BYTE = '0') THEN
          nextState <= DECS;
        ELSE
          nextState <= PWAIT;
        END IF;
      WHEN DECS =>
        IF (OPCODE = "11" OR BYTE_COUNT = 0) THEN
          nextState <= IDLE;
        ELSE
          nextState <= P1;
        END IF;
    END CASE;
  END PROCESS NSL;
  
  OL: PROCESS(DATA, OPCODE, state, tempData, tempOpCode)
  BEGIN
    nextR_ENABLE <= '0';
    nextB_READY <= '0';
    nextTempOpCode <= tempOpCode;
    nextTempData <= tempData;
    CASE STATE IS
      WHEN IDLE =>
      WHEN P1 =>
        nextR_ENABLE <= '1';
      WHEN P2 =>
        nextR_ENABLE <= '0';
      WHEN P3 =>
      WHEN P4 =>
        nextTempData <= DATA;
        nextTempOpCode <= OPCODE;
        nextB_READY <= '1';
      WHEN PWAIT =>
      WHEN DECS =>
    END CASE;
  END PROCESS OL;
END brbuffer;