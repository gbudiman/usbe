-- $Id: $
-- File name:   keyreg.vhd
-- Created:     11/1/2010
-- Author:      Gloria Budiman
-- Lab Section: 337-02
-- Version:     1.0  Initial Design Entry
-- Description: Plainkey register.


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY keyreg IS
  PORT(CLK, RST, SBE, OE, RBUF_FULL: IN STD_LOGIC;
    RCV_DATA: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    PLAINKEY: OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
    KEY_ERROR, PROG_ERROR, CLR_RBUFF, PARITY_ERROR: OUT STD_LOGIC);
END keyreg;

ARCHITECTURE keyb OF keyreg IS
  TYPE keyState IS (IDLE, PREFILL, FILL, RECEIVE, ERROR, GOOD, CHECK_PARITY, VALIDATE, MDE);
  SIGNAL state, nextState: keyState;
  SIGNAL keyCount, nextKeyCount: STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL address, nextAddress: STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL currentPlainKey, nextPlainKey: STD_LOGIC_VECTOR(63 DOWNTO 0);
  SIGNAL parityAccumulator, nextParityAccumulator: STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL parityError, nextParityError: STD_LOGIC;
BEGIN
  keyp: PROCESS(CLK, RST, nextState, nextAddress, nextPlainKey, currentPlainKey, 
          nextParityAccumulator, nextParityError)
  BEGIN
    IF (RST = '1') THEN
      state <= IDLE;
      PARITY_ERROR <= '0';
      parityError <= '0';
    ELSIF (RISING_EDGE(CLK)) THEN
      state <= nextState;
      keyCount <= nextKeyCount;
      address <= nextAddress;
      currentPlainKey <= nextPlainKey;
      PLAINKEY <= currentPlainKey;
      parityAccumulator <= nextParityAccumulator;
      parityError <= nextParityError;
      PARITY_ERROR <= nextParityError;
    END IF;
  END PROCESS keyp;
  
  NSL: PROCESS(state, OE, SBE, RBUF_FULL, keyCount, RCV_DATA)
  BEGIN
  nextState <= state;
  CASE STATE IS
    WHEN IDLE =>
      IF RBUF_FULL = '1' THEN nextState <= PREFILL;
      ELSE nextState <= IDLE;
      END IF;
      
    WHEN PREFILL => nextState <= FILL;
    WHEN FILL =>
      IF keyCount = 7 THEN
        nextState <= CHECK_PARITY;
      ELSE
        nextState <= RECEIVE;
      END IF;
    WHEN CHECK_PARITY =>
      IF (RBUF_FULL = '1') THEN
        nextState <= VALIDATE;
      ELSE
        nextState <= CHECK_PARITY;
      END IF;
    WHEN VALIDATE =>
      nextState <= MDE;
    WHEN MDE =>
      nextState <= GOOD;
    WHEN RECEIVE =>
      IF SBE = '1' OR OE ='1' THEN nextState <= ERROR;
      ELSIF keyCount < 8 AND RBUF_FULL = '1' THEN nextState <= PREFILL;
      END IF;
    WHEN GOOD =>
      IF RBUF_FULL = '1' THEN nextState <= PREFILL;
      ELSE nextState <= GOOD;
      END IF;
    WHEN OTHERS =>
    END CASE;
  END PROCESS NSL;
    
  OL: PROCESS(state, keyCount, RCV_DATA, address, currentPlainKey, parityAccumulator, parityError)
  BEGIN
    nextKeyCount <= keyCount;
    key_Error <= '1';
    prog_Error <= '0';
    clr_rbuff <= '0';
    nextAddress <= address;
    nextPlainKey <= currentPlainKey;
    nextParityAccumulator <= parityAccumulator;
    nextParityError <= parityError;
    CASE STATE IS
      WHEN ERROR => PROG_ERROR <= '1';
      WHEN GOOD => 
        IF (parityError = '1') THEN
          KEY_ERROR <= '1';
        ELSE
          KEY_ERROR <= '0';
        END IF;
        nextKeyCount <= "0000";
        nextParityAccumulator <= x"00";
      WHEN PREFILL =>
        CASE keyCount IS
          WHEN "0000" => nextaddress <= x"00";
          WHEN "0001" => nextaddress <= x"08";
          WHEN "0010" => nextaddress <= x"10";
          WHEN "0011" => nextaddress <= x"18";
          WHEN "0100" => nextaddress <= x"20";
          WHEN "0101" => nextaddress <= x"28";
          WHEN "0110" => nextaddress <= x"30";
          WHEN "0111" => nextaddress <= x"38";
          WHEN OTHERS => nextaddress <= x"FF";
        END CASE;
      WHEN FILL =>
        nextPlainKey(CONV_INTEGER(address)) <= RCV_DATA(0);   
        nextPlainKey(CONV_INTEGER(address + 1)) <= RCV_DATA(1);  
        nextPlainKey(CONV_INTEGER(address + 2)) <= RCV_DATA(2);  
        nextPlainKey(CONV_INTEGER(address + 3)) <= RCV_DATA(3);  
        nextPlainKey(CONV_INTEGER(address + 4)) <= RCV_DATA(4);  
        nextPlainKey(CONV_INTEGER(address + 5)) <= RCV_DATA(5);  
        nextPlainKey(CONV_INTEGER(address + 6)) <= RCV_DATA(6);  
        nextPlainKey(CONV_INTEGER(address + 7)) <= RCV_DATA(7);
        nextParityAccumulator <= parityAccumulator + RCV_DATA;             
        nextKeyCount <= keyCount + 1;
        CLR_RBUFF <= '1';
      WHEN RECEIVE =>
        CLR_RBUFF <= '0';
      WHEN CHECK_PARITY =>
      WHEN VALIDATE =>
        nextParityAccumulator <= parityAccumulator + RCV_DATA;
        CLR_RBUFF <= '1';
      WHEN MDE =>
        IF (parityAccumulator = x"FF") THEN
          nextParityError <= '0';
        ELSE
          nextParityError <= '1';
        END IF;
      WHEN IDLE =>
        nextKeyCount <= "0000";
        key_Error <= '1';
        prog_Error <= '0';
        clr_rbuff <= '0';
        nextPlainKey <= x"0000000000000000";
        nextParityAccumulator <= x"00";
    END CASE;
  END PROCESS OL;
END keyb;