-- $Id: $
-- File name:   KSA
-- Created:     11/9/2010
-- Author:      Gloria Budiman
-- Lab Section: 337-02
-- Version:     1.0  Initial Design Entry
-- Description: KSA, permutation table generator.


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.numeric_std.ALL;

ENTITY KSA IS
  PORT(KEY: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    CLK, RST, KEY_ERROR: IN STD_LOGIC;
    BYTE_READY: IN STD_LOGIC;
    BYTE: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    OPCODE: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    --TABLE_READY: OUT STD_LOGIC;
    --OUT_TABLE: OUT STD_LOGIC_VECTOR(2047 DOWNTO 0));
    PROCESSED_DATA: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    PDATA_READY: OUT STD_LOGIC);
END KSA;

ARCHITECTURE bksa OF KSA IS
--function INT_TO_STD_LOGIC( X: INTEGER; NumBits: INTEGER )
--   return STD_LOGIC_VECTOR is
--  variable RES : STD_LOGIC_VECTOR(NumBits-1 downto 0);
--  variable tmp : INTEGER;
--begin
--  tmp := X;
--  for i in 0 to NumBits-1 loop
--    if (tmp mod 2)=1 then
--      res(i) := '1';
--    else
--      res(i) := '0';
--    end if;
--    tmp := tmp/2;
--  end loop;
--  return res;
--end;

  TYPE myState IS (IDLE, PREFILL, D_SWAP, D_SWAP_J, D_SWAP_X, D_SWAP_Y, DONE, PSTEPA, PSTEPB1, PSTEPB2, PSTEPC, PSTEPD, PWAIT, PASSTHROUGH, PTOUT, PACKETRESET);
  TYPE pArray IS ARRAY(0 TO 255) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL permuteTable, nextPermuteTable: pArray;
  TYPE kArray IS ARRAY(0 TO 7) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL keyTable: kArray;
  SIGNAL state, nextState: myState;
  SIGNAL prefillComplete, nextPrefillComplete: STD_LOGIC;
  SIGNAL permuteComplete, nextPermuteComplete: STD_LOGIC;
  SIGNAL si, sj, nextsi, nextsj: STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL inti, intj, nextinti, nextintj: STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL keyi, nextKeyi: STD_LOGIC_VECTOR(2 DOWNTO 0);
  SIGNAL temp, nextTemp: STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL xordata: STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL delaydata: STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL p_ready_flop: STD_LOGIC;
