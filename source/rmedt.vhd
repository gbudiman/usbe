-- VHDL Entity My_Lib.RMEDT.symbol
--
-- Created:
--          by - mg28.bin (srge09.ecn.purdue.edu)
--          at - 16:11:43 12/03/10
--
-- Generated by Mentor Graphics' HDL Designer(TM) 2009.2 (Build 10)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY RMEDT IS
   PORT( 
      CLK        : IN     std_logic;
      DM1_RX     : IN     std_logic;
      DP1_RX     : IN     std_logic;
      RST        : IN     std_logic;
      SERIAL_IN  : IN     std_logic;
      CRC_ERROR  : OUT    std_logic;
      EMPTY      : OUT    STD_LOGIC;
      FULL       : OUT    STD_LOGIC;
      KEY_ERROR  : OUT    std_logic;
      PROG_ERROR : OUT    std_logic;
      PARITY_ERROR: OUT   std_logic;
      RBUF_FULL  : OUT    std_logic;
      R_ERROR    : OUT    std_logic;
      SENDING    : OUT    std_logic;
      dm_tx_out  : OUT    std_logic;
      dp_tx_out  : OUT    std_logic
   );

-- Declarations

END RMEDT ;

--
-- VHDL Architecture My_Lib.RMEDT.struct
--
-- Created:
--          by - mg28.bin (srge09.ecn.purdue.edu)
--          at - 16:11:43 12/03/10
--
-- Generated by Mentor Graphics' HDL Designer(TM) 2009.2 (Build 10)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

--  LIBRARY My_Lib;

ARCHITECTURE struct OF RMEDT IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL NEXT_BYTE      : STD_LOGIC;
   SIGNAL PDATA_READY    : STD_LOGIC;
   SIGNAL PRGA_OPCODE    : STD_LOGIC_VECTOR(1 DOWNTO 0);
   SIGNAL PROCESSED_DATA : STD_LOGIC_VECTOR(7 DOWNTO 0);


   -- Component Declarations
   COMPONENT RMED
   PORT (
      CLK            : IN     std_logic ;
      DM1_RX         : IN     std_logic ;
      DP1_RX         : IN     std_logic ;
      NEXT_BYTE      : IN     STD_LOGIC ;
      RST            : IN     std_logic ;
      SERIAL_IN      : IN     std_logic ;
      CRC_ERROR      : OUT    std_logic ;
      EMPTY          : OUT    STD_LOGIC ;
      FULL           : OUT    STD_LOGIC ;
      KEY_ERROR      : OUT    std_logic ;
      PDATA_READY    : OUT    STD_LOGIC ;
      PRGA_OPCODE    : OUT    STD_LOGIC_VECTOR (1 DOWNTO 0);
      PROCESSED_DATA : OUT    STD_LOGIC_VECTOR (7 DOWNTO 0);
      PROG_ERROR     : OUT    std_logic ;
      PARITY_ERROR   : OUT    std_logic;
      RBUF_FULL      : OUT    std_logic ;
      R_ERROR        : OUT    std_logic 
   );
   END COMPONENT;
   COMPONENT transmitter_block
   PORT (
      PRGA_OUT    : IN     std_logic_vector (7 DOWNTO 0);
      clk         : IN     std_logic;
      p_ready     : IN     std_logic;
      prga_opcode : IN     std_logic_vector (1 DOWNTO 0);
      rst         : IN     std_logic;
      NEXT_BYTE   : OUT    std_logic;
      SENDING     : OUT    std_logic;
      dm_tx_out   : OUT    std_logic;
      dp_tx_out   : OUT    std_logic
   );
   END COMPONENT;

   -- Optional embedded configurations
   -- pragma synthesis_off
   --FOR ALL : RMED USE ENTITY My_Lib.RMED;
   --FOR ALL : transmitter_block USE ENTITY My_Lib.transmitter_block;
   -- pragma synthesis_on


BEGIN

   -- Instance port mappings.
   U_0 : RMED
      PORT MAP (
         CLK            => CLK,
         DM1_RX         => DM1_RX,
         DP1_RX         => DP1_RX,
         NEXT_BYTE      => NEXT_BYTE,
         RST            => RST,
         SERIAL_IN      => SERIAL_IN,
         CRC_ERROR      => CRC_ERROR,
         EMPTY          => EMPTY,
         FULL           => FULL,
         KEY_ERROR      => KEY_ERROR,
         PDATA_READY    => PDATA_READY,
         PRGA_OPCODE    => PRGA_OPCODE,
         PROCESSED_DATA => PROCESSED_DATA,
         PROG_ERROR     => PROG_ERROR,
         PARITY_ERROR   => PARITY_ERROR,
         RBUF_FULL      => RBUF_FULL,
         R_ERROR        => R_ERROR
      );
   U_1 : transmitter_block
      PORT MAP (
         PRGA_OUT    => PROCESSED_DATA,
         clk         => CLK,
         p_ready     => PDATA_READY,
         prga_opcode => PRGA_OPCODE,
         rst         => RST,
         SENDING     => SENDING,
         dm_tx_out   => dm_tx_out,
         dp_tx_out   => dp_tx_out,
         NEXT_BYTE   => NEXT_BYTE
      );

END struct;
