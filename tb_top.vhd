--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:30:51 05/20/2010
-- Design Name:   
-- Module Name:   C:/Xilinx/11.1/Apps/Communication 19 May/tb_top.vhd
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
 
ENTITY tb_top IS
END tb_top;
 
ARCHITECTURE behavior OF tb_top IS 
 
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
         Out_RP17_M2 : OUT  std_logic;
         R_EXTCLK_A14 : OUT  std_logic;
         R_FRAME_VALID_F20 : IN  std_logic;
         R_LINE_VALID_F19 : IN  std_logic;
         R_PIXCLK_C16 : IN  std_logic;
         R_TRIGGER_A15 : OUT  std_logic;
         R_CAM_DATA0_C22 : IN  std_logic;
         R_CAM_DATA1_D22 : IN  std_logic;
         R_CAM_DATA2_C23 : IN  std_logic;
         R_CAM_DATA3_D23 : IN  std_logic;
         R_CAM_DATA4_A22 : IN  std_logic;
         R_CAM_DATA5_B23 : IN  std_logic;
         R_CAM_DATA6_G17 : IN  std_logic;
         R_CAM_DATA7_H17 : IN  std_logic;
         R_CAM_DATA8_B21 : IN  std_logic;
         R_CAM_DATA9_C21 : IN  std_logic;
         R_CAM_DATA10_D21 : IN  std_logic;
         R_CAM_DATA11_E21 : IN  std_logic;
         L_EXTCLK_B13 : OUT  std_logic;
         L_FRAME_VALID_F12 : IN  std_logic;
         L_LINE_VALID_C11 : IN  std_logic;
         L_PIXCLK_K11 : IN  std_logic;
         L_TRIGGER_G10 : OUT  std_logic;
         L_CAM_DATA0_B10 : IN  std_logic;
         L_CAM_DATA1_A10 : IN  std_logic;
         L_CAM_DATA2_D10 : IN  std_logic;
         L_CAM_DATA3_C10 : IN  std_logic;
         L_CAM_DATA4_H12 : IN  std_logic;
         L_CAM_DATA5_G12 : IN  std_logic;
         L_CAM_DATA6_B9 : IN  std_logic;
         L_CAM_DATA7_A9 : IN  std_logic;
         L_CAM_DATA8_D9 : IN  std_logic;
         L_CAM_DATA9_E10 : IN  std_logic;
         L_CAM_DATA10_B8 : IN  std_logic;
         L_CAM_DATA11_C7 : IN  std_logic;
         InOut_I2C_L_SDA_B15 : INOUT  std_logic;
         InOut_I2C_L_SCL_F14 : INOUT  std_logic;
         InOut_I2C_R_SDA_G9 : INOUT  std_logic;
         InOut_I2C_R_SCL_F7 : INOUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal In_CLK_50_Ref_E1 : std_logic := '0';
   signal In_PHY_RX0_J9 : std_logic := '0';
   signal In_PHY_RX1_J8 : std_logic := '0';
   signal In_PHY_CRS_G13 : std_logic := '0';
   signal R_FRAME_VALID_F20 : std_logic := '0';
   signal R_LINE_VALID_F19 : std_logic := '0';
   signal R_PIXCLK_C16 : std_logic := '0';
   signal R_CAM_DATA0_C22 : std_logic := '0';
   signal R_CAM_DATA1_D22 : std_logic := '0';
   signal R_CAM_DATA2_C23 : std_logic := '0';
   signal R_CAM_DATA3_D23 : std_logic := '0';
   signal R_CAM_DATA4_A22 : std_logic := '0';
   signal R_CAM_DATA5_B23 : std_logic := '0';
   signal R_CAM_DATA6_G17 : std_logic := '0';
   signal R_CAM_DATA7_H17 : std_logic := '0';
   signal R_CAM_DATA8_B21 : std_logic := '0';
   signal R_CAM_DATA9_C21 : std_logic := '0';
   signal R_CAM_DATA10_D21 : std_logic := '0';
   signal R_CAM_DATA11_E21 : std_logic := '0';
   signal L_FRAME_VALID_F12 : std_logic := '0';
   signal L_LINE_VALID_C11 : std_logic := '0';
   signal L_PIXCLK_K11 : std_logic := '0';
   signal L_CAM_DATA0_B10 : std_logic := '0';
   signal L_CAM_DATA1_A10 : std_logic := '0';
   signal L_CAM_DATA2_D10 : std_logic := '0';
   signal L_CAM_DATA3_C10 : std_logic := '0';
   signal L_CAM_DATA4_H12 : std_logic := '0';
   signal L_CAM_DATA5_G12 : std_logic := '0';
   signal L_CAM_DATA6_B9 : std_logic := '0';
   signal L_CAM_DATA7_A9 : std_logic := '0';
   signal L_CAM_DATA8_D9 : std_logic := '0';
   signal L_CAM_DATA9_E10 : std_logic := '0';
   signal L_CAM_DATA10_B8 : std_logic := '0';
   signal L_CAM_DATA11_C7 : std_logic := '0';

	--BiDirs
   signal Out_PHY_MDIO_J7 : std_logic;
   signal InOut_I2C_L_SDA_B15 : std_logic;
   signal InOut_I2C_L_SCL_F14 : std_logic;
   signal InOut_I2C_R_SDA_G9 : std_logic;
   signal InOut_I2C_R_SCL_F7 : std_logic;

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
   signal R_EXTCLK_A14 : std_logic;
   signal R_TRIGGER_A15 : std_logic;
   signal L_EXTCLK_B13 : std_logic;
   signal L_TRIGGER_G10 : std_logic;
 
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
          Out_RP17_M2 => Out_RP17_M2,
          R_EXTCLK_A14 => R_EXTCLK_A14,
          R_FRAME_VALID_F20 => R_FRAME_VALID_F20,
          R_LINE_VALID_F19 => R_LINE_VALID_F19,
          R_PIXCLK_C16 => R_PIXCLK_C16,
          R_TRIGGER_A15 => R_TRIGGER_A15,
          R_CAM_DATA0_C22 => R_CAM_DATA0_C22,
          R_CAM_DATA1_D22 => R_CAM_DATA1_D22,
          R_CAM_DATA2_C23 => R_CAM_DATA2_C23,
          R_CAM_DATA3_D23 => R_CAM_DATA3_D23,
          R_CAM_DATA4_A22 => R_CAM_DATA4_A22,
          R_CAM_DATA5_B23 => R_CAM_DATA5_B23,
          R_CAM_DATA6_G17 => R_CAM_DATA6_G17,
          R_CAM_DATA7_H17 => R_CAM_DATA7_H17,
          R_CAM_DATA8_B21 => R_CAM_DATA8_B21,
          R_CAM_DATA9_C21 => R_CAM_DATA9_C21,
          R_CAM_DATA10_D21 => R_CAM_DATA10_D21,
          R_CAM_DATA11_E21 => R_CAM_DATA11_E21,
          L_EXTCLK_B13 => L_EXTCLK_B13,
          L_FRAME_VALID_F12 => L_FRAME_VALID_F12,
          L_LINE_VALID_C11 => L_LINE_VALID_C11,
          L_PIXCLK_K11 => L_PIXCLK_K11,
          L_TRIGGER_G10 => L_TRIGGER_G10,
          L_CAM_DATA0_B10 => L_CAM_DATA0_B10,
          L_CAM_DATA1_A10 => L_CAM_DATA1_A10,
          L_CAM_DATA2_D10 => L_CAM_DATA2_D10,
          L_CAM_DATA3_C10 => L_CAM_DATA3_C10,
          L_CAM_DATA4_H12 => L_CAM_DATA4_H12,
          L_CAM_DATA5_G12 => L_CAM_DATA5_G12,
          L_CAM_DATA6_B9 => L_CAM_DATA6_B9,
          L_CAM_DATA7_A9 => L_CAM_DATA7_A9,
          L_CAM_DATA8_D9 => L_CAM_DATA8_D9,
          L_CAM_DATA9_E10 => L_CAM_DATA9_E10,
          L_CAM_DATA10_B8 => L_CAM_DATA10_B8,
          L_CAM_DATA11_C7 => L_CAM_DATA11_C7,
          InOut_I2C_L_SDA_B15 => InOut_I2C_L_SDA_B15,
          InOut_I2C_L_SCL_F14 => InOut_I2C_L_SCL_F14,
          InOut_I2C_R_SDA_G9 => InOut_I2C_R_SDA_G9,
          InOut_I2C_R_SCL_F7 => InOut_I2C_R_SCL_F7
        );
 
   -- No clocks detected in port list. Replace In_CLK_50_Ref_E1 below with 
   -- appropriate port name 
 
   In_CLK_50_Ref_E1_process :process
   begin
		In_CLK_50_Ref_E1 <= '0';
		wait for 1ns/2;
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
