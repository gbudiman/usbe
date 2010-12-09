-- $Id: $
-- File name:   tb_KSA.vhd
-- Created:     11/9/2010
-- Author:      Gloria Budiman
-- Lab Section: 337-02
-- Version:     1.0  Initial Test Bench

library ieee;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model
library ECE337_IP;
use ECE337_IP.all;

entity tb_KSA is
  generic (Period : Time :=  10.4167 ns);
end tb_KSA;

architecture TEST of tb_KSA is

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

  component KSA
    PORT(
         KEY : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
         CLK : IN STD_LOGIC;
         RST : IN STD_LOGIC;
         BYTE: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
         OPCODE: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
         BYTE_READY: IN STD_LOGIC;
         KEY_ERROR : IN STD_LOGIC;
         DATA_IN : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
         PDATA_READY : OUT STD_LOGIC;
         PROCESSED_DATA : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
         W_ENABLE, R_ENABLE: OUT STD_LOGIC;
         DATA, ADDR : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
  end component;
  
  component scalable_off_chip_sram is
    generic (
      -- Memory Model parameters
      ADDR_SIZE_BITS	: natural	:= 8;		-- Address bus size in bits/pins with addresses corresponding to 
                                          -- the starting word of the accesss
      WORD_SIZE_BYTES	: natural	:= 1;			-- Word size of the memory in bytes
      DATA_SIZE_WORDS	: natural	:= 1;			-- Data bus size in "words"
      READ_DELAY			: time		:= 10 ns;	-- Delay/latency per read access (total time between start of supplying address and when the data read from memory appears on the r_data port)
                                          -- Keep the 10 ns delay for on-chip SRAM
      WRITE_DELAY			: time		:= 10 ns		-- Delay/latency per write access (total time between start of supplying address and when the w_data value is written into memory)
                                          -- Keep the 10 ns delay for on-chip SRAM
          );
  port 	(
    -- Test bench control signals
    mem_clr				: in	boolean;
    mem_init			: in	boolean;
    mem_dump			: in	boolean;
    verbose				: in	boolean;
    init_filename	: in 	string;
    dump_filename	: in 	string;
    start_address	: in	natural;
    last_address	: in	natural;
    
    -- Memory interface signals
    r_enable	: in		std_logic;
    w_enable	: in		std_logic;
    addr			: in		std_logic_vector((addr_size_bits - 1) downto 0);
    data			: inout	std_logic_vector(((data_size_words * word_size_bytes * 8) - 1) downto 0)
      );
  end component scalable_off_chip_sram;

-- Insert signals Declarations here
  signal KEY : STD_LOGIC_VECTOR(63 DOWNTO 0);
  signal OPCODE: STD_LOGIC_VECTOR(1 DOWNTO 0);
  signal TB_DATA_IN: STD_LOGIC_VECTOR(7 DOWNTO 0);
  signal BYTE : STD_LOGIC_VECTOR(7 DOWNTO 0);
  signal BYTE_READY : STD_LOGIC;
  signal CLK : STD_LOGIC;
  signal RST : STD_LOGIC;
  signal KEY_ERROR : STD_LOGIC;
  signal PDATA_READY : STD_LOGIC;
  signal PROCESSED_DATA : STD_LOGIC_VECTOR(7 DOWNTO 0);
  signal TB_W_ENABLE, TB_R_ENABLE: STD_LOGIC;
  signal TB_SRAM_DATA, TB_DUT_DATA, TB_ADDR: STD_LOGIC_VECTOR(7 DOWNTO 0);
  signal tb_mem_dump: boolean;
  signal tb_dump_filename, tb_init_filename: string(1 to 24);
  signal tb_start_address, tb_last_address: natural;

-- signal <name> : <type>;
PROCEDURE sendUSB (
  constant ASCII: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
  constant OC: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
  signal OPCODE: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
  signal BYTE: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
  signal BYTE_READY: OUT STD_LOGIC ) IS
BEGIN
  BYTE <= ASCII;
  OPCODE <= OC;
  BYTE_READY <= '1'; wait for period; BYTE_READY <= '0'; wait for 24 * period;
END sendUSB;

begin
  DUT: KSA port map(
                KEY => KEY,
                OPCODE => OPCODE,
                BYTE => BYTE,
                BYTE_READY => BYTE_READY,
                CLK => CLK,
                RST => RST,
                DATA_IN => TB_DATA_IN,
                KEY_ERROR => KEY_ERROR,
                PDATA_READY => PDATA_READY,
                PROCESSED_DATA => PROCESSED_DATA,
                W_ENABLE => TB_W_ENABLE,
                R_ENABLE => TB_R_ENABLE,
                DATA => TB_DUT_DATA,
                ADDR => TB_ADDR
                );
  Memory: scalable_off_chip_sram
    generic map (
      -- Memory interface parameters
      ADDR_SIZE_BITS	=> 8,
      WORD_SIZE_BYTES	=> 1,
      DATA_SIZE_WORDS	=> 1,
      READ_DELAY			=> (Period - 5 ns),	-- CLK is 2 ns longer than access delay for conservative padding for flipflop setup times and propagation delays from the external SRAM chip to the internal flipflops
      WRITE_DELAY			=> (Period - 5 ns)		-- CLK is 2 ns longer than access delay for conservative padding for Real SRAM hold times and propagation delays from the internal flipflops to the external SRAM chip
    )
    port map	(
      -- Test bench control signals
      mem_clr				=> false,
      mem_init			=> false,
      mem_dump			=> tb_mem_dump,
      verbose				=> false,
      init_filename	=> tb_init_filename,
      dump_filename	=> tb_dump_filename,
      start_address	=> tb_start_address,
      last_address	=> tb_last_address,
      
      -- Memory interface signalssim:/tb_ksa/dut/prefillcomplete

      r_enable	=> TB_r_enable,
      w_enable	=> TB_w_enable,
      addr			=> TB_addr,
      data			=> TB_sram_data
    );
--   GOLD: <GOLD_NAME> port map(<put mappings here>);
autoClock: process
  BEGIN
    clk <= '0';
    wait for period/2;
    clk <= '1';
    wait for period/2;
  END process autoClock;

IO_DATA: process (TB_W_ENABLE, TB_R_ENABLE, TB_sram_DATA, TB_DUT_DATA)
  begin
    if (tb_r_enable = '1') then
      -- Read mode -> the data pins should connect to the r_data bus & the other bus should float
      TB_DATA_IN	<= tb_sram_data;
      tb_sram_data				<= (others=>'Z');
    elsif(tb_w_enable = '1') then
      -- Write mode -> the data pins should connect to the w_data bus & the other bus should float
      tb_DATA_IN	<= (others=>'Z');
      tb_sram_data	<= TB_DUT_DATA;
    else
      -- Disconnect both busses
      tb_DATA_IN	<= (others=>'Z');
      tb_sram_data				<= (others=>'Z');
    end if;
  end process IO_DATA;
  
process

  begin

-- Insert TEST BENCH Code Here

  KEY <= x"5345435245542121";
  KEY_ERROR <= '0';
  BYTE_READY <= '0';
  RST <= '1';
  wait for 20 ns;
  RST <= '0';
  
  wait for 5350 ns;
  tb_mem_dump				<= TRUE;
  tb_dump_filename	<=	"source/test_prefilld.txt";
  tb_start_address	<= 0; -- Can be any address 
  tb_last_address		<= 255; -- Can be any address larger than the start_address
  wait for 15 ns; -- Can be as long or as short as you like, as long as it is longer than 1 simulation time-step
  tb_mem_dump <= FALSE;
  
  wait for 28 us;
  tb_mem_dump				<= TRUE;
  tb_dump_filename	<=	"source/test_mem_dump.txt";
  tb_start_address	<= 0; -- Can be any address 
  tb_last_address		<= 255; -- Can be any address larger than the start_address
  wait for 2 us; -- Can be as long or as short as you like, as long as it is longer than 1 simulation time-step
  tb_mem_dump <= FALSE;
  
  sendUSB(x"FF", "00", OPCODE, BYTE, BYTE_READY); --PID?
  sendUSB(x"54", "01", OPCODE, BYTE, BYTE_READY); --T
  sendUSB(x"68", "01", OPCODE, BYTE, BYTE_READY); --h
  tb_mem_dump				<= TRUE;
  tb_dump_filename	<=	"source/test_mem_dum1.txt";
  tb_start_address	<= 0; -- Can be any address 
  tb_last_address		<= 255; -- Can be any address larger than the start_address
  wait for 1 ns; -- Can be as long or as short as you like, as long as it is longer than 1 simulation time-step
  tb_mem_dump <= FALSE;
  sendUSB(x"69", "01", OPCODE, BYTE, BYTE_READY); --i
  sendUSB(x"73", "01", OPCODE, BYTE, BYTE_READY); --s
  tb_mem_dump				<= TRUE;
  tb_dump_filename	<=	"source/test_mem_dum2.txt";
  tb_start_address	<= 0; -- Can be any address 
  tb_last_address		<= 255; -- Can be any address larger than the start_address
  wait for 1 ns; -- Can be as long or as short as you like, as long as it is longer than 1 simulation time-step
  tb_mem_dump <= FALSE;
  sendUSB(x"20", "01", OPCODE, BYTE, BYTE_READY); --
  sendUSB(x"69", "01", OPCODE, BYTE, BYTE_READY); -- i
  sendUSB(x"73", "01", OPCODE, BYTE, BYTE_READY); -- s
  sendUSB(x"20", "01", OPCODE, BYTE, BYTE_READY); --
  sendUSB(x"61", "01", OPCODE, BYTE, BYTE_READY); -- a
  sendUSB(x"77", "01", OPCODE, BYTE, BYTE_READY); -- w
  sendUSB(x"65", "01", OPCODE, BYTE, BYTE_READY); -- e
  sendUSB(x"73", "01", OPCODE, BYTE, BYTE_READY); -- s
  sendUSB(x"6f", "01", OPCODE, BYTE, BYTE_READY); -- o
  sendUSB(x"6d", "01", OPCODE, BYTE, BYTE_READY); -- m
  sendUSB(x"65", "01", OPCODE, BYTE, BYTE_READY); -- e
  report "Next cycle" severity note;
  sendUSB(x"FF", "11", OPCODE, BYTE, BYTE_READY);
  sendUSB(x"54", "01", OPCODE, BYTE, BYTE_READY); --T
  sendUSB(x"68", "01", OPCODE, BYTE, BYTE_READY); --h
  sendUSB(x"69", "01", OPCODE, BYTE, BYTE_READY); --i
  sendUSB(x"73", "01", OPCODE, BYTE, BYTE_READY); --s
  sendUSB(x"20", "01", OPCODE, BYTE, BYTE_READY); --
  sendUSB(x"69", "01", OPCODE, BYTE, BYTE_READY); -- i
  sendUSB(x"73", "01", OPCODE, BYTE, BYTE_READY); -- s
  sendUSB(x"20", "01", OPCODE, BYTE, BYTE_READY); --
  sendUSB(x"61", "01", OPCODE, BYTE, BYTE_READY); -- a
  sendUSB(x"77", "01", OPCODE, BYTE, BYTE_READY); -- w
  sendUSB(x"65", "01", OPCODE, BYTE, BYTE_READY); -- e
  sendUSB(x"73", "01", OPCODE, BYTE, BYTE_READY); -- s
  sendUSB(x"6f", "01", OPCODE, BYTE, BYTE_READY); -- o
  sendUSB(x"6d", "01", OPCODE, BYTE, BYTE_READY); -- m
  sendUSB(x"65", "01", OPCODE, BYTE, BYTE_READY); -- e  
--  sendUSB(x"FA", BYTE, BYTE_READY); --T
--  sendUSB(x"4A", BYTE, BYTE_READY); --h
--  sendUSB(x"94", BYTE, BYTE_READY); --i
--  sendUSB(x"E6", BYTE, BYTE_READY); --s
--  sendUSB(x"51", BYTE, BYTE_READY); --
--  sendUSB(x"2B", BYTE, BYTE_READY); -- i
--  sendUSB(x"CE", BYTE, BYTE_READY); -- s
--  sendUSB(x"B3", BYTE, BYTE_READY); --
--  sendUSB(x"88", BYTE, BYTE_READY); -- a
--  sendUSB(x"56", BYTE, BYTE_READY); -- w
--  sendUSB(x"17", BYTE, BYTE_READY); -- e
--  sendUSB(x"E4", BYTE, BYTE_READY); -- s
--  sendUSB(x"F3", BYTE, BYTE_READY); -- o
--  sendUSB(x"0E", BYTE, BYTE_READY); -- m
--  sendUSB(x"31", BYTE, BYTE_READY); -- e
--  BYTE <= "T";
--  BYTE_READY <= '1'; wait for period; BYTE_READY <= '0'; wait for 7 * period;
--  
--  BYTE <= ; 
--  BYTE_READY <= '1'; wait for period; BYTE_READY <= '0'; wait for 7 * period;
--  
--  BYTE <= x"4F";
--  BYTE_READY <= '1'; wait for period; BYTE_READY <= '0'; wait for 7 * period;
--  
--  BYTE <= x"52";
--  BYTE_READY <= '1'; wait for period; BYTE_READY <= '0'; wait for 7 * period;
--  
--  BYTE <= x"49";
--  BYTE_READY <= '1'; wait for period; BYTE_READY <= '0'; wait for 7 * period;
--  
--  BYTE <= x"41";
--  BYTE_READY <= '1'; wait for period; BYTE_READY <= '0'; wait for 7 * period;

  --BYTE <= x"E9";
--  BYTE_READY <= '1'; wait for period; BYTE_READY <= '0'; wait for 7 * period;
--
--  BYTE <= x"6E"; 
--  BYTE_READY <= '1'; wait for period; BYTE_READY <= '0'; wait for 7 * period;
--
--  BYTE <= x"B2";
--  BYTE_READY <= '1'; wait for period; BYTE_READY <= '0'; wait for 7 * period;
--
--  BYTE <= x"C7";
--  BYTE_READY <= '1'; wait for period; BYTE_READY <= '0'; wait for 7 * period;
--
--  BYTE <= x"38";
--  BYTE_READY <= '1'; wait for period; BYTE_READY <= '0'; wait for 7 * period;
--
--  BYTE <= x"03";
--  BYTE_READY <= '1'; wait for period; BYTE_READY <= '0'; wait for 7 * period;
  
  wait;
    --KEY <= 
    --CLK <= 
    --RST <= 
    --KEY_ERROR <= 

  end process;
end TEST;