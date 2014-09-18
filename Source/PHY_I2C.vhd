----------------------------------------------------------------------------------
-- Company:	 Mälardalen University - Robotic project
-- Engineer: Mostafa - Nima
-- 
-- Create Date:    	17:27:55 04/13/2010 
-- Module Name:    	PHY_I2C - Behavioral 
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

entity PHY_I2C is
PORT (
		  In_CLK_50								: 	    In STD_LOGIC;								-- Should be 50 to make the right clock for management	
	  	  In_Load								: 		 In STD_LOGIC;								-- Load the input Data_8
		  In_IsRead								: 	    In STD_LOGIC;								-- Write to Or read from registers
		  In_Command							: 	    In STD_LOGIC_VECTOR(15 downto 0);	--	Input Data_8									
		  In_RegisterAddress					: 		 In STD_LOGIC_VECTOR(4  downto 0);	-- Register Address of input command
		  In_IDLE_VAL							:		 In STD_LOGIC;		
        Out_PHY_MDIO							:		 InOut STD_LOGIC:='Z';					-- PHY Data_8	
        Out_PHY_MDC							:		 Out STD_LOGIC;							-- PHY Clock
		  Out_IsActive							: 		 Out STD_LOGIC:= '0' 					--	When component is active this pin goes high
	);
end PHY_I2C;

architecture Behavioral of PHY_I2C is


--====================================================================================
--====== Define Clcok Signal 2.5 MgH for PHY Management                    ===========
--====================================================================================
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
TYPE 		Status IS (Off_1, Idle_2, Preamble_3, OpCode_4, PHYAddress_5, RegisterAddress_6, TurnAround_7, Data_8, End_9); 
SIGNAL 	CurrentState: Status:= Off_1;
-- Counters are in c++ lang. Means they are reduced by one so 0 means 1
SIGNAL 	Counter_IDLE						: 		STD_LOGIC_VECTOR(7 downto 0);
SIGNAL 	Counter_Preamble					: 		INTEGER;
SIGNAL 	Counter_OpCode						: 		INTEGER;
SIGNAL 	Counter_PHYAddress				: 		INTEGER;
SIGNAL 	Counter_RegisterAddress			: 		INTEGER;
SIGNAL 	Counter_TurnAround				: 		INTEGER;
SIGNAL 	Counter_Data						: 		INTEGER;
Constant 	Value_Preemble						:		STD_LOGIC_VECTOR(33 downto 0):= "1111111111111111111111111111111101";
Constant 	Value_PhyAddress					: 		STD_LOGIC_VECTOR(4  downto 0):= "00000";
SIGNAL 	OpCode						: 		STD_LOGIC_VECTOR(1  downto 0);						--'01' for write and '10' for read 
SIGNAL 	TurnAround					: 		STD_LOGIC_VECTOR(1  downto 0):= "10";						--"10" >Write and "zz">read 
SIGNAL 	CLKMacker_Out_CLK					: 		STD_LOGIC;

BEGIN

--====================================================================================
--====== Map ports and signals                                            ============
--====================================================================================
Out_PHY_MDC					<=	CLKMacker_Out_CLK;
--====================================================================================
--====== Get instance of components                                       ============
--====================================================================================

-- The Clock for Management is 2.5 MH
Instance_ClockMacker		:		ClockMaker 		PORT map	
								( 
										In_CLK			=> In_CLK_50,
										In_Divider 		=> "000000000000000000000000000000001010", --50/10*2 = 2.5
										Out_CLK			=> CLKMacker_Out_CLK
								);
--====================================================================================
--====== Main Process					                                      ============
--====================================================================================
Clocked_PROCESS : PROCESS (In_CLK_50, CLKMacker_Out_CLK, In_Load)
	BEGIN
		IF falling_edge(CLKMacker_Out_CLK) THEN
			-----------------Load Condition----------------
			IF In_Load = '1' THEN
				Out_IsActive				<= '1';			
				--Counters are in c++ lang. Means they are reduced by one so 0 means 1
				CurrentState				<=	Idle_2;
				Counter_IDLE				<= ( Others=> '1');
				Counter_Preamble			<= 33;  -- 32 of preamble + 2 SFD = 34
				Counter_OpCode				<= 1;
				Counter_PHYAddress		<= 4;
				Counter_RegisterAddress	<= 4;
				Counter_TurnAround		<= 1;
				Counter_Data				<= 15;			
				IF In_IsRead	=	'1' THEN
					OpCode			<="10";
					TurnAround	<="ZZ";
				ELSE
					OpCode			<="01";
					TurnAround	<="10";
				END IF;			
			-----------------Load Condition----------------
				
			ELSE
				CASE CurrentState	IS
					--==**==--
					WHEN	Off_1	=> 
						Out_IsActive								<= '0';
					--==**==--
					WHEN	Idle_2	=> 
						IF Counter_IDLE(7)= '0' THEN 				
							CurrentState 					<= Preamble_3;		
						ELSE						
							Counter_IDLE					<= Counter_IDLE - 1;	
						END IF;
					--==**==--
					WHEN	Preamble_3	=> 
						Out_PHY_MDIO				<= Value_Preemble(Counter_Preamble);								
						IF Counter_Preamble > 0 THEN 			
							Counter_Preamble			<= Counter_Preamble - 1;	
						ELSE
							CurrentState 				<= OpCode_4;		
						END IF;
					--==**==--	
					WHEN	OpCode_4	=> 
						Out_PHY_MDIO				<= OpCode(Counter_OpCode);	
						IF Counter_OpCode	  > 0 THEN 			
							Counter_OpCode				<= Counter_OpCode - 1;	
						ELSE
							CurrentState 				<= PHYAddress_5;		
						END IF;
					--==**==--
					WHEN	PHYAddress_5	=> 
						Out_PHY_MDIO				<= Value_PHYAddress(Counter_PHYAddress);	
						IF Counter_PHYAddress		> 0 THEN 			
							Counter_PHYAddress		<= Counter_PHYAddress - 1;	
						ELSE
							CurrentState 				<= RegisterAddress_6;		
						END IF;		
					--==**==--
					WHEN	RegisterAddress_6	=> 
						Out_PHY_MDIO				<= In_RegisterAddress(Counter_RegisterAddress);	
						IF Counter_RegisterAddress		> 0 THEN 			
							Counter_RegisterAddress	<= Counter_RegisterAddress - 1;	
						ELSE
							CurrentState 				<= TurnAround_7;		
						END IF;		
					--==**==--	
					WHEN	TurnAround_7	=> 
						Out_PHY_MDIO				<= TurnAround(Counter_TurnAround);	
						IF Counter_TurnAround		> 0 THEN 			
							Counter_TurnAround		<= Counter_TurnAround - 1;	
						ELSE
							CurrentState 				<= Data_8;		
						END IF;			
					--==**==--
					WHEN	Data_8	=> 
						IF	In_IsRead					=	'1'	THEN
							CurrentState 				<= Off_1;
								--TODO: Read the status 
						ELSE	--Write Data
							Out_PHY_MDIO			<= In_Command(Counter_Data);	
							IF Counter_Data			> 0 THEN 			
								Counter_Data			<= Counter_Data - 1;	
							ELSE
								CurrentState 			<= End_9;	 	
							END IF;									
						END IF;
					--==**==--	
					WHEN	End_9	=> 
						Out_PHY_MDIO			<=In_IDLE_VAL;
						CurrentState 			<= Off_1;
					--==**==--
				END CASE;
			END IF; -- END OF In_Load
		END IF; -- END OF Rising_Edge(IN_CLK_50)
	END PROCESS Clocked_PROCESS;
END Behavioral;

