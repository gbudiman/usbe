-- $Id: $
-- File name:   timer.vhd
-- Created:     9/21/2010
-- Author:      Gloria Budiman
-- Lab Section: 337-02
-- Version:     1.0  Initial Design Entry
-- Description: Timer module for UART.


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY uart_timer IS
	PORT(CLK, RST, TIMER_TRIG: IN STD_LOGIC;
		STOP_RCVING, SHIFT_STROBE: OUT STD_LOGIC);
END uart_timer;

ARCHITECTURE timerB OF uart_timer IS
	SIGNAL state, nextState: STD_LOGIC_VECTOR (7 DOWNTO 0);
BEGIN
	sReg: PROCESS(CLK, RST, nextState, TIMER_TRIG)
	BEGIN
		IF (RST = '1') THEN
			STOP_RCVING <= '0';
			state <= "00000000";
			nextState <= "00000000";
		ELSIF (RISING_EDGE(CLK)) THEN
			IF (CONV_INTEGER(nextState) = 109) THEN
			  STOP_RCVING <= '1';
			ELSE
			  STOP_RCVING <= '0';
			END IF;
			
			IF (CONV_INTEGER(nextState) = 109) THEN
			  nextState <= "00000000";
			ELSIF TIMER_TRIG = '1' THEN
			  nextState <= nextState + 1;
			ELSE
			  nextState <= nextState;
			END IF;
			state <= nextState;
		END IF;
	END PROCESS sReg;
	

	outReg: PROCESS(state, nextState, clk)
	BEGIN
	  SHIFT_STROBE <= '0';
		-- Generate a 1 pulse-clock at the middle
		-- of byte-receive
		IF CONV_INTEGER(state) = 2 OR
		      CONV_INTEGER(state) = 12 OR
		      CONV_INTEGER(state) = 22 OR
		      CONV_INTEGER(state) = 32 OR
		      CONV_INTEGER(state) = 42 OR
		      CONV_INTEGER(state) = 52 OR
		      CONV_INTEGER(state) = 62 OR
		      CONV_INTEGER(state) = 72 OR
		      CONV_INTEGER(state) = 82 OR
		      CONV_INTEGER(state) = 92 OR
		      CONV_INTEGER(state) = 102 THEN
		      SHIFT_STROBE <= '1';
		ELSIF CONV_INTEGER(state) = 3 OR
		      CONV_INTEGER(state) = 13 OR
		      CONV_INTEGER(state) = 23 OR
		      CONV_INTEGER(state) = 33 OR
		      CONV_INTEGER(state) = 43 OR
		      CONV_INTEGER(state) = 53 OR
		      CONV_INTEGER(state) = 63 OR
		      CONV_INTEGER(state) = 73 OR
		      CONV_INTEGER(state) = 83 OR
		      CONV_INTEGER(state) = 93 OR
		      CONV_INTEGER(state) = 103 THEN
		      SHIFT_STROBE <= '0';
		END IF;
		
	END PROCESS outReg;
END timerB;
