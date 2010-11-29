-- $Id: $
-- File name:   tcu.vhd
-- Created:     11/2/2010
-- Author:      Michael Kelton
-- Lab Section: 337-01
-- Version:     1.0  Initial Design Entry
-- Description: The host to slave transmitter control unit.


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


entity tcu is
  port( clk   :in std_logic;
        rst   :in std_logic;
        p_ready :in std_logic;
        t_bitstuff  :in std_logic;
        PRGA_OUT  :in std_logic_vector(7 downto 0);
        --t_crc   :in std_logic_vector(15 downto 0);
        sending  :out  std_logic;
        EOP       :out  std_logic;
        next_byte  :out  std_logic;
        send_data   :out std_logic_vector(7 downto 0)
        );
  end tcu;
  
  architecture behavioral of tcu is
    
    type state_type is (IDLE, SEND);
    signal state, nextstate : state_type;
    signal count, nextcount : STD_LOGIC_VECTOR(6 downto 0);  
    
    begin
      
    holdReg : process(CLK, RST)
    BEGIN       
      if (RST = '1') then
        state <= IDLE;
        count <= "0000000";
      elsif(CLK'event and CLK = '1') then
          state <= nextstate;
          count <= nextcount;
          
          
        end if;
      end process holdReg;
      
      
    Next_State:process(state, p_ready, count, t_bitstuff)
    Begin
      case state is
                  when IDLE =>
                    
                    nextstate <= IDLE;
                    nextcount <= "0000000";
                    sending <= '0';
                    EOP <= '0';
                    next_byte <= '0';
                    
                    if p_ready = '1' then
                      send_data <= PRGA_OUT;
                      nextstate <= SEND;
                    end if;
                    

                  when SEND =>
                  
                    nextstate <= SEND;
                    nextcount <= count + 1;
                    sending <= '1';
                    
                    if t_bitstuff = '1' then
                      nextcount <= count;
                    end if;
                    
                    if count = "1000000" then  --64
                      next_byte <= '1';
                        
                      if p_ready = '0' then
                        nextstate <= IDLE;
                        EOP <= '1';  
                      end if;
    
                      nextcount <= "0000000";
                      send_data <= PRGA_OUT;
                    end if;
                    
                    

                when others =>
                  
                  nextcount <= "0000000";
                  nextstate <= IDLE;
                  sending <= '0';
                  EOP <= '0';
                  next_byte <= '0';
                
              end case;
            end process Next_state;
             
      
      

end behavioral;    
