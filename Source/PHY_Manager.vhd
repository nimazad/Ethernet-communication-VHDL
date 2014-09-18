----------------------------------------------------------------------------------
-- Company:	 Mälardalen University - Robotic project
-- EngIneer: Mostafa - Nima
-- 
-- Create Date:    12:55:11 04/14/2010 
-- Design Name: 
-- Module Name:    PHY_Manager - Behavioral 
-- Project Name: 		Ethernet Comunication
-- Target Devices: 	Two Camera board
-- Tool versions: 	ISE 10.1
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

ENTITY PHY_Manager IS
PORT (
		  In_CLK_50					: 	    In STD_LOGIC;	
        Out_PHY_MDIO				:		 InOut STD_LOGIC;					-- PHY Data	
        Out_PHY_MDC				:		 Out STD_LOGIC;					-- PHY Clock
  		  Out_IsActive				: 		 Out STD_LOGIC					--WHEN Component is active
    );
END PHY_Manager;

architecture Behavioral of PHY_Manager IS

--====================================================================================
--====== Define Components  										                  ===========
--====================================================================================
Component PHY_I2C is
PORT (
		  In_CLK_50								: 	    In STD_LOGIC;								-- Should be 50 to make the right clock for management	
	  	  In_Load								: 		 In STD_LOGIC;								-- Load the input Data_8
		  In_IsRead								: 	    In STD_LOGIC;								-- Write to Or read from registers
		  In_Command							: 	    In STD_LOGIC_VECTOR(15 downto 0);	--	Input Data_8									
		  In_RegisterAddress					: 		 In STD_LOGIC_VECTOR(4  downto 0);	-- Register Address of input command
		  In_IDLE_VAL							:		 In STD_LOGIC;		
        Out_PHY_MDIO							:		 InOut STD_LOGIC;							-- PHY Data_8	
        Out_PHY_MDC							:		 Out STD_LOGIC;							-- PHY Clock
		  Out_IsActive							: 		 Out STD_LOGIC:= '0' 					--	When component is active this pin goes high
	);
end Component;

component ClockMaker IS
PORT(
        In_CLK								: In 	STD_LOGIC;								-- Input clock
        In_Divider						: in 	STD_LOGIC_Vector(35 downto 0);	-- Divider value
        Out_CLK							: Out STD_LOGIC								-- output clock 
    );
END component;
--====================================================================================
--====== Define Signals needed for controlling the program                 ===========
--====================================================================================
TYPE 		Status IS (Init, Set_1, Wait_2, End_3); 
SIGNAL 	CurrentState: Status:= Init;
Constant PHY_Command_0 				: 		 STD_LOGIC_VECTOR (15 downto 0) := "0010000100000000"; 
Constant PHY_Command_1 				: 		 STD_LOGIC_VECTOR (15 downto 0) := "0000010110000000"; 
Constant PHY_RegisterAddr_0			: 		 STD_LOGIC_VECTOR(4 downto 0)   := "00000";
Constant PHY_RegisterAddr_1			: 		 STD_LOGIC_VECTOR(4 downto 0)   := "10000";

--Counters are in c++ lang. Means they are reduced by one so 0 means 1
Constant Command_count_MAX			:		 STD_LOGIC	:='1';  					  -- The number of commands sending after reset
SIGNAL Command_count					:		 STD_LOGIC	:='0';
attribute keep : string; 
--Signals For I2C
SIGNAL I2C_In_Load					:		 STD_LOGIC:='0';
SIGNAL I2C_In_Command				:		 STD_LOGIC_VECTOR(15 downto 0) := (Others => '1');
SIGNAL I2C_In_RegisterAddr			:		 STD_LOGIC_VECTOR(4 downto 0); 
SIGNAL I2C_In_IsRead					:		 STD_LOGIC:='0';
SIGNAL I2C_Out_IsActive				:		 STD_LOGIC;
SIGNAL I2C_Out_PHY_MDC				:		 STD_LOGIC; 
SIGNAL CLKMacker_Out_CLK_1M		:		 STD_LOGIC; 

--attribute keep of I2C_In_Command	: 		 signal is "true";
--attribute keep of I2C_In_RegisterAddr	: 		 signal is "true";

BEGIN
--
Out_PHY_MDC								<= 	I2C_Out_PHY_MDC;			
		

--====================================================================================
--====== Get instance of components                                       ============
--====================================================================================

-- Instance of I2C component
Instance_PHY_I2C		:		PHY_I2C 		PORT map	
								( 
										 In_CLK_50								=> In_CLK_50,
										  In_Load								=> I2C_In_Load,
										  In_IsRead								=> I2C_In_IsRead,    
										  In_Command							=> I2C_In_Command,	    
										  In_RegisterAddress					=> I2C_In_RegisterAddr,		 
										  In_IDLE_VAL							=>	'Z',	 
										  Out_PHY_MDIO							=>	Out_PHY_MDIO,	 
										  Out_PHY_MDC							=>	I2C_Out_PHY_MDC,	 
										  Out_IsActive							=> I2C_Out_IsActive	
								);
								
-- The Clock for Management is 1 MH
Instance_ClockMacker		:		ClockMaker 		PORT map	
								( 
										In_CLK			=> In_CLK_50,
										In_Divider 		=> "000000000000000000000000000000011001", --50/25*2 = 1
										Out_CLK			=> CLKMacker_Out_CLK_1M
								);
PROCESS(In_CLK_50,CLKMacker_Out_CLK_1M,Command_count)
	BEGIN	
		IF  rising_edge(CLKMacker_Out_CLK_1M) THEN
				CASE CurrentState IS 
						--==**==--
						WHEN Init	=>
							Command_count		<='0';
							Out_IsActive		<=	'1';
							CurrentState		<=	Set_1;				
						--==**==--
						WHEN Set_1	=>
							IF Command_count = '0' THEN
								I2C_In_Command 			<= PHY_Command_0; 
								I2C_In_RegisterAddr		<= PHY_RegisterAddr_0;
								I2C_In_IsRead 				<= '0'; 
							ELSE
								I2C_In_Command 			<= PHY_Command_1; 
								I2C_In_RegisterAddr		<= PHY_RegisterAddr_1;
								I2C_In_IsRead 				<= '0'; 							
							END IF;

							I2C_In_Load					<=	'1';
							CurrentState				<=	Wait_2;
						--==**==--
						WHEN Wait_2	=>
							I2C_In_Load					<=	'0';
							IF I2C_Out_IsActive	=	'0'	THEN
								IF	Command_count	=	Command_count_MAX	THEN
									CurrentState		<=	End_3;
								ELSE
									Command_Count		<=	'1';
									CurrentState		<=	Set_1;
								END IF;
							END IF;
						--==**==--
						WHEN End_3	=>
							Out_IsActive	<=	'0';
				END CASE;			

		END IF;
	END PROCESS;

END Behavioral;

