-- $Id: $
-- File name:   rcu.vhd
-- Created:     11/11/2010
-- Author:      Brent O'Brien
-- Lab Section: 337-01
-- Version:     1.0  Initial Design Entry
-- Description: receiver side control unit

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

Entity rcu is
  port(
    CLK:in std_logic;
    RST:in std_logic;
    D_EDGE:in std_logic;
    EOP:in std_logic;
    SHIFT_ENABLE:in std_logic;
    BITSTUFF: in std_logic;
    RX_CRC: in std_logic_vector(7 downto 0);
    RCV_DATA: in std_logic_vector(7 downto 0);
    RCVING:out std_logic;
    W_ENABLE:out std_logic;
    R_ERROR:out std_logic;
    CRC_ERROR:out std_logic
  );
end rcu;

architecture moore of rcu is
  type state_type is (IDLE, RECEIVING, CHECK_SYNC, POST_SYNC, NO_SYNC, ERROR,
  EOP_DETECT, WRITE_BYTE, ERROR2, PREIDLE, NO_SYNC2);
  signal state, nextstate : state_type;
  signal count, nextcount : STD_LOGIC_VECTOR(3 downto 0);
  signal nxtR_ERROR, nxtCRC_ERROR : std_logic;
  begin
  StateReg : process(CLK, RST)
    begin
      if (RST = '1') then
        state <= IDLE;
        count <= "0000";
        R_ERROR <= '0';
      elsif(CLK'event and CLK = '1') then
        state <= nextstate;
        count <= nextcount;
        R_ERROR <= nxtR_ERROR;
        CRC_ERROR <= nxtCRC_ERROR;
      end if;
    end process StateReg;
    
    Next_State:process(state, EOP, count, D_EDGE, SHIFT_ENABLE, RCV_DATA)
          Begin
            case state is
            when IDLE =>
                          RCVING <= '0';
                          nxtR_ERROR <= '0';
                          nxtCRC_ERROR <= '0';
                          W_ENABLE <= '0';
                          nextcount <= "0000";
                          if ( D_EDGE = '1') then
                            nextstate <= RECEIVING;
                          else
                            nextstate <= IDLE;
                          end if;
            when PREIDLE =>
                          RCVING <= '0';
                          nxtR_ERROR <= '0';
                          nxtCRC_ERROR <= '0';
                          W_ENABLE <= '0';
                          nextcount <= "0000";
                          if ( D_EDGE = '1') then
                            nextstate <= IDLE;
                          else
                            nextstate <= PREIDLE;
                          end if;
            when RECEIVING =>
                          nextcount <= count;
                          RCVING <= '1';
                          nxtR_ERROR <= '0';
                          nxtCRC_ERROR <= '0';
                          W_ENABLE <= '0';
                          if ( EOP = '1') then
                            nextstate <= ERROR;
                            nxtR_ERROR <= '1';
                          elsif (count = "1000") then
                            nextstate <= CHECK_SYNC;
                            nextcount <= "0000";
                          elsif (SHIFT_ENABLE = '1') then
                            nextstate <= RECEIVING;
                            if (BITSTUFF = '1') then
                              nextcount <= count;
                            else
                              nextcount <= count + 1;
                            end if;
                          else
                            nextstate <= RECEIVING;
                          end if;                                                  
            when CHECK_SYNC =>
                          RCVING <= '1';
                          nxtR_ERROR <= '0';
                          nxtCRC_ERROR <= '0';
                          W_ENABLE <= '0';
                          nextcount <= "0000";
                          if ( RCV_DATA = "10000000") then
                            nextstate <= POST_SYNC;
                          else
                            nextstate <= NO_SYNC;
                            nxtR_ERROR <= '1';
                          end if;
            when NO_SYNC =>
                          RCVING <= '1';
                          nxtR_ERROR <= '1';
                          nxtCRC_ERROR <= '0';
                          W_ENABLE <= '0';
                          nextcount <= "0000";
                          if ( EOP = '1') then
                            nextstate <= NO_SYNC2;
                          else
                            nextstate <= NO_SYNC;
                          end if;
            when NO_SYNC2 =>
                          RCVING<= '0';
                          nxtR_ERROR <= '1';
                          nxtCRC_ERROR <= '0';
                          W_ENABLE <= '0';
                          nextcount <= "0000";
                          nextstate <= ERROR;  
            when ERROR =>
                          RCVING <= '0';
                          nxtR_ERROR <= nxtR_ERROR;
                          nxtCRC_ERROR <= nxtCRC_ERROR;
                          W_ENABLE <= '0';
                          nextcount <= "0000";
                          if ( D_EDGE = '1') then
                            nextstate <= ERROR2;
                          else
                            nextstate <= ERROR;
                          end if;
                          
            when ERROR2 =>
                          RCVING <= '0';
                          nxtR_ERROR <= nxtR_ERROR;
                          nxtCRC_ERROR <= nxtCRC_ERROR;
                          W_ENABLE <= '0';
                          nextcount <= "0000";
                          if ( D_EDGE = '1') then
                            nextstate <= RECEIVING;
                            nxtR_ERROR <= '0';
                          else
                            nextstate <= ERROR2;
                          end if;                          
            when POST_SYNC =>
                        nextcount <= count;
                        RCVING <= '1';
                        nxtR_ERROR <= '0';
                        nxtCRC_ERROR <= '0';
                        W_ENABLE <= '0';
                        if ( EOP = '1') then
                          nextstate <= EOP_DETECT;
                        elsif (count = "1000") then
                          nextstate <= WRITE_BYTE;
                          nextcount <= "0000";
                        elsif (SHIFT_ENABLE = '1') then
                          nextstate <= POST_SYNC;
                          if (BITSTUFF = '1') then
                            nextcount <= count;
                          else
                            nextcount <= count + 1;
                          end if;
                        else
                          nextstate <= POST_SYNC;
                        end if;                                                 
            when WRITE_BYTE =>
                          RCVING <= '1';
                          nxtR_ERROR <= '0';
                          nxtCRC_ERROR <= '0';
                          W_ENABLE <= '1';
                          nextcount <= "0000";
                          nextstate <= POST_SYNC;
                          
            when EOP_DETECT =>
                          RCVING <= '0';
                          nxtR_ERROR <= '0';
                          nxtCRC_ERROR <= '0';
                          W_ENABLE <= '0';
                          nextcount <= "0000";
                          if ( count = "0000") then
                            if (RX_CRC = RCV_Data) then
                              nextstate <= PREIDLE;
                            else
                              nextstate <= ERROR;
                              nxtCRC_ERROR <= '1';
                            end if;
                          else
                            nextstate <= ERROR;
                            nxtR_ERROR <= '1';
                          end if;                                      
            when others =>
                          RCVING <= '0';
                          nxtR_ERROR <= '0';
                          nxtCRC_ERROR <= '0';
                          W_ENABLE <= '0';
                          nextcount <= "0000";
                          nextstate <= IDLE;
                          
  end case;
end process Next_State;
end architecture;                             


