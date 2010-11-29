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
  TYPE myState IS (IDLE, PROCESSING, PASS, WAITST, GET);
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
  
  NSL: PROCESS(state, NEXT_BYTE, BYTE_COUNT, OPCODE)
  BEGIN
    nextState <= state;
    CASE STATE IS
      WHEN IDLE =>
        nextState <= IDLE;
        IF ((BYTE_COUNT > 15 AND NEXT_BYTE = '1') OR EOP = '1') THEN
          nextState <= PASS;
        ELSE
          nextState <= IDLE;
        END IF;
      WHEN PASS =>
        nextState <= WAITST;
      WHEN WAITST =>
        nextState <= GET;
      WHEN GET =>
        nextState <= PROCESSING;
      WHEN PROCESSING =>
        IF (OPCODE = "10" OR OPCODE = "11") THEN nextState <= IDLE;
        ELSIF (NEXT_BYTE = '1') THEN nextState <= PASS;
        ELSE nextState <= PROCESSING;
        END IF;
    END CASE;
  END PROCESS NSL;
  
  OL: PROCESS(DATA, OPCODE, state)
  BEGIN
    nextR_ENABLE <= '0';
    CASE STATE IS
      WHEN IDLE =>
        nextB_READY <= '0';
      WHEN PASS =>
        nextR_ENABLE <= '1';
        nextB_READY <= '0';
      WHEN WAITST =>
        nextB_READY <= '0';
      WHEN GET =>
        nextTempData <= DATA;
        nextTempOpcode <= OPCODE;
        nextB_READY <= '1';
      WHEN PROCESSING =>
        nextB_READY <= '1';
    END CASE;
  END PROCESS OL;
END brbuffer;