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
    DATA_IN: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    PROCESSED_DATA: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    PDATA_READY: OUT STD_LOGIC;
    W_ENABLE, R_ENABLE: OUT STD_LOGIC;
    ADDR, DATA: OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
END KSA;

ARCHITECTURE bksa OF KSA IS
  TYPE myState IS (IDLE, PREFILL, PREFILL_WAIT, D_SWAP, D_SWAP_J, D_SWAP_J_P, D_SWAP_J_Q, D_SWAP_X, D_SWAP_X_P, D_SWAP_X_Q, D_SWAP_Y, D_SWAP_Y_P, DONE, PSTEPA, PSTEPA_P, PSTEPB1, PSTEPB1_P, PSTEPB1_Q, PSTEPB1_R, PSTEPB2, PSTEPB2_P, PSTEPC, PSTEPC_Q, PSTEPC_R, PSTEPD_P, PWAIT, PASSTHROUGH, PTOUT, PACKETRESET);
  --TYPE pArray IS ARRAY(0 TO 255) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
  --SIGNAL permuteTable, nextPermuteTable: pArray;
  TYPE kArray IS ARRAY(0 TO 7) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL keyTable, nextKeyTable: kArray;
  SIGNAL state, nextState: myState;
  SIGNAL prefillComplete, nextPrefillComplete: STD_LOGIC;
  SIGNAL permuteComplete, nextPermuteComplete: STD_LOGIC;
  SIGNAL si, sj, nextsi, nextsj: STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL inti, intj, nextinti, nextintj: STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL keyi, nextKeyi: STD_LOGIC_VECTOR(2 DOWNTO 0);
  SIGNAL temp, nextTemp: STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL extratemp, nextExtraTemp: STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL xordata: STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL delaydata, nextDelayData: STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL p_ready_flop: STD_LOGIC;
  SIGNAL currentProcessedData, nextProcessedData: STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL prefillCounter, nextPrefillCounter: STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL fw_enable, fr_enable, nfw_enable, nfr_enable: STD_LOGIC;
  SIGNAL faddr, fdata, nfaddr, nfdata: STD_LOGIC_VECTOR(7 DOWNTO 0);
