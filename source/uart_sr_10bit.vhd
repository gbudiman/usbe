------------------------------------------------
-- Purdue University - West Lafayette, IN     --
-- ECE 495d: ASIC design lab                  --
-- Lab 5: UART Receiver unit                  --
------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY uart_sr_10bit IS
    PORT(
        CLK : IN std_logic;
        RST : IN std_logic;
        SHIFT_STROBE: IN std_logic;
        SERIAL_IN : IN std_logic;
        LOAD_DATA : OUT std_logic_vector(7 downto 0);
        STOP_DATA : OUT std_logic_vector(1 downto 0)
    );
END uart_sr_10bit;


ARCHITECTURE dataflow OF uart_sr_10bit IS
       signal present_val : std_logic_vector(9 downto 0);
       signal next_val : std_logic_vector(9 downto 0);
BEGIN
   REG: process (CLK, RST)
   begin  -- process
    if RST = '1' then
      present_val <= "0000000000";
    elsif rising_edge(CLK) then
      present_val <= next_val;
    end if; 
   end process;

   next_val <= SERIAL_IN & present_val(9 downto 1) when SHIFT_STROBE='1'
              else present_val;

   LOAD_DATA <= present_val(7 downto 0);
   STOP_DATA <= present_val(9 downto 8);
     
   
end dataflow;