BEGIN
  TLB: PROCESS(CLK, RST, 
    nextState, nextsi, nextsj, nextinti, nextintj, nextTemp, nextPermuteComplete, nextPrefillComplete, 
    nextKeyi, nextPermuteTable, p_ready_flop)
  BEGIN
    IF (RST = '1') THEN
      state <= IDLE;
      si <= x"00";
      PDATA_READY <= '0';
    ELSIF (RISING_EDGE(CLK)) THEN
      state <= nextState;
      si <= nextsi;
      sj <= nextsj;
      inti <= nextinti;
      intj <= nextintj;
      keyi <= nextKeyi;
      permuteComplete <= nextPermuteComplete;
      prefillComplete <= nextPrefillComplete;
      temp <= nextTemp;
      permuteTable <= nextPermuteTable;
      PDATA_READY <= p_ready_flop;
    END IF;
  END PROCESS TLB;
  
  NSL: PROCESS(KEY_ERROR, state, permuteComplete, prefillComplete, BYTE_READY, OPCODE)
  BEGIN
    nextState <= state;
    CASE state IS
      WHEN IDLE =>
        IF (KEY_ERROR = '0') THEN
          nextState <= PREFILL;
        ELSE nextState <= IDLE;
        END IF;
      WHEN PREFILL =>
        IF (prefillComplete = '1') THEN
          nextState <= D_SWAP;
        ELSE nextState <= PREFILL;
        END IF;
      WHEN D_SWAP =>
        nextState <= D_SWAP_J;
      WHEN D_SWAP_J =>
        nextState <= D_SWAP_X;
      WHEN D_SWAP_X =>
        nextState <= D_SWAP_Y;
      WHEN D_SWAP_Y =>
        IF (permuteComplete = '1') THEN
          nextState <= DONE;
        ELSE
          nextState <= D_SWAP;
        END IF;
      WHEN DONE =>
        IF (KEY_ERROR = '1') THEN
          nextState <= IDLE;
        ELSIF (BYTE_READY = '1') THEN
          IF (OPCODE = "01") THEN
            nextState <= PSTEPA;
          ELSIF (OPCODE = "00") THEN
            nextState <= PASSTHROUGH;
          ELSIF (OPCODE = "11") THEN
            nextState <= PACKETRESET;
          ELSE
            nextState <= DONE;
          END IF;
        ELSE 
          nextState <= DONE;
        END IF;
      WHEN PSTEPA =>
        nextState <= PSTEPB1;
      WHEN PSTEPB1 =>
        nextState <= PSTEPB2;
      WHEN PSTEPB2 =>
        nextState <= PSTEPC;
      WHEN PSTEPC =>
        nextState <= PSTEPD;
      WHEN PSTEPD =>
        nextState <= PWAIT;
      WHEN PWAIT =>
        IF (KEY_ERROR = '1') THEN
          nextState <= IDLE;
        ELSIF (BYTE_READY = '1') THEN
          IF (OPCODE = "01") THEN
            nextState <= PSTEPA;
          ELSIF (OPCODE = "00") THEN
            nextState <= PASSTHROUGH;
          ELSIF (OPCODE = "11") THEN
            nextState <= PACKETRESET;
          ELSE
            nextState <= PWAIT;
          END IF;
        ELSE
          nextState <= PWAIT;
        END IF;
      WHEN PASSTHROUGH =>
        nextState <= PTOUT;
      WHEN PTOUT =>
        IF (KEY_ERROR = '1') THEN
          nextState <= IDLE;
        ELSIF (BYTE_READY = '1') THEN
          IF (OPCODE = "01") THEN
            nextState <= PSTEPA;
          ELSIF (OPCODE = "00") THEN
            nextState <= PASSTHROUGH;
          ELSIF (OPCODE = "11") THEN
            nextState <= PACKETRESET;
          ELSE
            nextState <= PTOUT;
          END IF;
        ELSE
          nextState <= PTOUT;
        END IF;
      WHEN PACKETRESET =>
        IF (KEY_ERROR = '1') THEN
          nextState <= IDLE;
        ELSIF (BYTE_READY = '1') THEN
          IF (OPCODE = "01") THEN
            nextState <= PSTEPA;
          ELSIF (OPCODE = "00") THEN
            nextState <= PASSTHROUGH;
          ELSIF (OPCODE = "11") THEN
            nextState <= PACKETRESET;
          ELSE
            nextState <= PACKETRESET;
          END IF;
        ELSE
          nextState <= PACKETRESET;
        END IF;
      WHEN OTHERS =>
        nextState <= IDLE;
    END CASE;
  END PROCESS NSL;
  
  OL: PROCESS(state, keyTable, permuteTable, 
    si, sj, key, keyi, nextsi, nextsj, temp, inti, intj, 
    xordata, delaydata, BYTE, prefillComplete, permuteComplete)
  BEGIN         
    nextsi <= si; 
    nextinti <= inti;
    nextintj <= intj;
    --PDATA_READY <= '0';
    p_ready_flop <= '0';
    delaydata <= delaydata;
    xordata <= xordata;
    nextkeyi <= keyi;
    nextsj <= sj;
    nextPermuteComplete <= permuteComplete;
    nextPrefillComplete <= prefillComplete;
    nextPermuteTable <= permuteTable;
    keyTable <= keyTable;
    nextTemp <= temp;
    nextKeyI <= keyi;
    CASE state IS
      WHEN IDLE => -- state 0
        nextPrefillComplete <= '0';
        nextPermuteComplete <= '0';
        --TABLE_READY <= '0';
        --PDATA_READY <= '0';
        --for i in 0 to 2047 loop
        --  OUT_TABLE(i) <= '0';
        --end loop;
      WHEN PREFILL => -- state 1
        for i in 0 to 255 loop
          --pArray(i) <= INT_TO_STD_LOGIC_VECTOR(i, 8);
          nextPermuteTable(i) <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, 8));
        end loop;
        
        for i in 0 to 7 loop
          keyTable(i)(0) <= key(i * 8);
          keyTable(i)(1) <= key(i * 8 + 1);
          keyTable(i)(2) <= key(i * 8 + 2);
          keyTable(i)(3) <= key(i * 8 + 3);
          keyTable(i)(4) <= key(i * 8 + 4);
          keyTable(i)(5) <= key(i * 8 + 5);
          keyTable(i)(6) <= key(i * 8 + 6);
          keyTable(i)(7) <= key(i * 8 + 7);
        end loop;
        nextsj <= x"00";
        nextPrefillComplete <= '1';
      WHEN D_SWAP => -- state 2
        IF (si + 1 = x"00") THEN
          nextsi <= x"00";
          nextPermuteComplete <= '1';
        ELSE
          nextsi <= si + 1;
        END IF;
        nextKeyi(2) <= si(2);
        nextKeyi(1) <= si(1);
        nextKeyi(0) <= si(0);
      WHEN D_SWAP_J => -- state 3
        nextTemp <= permuteTable(CONV_INTEGER(si - 1));
        nextsj <= sj + permuteTable(CONV_INTEGER(si - 1)) + keyTable(CONV_INTEGER(keyi));
      WHEN D_SWAP_X => -- state 4
        nextPermuteTable(CONV_INTEGER(si - 1)) <= permuteTable(CONV_INTEGER(sj));
      WHEN D_SWAP_Y => -- state 5
        nextPermuteTable(CONV_INTEGER(sj)) <= temp;
      WHEN DONE => -- state 6
        nextinti <= x"00";
        nextintj <= x"00";
        nextsi <= x"00";
        nextsj <= x"00";
        --for i in 0 to 255 loop