BEGIN
  TLB: PROCESS(CLK, RST, 
    nextState, nextsi, nextsj, nextinti, nextintj, nextTemp, nextExtraTemp, nextPermuteComplete, nextPrefillComplete, 
    nextKeyi, p_ready_flop, nextProcessedData, nextKeyTable, nextDelayData, nextPrefillCounter,
    nfaddr, nfdata, nfw_enable, nfr_enable)
  BEGIN
    IF (RST = '1') THEN
      state <= IDLE;
      si <= x"00";
      sj <= x"00";
      PDATA_READY <= '0';
      currentProcessedData <= x"00";
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
      extraTemp <= nextExtraTemp;
      --permuteTable <= nextPermuteTable;
      PDATA_READY <= p_ready_flop;
      PROCESSED_DATA <= nextProcessedData;
      currentProcessedData <= nextProcessedData;
      keyTable <= nextKeyTable;
      delayData <= nextDelayData;
      prefillCounter <= nextPrefillCounter;
      faddr <= nfaddr;
      fdata <= nfdata;
      fw_enable <= nfw_enable;
      fr_enable <= nfr_enable;
      W_ENABLE <= nfw_enable;
      R_ENABLE <= nfr_enable;
      DATA <= nfdata;
      fdata <= nfdata;
      ADDR <= nfaddr;
      faddr <= nfaddr;
    END IF;
  END PROCESS TLB;
  
  NSL: PROCESS(KEY_ERROR, state, permuteComplete, prefillComplete, prefillCounter, BYTE_READY, OPCODE)
  BEGIN
    nextState <= state;
    nextPrefillComplete <= prefillComplete;
    CASE state IS
      WHEN IDLE =>
        nextPrefillComplete <= '0';
        IF (KEY_ERROR = '0') THEN
          nextState <= PREFILL;
        ELSE nextState <= IDLE;
        END IF;
      WHEN PREFILL =>
        nextState <= PREFILL_WAIT;
      WHEN PREFILL_WAIT =>
        IF (prefillCounter = x"00") THEN
          nextPrefillComplete <= '1';
          nextState <= D_SWAP;
        ELSE
          nextState <= PREFILL;
        END IF;
      WHEN D_SWAP =>
        nextState <= D_SWAP_J;
      WHEN D_SWAP_J =>
        nextState <= D_SWAP_J_P;
      WHEN D_SWAP_J_P =>
        nextState <= D_SWAP_J_Q;
      WHEN D_SWAP_J_Q =>
        nextState <= D_SWAP_X;
      WHEN D_SWAP_X =>
        nextState <= D_SWAP_X_P;
      WHEN D_SWAP_X_P =>
        nextState <= D_SWAP_X_Q;
      WHEN D_SWAP_X_Q =>
        nextState <= D_SWAP_Y;
      WHEN D_SWAP_Y =>
        nextState <= D_SWAP_Y_P;
      WHEN D_SWAP_Y_P =>
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
        nextState <= PSTEPA_P;
      WHEN PSTEPA_P =>
        nextState <= PSTEPB1;
      WHEN PSTEPB1 =>
        nextState <= PSTEPB1_P;
      WHEN PSTEPB1_P =>
        nextState <= PSTEPB1_Q;
      WHEN PSTEPB1_Q =>
        nextState <= PSTEPB1_R;
      WHEN PSTEPB1_R =>
        nextState <= PSTEPB2;
      WHEN PSTEPB2 =>
        nextState <= PSTEPB2_P;
      WHEN PSTEPB2_P =>
        nextState <= PSTEPC;
      WHEN PSTEPC =>
        nextState <= PSTEPC_Q;
      WHEN PSTEPC_Q =>
        nextState <= PSTEPC_R;
      WHEN PSTEPC_R =>
        nextState <= PSTEPD_P;
      WHEN PSTEPD_P =>
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
    END CASE;
  END PROCESS NSL;
  
  OL: PROCESS(state, keyTable, prefillCounter, DATA_IN, extraTemp,
    si, sj, key, keyi, nextsi, nextsj, temp, inti, intj, fr_enable, fw_enable, fdata, faddr,
    xordata, delaydata, BYTE, permuteComplete, currentProcessedData)
  BEGIN         
    nextsi <= si; 
    nextinti <= inti;
    nextintj <= intj;
    --PDATA_READY <= '0';
    p_ready_flop <= '0';
    nextDelaydata <= delaydata;
    xordata <= xordata;
    nextkeyi <= keyi;
    nextsj <= sj;
    nextPermuteComplete <= permuteComplete;
    --nextPermuteTable <= permuteTable;
    nextKeyTable <= keyTable;
    nextTemp <= temp;
    nextExtraTemp <= extraTemp;
    nextKeyI <= keyi;
    nextProcessedData <= currentProcessedData;
    nextPrefillCounter <= prefillCounter;
    nfdata <= fdata;
    nfaddr <= faddr;
    nfr_enable <= fr_enable;
    nfw_enable <= fw_enable;
    CASE state IS
      WHEN IDLE => -- state 0
        nextPermuteComplete <= '0';
        nextPrefillCounter <= x"00";
        nfr_enable <= '0';
        nfw_enable <= '0';
      WHEN PREFILL => -- state 1
        nfw_enable <= '1';
        nfaddr <= prefillCounter;
        nfdata <= prefillCounter;
        nextPrefillCounter <= prefillCounter + 1;
        --for i in 0 to 255 loop
--          nextPermuteTable(i) <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, 8));
--        end loop;
--        
        for i in 0 to 7 loop
          nextKeyTable(i)(0) <= key(i * 8);
          nextKeyTable(i)(1) <= key(i * 8 + 1);
          nextKeyTable(i)(2) <= key(i * 8 + 2);
          nextKeyTable(i)(3) <= key(i * 8 + 3);
          nextKeyTable(i)(4) <= key(i * 8 + 4);
          nextKeyTable(i)(5) <= key(i * 8 + 5);
          nextKeyTable(i)(6) <= key(i * 8 + 6);
          nextKeyTable(i)(7) <= key(i * 8 + 7);
        end loop;
