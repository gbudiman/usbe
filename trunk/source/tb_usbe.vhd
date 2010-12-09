-- $Id: $
-- File name:   tb_rmedt_square.vhd
-- Created:     12/6/2010
-- Author:      Gloria Budiman
-- Lab Section: 337-02
-- Version:     1.0  Initial Test Bench

library IEEE;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library ECE337_IP;
use ECE337_IP.all;

--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model

entity tb_usbe is
  generic (Period : Time :=  10.4167 ns);
end tb_usbe;

architecture TEST of tb_usbe is

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

  component rmedt_square
    PORT(
      CLK              : IN     std_logic;
      DMRH             : IN     std_logic;
      DMRS             : IN     std_logic;
      DPRH             : IN     std_logic;
      DPRS             : IN     std_logic;
      RST              : IN     std_logic;
      SERIAL_IN        : IN     std_logic;
      DATA_IN_H, DATA_IN_S: IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      BSE_H            : OUT    std_logic;
      BSE_S            : OUT    std_logic;
      CRCE_H           : OUT    std_logic;
      CRCE_S           : OUT    std_logic;
      DMTH             : OUT    std_logic;
      DMTS             : OUT    std_logic;
      DPTH             : OUT    std_logic;
      DPTS             : OUT    std_logic;
      EMPTY_H          : OUT    STD_LOGIC;
      EMPTY_S          : OUT    STD_LOGIC;
      FULL_H           : OUT    STD_LOGIC;
      FULL_S           : OUT    STD_LOGIC;
      RE_H             : OUT    std_logic;
      RE_S             : OUT    std_logic;
      c_key_error      : OUT    std_logic;
      c_parity_error   : OUT    std_logic;
      c_prog_error     : OUT    std_logic;
      host_is_sending  : OUT    std_logic;
      slave_is_sending : OUT    std_logic;
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
  signal DMRH : std_logic;
  signal DMRS : std_logic;
  signal DPRH : std_logic;
  signal DPRS : std_logic;
  signal RST : std_logic;
  signal SERIAL_IN : std_logic;
  signal DATA_IN_H, DATA_IN_S: STD_LOGIC_VECTOR(7 DOWNTO 0);
  signal BSE_H : std_logic;
  signal BSE_S : std_logic;
  signal CRCE_H : std_logic;
  signal CRCE_S : std_logic;
  signal DMTH : std_logic;
  signal DMTS : std_logic;
  signal DPTH : std_logic;
  signal DPTS : std_logic;
  signal EMPTY_H : STD_LOGIC;
  signal EMPTY_S : STD_LOGIC;
  signal FULL_H : STD_LOGIC;
  signal FULL_S : STD_LOGIC;
  signal RE_H : std_logic;
  signal RE_S : std_logic;
  signal c_key_error : std_logic;
  signal c_parity_error : std_logic;
  signal c_prog_error : std_logic;
  signal DPHS : std_logic;
  signal DPSS : std_logic;
  signal DMHS : std_logic;
  signal DMSS : std_logic;
  signal DPTS_ex : std_logic;
  signal DMTS_ex : std_logic;
  signal DPTH_ex : std_logic;
  signal DMTH_ex : std_logic;
  signal host_is_sending : std_logic;
  signal slave_is_sending : std_logic;
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
        wait for 8* Period;
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
  
procedure SHEXtoNRZI (
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
        wait for 8*1.025 * Period;
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
      wait for 8*1.025*Period;
      bc_count := count;
    end loop;
  end SHEXtoNRZI;
  
  procedure FHEXtoNRZI (
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
        wait for 8 * 0.975 * Period;
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
      wait for 8 * 0.975 * Period;
      bc_count := count;
    end loop;
  end FHEXtoNRZI;
  
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
  DUT: rmedt_square port map(
                CLK => CLK,
                RST => RST,
                DMRH => DMRH,
                DMRS => DMRS,
                DPRH => DPRH,
                DPRS => DPRS,
                DMTH => DMTH,
                DMTS => DMTS,
                DPTH => DPTH,
                DPTS => DPTS,
                SERIAL_IN => SERIAL_IN,
                DATA_IN_H => DATA_IN_H,
                DATA_IN_S => DATA_IN_S,
                BSE_H => BSE_H,
                BSE_S => BSE_S,
                CRCE_H => CRCE_H,
                CRCE_S => CRCE_S,
                EMPTY_H => EMPTY_H,
                EMPTY_S => EMPTY_S,
                FULL_H => FULL_H,
                FULL_S => FULL_S,
                RE_H => RE_H,
                RE_S => RE_S,
                c_key_error => c_key_error,
                c_parity_error => c_parity_error,
                c_prog_error => c_prog_error,
                host_is_sending => host_is_sending,
                slave_is_sending => slave_is_sending,
                W_ENABLE_H => W_ENABLE_H,
                W_ENABLE_S => W_ENABLE_S,
                R_ENABLE_H => R_ENABLE_H,
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
  DPHS <= '1';
  DMHS <= '0';
  DPSS <= 'H';
  DMSS <= 'L';
  SERIAL_IN <= '1';
  wait for 12 ns;
  RST <= '0';
  wait for 12 ns;
  report "Wrong Parity" severity note;
  sendUART(x"21", serial_in); -- !
  sendUART(x"21", serial_in); -- !
  sendUART(x"54", serial_in); -- T
  sendUART(x"45", serial_in); -- E
  sendUART(x"52", serial_in); -- R
  sendUART(x"43", serial_in); -- C
  sendUART(x"45", serial_in); -- E
  sendUART(x"53", serial_in); -- S
  sendUART(x"36", serial_in); -- wrong parity
  report "Correct Parity" severity note;
  sendUART(x"21", serial_in); -- !
  sendUART(x"21", serial_in); -- !
  sendUART(x"54", serial_in); -- T
  sendUART(x"45", serial_in); -- E
  sendUART(x"52", serial_in); -- R
  sendUART(x"43", serial_in); -- C
  sendUART(x"45", serial_in); -- E
  sendUART(x"53", serial_in); -- S
  sendUART("11110111", serial_in); -- correct parity
  
  wait for 24 us;
  
  report "Send unencrypted input and get encrypted output with correct CRC" severity note;
  
  HEXtoNRZI("10000000", BC, DPHS, DMHS);
  HEXtoNRZI(x"39", BC, DPHS, DMHS);
  STRINGtoNRZI("Unencrypted input", 17, BC, DPHS, DMHS);
  HEXtoNRZI(x"EC", BC, DPHS, DMHS);
  HEXtoNRZI(x"A6", BC, DPHS, DMHS);
  sendEOP(0, DPHS, DMHS);
  BC := 0;
  wait for 12 us;
  
  wait for 12 us;
  report "Bitstuff error" severity note;
  HEXtoNRZI("10000000", BC, DPHS, DMHS);
  HEXtoNRZI(x"39", BC, DPHS, DMHS);
  sendByteFast("11111111", 0, DPHS, DMHS);
  HEXtoNRZI(x"39", BC, DPHS, DMHS);
  HEXtoNRZI(x"39", BC, DPHS, DMHS);
  sendEOP(0, DPHS, DMHS);
  wait for 12 us;
  
  wait for 12 us;
  report "improper number of bits" severity note;
  HEXtoNRZI("10000000", BC, DPHS, DMHS);
  HEXtoNRZI(x"39", BC, DPHS, DMHS);
  sendByteFast("00000000", 7, DPHS, DMHS);
  HEXtoNRZI(x"39", BC, DPHS, DMHS);
  HEXtoNRZI(x"39", BC, DPHS, DMHS);
  sendEOP(0, DPHS, DMHS);
  
  wait for 12 us;
  report "Bitstuff 1's example" severity note;
  HEXtoNRZI("10000000", BC, DPHS, DMHS);
  HEXtoNRZI(x"FF", BC, DPHS, DMHS);
  HEXtoNRZI(x"AA", BC, DPHS, DMHS);
  HEXtoNRZI(x"AA", BC, DPHS, DMHS);
  sendEOP(0, DPHS, DMHS);
  
  wait for 12 us;
  report "Bitstuff 0's example" severity note;
  HEXtoNRZI("10000000", BC, DPHS, DMHS);
  HEXtoNRZI(x"00", BC, DPHS, DMHS);
  HEXtoNRZI(x"AA", BC, DPHS, DMHS);
  HEXtoNRZI(x"AA", BC, DPHS, DMHS);
  sendEOP(0, DPHS, DMHS);
  report "RESET!!!@!@" severity note;
  rst<='1';
  wait for 20 ns;
  rst<='0';
  wait for 10 us;
  report "Fresh key to check encrypted input" severity note;
  sendUART(x"22", serial_in); -- "
  sendUART(x"54", serial_in); -- T
  sendUART(x"45", serial_in); -- E
  sendUART(x"52", serial_in); -- R
  sendUART(x"43", serial_in); -- C
  sendUART(x"45", serial_in); -- E
  sendUART(x"53", serial_in); -- S
  sendUART(x"22", serial_in); -- "
  sendUART("11110101", serial_in); -- parity
  
  DPSS <= '1';
  DMSS <= '0';
  DPHS <= 'H';
  DMHS <= 'L';
  wait for 24 us;  
  
  report "Send encrypted input and get unencrypted output with incorrect CRC" severity note;
  
  HEXtoNRZI("10000000", BC, DPSS, DMSS);
  HEXtoNRZI(x"90", BC, DPSS, DMSS);
  HEXtoNRZI(x"EA", BC, DPSS, DMSS);
  HEXtoNRZI(x"BE", BC, DPSS, DMSS);
  HEXtoNRZI(x"FE", BC, DPSS, DMSS);
  HEXtoNRZI(x"DC", BC, DPSS, DMSS);
  HEXtoNRZI(x"EB", BC, DPSS, DMSS);
  HEXtoNRZI(x"E2", BC, DPSS, DMSS);
  HEXtoNRZI(x"8A", BC, DPSS, DMSS);
  HEXtoNRZI(x"DE", BC, DPSS, DMSS);
  HEXtoNRZI(x"3C", BC, DPSS, DMSS);
  HEXtoNRZI(x"25", BC, DPSS, DMSS);
  HEXtoNRZI(x"DD", BC, DPSS, DMSS);
  HEXtoNRZI(x"FE", BC, DPSS, DMSS);
  HEXtoNRZI(x"33", BC, DPSS, DMSS);
  HEXtoNRZI(x"2D", BC, DPSS, DMSS);
  HEXtoNRZI(x"96", BC, DPSS, DMSS);
  HEXtoNRZI(x"20", BC, DPSS, DMSS);
  HEXtoNRZI(x"E4", BC, DPSS, DMSS);
  sendEOP(0, DPSS, DMSS); 
  wait for 12 us;
  report "Send encrypted input FAST and get nonsense output with incorrect CRC" severity note;
  
  FHEXtoNRZI("10000000", BC, DPSS, DMSS);
  FHEXtoNRZI(x"90", BC, DPSS, DMSS);
  FHEXtoNRZI(x"EA", BC, DPSS, DMSS);
  FHEXtoNRZI(x"BE", BC, DPSS, DMSS);
  FHEXtoNRZI(x"FE", BC, DPSS, DMSS);
  FHEXtoNRZI(x"DC", BC, DPSS, DMSS);
  FHEXtoNRZI(x"EB", BC, DPSS, DMSS);
  FHEXtoNRZI(x"E2", BC, DPSS, DMSS);
  FHEXtoNRZI(x"8A", BC, DPSS, DMSS);
  FHEXtoNRZI(x"DE", BC, DPSS, DMSS);
  FHEXtoNRZI(x"3C", BC, DPSS, DMSS);
  FHEXtoNRZI(x"25", BC, DPSS, DMSS);
  FHEXtoNRZI(x"DD", BC, DPSS, DMSS);
  FHEXtoNRZI(x"FE", BC, DPSS, DMSS);
  FHEXtoNRZI(x"33", BC, DPSS, DMSS);
  FHEXtoNRZI(x"2D", BC, DPSS, DMSS);
  FHEXtoNRZI(x"96", BC, DPSS, DMSS);
  FHEXtoNRZI(x"20", BC, DPSS, DMSS);
  FHEXtoNRZI(x"E4", BC, DPSS, DMSS);
  sendEOP(0, DPSS, DMSS); 
  
  report "Immediately Send encrypted input SLOW and get nonsense output with incorrect CRC" severity note;
  
  SHEXtoNRZI("10000000", BC, DPSS, DMSS);
  SHEXtoNRZI(x"90", BC, DPSS, DMSS);
  SHEXtoNRZI(x"EA", BC, DPSS, DMSS);
  SHEXtoNRZI(x"BE", BC, DPSS, DMSS);
  SHEXtoNRZI(x"FE", BC, DPSS, DMSS);
  SHEXtoNRZI(x"DC", BC, DPSS, DMSS);
  SHEXtoNRZI(x"EB", BC, DPSS, DMSS);
  SHEXtoNRZI(x"E2", BC, DPSS, DMSS);
  SHEXtoNRZI(x"8A", BC, DPSS, DMSS);
  SHEXtoNRZI(x"DE", BC, DPSS, DMSS);
  SHEXtoNRZI(x"3C", BC, DPSS, DMSS);
  SHEXtoNRZI(x"25", BC, DPSS, DMSS);
  SHEXtoNRZI(x"DD", BC, DPSS, DMSS);
  SHEXtoNRZI(x"FE", BC, DPSS, DMSS);
  SHEXtoNRZI(x"33", BC, DPSS, DMSS);
  SHEXtoNRZI(x"2D", BC, DPSS, DMSS);
  SHEXtoNRZI(x"96", BC, DPSS, DMSS);
  SHEXtoNRZI(x"20", BC, DPSS, DMSS);
  SHEXtoNRZI(x"E4", BC, DPSS, DMSS);
  sendEOP(0, DPSS, DMSS); 
  
  wait;
    --CLK <= 
--    DMRH <= 
--    DMRS <= 
--    DPRH <= 
--    DPRS <= 
--    RST <= 
--    SERIAL_IN <= 

  end process;
  
  DPTH_ex <= 'Z' WHEN slave_is_sending = '0' ELSE DPTH;
  DMTH_ex <= 'Z' WHEN slave_is_sending = '0' ELSE DMTH;
  DPTS_ex <= 'Z' WHEN host_is_sending = '0' ELSE DPTS;
  DMTS_ex <= 'Z' WHEN host_is_sending = '0' ELSE DMTS;
  
  DPHS <= DPTH_ex WHEN slave_is_sending = '1' ELSE 'H';
  DMHS <= DMTH_ex WHEN slave_is_sending = '1' ELSE 'L';
  DPSS <= DPTS_ex WHEN host_is_sending = '1' ELSE 'H';
  DMSS <= DMTS_ex WHEN host_is_sending = '1' ELSE 'L';
  
  DPRH <= DPHS WHEN slave_is_sending = '0' ELSE 'H';
  DMRH <= DMHS WHEN slave_is_sending = '0' ELSE 'L';
  DPRS <= DPSS WHEN host_is_sending = '0' ELSE 'H';
  DMRS <= DMSS WHEN host_is_sending = '0' ELSE 'L';
  
end TEST;