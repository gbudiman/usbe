-- $Id: $
-- File name:   rcu.vhd
-- Created:     9/21/2010
-- Author:      Gloria Budiman
-- Lab Section: 337-02
-- Version:     1.0  Initial Design Entry
-- Description: Receiver Control Unit for UART.


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.std_logic_arith.ALL;

ENTITY uart_rcu IS
	PORT(CLK, RST, START_BIT, STOP_RCVING, SB_DETECT: IN STD_LOGIC;
		RBUF_LOAD, TIMER_TRIG, CHK_ERROR, SET_RBUF_FULL, SBC_EN, SBC_CLR: OUT STD_LOGIC);
END uart_rcu;

ARCHITECTURE rcub OF uart_rcu IS
  TYPE myState IS (IDLE, CAPTURE, DETECT_SB, DETECT_WAIT, OVERRUN, C1, C2, C3);
  SIGNAL state, nextState: myState;
  SIGNAL count, nextCount: STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL timerRunning: STD_LOGIC;
BEGIN
  --nextCount <= count + 1 WHEN timerRunning = '1' ELSE "00000000";
  
  -- RCU's register
  sReg: PROCESS(CLK, RST, timerRunning, nextState)
  BEGIN
    IF RST = '1' THEN
      TIMER_TRIG <= '0';
      CHK_ERROR <= '0';
      SET_RBUF_FULL <= '0';
      SBC_EN <= '0';
      SBC_CLR <= '0';
      RBUF_LOAD <= '0';
      state <= IDLE;
      timerRunning <= '0';
      count <= "00000000";
      nextCount <= "00000001";
    ELSIF (RISING_EDGE(CLK)) THEN
      state <= nextState;
      count <= nextCount;
      IF timerRunning = '1' THEN
        nextCount <= count + 2;
      ELSE
        nextCount <= "00000001";
      END IF;
      
      IF nextState = CAPTURE THEN
        timerRunning <= '1';
        timer_trig <= '1';
        RBUF_LOAD <= '0';
        SET_RBUF_FULL <= '0';
        CHK_ERROR <= '0';
        SBC_CLR <= '1';
      ELSIF nextState = DETECT_SB THEN
        timerRunning <= '0';
        timer_trig <= '0';
        SBC_EN <= '1'; 
        SBC_CLR <= '0';     
      ELSIF nextState = C1 THEN
        --SET_RBUF_FULL <= '1';
        --RBUF_LOAD <= '1';
        CHK_ERROR <= '1';
        SBC_EN <= '0';
      ELSIF nextState = C2 THEN
        RBUF_LOAD <= '1';
      ELSIF nextState = C3 THEN
        SET_RBUF_FULL <= '1';
      ELSIF nextState = OVERRUN THEN
        SET_RBUF_FULL <= '1';
        --RBUF_LOAD <= '1';
        CHK_ERROR <= '1';
        SBC_EN <= '0';
      ELSIF nextState = IDLE THEN
        rbuf_load <= '0';
        timer_trig <= '0';
        chk_error <= '0';
        set_rbuf_full <= '0';
        sbc_en <= '0';
        sbc_clr <= '0';
      ELSE
        timerRunning <= '0';
      END IF;
    END IF;
  END PROCESS sReg;
  
  -- Next State Logic
  NSL: PROCESS(count, state, start_bit, sb_detect)
  BEGIN
    CASE state IS
    WHEN IDLE =>
      IF (start_bit = '1') THEN
        nextState <= CAPTURE;
      ELSE
        nextState <= IDLE;
      END IF;
    WHEN CAPTURE =>
      IF CONV_INTEGER(count) > 108 THEN
        nextState <= DETECT_SB;
      ELSE
        nextState <= CAPTURE;
      END IF;
    WHEN DETECT_SB =>
      nextState <= DETECT_WAIT;
    WHEN DETECT_WAIT =>
      IF sb_detect = '1' THEN
        nextState <= C1;
      ELSE
        nextState <= OVERRUN;
      END IF;
    WHEN OVERRUN =>
      nextState <= IDLE;
    WHEN C1 =>
      nextState <= C2;
    WHEN C2 =>
      nextState <= C3;
    WHEN C3 =>
      nextState <= IDLE;
    WHEN OTHERS =>
      nextState <= IDLE;
    END CASE;
  END PROCESS NSL;
  
  -- Process logic
--  pLogic: PROCESS(clk, state)
--  BEGIN
--    IF RISING_EDGE(clk) THEN
--      CASE state IS
--      WHEN IDLE =>
--        chk_error <= '0';
--        set_rbuf_full <= '0';
--        rbuf_load <= '0';
--        sbc_en <= '0';
--      WHEN CAPTURE =>
--        timerRunning <= '1';
--        timer_trig <= '1';
--      WHEN DETECT_SB =>
--        timer_trig <= '0';
--        timerRunning <= '0';
--        sbc_en <= '1';
--      WHEN DETECT_WAIT =>
--        sbc_en <= '0';
--      WHEN OVERRUN =>
--        chk_error <= '1';
--        set_rbuf_full <= '1';
--      WHEN COMPLETE =>
--        set_rbuf_full <= '1';
--        rbuf_load <= '1';
--      WHEN OTHERS =>
--        chk_error <= '0';
--        sbc_en <= '0';
--        rbuf_load <= '0';
--        set_rbuf_full <= '0';
--        timer_trig <= '0';
--        sbc_clr <= '0';
--        timerRunning <= '0';
--      END CASE;
--    END IF;
--  END PROCESS pLogic;
  
END rcub;
