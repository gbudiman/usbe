-- $Id: $
-- File name:   rx_CRC_CALC.vhd
-- Created:     11/20/2010
-- Author:      Brent O'Brien
-- Lab Section: 337-01
-- Version:     1.0  Initial Design Entry
-- Description: This block calculates the CRC for the receiver.


--------------------------------------------------------------------------------
-- Copyright (C) 1999-2008 Easics NV.
-- This source file may be used and distributed without restriction
-- provided that this copyright statement is not removed from the file
-- and that any derivative work contains the original copyright notice
-- and the associated disclaimer.
--
-- THIS SOURCE FILE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS
-- OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
-- WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
--
-- Purpose : synthesizable CRC function
--   * polynomial: (0 2 15 16)
--   * data width: 8
--
-- Info : tools@easics.be
--        http://www.easics.com
--------------------------------------------------------------------------------

library ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

--package PCK_CRC16_D8 is
--  -- polynomial: (0 2 15 16)
--  -- data width: 8
--  -- convention: the first serial bit is D[7]
--  function nextCRC16_D8
--    (Data: std_logic_vector(7 downto 0);
--     crc:  std_logic_vector(15 downto 0))
--    return std_logic_vector;
--end PCK_CRC16_D8;
--
--
--package body PCK_CRC16_D8 is
--
--  -- polynomial: (0 2 15 16)
--  -- data width: 8
--  -- convention: the first serial bit is D[7]
--  function nextCRC16_D8
--    (Data: std_logic_vector(7 downto 0);
--     crc:  std_logic_vector(15 downto 0))
--    return std_logic_vector is
--
--    variable d:      std_logic_vector(7 downto 0);
--    variable c:      std_logic_vector(15 downto 0);
--    variable newcrc: std_logic_vector(15 downto 0);
--
--  begin
--    d := Data;
--    c := crc;
--
--    newcrc(0) := d(7) xor d(6) xor d(5) xor d(4) xor d(3) xor d(2) xor d(1) xor d(0) xor c(8) xor c(9) xor c(10) xor c(11) xor c(12) xor c(13) xor c(14) xor c(15);
--    newcrc(1) := d(7) xor d(6) xor d(5) xor d(4) xor d(3) xor d(2) xor d(1) xor c(9) xor c(10) xor c(11) xor c(12) xor c(13) xor c(14) xor c(15);
--    newcrc(2) := d(1) xor d(0) xor c(8) xor c(9);
--    newcrc(3) := d(2) xor d(1) xor c(9) xor c(10);
--    newcrc(4) := d(3) xor d(2) xor c(10) xor c(11);
--    newcrc(5) := d(4) xor d(3) xor c(11) xor c(12);
--    newcrc(6) := d(5) xor d(4) xor c(12) xor c(13);
--    newcrc(7) := d(6) xor d(5) xor c(13) xor c(14);
--    newcrc(8) := d(7) xor d(6) xor c(0) xor c(14) xor c(15);
--    newcrc(9) := d(7) xor c(1) xor c(15);
--    newcrc(10) := c(2);
--    newcrc(11) := c(3);
--    newcrc(12) := c(4);
--    newcrc(13) := c(5);
--    newcrc(14) := c(6);
--    newcrc(15) := d(7) xor d(6) xor d(5) xor d(4) xor d(3) xor d(2) xor d(1) xor d(0) xor c(7) xor c(8) xor c(9) xor c(10) xor c(11) xor c(12) xor c(13) xor c(14) xor c(15);
--    return newcrc;
--  end nextCRC16_D8;
--
--end PCK_CRC16_D8;
--
Entity rx_CRC_CALC is
  port(
    CLK:in std_logic;
    RST:in std_logic;
    W_ENABLE: in std_logic;
    OPCODE: in std_logic_vector(1 downto 0);
    RCV_DATA: in std_logic_vector(7 downto 0);
    RX_CRC: out std_logic_vector(15 downto 0)
    );
end rx_CRC_CALC;

architecture moore of rx_CRC_CALC is
  
  -- polynomial: (0 2 15 16)
  -- data width: 8
  -- convention: the first serial bit is D[7]
  function nextCRC16_D8
    (Data: std_logic_vector(7 downto 0);
     crc:  std_logic_vector(15 downto 0))
    return std_logic_vector is

    variable d:      std_logic_vector(7 downto 0);
    variable c:      std_logic_vector(15 downto 0);
    variable newcrc: std_logic_vector(15 downto 0);

  begin
    d := Data;
    c := crc;

    newcrc(0) := d(7) xor d(6) xor d(5) xor d(4) xor d(3) xor d(2) xor d(1) xor d(0) xor c(8) xor c(9) xor c(10) xor c(11) xor c(12) xor c(13) xor c(14) xor c(15);
    newcrc(1) := d(7) xor d(6) xor d(5) xor d(4) xor d(3) xor d(2) xor d(1) xor c(9) xor c(10) xor c(11) xor c(12) xor c(13) xor c(14) xor c(15);
    newcrc(2) := d(1) xor d(0) xor c(8) xor c(9);
    newcrc(3) := d(2) xor d(1) xor c(9) xor c(10);
    newcrc(4) := d(3) xor d(2) xor c(10) xor c(11);
    newcrc(5) := d(4) xor d(3) xor c(11) xor c(12);
    newcrc(6) := d(5) xor d(4) xor c(12) xor c(13);
    newcrc(7) := d(6) xor d(5) xor c(13) xor c(14);
    newcrc(8) := d(7) xor d(6) xor c(0) xor c(14) xor c(15);
    newcrc(9) := d(7) xor c(1) xor c(15);
    newcrc(10) := c(2);
    newcrc(11) := c(3);
    newcrc(12) := c(4);
    newcrc(13) := c(5);
    newcrc(14) := c(6);
    newcrc(15) := d(7) xor d(6) xor d(5) xor d(4) xor d(3) xor d(2) xor d(1) xor d(0) xor c(7) xor c(8) xor c(9) xor c(10) xor c(11) xor c(12) xor c(13) xor c(14) xor c(15);
    return newcrc;
  end nextCRC16_D8;

signal current_crc, current_rcv_data: std_logic_vector(15 downto 0);  
signal cache_1, cache_2: std_logic_vector(15 downto 0);
begin
  NEWCRC:process(CLK, RST)
    begin
      if (RST = '1') then
        current_crc <= x"0000";
      elsif(CLK'event and CLK = '1') then
        if (W_ENABLE = '1' AND OPCODE = "01") then
          current_crc <= nextCRC16_D8(RCV_DATA, current_crc);
          cache_1 <= current_crc;
          cache_2 <= cache_1;
        elsif (OPCODE = "11") then
          current_crc <= x"0000";
        end if;
      end if;
    end process NEWCRC;
    
    RX_CRC <= cache_2;
    
end moore;