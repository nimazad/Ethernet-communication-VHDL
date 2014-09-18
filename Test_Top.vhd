--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   22:29:30 05/12/2010
-- Design Name:   
-- Module Name:   C:/VHDL/NETVHDL/NETVHDL/Communication/Test_Top.vhd
-- Project Name:  Communication
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Top
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
 
ENTITY Test_Top IS
END Test_Top;
 
ARCHITECTURE behavior OF Test_Top IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Top
    PORT(
         In_CLK_50_Ref_E1 : IN  std_logic;
         In_PHY_RX0_J9 : IN  std_logic;
         In_PHY_RX1_J8 : IN  std_logic;
         In_PHY_CRS_G13 : IN  std_logic;
         Out_PHY_DATA_0_D3 : OUT  std_logic;
         Out_PHY_DATA_1_F4 : OUT  std_logic;
         Out_PHY_TXEN_E4 : OUT  std_logic;
         Out_PHY_MDIO_J7 : INOUT  std_logic;
         Out_PHY_MDC_H6 : OUT  std_logic;
         Out_PHY_Reset_J6 : OUT  std_logic;
         Out_LED_C0_AC1 : OUT  std_logic;
         Out_LED_C1_AB1 : OUT  std_logic;
         Out_LED_C2_W6 : OUT  std_logic;
         Out_RP6_AF14 : OUT  std_logic;
         Out_RP4_AD15 : OUT  std_logic;
         Out_RP8_AE14 : OUT  std_logic;
         Out_RP9_AF13 : OUT  std_logic;
         Out_RP18_P1 : OUT  std_logic;
         Out_RP17_M2 : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal In_CLK_50_Ref_E1 : std_logic := '0';
   signal In_PHY_RX0_J9 : std_logic := '0';
   signal In_PHY_RX1_J8 : std_logic := '0';
   signal In_PHY_CRS_G13 : std_logic := '0';

	--BiDirs
   signal Out_PHY_MDIO_J7 : std_logic;

 	--Outputs
   signal Out_PHY_DATA_0_D3 : std_logic;
   signal Out_PHY_DATA_1_F4 : std_logic;
   signal Out_PHY_TXEN_E4 : std_logic;
   signal Out_PHY_MDC_H6 : std_logic;
   signal Out_PHY_Reset_J6 : std_logic;
   signal Out_LED_C0_AC1 : std_logic;
   signal Out_LED_C1_AB1 : std_logic;
   signal Out_LED_C2_W6 : std_logic;
   signal Out_RP6_AF14 : std_logic;
   signal Out_RP4_AD15 : std_logic;
   signal Out_RP8_AE14 : std_logic;
   signal Out_RP9_AF13 : std_logic;
   signal Out_RP18_P1 : std_logic;
   signal Out_RP17_M2 : std_logic;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Top PORT MAP (
          In_CLK_50_Ref_E1 => In_CLK_50_Ref_E1,
          In_PHY_RX0_J9 => In_PHY_RX0_J9,
          In_PHY_RX1_J8 => In_PHY_RX1_J8,
          In_PHY_CRS_G13 => In_PHY_CRS_G13,
          Out_PHY_DATA_0_D3 => Out_PHY_DATA_0_D3,
          Out_PHY_DATA_1_F4 => Out_PHY_DATA_1_F4,
          Out_PHY_TXEN_E4 => Out_PHY_TXEN_E4,
          Out_PHY_MDIO_J7 => Out_PHY_MDIO_J7,
          Out_PHY_MDC_H6 => Out_PHY_MDC_H6,
          Out_PHY_Reset_J6 => Out_PHY_Reset_J6,
          Out_LED_C0_AC1 => Out_LED_C0_AC1,
          Out_LED_C1_AB1 => Out_LED_C1_AB1,
          Out_LED_C2_W6 => Out_LED_C2_W6,
          Out_RP6_AF14 => Out_RP6_AF14,
          Out_RP4_AD15 => Out_RP4_AD15,
          Out_RP8_AE14 => Out_RP8_AE14,
          Out_RP9_AF13 => Out_RP9_AF13,
          Out_RP18_P1 => Out_RP18_P1,
          Out_RP17_M2 => Out_RP17_M2
        );
 
   -- No clocks detected in port list. Replace In_CLK_50_Ref_E1 below with 
   -- appropriate port name 
 
 
  periode :process
   begin
		In_CLK_50_Ref_E1 <= '0';		
		wait for 1ns / 2;
		In_CLK_50_Ref_E1 <= '1';
		wait for 1ns/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100ms.
      wait for 100ms;	

      wait for 1ns*10;

      -- insert stimulus here 

      wait;
   end process;

END;
