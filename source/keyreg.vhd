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
    KEY_ERROR, PROG_ERROR, SIG_TRUNCATED, CLR_RBUFF: OUT STD_LOGIC);
END keyreg;

ARCHITECTURE keyb OF keyreg IS
  TYPE keyState IS (IDLE, FILL, RECEIVE, ERROR, GOOD, TRUNCATED);
  SIGNAL state, nextState: keyState;
  SIGNAL keyCount, nextKeyCount: STD_LOGIC_VECTOR(3 DOWNTO 0);
BEGIN
  keyp: PROCESS(CLK, RST, nextState)
  BEGIN
    IF (RST = '1') THEN
      state <= IDLE;
    ELSIF (RISING_EDGE(CLK)) THEN
      state <= nextState;
      keyCount <= nextKeyCount;
    END IF;
  END PROCESS keyp;
  
  NSL: PROCESS(state, OE, SBE, RBUF_FULL, keyCount, RCV_DATA)
  BEGIN
  nextState <= state;
  CASE STATE IS
    WHEN IDLE =>
      IF RBUF_FULL = '1' THEN nextState <= FILL;
      ELSE nextState <= IDLE;
      END IF;
    WHEN FILL =>
      IF keyCount = 7 THEN
        nextState <= GOOD;
      ELSE
        nextState <= RECEIVE;
      END IF;
    WHEN RECEIVE =>
      IF SBE = '1' OR OE ='1' THEN nextState <= ERROR;
      ELSIF keyCount < 8 AND RBUF_FULL = '1' THEN nextState <= FILL;
      END IF;
    WHEN GOOD =>
      IF RBUF_FULL = '1' THEN nextState <= TRUNCATED;
      ELSE nextState <= GOOD;
      END IF;
    WHEN OTHERS =>
    END CASE;
  END PROCESS NSL;
    
  OL: PROCESS(state, keyCount)
    VARIABLE address: INTEGER;
  BEGIN
    nextKeyCount <= keyCount;
    key_Error <= '1';
    prog_Error <= '0';
    clr_rbuff <= '0';
    sig_truncated <= '0';
    CASE STATE IS
      WHEN ERROR => PROG_ERROR <= '1';
      WHEN TRUNCATED => SIG_TRUNCATED <= '1';
      WHEN GOOD => KEY_ERROR <= '0';
      WHEN FILL =>
        CASE keyCount IS
          --WHEN "0000" => address <= x"00";
--          WHEN "0001" => address <= x"08";
--          WHEN "0010" => address <= x"10";
--          WHEN "0011" => address <= x"18";
--          WHEN "0100" => address <= x"20";
--          WHEN "0101" => address <= x"28";
--          WHEN "0110" => address <= x"30";
--          WHEN "0111" => address <= x"38";
          WHEN "0000" => address := 0;
          WHEN "0001" => address := 8;
          WHEN "0010" => address := 16;
          WHEN "0011" => address := 24;
          WHEN "0100" => address := 32;
          WHEN "0101" => address := 40;
          WHEN "0110" => address := 48;
          WHEN "0111" => address := 56;
          WHEN OTHERS => address := 0;
        END CASE;
          
        PLAINKEY(address) <= RCV_DATA(0);   
        PLAINKEY(address + 1) <= RCV_DATA(1);  
        PLAINKEY(address + 2) <= RCV_DATA(2);  
        PLAINKEY(address + 3) <= RCV_DATA(3);  
        PLAINKEY(address + 4) <= RCV_DATA(4);  
        PLAINKEY(address + 5) <= RCV_DATA(5);  
        PLAINKEY(address + 6) <= RCV_DATA(6);  
        PLAINKEY(address + 7) <= RCV_DATA(7);             
        nextKeyCount <= keyCount + 1;
        CLR_RBUFF <= '1';
      WHEN RECEIVE =>
        CLR_RBUFF <= '0';
      WHEN IDLE =>
        nextKeyCount <= "0000";
        key_Error <= '1';
        prog_Error <= '0';
        clr_rbuff <= '0';
        sig_truncated <= '0';
        PLAINKEY <= x"0000000000000000";
    END CASE;
  END PROCESS OL;
END keyb;