--        nextsj <= x"00";
--        nextPrefillComplete <= '1';
      WHEN PREFILL_WAIT =>
        nfw_enable <= '0';
        nfdata <= "ZZZZZZZZ";
        nfaddr <= "ZZZZZZZZ";
      WHEN D_SWAP => -- state 2
        IF (si = x"FF") THEN
          nextsi <= x"00";
          nextPermuteComplete <= '1';
        ELSE
          nextsi <= si + 1;
        END IF;
        nextKeyi(2) <= si(2);
        nextKeyi(1) <= si(1);
        nextKeyi(0) <= si(0);
      WHEN D_SWAP_J =>
        nfr_enable <= '1';
        nfaddr <= si - 1;
      WHEN D_SWAP_J_P => -- state 3
      WHEN D_SWAP_J_Q =>
        nfr_enable <= '0';
        nfaddr <= "ZZZZZZZZ";
        nextTemp <= DATA_IN;
        nextSJ <= sj + DATA_IN + keyTable(CONV_INTEGER(keyi));
        --nextTemp <= permuteTable(CONV_INTEGER(si - 1));
        --nextsj <= sj + permuteTable(CONV_INTEGER(si - 1)) + keyTable(CONV_INTEGER(keyi));
      WHEN D_SWAP_X =>
        nfr_enable <= '1';
        nfaddr <= sj;
      WHEN D_SWAP_X_P => -- state 4
        nfr_enable <= '0';
        nfw_enable <= '1';
        nfdata <= DATA_IN;
        nfaddr <= si - 1;
        --nextPermuteTable(CONV_INTEGER(si - 1)) <= permuteTable(CONV_INTEGER(sj));
      WHEN D_SWAP_X_Q =>
        nfw_enable <= '0';
        nfaddr <= "ZZZZZZZZ";
      WHEN D_SWAP_Y => -- state 5
        nfw_enable <= '1';
        nfaddr <= sj;
        nfdata <= temp;
      WHEN D_SWAP_Y_P =>
        nfw_enable <= '0';
        nfaddr <= "ZZZZZZZZ";
        --nextPermuteTable(CONV_INTEGER(sj)) <= temp;
      WHEN DONE => -- state 6
        nextinti <= x"00";
        nextintj <= x"00";
        nextsi <= x"00";
        nextsj <= x"00";
      WHEN PSTEPA =>
        nextinti <= inti + 1;
        nfr_enable <= '1';    -- READ!
        nfaddr <= inti + 1;
      WHEN PSTEPA_P =>
        nfr_enable <= '0';
        nfaddr <= "ZZZZZZZZ";
        nextintj <= intj + DATA_IN; -- j = j + S(i)
        nextTemp <= DATA_IN;
        --nextintj <= intj + permuteTable(CONV_INTEGER(inti + 1));
        --nextTemp <= permuteTable(CONV_INTEGER(inti + 1));
        nextDelaydata <= BYTE;
      WHEN PSTEPB1 =>
        nfr_enable <= '1';    -- READ!
        nfaddr <= intj;
      WHEN PSTEPB1_P =>
        nfr_enable <= '0';
        nfaddr <= "ZZZZZZZZ";
        nextTemp <= DATA_IN;
        --nfw_enable <= '1';
        --nfaddr <= inti;
        --nfdata <= DATA_IN;
        --nextPermuteTable(CONV_INTEGER(inti)) <= permuteTable(CONV_INTEGER(intj));
      WHEN PSTEPB1_Q =>
        nfr_enable <= '1';
        nfaddr <= inti;
        --nfw_enable <= '0';
        --nfr_enable <= '1';
        --nfaddr <= intj;
        --nfdata <= temp;
      WHEN PSTEPB1_R =>
        nfr_enable <= '0';
        nfw_enable <= '1';
        nextExtraTemp <= DATA_IN;
        nfdata <= temp;
        nfaddr <= inti;
      WHEN PSTEPB2 =>
        nfw_enable <= '0';
        nfaddr <= "ZZZZZZZZ";
        --nextPermuteTable(CONV_INTEGER(intj)) <= temp;
      WHEN PSTEPB2_P =>
        nfw_enable <= '1';
        nfaddr <= intj;
        nfdata <= extratemp;
      WHEN PSTEPC =>
        nfw_enable <= '0';
        nfaddr <= "ZZZZZZZZ";
        nextTemp <= temp + extraTemp;
      WHEN PSTEPC_Q =>
        nfr_enable <= '1';
        nfaddr <= temp;
      WHEN PSTEPC_R =>
        nfr_enable <= '0';
        nfaddr <= "ZZZZZZZZ";
        nextTemp <= DATA_IN;
      WHEN PSTEPD_P =>
        nextProcessedData <= temp XOR delaydata;
        --xordata <= permuteTable(CONV_INTEGER(temp));
        --nextProcessedData <= permuteTable(CONV_INTEGER(temp)) XOR delaydata;
        p_ready_flop <= '1';
      WHEN PWAIT =>
      WHEN PASSTHROUGH =>
        nextProcessedData <= BYTE;
        p_ready_flop <= '1';
      WHEN PTOUT =>
      WHEN PACKETRESET =>
    END CASE;
  END PROCESS OL;
END bksa;