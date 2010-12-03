-- $Id: $
-- File name:   tb_transmitter_block.vhd
-- Created:     12/2/2010
-- Author:      Michael Kelton
-- Lab Section: 337-01
-- Version:     1.0  Initial Test Bench

library ieee;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model

entity tb_transmitter_block is
  generic(period : time := 10.42 ns);
end tb_transmitter_block;

architecture TEST of tb_transmitter_block is

  function INT_TO_STD_LOGIC( X: INTEGER; NumBits: INTEGER )
     return STD_LOGIC_VECTOR is
    variable RES : STD_LOGIC_VECTOR(NumBits-1 downto 0);
    variable tmp : INTEGER;
  begin
    tmp := X;
    for i in 0 to NumBits-1 loop
      if (tmp mod 2)=1 then
        res(i) := '1';
      else
        res(i) := '0';
      end if;
      tmp := tmp/2;
    end loop;
    return res;
  end;
  
  procedure READ_FIFO(
    constant  byte    : in std_logic_vector(7 downto 0);
    constant  op      : in std_logic_vector(1 downto 0);
    signal NEXT_BYTE  : in std_logic;
    signal p_ready    : inout  std_logic;
    signal PRGA_out   : inout  std_logic_vector(7 downto 0);
    signal prga_opcode    : inout std_logic_vector(1 downto 0)
    ) is
 
    begin 
      
      wait until NEXT_BYTE = '1';
      PRGA_OUT <= byte;
      prga_opcode <= op;
      wait for period;
      p_ready <= '1';
      wait for period;
      p_ready <= '0';
      
    end READ_FIFO;
    

  component transmitter_block
    PORT(
         PRGA_OUT : IN std_logic_vector (7 DOWNTO 0);
         clk : IN std_logic;
         p_ready : IN std_logic;
         prga_opcode : IN std_logic_vector (1 DOWNTO 0);
         rst : IN std_logic;
         NEXT_BYTE: OUT std_logic
    );
  end component;

-- Insert signals Declarations here
  signal PRGA_OUT : std_logic_vector (7 DOWNTO 0);
  signal clk : std_logic;
  signal p_ready : std_logic;
  signal prga_opcode : std_logic_vector (1 DOWNTO 0);
  signal rst : std_logic;
  signal NEXT_BYTE : std_logic;

-- signal <name> : <type>;

begin
  DUT: transmitter_block port map(
                PRGA_OUT => PRGA_OUT,
                clk => clk,
                p_ready => p_ready,
                prga_opcode => prga_opcode,
                rst => rst,
                NEXT_BYTE => NEXT_BYTE
                );

process
  begin
  CLK <= '1';
  wait for period/2;
  CLK <= '0';
  wait for period/2;
end process;

process

  begin

-- Insert TEST BENCH Code Here

    PRGA_OUT <= "00000000";
    p_ready <= '0';
    prga_opcode <= "00";
    rst <= '1';
    NEXT_BYTE <= '1';
    wait for period;
    rst <= '0';
    READ_FIFO(x"80", "00", NEXT_BYTE,p_ready,PRGA_out, prga_opcode); 
    READ_FIFO(x"D4", "00", NEXT_BYTE,p_ready,PRGA_out, prga_opcode); 
    READ_FIFO(x"40", "01", NEXT_BYTE,p_ready,PRGA_out, prga_opcode); 
    READ_FIFO(x"41", "01", NEXT_BYTE,p_ready,PRGA_out, prga_opcode); 
    READ_FIFO(x"42", "01", NEXT_BYTE,p_ready,PRGA_out, prga_opcode); 
    READ_FIFO(x"43", "01", NEXT_BYTE,p_ready,PRGA_out, prga_opcode); 
    READ_FIFO(x"44", "01", NEXT_BYTE,p_ready,PRGA_out, prga_opcode); 
    READ_FIFO(x"45", "01", NEXT_BYTE,p_ready,PRGA_out, prga_opcode); 
    READ_FIFO(x"46", "01", NEXT_BYTE,p_ready,PRGA_out, prga_opcode); 
    READ_FIFO(x"47", "01", NEXT_BYTE,p_ready,PRGA_out, prga_opcode); 
    READ_FIFO(x"48", "01", NEXT_BYTE,p_ready,PRGA_out, prga_opcode); 
    READ_FIFO(x"49", "11", NEXT_BYTE,p_ready,PRGA_out, prga_opcode); 

  end process;
end TEST;