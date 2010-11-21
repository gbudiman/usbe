-- $Id: $
-- File name:   rx_decode.vhd
-- Created:     11/4/2010
-- Author:      Brent O'Brien
-- Lab Section: 337-01
-- Version:     1.0  Initial Design Entry
-- Description: Host to Slave decoder


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

Entity rx_decode is
  port(
    CLK:in std_logic;
    RST:in std_logic;
    DP1_RX:in std_logic;
    SHIFT_ENABLE: in std_logic;
    EOP: in std_logic;
    D_ORIG: out std_logic;
    BITSTUFF: out std_logic
  );
end rx_decode;
architecture moore of rx_decode is
  type state_type is (ZERO, ONE, TWO, THREE, FOUR, FIVE, SIX, READ_STUFF);
  signal state, nextstate : state_type;
  signal DP_hold1, DP_hold2: std_logic;
  signal DP_hold1_nxt, DP_hold2_nxt: std_logic;
  begin
    holdReg : process(CLK, RST)
      BEGIN       
        if (RST = '1') then
          DP_hold1 <= '1';
          DP_hold2 <= '1';
          state <= ZERO;
        elsif(CLK'event and CLK = '1') then
          state <= nextstate;
          DP_hold1 <= DP_hold1_nxt;
          DP_hold2 <= DP_hold2_nxt;  
          if (EOP = '1') then
            DP_hold1 <= '1';
            DP_hold2 <= '1';
          end if;
          
        end if;
      end process holdReg;
      
      D_ORIG <= (DP_hold1 xnor DP_hold2);
      
    Next_State:process(state, SHIFT_ENABLE, DP1_RX, RST)
          Begin
            case state is
            when ZERO =>   
                            nextstate <= ZERO;
                            DP_hold1_nxt <= DP_hold1;
                            DP_hold2_nxt <= DP_hold2;
                          if ( SHIFT_ENABLE = '1') then
                            if DP1_RX = '1' then
                              nextstate <= ONE;
                            else
                              nextstate <= ZERO;
                            end if;
                            DP_hold1_nxt <= DP1_RX;
                            DP_hold2_nxt <= DP_hold1;
                          end if;
                          BITSTUFF <= '0';
            when ONE =>
                            nextstate <= ONE;
                            DP_hold1_nxt <= DP_hold1;
                            DP_hold2_nxt <= DP_hold2;
                          if ( SHIFT_ENABLE = '1') then
                            if DP1_RX = '1' then
                              nextstate <= TWO;
                            else
                              nextstate <= ZERO;
                            end if;
                            DP_hold1_nxt <= DP1_RX;
                            DP_hold2_nxt <= DP_hold1;
                          end if;
                          BITSTUFF <= '0';
            when TWO =>
                            nextstate <= TWO;
                            DP_hold1_nxt <=DP_hold1;
                            DP_hold2_nxt <= DP_hold2;
                          if ( SHIFT_ENABLE = '1') then
                            if DP1_RX = '1' then
                              nextstate <= THREE;
                            else
                              nextstate <= ZERO;
                            end if;
                            DP_hold1_nxt <= DP1_RX;
                            DP_hold2_nxt <= DP_hold1;
                          end if;
                          BITSTUFF <= '0'; 
            when THREE =>
                            nextstate <= THREE;
                            DP_hold1_nxt <= DP_hold1;
                            DP_hold2_nxt <= DP_hold2;
                          if ( SHIFT_ENABLE = '1') then
                            if DP1_RX = '1' then
                              nextstate <= FOUR;
                            else
                              nextstate <= ZERO;
                            end if;
                            DP_hold1_nxt <= DP1_RX;
                            DP_hold2_nxt <= DP_hold1;
                          end if;
                          bitstuff <= '0';
            when FOUR =>
                            nextstate <= FOUR;
                            DP_hold1_nxt <= DP_hold1;
                            DP_hold2_nxt <= DP_hold2;
                          if ( SHIFT_ENABLE = '1') then
                            if DP1_RX = '1' then
                              nextstate <= FIVE;
                            else
                              nextstate <= ZERO;
                            end if;
                            DP_hold1_nxt <= DP1_RX;
                            DP_hold2_nxt <= DP_hold1;
                          end if;
                          BITSTUFF <= '0';
            when FIVE =>
                            nextstate <= FIVE;
                            DP_hold1_nxt <= DP_hold1;
                            DP_hold2_nxt <= DP_hold2;
                          if ( SHIFT_ENABLE = '1') then
                            if DP1_RX = '1' then
                              nextstate <= SIX;
                            else
                              nextstate <= ZERO;
                            end if;
                            DP_hold1_nxt <= DP1_RX;
                            DP_hold2_nxt <= DP_hold1;
                          end if;
                          BITSTUFF <= '0';
            when SIX =>
                            nextstate <= SIX;
                            DP_hold1_nxt <= DP_hold1;
                            DP_hold2_nxt <= DP_hold2;
                          if ( SHIFT_ENABLE = '1') then
                            nextstate <= READ_STUFF;
                            DP_hold1_nxt <= DP_hold1;
                            DP_hold2_nxt <= DP_hold2;
                          end if;
                          BITSTUFF <= '0';
                          
            when READ_STUFF =>
                            nextstate <= READ_STUFF;
                            DP_hold1_nxt <= DP_hold1;
                            DP_hold2_nxt <= DP_hold2;
                          if ( SHIFT_ENABLE = '1') then
                            DP_hold1_nxt <= DP1_RX;
                            DP_hold2_nxt <= DP_hold1;
                            if (DP1_RX = '1') then
                              nextstate <= ONE;
                            else
                              nextstate <= ZERO;
                            end if;
                          end if;              
                          BITSTUFF <='1';
                          
                          
            when others =>  nextstate <= ZERO;
                            BITSTUFF <= '0';
                            DP_hold1_nxt <= '1';
                            DP_hold2_nxt <= '1';                                                                                                              
                                                   
  end case;
end process Next_State;
end architecture;