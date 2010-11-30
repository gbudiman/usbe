-- VHDL Entity USBE_RX_lib.Receiver_Block.symbol
--
-- Created:
--          by - mg47.bin (srge00.ecn.purdue.edu)
--          at - 15:21:39 11/30/10
--
-- Generated by Mentor Graphics' HDL Designer(TM) 2009.2 (Build 10)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY Receiver_Block IS
   PORT( 
      CLK       : IN     std_logic;
      DM1_RX    : IN     std_logic;
      DP1_RX    : IN     std_logic;
      RST       : IN     std_logic;
      CRC_ERROR : OUT    std_logic;
      OPCODE    : OUT    std_logic_vector (1 DOWNTO 0);
      RCV_DATA  : OUT    std_logic_vector (7 DOWNTO 0);
      R_ERROR   : OUT    std_logic;
      W_ENABLE  : OUT    std_logic
   );

-- Declarations

END Receiver_Block ;

--
-- VHDL Architecture USBE_RX_lib.Receiver_Block.struct
--
-- Created:
--          by - mg47.bin (srge00.ecn.purdue.edu)
--          at - 15:21:39 11/30/10
--
-- Generated by Mentor Graphics' HDL Designer(TM) 2009.2 (Build 10)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

ARCHITECTURE struct OF Receiver_Block IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL BITSTUFF     : std_logic;
   SIGNAL D_EDGE       : std_logic;
   SIGNAL D_ORIG       : std_logic;
   SIGNAL EOP          : std_logic;
   SIGNAL RCVING       : std_logic;
   SIGNAL RX_CRC       : std_logic_vector(15 DOWNTO 0);
   SIGNAL SHIFT_ENABLE : std_logic;
   SIGNAL rx_CHECK_CRC : std_logic_vector(15 DOWNTO 0);

   -- Implicit buffer signal declarations
   SIGNAL OPCODE_internal   : std_logic_vector (1 DOWNTO 0);
   SIGNAL RCV_DATA_internal : std_logic_vector (7 DOWNTO 0);
   SIGNAL W_ENABLE_internal : std_logic;


   -- Component Declarations
   COMPONENT rx_CRC_CALC
   PORT (
      CLK      : IN     std_logic;
      OPCODE   : IN     std_logic_vector (1 DOWNTO 0);
      RCV_DATA : IN     std_logic_vector (7 DOWNTO 0);
      RST      : IN     std_logic;
      W_ENABLE : IN     std_logic;
      RX_CRC   : OUT    std_logic_vector (15 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT rx_accumulator
   PORT (
      CLK          : IN     std_logic;
      RCV_DATA     : IN     std_logic_vector (7 DOWNTO 0);
      RST          : IN     std_logic;
      W_ENABLE     : IN     std_logic;
      rx_CHECK_CRC : OUT    std_logic_vector (15 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT rx_decode
   PORT (
      CLK          : IN     std_logic;
      DP1_RX       : IN     std_logic;
      EOP          : IN     std_logic;
      RST          : IN     std_logic;
      SHIFT_ENABLE : IN     std_logic;
      BITSTUFF     : OUT    std_logic;
      D_ORIG       : OUT    std_logic
   );
   END COMPONENT;
   COMPONENT rx_edgedetect
   PORT (
      CLK    : IN     std_logic;
      DP1_RX : IN     std_logic;
      RST    : IN     std_logic;
      D_EDGE : OUT    std_logic
   );
   END COMPONENT;
   COMPONENT rx_eopdetect
   PORT (
      DM1_RX : IN     std_logic;
      DP1_RX : IN     std_logic;
      EOP    : OUT    std_logic
   );
   END COMPONENT;
   COMPONENT rx_rcu
   PORT (
      BITSTUFF     : IN     std_logic;
      CLK          : IN     std_logic;
      D_EDGE       : IN     std_logic;
      EOP          : IN     std_logic;
      RCV_DATA     : IN     std_logic_vector (7 DOWNTO 0);
      RST          : IN     std_logic;
      RX_CHECK_CRC : IN     std_logic_vector (15 DOWNTO 0);
      RX_CRC       : IN     std_logic_vector (15 DOWNTO 0);
      SHIFT_ENABLE : IN     std_logic;
      CRC_ERROR    : OUT    std_logic;
      OPCODE       : OUT    std_logic_vector (1 DOWNTO 0);
      RCVING       : OUT    std_logic;
      R_ERROR      : OUT    std_logic;
      W_ENABLE     : OUT    std_logic
   );
   END COMPONENT;
   COMPONENT rx_shift_reg
   PORT (
      BITSTUFF     : IN     std_logic;
      CLK          : IN     std_logic;
      D_ORIG       : IN     std_logic;
      RST          : IN     std_logic;
      SHIFT_ENABLE : IN     std_logic;
      RCV_DATA     : OUT    std_logic_vector (7 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT rx_timer
   PORT (
      CLK          : IN     std_logic;
      D_EDGE       : IN     std_logic;
      RCVING       : IN     std_logic;
      RST          : IN     std_logic;
      SHIFT_ENABLE : OUT    std_logic
   );
   END COMPONENT;

--   -- Optional embedded configurations
--   -- pragma synthesis_off
--   FOR ALL : rx_CRC_CALC USE ENTITY USBE_RX_lib.rx_CRC_CALC;
--   FOR ALL : rx_accumulator USE ENTITY USBE_RX_lib.rx_accumulator;
--   FOR ALL : rx_decode USE ENTITY USBE_RX_lib.rx_decode;
--   FOR ALL : rx_edgedetect USE ENTITY USBE_RX_lib.rx_edgedetect;
--   FOR ALL : rx_eopdetect USE ENTITY USBE_RX_lib.rx_eopdetect;
--   FOR ALL : rx_rcu USE ENTITY USBE_RX_lib.rx_rcu;
--   FOR ALL : rx_shift_reg USE ENTITY USBE_RX_lib.rx_shift_reg;
--   FOR ALL : rx_timer USE ENTITY USBE_RX_lib.rx_timer;
--   -- pragma synthesis_on


BEGIN

   -- Instance port mappings.
   U_1 : rx_CRC_CALC
      PORT MAP (
         CLK      => CLK,
         RST      => RST,
         W_ENABLE => W_ENABLE_internal,
         OPCODE   => OPCODE_internal,
         RCV_DATA => RCV_DATA_internal,
         RX_CRC   => RX_CRC
      );
   U_0 : rx_accumulator
      PORT MAP (
         CLK          => CLK,
         RST          => RST,
         RCV_DATA     => RCV_DATA_internal,
         W_ENABLE     => W_ENABLE_internal,
         rx_CHECK_CRC => rx_CHECK_CRC
      );
   U_2 : rx_decode
      PORT MAP (
         CLK          => CLK,
         RST          => RST,
         DP1_RX       => DP1_RX,
         SHIFT_ENABLE => SHIFT_ENABLE,
         EOP          => EOP,
         D_ORIG       => D_ORIG,
         BITSTUFF     => BITSTUFF
      );
   U_4 : rx_edgedetect
      PORT MAP (
         CLK    => CLK,
         RST    => RST,
         DP1_RX => DP1_RX,
         D_EDGE => D_EDGE
      );
   U_3 : rx_eopdetect
      PORT MAP (
         DP1_RX => DP1_RX,
         DM1_RX => DM1_RX,
         EOP    => EOP
      );
   U_5 : rx_rcu
      PORT MAP (
         CLK          => CLK,
         RST          => RST,
         D_EDGE       => D_EDGE,
         EOP          => EOP,
         SHIFT_ENABLE => SHIFT_ENABLE,
         BITSTUFF     => BITSTUFF,
         RX_CRC       => RX_CRC,
         RX_CHECK_CRC => rx_CHECK_CRC,
         RCV_DATA     => RCV_DATA_internal,
         RCVING       => RCVING,
         W_ENABLE     => W_ENABLE_internal,
         R_ERROR      => R_ERROR,
         CRC_ERROR    => CRC_ERROR,
         OPCODE       => OPCODE_internal
      );
   U_6 : rx_shift_reg
      PORT MAP (
         CLK          => CLK,
         RST          => RST,
         SHIFT_ENABLE => SHIFT_ENABLE,
         D_ORIG       => D_ORIG,
         BITSTUFF     => BITSTUFF,
         RCV_DATA     => RCV_DATA_internal
      );
   U_7 : rx_timer
      PORT MAP (
         CLK          => CLK,
         RST          => RST,
         D_EDGE       => D_EDGE,
         RCVING       => RCVING,
         SHIFT_ENABLE => SHIFT_ENABLE
      );

   -- Implicit buffered output assignments
   OPCODE   <= OPCODE_internal;
   RCV_DATA <= RCV_DATA_internal;
   W_ENABLE <= W_ENABLE_internal;

END struct;
