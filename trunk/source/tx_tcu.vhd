-- $Id: $
-- File name:   tx_tcu.vhd
-- Created:     11/2/2010
-- Author:      Michael Kelton
-- Lab Section: 337-01
-- Version:     1.0  Initial Design Entry
-- Description: The host to slave transmitter control unit.


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


entity tx_tcu is
  port( clk   :in std_logic;
        rst   :in std_logic;
        p_ready :in std_logic;
        t_bitstuff  :in std_logic;
        PRGA_OUT  :in std_logic_vector(7 downto 0);
        prga_opcode :in std_logic_vector(1 downto 0);
        t_crc   :in std_logic_vector(15 downto 0);
        sending  :out  std_logic;
        EOP       :out  std_logic;
        next_byte  :out  std_logic;
        send_data   :out std_logic_vector(7 downto 0);
        t_strobe    :out std_logic        
        );
  end tx_tcu;
  
  architecture behavioral of tx_tcu is
    
    type state_type is (IDLE, SEND, MULTITASK, UPDATEDATA, SENDCRC1, SENDCRC2);
    signal state, nextstate : state_type;
    signal count, nextcount : STD_LOGIC_VECTOR(6 downto 0);
    signal flop_data : std_logic_vector(7 downto 0);  
    
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
      
      
    Next_State:process(state, p_ready, count, t_bitstuff, prga_opcode, flop_data, t_crc, PRGA_OUT)
    Begin
      nextcount <= count;
      next_byte <= '0';
      t_strobe <= '0';
      EOP <= '0';
-- Send_Data/Flop_Data may need to be defined for all states. 
      case state is
                  when IDLE =>
                    
                    nextstate <= IDLE;
                    nextcount <= "0000000";
                    sending <= '0';
                    next_byte <= '1';
                    
                    if p_ready = '1' then
                      next_byte <= '0';
                      flop_data <= PRGA_OUT;
                      nextstate <= SEND;
                      
                      if prga_opcode = "11" then
                        EOP <= '1';
                        nextstate <= IDLE;
                      end if;
                      
                    end if;
                    

                  when SEND =>
                  
                    nextstate <= SEND;
                    send_data <= flop_data;
                    nextcount <= count + 1;
                    sending <= '1';
                    
                    if prga_opcode = "11" then
                      if count = "0111111" then  -- 63
                        nextstate <= SENDCRC1;
                        nextcount <= "0000000";
                        next_byte <= '1';
                      end if;
                    end if;
                    
                    if t_bitstuff = '1' then
                      nextcount <= count;
                    end if;
                    
                    if count = "0000000" then
                      t_strobe <= '1';
                    elsif count = "0000001" then
                      t_strobe <= '0';
                    end if;                      
                    
                    if count = "0110000" then  --48
                      next_byte <= '1';                     
                      nextstate <= MULTITASK;
                    end if;
                    
                when MULTITASK =>
                  
                  nextstate <= MULTITASK;
                  send_data <= flop_data;
                  nextcount <= count + 1;
                  sending <= '1';
                  next_byte <= '1';
                  
                  if t_bitstuff = '1' then
                    nextcount <= count;
                  end if;
                  
                  if  p_ready = '1' then
                    nextstate <= UPDATEDATA;
                  end if;
                  
                  if count = "0111111" then
                    EOP <= '1';
                    nextstate <= IDLE;
                    nextcount <= "0000000";
                  end if;
                
                  
                when UPDATEDATA =>
                  
                  nextstate <= UPDATEDATA;
                  flop_data <= PRGA_OUT;                  
                  nextcount <= count + 1;                  
                  sending <= '1';
                  next_byte <= '0';
                  
                  if t_bitstuff = '1' then
                    nextcount <= count;
                  end if;
                  
                  if count = "0111111" then
                    nextstate <= SEND;
                    nextcount <= "0000000";
                  end if;
                  
                  if prga_opcode = "11" then
                    nextstate <= SENDCRC1;
                    
                    nextcount <= "0000000";
                    next_byte <= '1';
                  end if;
                  
                when SENDCRC1 =>
                  
                  nextstate <= SENDCRC1;
                  sending <= '1';
                  
                  if count = "0111111" then
                    nextstate <= SENDCRC2;
                  end if;
                  
                  send_data <= t_crc(15 downto 8);
                  
                when SENDCRC2 =>
                  
                  nextstate <= SENDCRC2;
                  sending <= '1';
                  
                  if count = "0111111" then
                    EOP <= '1';
                    nextstate <= IDLE;
                  end if;

                  send_data <= t_crc(7 downto 0);  
                    
                    

                when others =>
                  
                  nextcount <= "0000000";
                  nextstate <= IDLE;
                  sending <= '0';
                  EOP <= '0';
                  next_byte <= '1'; 
                
              end case;
            end process Next_state;
             
      
      

end behavioral;    
