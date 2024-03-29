-- VHDL Entity USBE_FULL.USBE.symbol
--
-- Created:
--          by - mg47.bin (srge04.ecn.purdue.edu)
--          at - 21:07:40 12/04/10
--
-- Generated by Mentor Graphics' HDL Designer(TM) 2009.2 (Build 10)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY USBE IS
   PORT( 
      CLK               : IN     std_logic;
      RST               : IN     std_logic;
      SERIAL_IN         : IN     std_logic;
      CRC_ERROR_HOST    : OUT    std_logic;
      CRC_ERROR_SLAVE   : OUT    std_logic;
      EMPTY_HOST        : OUT    STD_LOGIC;
      EMPTY_SLAVE       : OUT    STD_LOGIC;
      FULL_HOST         : OUT    STD_LOGIC;
      FULL_SLAVE        : OUT    STD_LOGIC;
      KEY_ERROR         : OUT    std_logic;
      PARITY_ERROR      : OUT    std_logic;
      PROG_ERROR        : OUT    std_logic;
      BS_ERROR_HOST     : OUT    std_logic;
      BS_ERROR_SLAVE    : OUT    std_logic;
      R_ERROR_HOST      : OUT    std_logic;
      R_ERROR_SLAVE     : OUT    std_logic;
      D_MINUS_HOSTSIDE  : INOUT  std_logic;
      D_MINUS_SLAVESIDE : INOUT  std_logic;
      D_PLUS_HOSTSIDE   : INOUT  std_logic;
      D_PLUS_SLAVESIDE  : INOUT  std_logic
   );

-- Declarations

END USBE ;

--
-- VHDL Architecture USBE_FULL.USBE.struct
--
-- Created:
--          by - mg47.bin (srge04.ecn.purdue.edu)
--          at - 21:07:40 12/04/10
--
-- Generated by Mentor Graphics' HDL Designer(TM) 2009.2 (Build 10)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ARCHITECTURE struct OF USBE IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL D_MINUS_RX_HOST  : std_logic;
   SIGNAL D_MINUS_RX_SLAVE : std_logic;
   SIGNAL D_MINUS_TX_HOST  : std_logic;
   SIGNAL D_MINUS_TX_SLAVE : std_logic;
   SIGNAL D_PLUS_RX_HOST   : std_logic;
   SIGNAL D_PLUS_RX_SLAVE  : std_logic;
   SIGNAL D_PLUS_TX_HOST   : std_logic;
   SIGNAL D_PLUS_TX_SLAVE  : std_logic;
   SIGNAL KEY_ERROR1       : std_logic;
   SIGNAL KEY_ERROR2       : std_logic;
   SIGNAL PARITY_ERROR1    : std_logic;
   SIGNAL PARITY_ERROR2    : std_logic;
   SIGNAL PROG_ERROR1      : std_logic;
   SIGNAL PROG_ERROR2      : std_logic;
   SIGNAL Host_is_Sending     : std_logic;
   SIGNAL Slave_is_Sending    : std_logic;
   
   SIGNAL D_PLUS_TX_HOST_ex   : std_logic;
   SIGNAL D_PLUS_TX_SLAVE_ex  : std_logic;
   SIGNAL D_MINUS_TX_HOST_ex  : std_logic;
   SIGNAL D_MINUS_TX_SLAVE_ex : std_logic;

   -- Component Declarations
   COMPONENT rmedt
   PORT (
      CLK          : IN     std_logic;
      DM1_RX       : IN     std_logic;
      DP1_RX       : IN     std_logic;
      RST          : IN     std_logic;
      SERIAL_IN    : IN     std_logic;
      CRC_ERROR    : OUT    std_logic;
      EMPTY        : OUT    STD_LOGIC;
      FULL         : OUT    STD_LOGIC;
      KEY_ERROR    : OUT    std_logic;
      PARITY_ERROR : OUT    std_logic;
      PROG_ERROR   : OUT    std_logic;
      BS_ERROR     : OUT std_logic;
      RBUF_FULL    : OUT    std_logic;
      R_ERROR      : OUT    std_logic;
      SENDING      : OUT    std_logic;
      dm_tx_out    : OUT    std_logic;
      dp_tx_out    : OUT    std_logic
   );
   END COMPONENT;