--          OUT_TABLE(i * 8) <= permuteTable(i)(0);
--          OUT_TABLE(i * 8 + 1) <= permuteTable(i)(1);
--          OUT_TABLE(i * 8 + 2) <= permuteTable(i)(2);
--          OUT_TABLE(i * 8 + 3) <= permuteTable(i)(3);
--          OUT_TABLE(i * 8 + 4) <= permuteTable(i)(4);
--          OUT_TABLE(i * 8 + 5) <= permuteTable(i)(5);
--          OUT_TABLE(i * 8 + 6) <= permuteTable(i)(6);
--          OUT_TABLE(i * 8 + 7) <= permuteTable(i)(7);
--        end loop;
--        TABLE_READY <= '1';
      WHEN PSTEPA =>
        nextinti <= inti + 1;
        nextintj <= intj + permuteTable(CONV_INTEGER(inti + 1));
        nextTemp <= permuteTable(CONV_INTEGER(inti + 1));
        delaydata <= BYTE;
      WHEN PSTEPB1 =>
        nextPermuteTable(CONV_INTEGER(inti)) <= permuteTable(CONV_INTEGER(intj));
      WHEN PSTEPB2 =>
        nextPermuteTable(CONV_INTEGER(intj)) <= temp;
      WHEN PSTEPC =>
        nextTemp <= permuteTable(CONV_INTEGER(inti)) + permuteTable(CONV_INTEGER(intj));
      WHEN PSTEPD =>
        xordata <= permuteTable(CONV_INTEGER(temp));
        PROCESSED_DATA <= permuteTable(CONV_INTEGER(temp)) XOR delaydata;
        --PDATA_READY <= '1';
        p_ready_flop <= '1';
      WHEN PWAIT =>
        --PROCESSED_DATA <= xordata XOR delaydata;
        --PDATA_READY <= '1';
      WHEN PASSTHROUGH =>
        delaydata <= BYTE;
        --PDATA_READY <= '1';
        p_ready_flop <= '1';
      WHEN PTOUT =>
        PROCESSED_DATA <= delaydata; 
        --PDATA_READY <= '1';
      WHEN PACKETRESET =>
        --nextinti <= x"00";
        --nextintj <= x"00";
    END CASE;
  END PROCESS OL;
END bksa;