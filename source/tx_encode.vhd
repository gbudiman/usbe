-- $Id: $
-- File name:   tx_encode.vhd
-- Created:     11/20/2010
-- Author:      Michael Kelton
-- Lab Section: 337-01
-- Version:     1.0  Initial Design Entry
-- Description: This is the encoder of the transmitter block for the USB encryption.


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

entity tx_encode is
  port( clk   :in std_logic;
        rst   :in std_logic;
        SHIFT_ENABLE_E :in std_logic;
        d_encode   :in std_logic;
        EOP        :in std_logic;
        t_bitstuff :out std_logic; 
        dp_tx_out  :out  std_logic;
        dm_tx_out  :out  std_logic
        );
  end tx_encode;
  
  
  architecture moore of tx_encode is
    
    type state_type is (ZERO, ONE, TWO, THREE, FOUR, FIVE, STUFF_BIT, EOP_STATE);
    signal state, nextstate : state_type;
    signal DE_holdout, DE_holdout_last, dm_tx_nxt: std_logic;
    signal DE_holdout_nxt, DE_holdout_BS, DE_holdout_BS_nxt: std_logic;
    
    
  begin
    
    
    
    holdReg : process(CLK, RST)
    BEGIN       
      if (RST = '1') then
        DE_holdout <= '1';
        DE_holdout_BS <= '0';
        state <= ZERO;
        dp_tx_out <= '1';
        dm_tx_out <= '0';
      elsif(CLK'event and CLK = '1') then
          state <= nextstate;
          
          DE_holdout_last <= DE_holdout;
          DE_holdout <= DE_holdout_nxt;
          DE_holdout_BS<= DE_holdout_BS_nxt;
          
          dp_tx_out <= DE_holdout_nxt;
          dm_tx_out <= dm_tx_nxt;  

          
        end if;
      end process holdReg;
      
      
            
          Next_State:process(state, SHIFT_ENABLE_E, d_encode, RST, EOP, DE_holdout, DE_holdout_BS)
                Begin
                  DE_holdout_BS_nxt <= DE_holdout_BS;
                  case state is
                  when ZERO =>   
                                  nextstate <= ZERO;
                                  
                                  DE_holdout_nxt <= DE_holdout;
                                  
                                  dm_tx_nxt <= NOT DE_holdout;
                                  
                                  if EOP = '1' then
                                    DE_holdout_nxt <= '0';
                                    dm_tx_nxt <= '0'; 
                                    nextstate <= EOP_STATE;
                                  else
                                    if (SHIFT_ENABLE_E = '1') then
                                      
                                      if (d_encode = '0') then
                                        
                                        DE_holdout_nxt <= NOT DE_holdout;
                                        dm_tx_nxt <= DE_holdout;
                                        nextstate <= ZERO;
                                        --if (DE_holdout = '0') then
--                                          nextstate <= ONE;
--                                        end if;
                                        
                                      else
                                        if  (DE_holdout = DE_holdout_last) then
                                          nextstate <= ONE;
                                        end if;
                                      end if;
                                      
                                    end if; 
                                  end if;
                                t_bitstuff <= '0';
                  when ONE =>
                                  nextstate <= ONE;
                                  
                                  DE_holdout_nxt <= DE_holdout;
                                  
                                  dm_tx_nxt <= NOT DE_holdout;
                                  
                                  if EOP = '1' then
                                    DE_holdout_nxt <= '0';
                                    dm_tx_nxt <= '0';
                                    nextstate <= EOP_STATE;
                                  else
                                    if (SHIFT_ENABLE_E = '1') then
                                      
                                      if (d_encode = '0') then
                                        
                                        DE_holdout_nxt <= NOT DE_holdout;
                                        dm_tx_nxt <= DE_holdout;
                                        
                                        if (DE_holdout = '0') then
                                          nextstate <= ZERO;
                                        else
                                          nextstate <= ZERO;
                                        end if;
                                        
                                      else
                                        if  (DE_holdout = DE_holdout_last) then
                                          nextstate <= TWO;
                                        else
                                          nextstate <= ZERO;
                                        end if;
                                      end if;
                                      
                                    end if; 
                                  end if;
                                t_bitstuff <= '0';
                  when TWO =>
                                  nextstate <= TWO;
                                  
                                  DE_holdout_nxt <= DE_holdout;
                                  
                                  dm_tx_nxt <= NOT DE_holdout;
                                  
                                  if EOP = '1' then
                                    DE_holdout_nxt <= '0';
                                    dm_tx_nxt <= '0';
                                    nextstate <= EOP_STATE;
                                  else
                                    if (SHIFT_ENABLE_E = '1') then
                                      
                                      if (d_encode = '0') then
                                        
                                        DE_holdout_nxt <= NOT DE_holdout;
                                        dm_tx_nxt <= DE_holdout;
                                        nextstate <= ZERO;
                                        
                                      else
                                        if  (DE_holdout = DE_holdout_last) then
                                          nextstate <= THREE;
                                        else
                                          nextstate <= ZERO;
                                        end if;
                                      end if;
                                      
                                    end if; 
                                  end if;
                                t_bitstuff <= '0'; 
                  when THREE =>
                                  nextstate <= THREE;
                                  
                                  DE_holdout_nxt <= DE_holdout;
                                  
                                  dm_tx_nxt <= NOT DE_holdout;
                                  
                                  if EOP = '1' then
                                    DE_holdout_nxt <= '0';
                                    dm_tx_nxt <= '0';
                                    nextstate <= EOP_STATE;
                                  else
                                    if (SHIFT_ENABLE_E = '1') then
                                      
                                      if (d_encode = '0') then
                                        
                                        DE_holdout_nxt <= NOT DE_holdout;
                                        dm_tx_nxt <= DE_holdout;
                                        
                                        if (DE_holdout = '0') then
                                          nextstate <= ZERO;
                                        else
                                          nextstate <= ZERO;
                                        end if;
                                        
                                      else
                                        if  (DE_holdout = DE_holdout_last) then
                                          nextstate <= FOUR;
                                        else
                                          nextstate <= ZERO;
                                        end if;
                                      end if;
                                      
                                    end if; 
                                  end if;
                                t_bitstuff <= '0';
                  when FOUR =>
                                  nextstate <= FOUR;
                                  
                                  DE_holdout_nxt <= DE_holdout;
                                  
                                  dm_tx_nxt <= NOT DE_holdout;
                                  
                                  if EOP = '1' then
                                    DE_holdout_nxt <= '0';
                                    dm_tx_nxt <= '0';
                                    nextstate <= EOP_STATE;
                                  else
                                    if (SHIFT_ENABLE_E = '1') then
                                      
                                      if (d_encode = '0') then
                                        
                                        DE_holdout_nxt <= NOT DE_holdout;
                                        dm_tx_nxt <= DE_holdout;
                                        
                                        if (DE_holdout = '0') then
                                          nextstate <= ZERO;
                                        else
                                          nextstate <= ZERO;
                                        end if;
                                        
                                      else
                                        if  (DE_holdout = DE_holdout_last) then
                                          nextstate <= FIVE;
                                        else
                                          nextstate <= ZERO;
                                        end if;
                                      end if;
                                      
                                    end if; 
                                  end if;
                                t_bitstuff <= '0';
                  when FIVE =>
                                  nextstate <= FIVE;
                                  
                                  DE_holdout_nxt <= DE_holdout;
                                  
                                  dm_tx_nxt <= NOT DE_holdout;
                                  
                                  if EOP = '1' then
                                    DE_holdout_nxt <= '0';
                                    dm_tx_nxt <= '0';
                                    nextstate <= EOP_STATE;
                                  else
                                    
                                    if (SHIFT_ENABLE_E = '1') then
                                      nextstate <= STUFF_BIT;
                                      DE_holdout_BS_nxt <= DE_holdout;
                                      DE_holdout_nxt <= NOT DE_holdout;
                                      dm_tx_nxt <= DE_holdout;
                                    end if;
                              
                                  end if;
                                t_bitstuff <= '0';
                                
                  when STUFF_BIT =>
                                  nextstate <= STUFF_BIT;
                                  
                                  DE_holdout_nxt <= NOT DE_holdout_BS;
                                  
                                  dm_tx_nxt <= DE_holdout_BS;
                                  
                                  if EOP = '1' then
                                    DE_holdout_nxt <= '0';
                                    dm_tx_nxt <= '0';
                                    nextstate <= EOP_STATE;
                                  else
                                    if (SHIFT_ENABLE_E = '1') then
                                      
                                      nextstate <= ZERO;
                                      
                                      if (d_encode = '0') then
                                        
                                        DE_holdout_nxt <= NOT DE_holdout_BS;
                                        dm_tx_nxt <= DE_holdout_BS;
                                        if  (DE_holdout_BS = DE_holdout) then
                                          nextstate <= ONE;
                                        end if;
                                        
                                      else
                                        if  (DE_holdout_BS = DE_holdout) then
                                          nextstate <= ONE;
                                        end if;
                                          DE_holdout_nxt <= DE_holdout_BS;
                                          
                                          dm_tx_nxt <= NOT DE_holdout_BS;
                                      end if;
                                      
                                    end if;  
                                  end if;
                                t_bitstuff <= '1';
                            
                  when EOP_STATE =>
                                  nextstate <= ZERO;
                                  
                                  DE_holdout_nxt <= '1';
                                  
                                  dm_tx_nxt <= '0';
                                  
                                  if EOP = '1' then
                                    DE_holdout_nxt <= '0';
                                    dm_tx_nxt <= '0';
                                    nextstate <= EOP_STATE;
                                  
                                  end if;
                                t_bitstuff <= '0';  
                              
                  when others =>  nextstate <= ZERO;
                                  t_bitstuff <= '0';
                                  DE_holdout_nxt <= '1';
                                  dm_tx_nxt <= '1';                                                                                                              
                                                         
        end case;
      end process Next_State;
  end architecture;