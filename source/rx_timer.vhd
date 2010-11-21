-- $Id: $
-- File name:   rx_timer.vhd
-- Created:     11/11/2010
-- Author:      Brent O'Brien
-- Lab Section: 337-01
-- Version:     1.0  Initial Design Entry
-- Description: Timer for the receiver portions of the device


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

Entity rx_timer is
  port(
    CLK:in std_logic;
    RST:in std_logic;
    D_EDGE:in std_logic;
    RCVING:in std_logic;
    SHIFT_ENABLE:out std_logic
  );
end rx_timer;

architecture moore of rx_timer is
  type state_type is (IDLE, RUNNING);
    signal state, nextstate : state_type;
    signal count, nextcount : STD_LOGIC_VECTOR(3 downto 0);
    begin
    StateReg : process(CLK, RST)
      begin
        if (RST = '1') then
          count <= "0000";
          state <= IDLE;
        elsif(CLK'event and CLK = '1') then
          count <= nextcount;
          state <= nextstate;
        end if;
      end process StateReg;
      
      Next_State:process(state, count, RCVING, D_EDGE)
        Begin
          SHIFT_ENABLE <= '0';
          case state is
          when IDLE => 
                          if RCVING = '1' then
                            nextstate <= RUNNING;
                            SHIFT_ENABLE <= '0';
                            nextcount <= "0101";
                          else
                            nextstate <= IDLE;
                            SHIFT_ENABLE <= '0';
                            nextcount <= "0001";
                          end if;
                          
          when RUNNING => 
                          if RCVING = '0' then
                            nextstate <= IDLE;
                            SHIFT_ENABLE <= '0';
                            nextcount <= "0000";
                          elsif D_EDGE = '1' then
                            nextstate <= RUNNING;
                            SHIFT_ENABLE <= '0';
                            nextcount <= "0101";
                          elsif count = "1000" then
                            nextstate <= RUNNING;
                            SHIFT_ENABLE <= '1';
                            nextcount <= "0001";
                          else
                            nextstate <= RUNNING;
                            SHIFT_ENABLE <= '0';
                            nextcount <= count + 1;
                          end if;    
                                                                      
                        
          when others =>
                          nextstate <= IDLE;
                          nextcount <= "0000";
                          SHIFT_ENABLE <= '0';
    end case;
  end process Next_State;
end architecture;            