BEGIN
   -- Architecture concurrent statements
   -- HDL Embedded Text Block 1 eb1
   -- eb1 1
   --THIS NEEDS CODE TOO!!!!!@!@!@                                       

   -- HDL Embedded Text Block 2 eb2
   -- eb2 2
   --THIS NEEDS CODE
   
   -- ModuleWare code(v1.9) for instance 'U_3' of 'nor'
   PROG_ERROR <= PROG_ERROR1 OR PROG_ERROR2;

   -- ModuleWare code(v1.9) for instance 'U_4' of 'nor'
   PARITY_ERROR <= PARITY_ERROR1 OR PARITY_ERROR2;

   -- ModuleWare code(v1.9) for instance 'U_2' of 'or'
   KEY_ERROR <= KEY_ERROR2 OR KEY_ERROR1;

   -- Instance port mappings.
   U_0 : RMEDT
      PORT MAP (
         CLK          => CLK,
         DM1_RX       => D_MINUS_RX_HOST,
         DP1_RX       => D_PLUS_RX_HOST,
         RST          => RST,
         SERIAL_IN    => SERIAL_IN,
         CRC_ERROR    => CRC_ERROR_HOST,
         EMPTY        => EMPTY_HOST,
         FULL         => FULL_HOST,
         KEY_ERROR    => KEY_ERROR1,
         PROG_ERROR   => PROG_ERROR1,
         PARITY_ERROR => PARITY_ERROR1,
         BS_ERROR     => BS_ERROR_HOST,
         RBUF_FULL    => OPEN,
         R_ERROR      => R_ERROR_HOST,
         SENDING      => Host_is_Sending,
         dm_tx_out    => D_MINUS_TX_SLAVE,
         dp_tx_out    => D_PLUS_TX_SLAVE
      );
   U_1 : RMEDT
      PORT MAP (
         CLK          => CLK,
         DM1_RX       => D_MINUS_RX_SLAVE,
         DP1_RX       => D_PLUS_RX_SLAVE,
         RST          => RST,
         SERIAL_IN    => SERIAL_IN,
         CRC_ERROR    => CRC_ERROR_SLAVE,
         EMPTY        => EMPTY_SLAVE,
         FULL         => FULL_SLAVE,
         KEY_ERROR    => KEY_ERROR2,
         PROG_ERROR   => PROG_ERROR2,
         PARITY_ERROR => PARITY_ERROR2,
         BS_ERROR     => BS_ERROR_SLAVE,
         RBUF_FULL    => OPEN,
         R_ERROR      => R_ERROR_SLAVE,
         SENDING      => Slave_is_Sending,
         dm_tx_out    => D_MINUS_TX_HOST,
         dp_tx_out    => D_PLUS_TX_HOST
      );
      

   D_PLUS_TX_HOST_ex <= 'Z' WHEN Slave_is_Sending = '0' ELSE D_PLUS_TX_HOST;
   D_MINUS_TX_HOST_ex <= 'Z' WHEN Slave_is_Sending = '0' ELSE D_MINUS_TX_HOST;
   D_PLUS_TX_SLAVE_ex <= 'Z' WHEN Host_is_Sending = '0' ELSE D_PLUS_TX_SLAVE;
   D_MINUS_TX_SLAVE_ex <= 'Z' WHEN Host_is_Sending = '0' ELSE D_MINUS_TX_SLAVE;
   
   --D_PLUS_TX_HOST <= D_PLUS_TX_HOST_ex;
   --D_MINUS_TX_HOST <= D_MINUS_TX_HOST_ex;
   --D_PLUS_TX_SLAVE <= D_PLUS_TX_SLAVE_ex;
   --D_MINUS_TX_SLAVE <= D_MINUS_TX_SLAVE_ex;
   
   D_PLUS_HOSTSIDE <= D_PLUS_TX_HOST_ex WHEN Slave_Is_Sending = '1' ELSE 'Z';
   D_MINUS_HOSTSIDE <= D_MINUS_TX_HOST_ex WHEN Slave_Is_Sending = '1' ELSE 'Z';
   D_PLUS_SLAVESIDE <= D_PLUS_TX_SLAVE_ex WHEN Host_is_Sending = '1' ELSE 'Z';
   D_MINUS_SLAVESIDE <= D_MINUS_TX_SLAVE_ex WHEN Host_is_Sending = '1' ELSE 'Z';
   
   D_PLUS_RX_HOST <= D_PLUS_HOSTSIDE WHEN Slave_is_Sending = '0' ELSE 'Z';
   D_MINUS_RX_HOST <= D_MINUS_HOSTSIDE WHEN Slave_is_Sending = '0' ELSE 'Z';
   D_PLUS_RX_SLAVE <= D_PLUS_SLAVESIDE WHEN Host_is_Sending = '0' ELSE 'Z';
   D_MINUS_RX_SLAVE <= D_MINUS_SLAVESIDE WHEN Host_is_Sending = '0' ELSE 'Z';
   
--       IO_DATA: process (RST, CLK, Sending_Host, Sending_Slave, 
--         D_Plus_Hostside, D_Minus_Hostside, D_Plus_Slaveside, D_Minus_Slaveside,
--         D_Plus_RX_Slave, D_Minus_RX_Slave, D_Plus_TX_Slave, D_Plus_TX_Host)
--       begin
--         
         --if (Sending_Host = '1') then
--           -- Host send state
--           -- Host side lines are on read
--           -- Slave side lines are on write
--           D_Plus_RX_Host <= D_Plus_Hostside;
--           D_Minus_RX_Host <= D_Minus_Hostside;
--           D_Plus_Slaveside <= D_Plus_TX_Slave;
--           D_Minus_Slaveside <= D_Minus_TX_Slave;
--         elsif(Sending_Slave = '1') then
--           -- Slave send state
--           -- Slave side lines are on read
--           -- Host side lines are on write
--           D_Plus_Hostside <= D_Plus_TX_Host;
--           D_Minus_Hostside <= D_Minus_TX_Host;
--           D_Plus_RX_Slave <= D_Plus_Slaveside;
--           D_Minus_RX_Slave <= D_Minus_Slaveside;
--         else
--           -- Neither sending
--           D_Plus_RX_Host <= D_Plus_Hostside;
--           D_Minus_RX_Host <= D_Minus_Hostside;
--           D_Plus_RX_Slave <= D_Plus_Slaveside;
--           D_Minus_RX_Slave <= D_Minus_Slaveside;	
----           D_Plus_TX_Host <= 'Z';
----           D_Minus_TX_Host <= 'Z';
----           D_Plus_TX_Slave <= 'Z';
----           D_Minus_TX_Slave <= 'Z';
--         end if;
       --end process IO_DATA;                                        
      
      

END struct;
