-- $Id: $
-- File name:   tx_timer.vhd
-- Created:     11/21/2010
-- Author:      Michael Kelton
-- Lab Section: 337-01
-- Version:     1.0  Initial Design Entry
-- Description: This is the timer for the Transmitter portion of the USB encryption.

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

Entity tx_timer is
  port(
    CLK:in std_logic;
    RST:in std_logic;
    SENDING:in std_logic;
    SHIFT_ENABLE_R:out std_logic;
    SHIFT_ENABLE_E:out std_logic
  );
end tx_timer;

architecture moore of tx_timer is
  type state_type is (IDLE, RUNNING);
    signal state, nextstate : state_type;
    signal count, nextcount : STD_LOGIC_VECTOR(3 downto 0);
    signal nxt_SHIFT_ENABLE_E : std_logic;
    
    begin
    StateReg : process(CLK, RST)
      begin
        if (RST = '1') then
          count <= "0000";
          state <= IDLE;
        elsif(CLK'event and CLK = '1') then
          count <= nextcount;
          state <= nextstate;
          SHIFT_ENABLE_E <= nxt_SHIFT_ENABLE_E;
        end if;
      end process StateReg;
      
      Next_State:process(state, count, SENDING)
        Begin
          SHIFT_ENABLE_R <= '0';
          case state is
          when IDLE => 
                          if SENDING = '1' then
                            nextstate <= RUNNING;
                            SHIFT_ENABLE_R <= '0';
                            nxt_SHIFT_ENABLE_E <= '0';
                            nextcount <= "0101";
                          else
                            nextstate <= IDLE;
                            SHIFT_ENABLE_R <= '0';
                            nxt_SHIFT_ENABLE_E <= '0';
                            nextcount <= "0001";
                          end if;
                          
          when RUNNING => 
                          if SENDING = '0' then
                            nextstate <= IDLE;
                            SHIFT_ENABLE_R <= '0';
                            nxt_SHIFT_ENABLE_E <= '0';
                            nextcount <= "0000";
                          elsif count = "1000" then
                            nextstate <= RUNNING;
                            SHIFT_ENABLE_R <= '1';
                            nxt_SHIFT_ENABLE_E <= '1';
                            nextcount <= "0001";
                          else
                            nextstate <= RUNNING;
                            SHIFT_ENABLE_R <= '0';
                            nxt_SHIFT_ENABLE_E <= '0';
                            nextcount <= count + 1;
                          end if;    
                                                                      
                        
          when others =>
                          nextstate <= IDLE;
                          nextcount <= "0000";
                          SHIFT_ENABLE_R <= '0';
                          nxt_SHIFT_ENABLE_E <= '0';
    end case;
  end process Next_State;
end architecture;            
