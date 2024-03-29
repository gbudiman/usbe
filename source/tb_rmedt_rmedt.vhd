-- $Id: $
-- File name:   tb_rmedt_rmedt.vhd
-- Created:     12/7/2010
-- Author:      Gloria Budiman
-- Lab Section: 337-02
-- Version:     1.0  Initial Test Bench

library ieee;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model
library ECE337_IP;
use ECE337_IP.all;

entity tb_rmedt_rmedt is
  generic (Period : Time :=  10.4167 ns);
end tb_rmedt_rmedt;

architecture TEST of tb_rmedt_rmedt is

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

  component rmedt_rmedt
    PORT(
         CLK : IN std_logic;
         DM1_RX : IN std_logic;
         DP1_RX : IN std_logic;
         RST : IN std_logic;
         SERIAL_IN : IN std_logic;
         DATA_IN_H, DATA_IN_S: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
         BS_ERROR : OUT std_logic;
         BS_ERROR1 : OUT std_logic;
         CRC_ERROR : OUT std_logic;
         CRC_ERROR1 : OUT std_logic;
         EMPTY : OUT STD_LOGIC;
         EMPTY1 : OUT STD_LOGIC;
         FULL : OUT STD_LOGIC;
         FULL1 : OUT STD_LOGIC;
         R_ERROR : OUT std_logic;
         R_ERROR1 : OUT std_logic;
         W_ENABLE_H, W_ENABLE_S, R_ENABLE_H, R_ENABLE_S: OUT STD_LOGIC;
         DATA_H, DATA_S, ADDR_H, ADDR_S: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
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
  signal CLK : std_logic;
  signal DM1_RX : std_logic;
  signal DP1_RX : std_logic;
  signal RST : std_logic;
  signal SERIAL_IN : std_logic;
  signal DATA_IN_H, DATA_IN_S: STD_LOGIC_VECTOR(7 DOWNTO 0);
  signal BS_ERROR : std_logic;
  signal BS_ERROR1 : std_logic;
  signal CRC_ERROR : std_logic;
  signal CRC_ERROR1 : std_logic;
  signal EMPTY : STD_LOGIC;
  signal EMPTY1 : STD_LOGIC;
  signal FULL : STD_LOGIC;
  signal FULL1 : STD_LOGIC;
  signal R_ERROR : std_logic;
  signal R_ERROR1 : std_logic;
  signal W_ENABLE_H, W_ENABLE_S, R_ENABLE_H, R_ENABLE_S: STD_LOGIC;
  signal DATA_H, DATA_S, ADDR_H, ADDR_S: STD_LOGIC_VECTOR(7 DOWNTO 0);
  signal tb_mem_dump: boolean;
  signal tb_dump_filename, tb_init_filename: string(1 to 24);
  signal tb_start_address, tb_last_address: natural;
  signal SRAM_DATA_H, SRAM_DATA_S: STD_LOGIC_VECTOR(7 DOWNTO 0);

-- signal <name> : <type>;
procedure sendUART(
  constant data_in: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
  signal serial_in: OUT STD_LOGIC) is
begin
  serial_in <= '0';
  wait for 10 * period;
  for i in 0 to 7 loop
    serial_in <= data_in(i);
    wait for 10 * period;
  end loop;
  serial_in <= '0';
  wait for 10 * period;
  serial_in <= '1';
  wait for 30 * period;
end sendUART;

procedure sendByteFast (
    constant data : in std_logic_vector(7 downto 0);
    constant length : integer;
    signal DP1_RX: OUT STD_LOGIC;
    signal DM1_RX: OUT STD_LOGIC) is
begin
    for i in 7 downto length loop
        DP1_RX <= data(i);
        DM1_RX <= NOT data(i);
        wait for 8*period * 1;
    end loop;
end sendByteFast;

procedure HEXtoNRZI (
  constant data : in std_logic_vector(7 downto 0);
  variable bc_count : inout integer;
  signal D    : inout std_logic; 
  signal D_MIN: out std_logic) is
  variable count: integer;
  variable D_Last: std_logic;
  begin
    count := bc_count;
--    case count is
--      when 0 => report "0";
--      when 1 => report "1";
--      when 2 => report "2";
--      when 3 => report "3";
--      when 4 => report "4";
--      when 5 => report "5";
--      when 6 => report "6";
--      when 7 => report "7";
--      when others => report "HUH?";
--    end case;
    for i in 0 to 7 loop
      -- report "IN" severity note;
      if (count = 6) then
        D_Last := D;
        if (data(i) = '0') then
          count := 1;
        else
          count := 0;
        end if;
        D <= not(D);
        D_MIN <= D;
        wait for 8*Period;
        if (data(i) = '0') then
          D <= not(D_Last);
          D_MIN <= D_Last;
        else
          D <= (D_LAST);
          D_MIN <= not(D_Last);
        end if;
      else
        if (data(i) = '0') then
          count := 0;
          D <= not(D);
          D_MIN <= D;
        else
          count := count + 1;
          D <= D;
          D_MIN <= not(D);
        end if;
      end if;
      wait for 8*Period;
      bc_count := count;
    end loop;
  end HEXtoNRZI;
  
procedure STRINGtoNRZI (
  constant word: IN string;
  constant length: IN integer;
  variable bc_count: inout integer;
  signal D: inout std_logic;
  signal D_MIN: out std_logic) is
  variable count: integer;
  variable D_Last: std_logic;
  variable data: std_logic_vector(7 downto 0);
  begin
    count := bc_count;
    for i in 1 to length loop
      data := CONV_STD_LOGIC_VECTOR(CONV_INTEGER(CHARACTER'POS(word(i))), 8);
      for i in 0 to 7 loop
        if (data(i) = '0') then
          count := 0;
          D <= not(D);
          D_MIN <= D;
        else
          if (count = 5) then
            D_Last := D;
            if (data(i) = '0') then
              count := 1;
            else
              count := 0;
            end if;
            D <= not(D);
            D_MIN <= D;
            wait for 8*Period;
            if (data(i) = '0') then
              D <= not(D_Last);
              D_MIN <= D_Last;
            else
              D <= (D_LAST);
              D_MIN <= not(D_Last);
            end if;
          else
            count := count + 1;
            D <= D;
            D_MIN <= not(D);
          end if;
        end if;
        wait for 8*Period;
      end loop;
    end loop;
    bc_count := count;
  end STRINGtoNRZI;
  
  procedure sendEOP (
      constant repeat: IN integer;
      signal d_plus: OUT STD_LOGIC;
      signal d_minus: OUT STD_LOGIC) is
  begin
    for i in 0 to repeat loop
      d_plus <= '0';
      d_minus <= '0';
      wait for 8 * period;
    end loop;
    d_plus <= '1';
    d_minus <= '0';
    wait for 8 * period;
  end sendEOP;
    
begin
  DUT: rmedt_rmedt port map(
                CLK => CLK,
                DM1_RX => DM1_RX,
                DP1_RX => DP1_RX,
                RST => RST,
                SERIAL_IN => SERIAL_IN,
                DATA_IN_H => DATA_IN_H,
                DATA_IN_S => DATA_IN_S,
                BS_ERROR => BS_ERROR,
                BS_ERROR1 => BS_ERROR1,
                CRC_ERROR => CRC_ERROR,
                CRC_ERROR1 => CRC_ERROR1,
                EMPTY => EMPTY,
                EMPTY1 => EMPTY1,
                FULL => FULL,
                FULL1 => FULL1,
                R_ERROR => R_ERROR,
                R_ERROR1 => R_ERROR1,
                W_ENABLE_H => W_ENABLE_H,
                R_ENABLE_H => R_ENABLE_H,
                W_ENABLE_S => W_ENABLE_S,
                R_ENABLE_S => R_ENABLE_S,
                DATA_H => DATA_H,
                DATA_S => DATA_S,
                ADDR_H => ADDR_H,
                ADDR_S => ADDR_S
                );
Memory_H: scalable_off_chip_sram
    generic map (
      -- Memory interface parameters
      ADDR_SIZE_BITS	=> 8,
      WORD_SIZE_BYTES	=> 1,
      DATA_SIZE_WORDS	=> 1,
      READ_DELAY			=> (Period - 2 ns),	-- CLK is 2 ns longer than access delay for conservative padding for flipflop setup times and propagation delays from the external SRAM chip to the internal flipflops
      WRITE_DELAY			=> (Period - 2 ns)		-- CLK is 2 ns longer than access delay for conservative padding for Real SRAM hold times and propagation delays from the internal flipflops to the external SRAM chip
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

      r_enable	=> r_enable_H,
      w_enable	=> w_enable_H,
      addr			=> addr_H,
      data			=> sram_data_H
    );
    
  Memory_S: scalable_off_chip_sram
    generic map (
      -- Memory interface parameters
      ADDR_SIZE_BITS	=> 8,
      WORD_SIZE_BYTES	=> 1,
      DATA_SIZE_WORDS	=> 1,
      READ_DELAY			=> (Period - 2 ns),	-- CLK is 2 ns longer than access delay for conservative padding for flipflop setup times and propagation delays from the external SRAM chip to the internal flipflops
      WRITE_DELAY			=> (Period - 2 ns)		-- CLK is 2 ns longer than access delay for conservative padding for Real SRAM hold times and propagation delays from the internal flipflops to the external SRAM chip
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
      
      -- Memory interface signa
      r_enable	=> r_enable_S,
      w_enable	=> w_enable_S,
      addr			=> addr_S,
      data			=> sram_data_s
    );
--   GOLD: <GOLD_NAME> port map(<put mappings here>);
autoClock: process
  BEGIN
    clk <= '0';
    wait for period/2;
    clk <= '1';
    wait for period/2;
  END process autoClock;
  
IO_DATA: process (W_ENABLE_H, W_ENABLE_S, R_ENABLE_H, R_ENABLE_S, sram_DATA_H, sram_DATA_S, DATA_H, DATA_S)
  begin
    if (r_enable_h = '1') then
      -- Read mode -> the data pins should connect to the r_data bus & the other bus should float
      DATA_IN_H	<= sram_data_H;
      sram_data_H				<= (others=>'Z');
    elsif(w_enable_h = '1') then
      -- Write mode -> the data pins should connect to the w_data bus & the other bus should float
      DATA_IN_H	<= (others=>'Z');
      sram_data_H	<= DATA_H;
    else
      -- Disconnect both busses
      DATA_IN_H	<= (others=>'Z');
      sram_data_H				<= (others=>'Z');
    end if;
    
    if (r_enable_s = '1') then
      -- Read mode -> the data pins should connect to the r_data bus & the other bus should float
      DATA_IN_S	<= sram_data_S;
      sram_data_S				<= (others=>'Z');
    elsif(w_enable_s = '1') then
      -- Write mode -> the data pins should connect to the w_data bus & the other bus should float
      DATA_IN_S	<= (others=>'Z');
      sram_data_S	<= DATA_S;
    else
      -- Disconnect both busses
      DATA_IN_S	<= (others=>'Z');
      sram_data_S				<= (others=>'Z');
    end if;
  end process IO_DATA;  
process
  variable bc: integer;
    begin
    bc := 0;
  -- Insert TEST BENCH Code Here
    RST <= '1';
    DP1_RX <= '1';
    DM1_RX <= '0';
    SERIAL_IN <= '1';
    wait for 12 ns;
    RST <= '0';
    wait for 12 ns;
    
    sendUART(x"21", serial_in); -- !
    sendUART(x"21", serial_in); -- !
    sendUART(x"54", serial_in); -- T
    sendUART(x"45", serial_in); -- E
    sendUART(x"52", serial_in); -- R
    sendUART(x"43", serial_in); -- C
    sendUART(x"45", serial_in); -- E
    sendUART(x"53", serial_in); -- S
    sendUART("11110111", serial_in); -- correct parity
    
    wait for 30 us;
    
    HEXtoNRZI("10000000", BC, DP1_RX, DM1_RX);
    HEXtoNRZI(x"39", BC, DP1_RX, DM1_RX);
    STRINGtoNRZI("This is a very long string to test transmitter correctness", 58, BC, DP1_RX, DM1_RX);
    HEXtoNRZI(x"68", BC, DP1_RX, DM1_RX);
    HEXtoNRZI(x"06", BC, DP1_RX, DM1_RX);
    sendEOP(1, DP1_RX, DM1_RX);
    BC := 0;
    
    report "Begin normal operation" severity note;
    HEXtoNRZI("10000000", BC, DP1_RX, DM1_RX);
    HEXtoNRZI(x"39", BC, DP1_RX, DM1_RX);
    STRINGtoNRZI("Another very long string to test transmitter correctness", 56, BC, DP1_RX, DM1_RX);
    HEXtoNRZI(x"DE", BC, DP1_RX, DM1_RX);
    HEXtoNRZI(x"9F", BC, DP1_RX, DM1_RX);
    sendEOP(1, DP1_RX, DM1_RX);
    BC := 0;
    
    HEXtoNRZI("10000000", BC, DP1_RX, DM1_RX);
    HEXtoNRZI(x"39", BC, DP1_RX, DM1_RX);
    STRINGtoNRZI("Short", 5, BC, DP1_RX, DM1_RX);
    HEXtoNRZI(x"93", BC, DP1_RX, DM1_RX);
    HEXtoNRZI(x"6B", BC, DP1_RX, DM1_RX);
    sendEOP(1, DP1_RX, DM1_RX);
    BC := 0;
    
    HEXtoNRZI("10000000", BC, DP1_RX, DM1_RX);
    HEXtoNRZI(x"39", BC, DP1_RX, DM1_RX);
    STRINGtoNRZI("Short", 5, BC, DP1_RX, DM1_RX);
    HEXtoNRZI(x"93", BC, DP1_RX, DM1_RX);
    HEXtoNRZI(x"6B", BC, DP1_RX, DM1_RX);
    sendEOP(1, DP1_RX, DM1_RX);
    BC := 0;
    
    wait;
    --CLK <= 
    --DM1_RX <= 
    --DP1_RX <= 
    --RST <= 
    --SERIAL_IN <= 

  end process;
end TEST;
