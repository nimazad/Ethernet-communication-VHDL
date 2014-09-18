----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:10:22 05/05/2010 
-- Design Name: 
-- Module Name:    Camera_Manager - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Camera_Manager is
PORT (
		-- maintenence pins
		In_Enable			: 	    In STD_LOGIC;		-- It shoudl workd when Enabled
		In_Reset				: 	    In STD_LOGIC;		
		In_CLK				: 	    In STD_LOGIC;		-- The clock should be less than 50 to be able to work with Ethernet
  		Out_IsActive		:	    Out STD_LOGIC;	-- Do not receive Commands then
		
		--Communication
		In_Command	: 	    In STD_LOGIC_Vector(7 downto 0);	--control data to manager
		In_Call		: 	    In STD_LOGIC;			--command to start process command
		Out_Error	: 	    Out STD_LOGIC;			--Error occurred during command processing
		Out_RDV		: 	    Out STD_LOGIC;			--(Rendezvous) command is processed

		--Picture data
		Out_Valid_Frame	: 	    Out STD_LOGIC;								-- Shows the valid period
		Out_Valid_Data		: 	    Out STD_LOGIC;								-- Rising shows the valid Data.
		Out_Data1_R			: 	    Out STD_LOGIC_Vector(11 downto 0);
		Out_Data1_G			: 	    Out STD_LOGIC_Vector(11 downto 0);
		Out_Data1_B			: 	    Out STD_LOGIC_Vector(11 downto 0);
		Out_Data2_R			: 	    Out STD_LOGIC_Vector(11 downto 0);
		Out_Data2_G 		: 	    Out STD_LOGIC_Vector(11 downto 0);
		Out_Data2_B			: 	    Out STD_LOGIC_Vector(11 downto 0)
    );
end Camera_Manager;

architecture Behavioral of Camera_Manager is

begin

PROCESS(In_CLK,In_Reset,In_Command,In_Call)
	Begin 
		IF rising_edge(In_CLK) THEN
			IF In_Enable = '1' AND In_Reset = '0' AND In_Command= x"00"  AND In_Call = '1' THEN
					Out_IsActive		<=	   '1';
					Out_Error			<= 	'1';
					Out_RDV				<= 	'1';
					Out_Valid_Frame	<= 	'1';
					Out_Valid_Data		<= 	'1';
					Out_Data1_R			<= 	(Others =>'1');
					Out_Data1_G			<= 	(Others =>'1');
					Out_Data1_B			<= 	(Others =>'1');
					Out_Data2_R			<= 	(Others =>'1');
					Out_Data2_G 		<= 	(Others =>'1');
					Out_Data2_B			<= 	(Others =>'1');
			ELSE
					Out_IsActive		<=	   '0';
					Out_Error			<= 	'0';
					Out_RDV				<= 	'0';
					Out_Valid_Frame	<= 	'0';
					Out_Valid_Data		<= 	'0';
					Out_Data1_R			<= 	(Others =>'0');
					Out_Data1_G			<= 	(Others =>'0');
					Out_Data1_B			<= 	(Others =>'0');
					Out_Data2_R			<= 	(Others =>'0');
					Out_Data2_G 		<= 	(Others =>'0');
					Out_Data2_B			<= 	(Others =>'0');
			END IF;		
		END IF;
	End process;

end Behavioral;

