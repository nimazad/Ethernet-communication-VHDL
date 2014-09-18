--:	 Mälardalen University - Robotic project
-- EngIneer: Mostafa - Nima
-- 
-- Create Date:    09:18:34 04/15/2010 
-- Design Name: 
-- Module Name:    UDP_Sender - Behavioral 
-- Project Name: 
-- Target Devices: Two Camera board
-- Tool versions:  ISE 10.1
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

entity UDP_Sender IS
PORT (
		  In_CLK_50								: 	     In STD_LOGIC;								-- Should be 50 for RMII	
	  	  In_Load								: 		 In STD_LOGIC;								-- Load the input Data_13
		  In_Length								: 		 In STD_LOGIC_VECTOR(15 downto 0);	-- Length of packet
  		  In_Data								: 		 In STD_LOGIC_VECTOR(7  downto 0);	-- Series of most significant byte of data
		  Out_PHY_TX							:		 Out STD_LOGIC_VECTOR(1  downto 0):=(Others=>'Z');							
          Out_PHY_TX_Enable						:		 Out STD_LOGIC:= 'Z';							
          Out_NextByte_Req						:		 Out STD_LOGIC:= '0';					-- When component IS ready for reading next byte
		  Out_IsActive							: 		 Out STD_LOGIC:= '0'; 						--	When component IS active this pin goes high
		  Out_CLK_12_Load						: 		 Out STD_LOGIC:= '0' 						--	Clock of Mac state manager process
	);
end UDP_Sender;

architecture Behavioral of UDP_Sender IS

--====================================================================================
--====== Define Components  										                  ===========
--====================================================================================
COMPONENT crc32_block IS
PORT(
		clk 			: In 	STD_LOGIC;
		rst 			: In 	STD_LOGIC;
		enable_s 	: In 	STD_LOGIC;
		newframe_s 	: In 	STD_LOGIC;
		data_crc_s 	: In 	STD_LOGIC_VECTOR(7 downto 0);          
		crc_s 		: Out STD_LOGIC_VECTOR(31 downto 0)
		);
END COMPONENT;


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
attribute keep : string;
TYPE 			Status	 IS (Off_1 , Idle_2, MAC_Preamble_3, MAC_Des_4, MAC_Src_5, Mac_Protocol_6,
				UDP_Version_7,UDP_Src_IP_8, UDP_Des_IP_9,UDP_Src_Port_10,UDP_Des_Port_10,UDP_Length_11,UDP_CheckSum_12,
				Data_13, Data_14, CRC_15); 
TYPE 			BS_Status IS ( BS_1_Pair, BS_2_Pair, BS_3_Pair, BS_4_Pair); 
SIGNAL 		UDP_NextState    			: Status	:= Off_1;
SIGNAL 		UDP_State_Current 			: Status	:= Off_1;
SIGNAL 		UDP_State_Old				: Status	:= Off_1;
SIGNAL 		BS_State_Current 			: BS_Status:= BS_1_Pair;

Constant    Constant_Mac_Src			: STD_LOGIC_VECTOR(47 downto 0):=x"010101010101";	--	Source Mac address
Constant 	Constant_Mac_Des			: STD_LOGIC_VECTOR(47 downto 0):= x"010101010101";--x"888888888888";
Constant	Constant_UDP_Version		: STD_LOGIC_VECTOR(95 downto 0) := x"4500007F2646000080114960";
Constant	Constant_UDP_Src_IP			: STD_LOGIC_VECTOR(31 downto 0) := x"C0A80A20";
Constant	Constant_UDP_Des_IP			: STD_LOGIC_VECTOR(31 downto 0) := x"FFFFFFFF";
Constant	Constant_UDP_Src_Port		: STD_LOGIC_VECTOR(15 downto 0) := x"445C";
Constant	Constant_UDP_Des_Port		: STD_LOGIC_VECTOR(15 downto 0) := x"445C";
Constant	Constant_UDP_CheckSum		: STD_LOGIC_VECTOR(15 downto 0) := x"9999";

-- Counters are in c++ lang. Means they are reduced by one so 0 means 1
SIGNAL 	Counter_IDLE						: 		STD_LOGIC_VECTOR(6 downto 0);
SIGNAL 	Counter_Mac_Preamble				: 		INTEGER range 63 downto 0;
SIGNAL 	Counter_MAC_Des						: 		INTEGER range 47 downto 0;
SIGNAL 	Counter_MAC_Src						: 		INTEGER range 47 downto 0;
SIGNAL 	Counter_Mac_Protocol				: 		INTEGER range 15 downto 0;
SIGNAL 	Counter_MAC_CRC							: 		INTEGER range 31 downto 0;
SIGNAL 	Counter_CurrentBit					: 		INTEGER;
SIGNAL 	Counter_UDP_Version					: 		INTEGER range 95 downto 0;
SIGNAL 	Counter_UDP_Src_IP					: 		INTEGER range 31 downto 0;
SIGNAL 	Counter_UDP_Des_IP					: 		INTEGER range 31 downto 0;
SIGNAL 	Counter_UDP_Src_Port				: 		INTEGER range 15 downto 0;
SIGNAL 	Counter_UDP_Des_Port				: 		INTEGER range 15 downto 0;
SIGNAL 	Counter_UDP_Length					: 		INTEGER range 15 downto 0;
SIGNAL 	Counter_UDP_CheckSum				: 		INTEGER range 15 downto 0;

Constant	Value_Preamble						:		STD_LOGIC_VECTOR(63 downto 0):= x"55555555555555D5";
Constant	Value_Protocol						:		STD_LOGIC_VECTOR(15 downto 0):= x"0800";
SIGNAL 	Value_CRC							: 		STD_LOGIC_VECTOR(31 downto 0);
SIGNAL 	Current_Byte						: 		STD_LOGIC_VECTOR(7  downto 0):=(Others=>'Z');
SIGNAL 	Old_Byte								: 		STD_LOGIC_VECTOR(7  downto 0):=(Others=>'Z');
SIGNAL 	Counter_Data_Array				: 		STD_LOGIC_VECTOR(15  downto 0);
SIGNAL 	CRCGenerator_In_Enabled 		:		STD_LOGIC:='0';
SIGNAL 	CLKMaker_CLK_12					: 		STD_LOGIC:='0';
SIGNAL 	CRCGen_In_Data						: 		STD_LOGIC_VECTOR(7  downto 0):=(Others=>'Z');
SIGNAL 	CRCGen_In_NewFram					: 		STD_LOGIC;


begin
--====================================================================================
--====== Map ports and signals                                            ============
--====================================================================================
--====================================================================================
--====== Get instance of components                                       ============
--====================================================================================

-- The Clock for Management is 2.5 MH
Instance_ClockMacker		:		ClockMaker 		PORT map	
								( 
										In_CLK			=> In_CLK_50,
										In_Divider 		=> "000000000000000000000000000000000010", --50/2*2 = 12,5
										Out_CLK			=> CLKMaker_CLK_12
								);
								
	--crc32 Component 
	Instance_CRC32_Block				: 	CRC32_Block 	PORT MAP
											(
												clk 			=> CLKMaker_CLK_12,
												rst 			=> In_Load,
												enable_s 	=> CRCGenerator_In_Enabled,
												newframe_s 	=> CRCGen_In_NewFram,
												data_crc_s 	=> CRCGen_In_Data,
												crc_s 		=> Value_CRC
											);
TXEN_PROCESS : PROCESS (In_CLK_50, UDP_NextState)
	BEGIN
		IF rising_edge(In_CLK_50) THEN						
			IF(UDP_State_Old = Off_1) THEN
					Out_PHY_TX_Enable <= '0';
			END IF;
			IF(UDP_State_Old = MAC_Preamble_3) THEN
					Out_PHY_TX_Enable <= '1';
			END IF;
		END IF;
	END PROCESS;
											
ByteSender_PROCESS : PROCESS (In_CLK_50, Current_Byte)
	BEGIN
		IF falling_edge(In_CLK_50) THEN						
			IF(UDP_State_Old /= Off_1) AND (UDP_State_Old /= Idle_2) THEN
				
				Counter_CurrentBit<= Counter_CurrentBit+2;
				CASE BS_State_Current	IS					
					--==**==--
					WHEN	BS_1_Pair	=> 
							Out_PHY_TX(0)		<= Old_Byte(0);
							Out_PHY_TX(1)		<= Old_Byte(1);				
							BS_State_Current	<= BS_2_Pair;

					--==**==--
					--==**==--
					WHEN	BS_2_Pair	=> 
							Out_PHY_TX(0)		<= Old_Byte(2);
							Out_PHY_TX(1)		<= Old_Byte(3);				
							BS_State_Current	<= BS_3_Pair;
					--==**==--
					--==**==--
					WHEN	BS_3_Pair	=> 
							Out_PHY_TX(0)		<= Old_Byte(4);
							Out_PHY_TX(1)		<= Old_Byte(5);							
							BS_State_Current 	<= BS_4_Pair;
					--==**==--
					--==**==--
					WHEN	BS_4_Pair	=> 
							Out_PHY_TX(0)		<= Old_Byte(6);
							Out_PHY_TX(1)		<= Old_Byte(7);				
							BS_State_Current	<= BS_1_Pair;
					--==**==--			
				END CASE;

			ELSE
				Counter_CurrentBit<= 0;
				Out_PHY_TX(0)		<= '0';
				Out_PHY_TX(1)		<= '0';
			END IF;
		END IF;
	END PROCESS;
	
Out_CLK_12_Load	<=	CLKMaker_CLK_12;
Clocked_PROCESS : PROCESS (In_CLK_50, CLKMaker_CLK_12, In_Load, UDP_NextState)
	BEGIN
		IF rising_edge(CLKMaker_CLK_12) THEN
		
			-- Shift the process
			UDP_State_Current <= UDP_NextState;
			UDP_State_Old     <= UDP_State_Current; 
			Old_Byte          <= Current_Byte;
			
			IF In_Load	=	'1'	THEN
			-----------------Load Condition----------------
				Out_IsActive				<= '1';			
				--Counters are in c++ lang. Means they are reduced by one so 0 means 1
				UDP_NextState				<=	Idle_2;
				
				--Reset Counter
				Counter_IDLE						<= ( Others=> '1');
				Counter_Data_Array					<= In_Length -9;
				Counter_Mac_Preamble				<= 63;  -- 56 of preamble + 8 SFD = 64
				Counter_MAC_Des						<= 47;
				Counter_MAC_Src						<= 47;
				Counter_Mac_Protocol				<= 15;
				Counter_MAC_CRC						<= 0;						
				Counter_UDP_Version					<= 95;
				Counter_UDP_Src_IP					<= 31;
				Counter_UDP_Des_IP					<= 31;
				Counter_UDP_Src_Port				<= 15;
				Counter_UDP_Des_Port				<= 15;
				Counter_UDP_Length					<= 15;
				Counter_UDP_CheckSum				<= 15;
				
				
			ELSE -------------NOT-Load Condition----------------				
				
				CASE UDP_NextState	IS
					--==**==--
					WHEN	Off_1	=> 
						Out_IsActive		<= '0';
					--==**==--
					WHEN	Idle_2	=> 								
						IF Counter_IDLE(6)= '0' THEN 				--Inter frame gap which IS 96 bit
							UDP_NextState 					<= MAC_Preamble_3;		
						ELSE						
							Counter_IDLE				<= Counter_IDLE - 1;	
						END IF;
				
					--==**==--
					WHEN	MAC_Preamble_3	=>
						Current_Byte		<= Value_Preamble(Counter_Mac_Preamble downto Counter_Mac_Preamble - 7);
						IF Counter_Mac_Preamble > 8 THEN
							Counter_Mac_Preamble		<= Counter_Mac_Preamble - 8;
						ELSE
							UDP_NextState 			<= MAC_Des_4;		
							CRCGenerator_In_Enabled	<=	'1';
							CRCGen_In_NewFram	<= '1';
						END IF;
					--==**==--
					WHEN	MAC_Des_4	=> 
						CRCGen_In_NewFram		<= '0';
						CRCGen_In_Data			<= Constant_Mac_Des(Counter_MAC_Des downto Counter_MAC_Des - 7);
						Current_Byte			<= Constant_Mac_Des(Counter_MAC_Des downto Counter_MAC_Des - 7);
						IF Counter_MAC_Des > 8 THEN
							Counter_MAC_Des		<= Counter_MAC_Des - 8;
						ELSE
							UDP_NextState 			<= MAC_Src_5;		
						END IF;								
					--==**==--
					WHEN	MAC_Src_5	=> 
						CRCGen_In_Data			<= Constant_Mac_Src(Counter_MAC_Src downto Counter_MAC_Src - 7);
						Current_Byte		<= Constant_Mac_Src(Counter_MAC_Src downto Counter_MAC_Src - 7);
						IF Counter_MAC_Src > 8 THEN
							Counter_MAC_Src		<= Counter_MAC_Src - 8;
						ELSE
							UDP_NextState 			<= Mac_Protocol_6;		
						END IF;	
					--==**==--
					WHEN	Mac_Protocol_6	=> 
						CRCGen_In_Data			<= Value_Protocol(Counter_Mac_Protocol downto Counter_Mac_Protocol - 7);
						Current_Byte			<= Value_Protocol(Counter_Mac_Protocol downto Counter_Mac_Protocol - 7);
						IF Counter_Mac_Protocol > 8 THEN
							Counter_Mac_Protocol		<= Counter_Mac_Protocol - 8;
						ELSE
							UDP_NextState 			<= UDP_Version_7;
						END IF;	
					--==**==--
					WHEN	UDP_Version_7	=> 
						CRCGen_In_Data			<= Constant_UDP_Version(Counter_UDP_Version downto Counter_UDP_Version - 7);
						Current_Byte			<= Constant_UDP_Version(Counter_UDP_Version downto Counter_UDP_Version - 7);
						IF Counter_UDP_Version > 7 THEN
							Counter_UDP_Version	<=	Counter_UDP_Version	-	8;
						ELSE
							UDP_NextState 		<= UDP_Src_IP_8;							
						END IF;	
					--==**==--
					WHEN	UDP_Src_IP_8	=> 
						CRCGen_In_Data			<= Constant_UDP_Src_IP(Counter_UDP_Src_IP downto Counter_UDP_Src_IP - 7);
						Current_Byte			<= Constant_UDP_Src_IP(Counter_UDP_Src_IP downto Counter_UDP_Src_IP - 7);
						IF Counter_UDP_Src_IP > 7 THEN
							Counter_UDP_Src_IP	<=	Counter_UDP_Src_IP	-	8;
						ELSE
							UDP_NextState 		<= UDP_Des_IP_9;							
						END IF;	
					--==**==--
					WHEN	UDP_Des_IP_9	=> 
						CRCGen_In_Data			<= Constant_UDP_Des_IP(Counter_UDP_Des_IP downto Counter_UDP_Des_IP - 7);
						Current_Byte			<= Constant_UDP_Des_IP(Counter_UDP_Des_IP downto Counter_UDP_Des_IP - 7);
						IF Counter_UDP_Des_IP > 7 THEN
							Counter_UDP_Des_IP	<=	Counter_UDP_Des_IP	-	8;
						ELSE
							UDP_NextState 		<= UDP_Src_Port_10;							
						END IF;	
					--==**==--
					WHEN	UDP_Src_Port_10	=> 
						CRCGen_In_Data			<= Constant_UDP_Src_Port(Counter_UDP_Src_Port downto Counter_UDP_Src_Port - 7);
						Current_Byte			<= Constant_UDP_Src_Port(Counter_UDP_Src_Port downto Counter_UDP_Src_Port - 7);
						IF Counter_UDP_Src_Port > 7 THEN
							Counter_UDP_Src_Port	<=	Counter_UDP_Src_Port	-	8;
						ELSE
							UDP_NextState 		<= UDP_Des_Port_10;							
						END IF;	
					--==**==--
					WHEN	UDP_Des_Port_10	=> 
						CRCGen_In_Data			<= Constant_UDP_Des_Port(Counter_UDP_Des_Port downto Counter_UDP_Des_Port - 7);
						Current_Byte			<= Constant_UDP_Des_Port(Counter_UDP_Des_Port downto Counter_UDP_Des_Port - 7);
						IF Counter_UDP_Des_Port > 7 THEN
							Counter_UDP_Des_Port	<=	Counter_UDP_Des_Port	-	8;
						ELSE
							UDP_NextState 		<= UDP_Length_11;							
						END IF;	
					--==**==--
					WHEN	UDP_Length_11	=> 
						CRCGen_In_Data			<= In_Length(Counter_UDP_Length downto Counter_UDP_Length - 7);
						Current_Byte			<= In_Length(Counter_UDP_Length downto Counter_UDP_Length - 7);
						IF Counter_UDP_Length > 7 THEN
							Counter_UDP_Length	<=	Counter_UDP_Length	-	8;
						ELSE
							UDP_NextState 		<= UDP_CheckSum_12;							
						END IF;	
					--==**==--
					WHEN	UDP_CheckSum_12	=> 
						CRCGen_In_Data			<= Constant_UDP_CheckSum(Counter_UDP_CheckSum downto Counter_UDP_CheckSum - 7);
						Current_Byte			<= Constant_UDP_CheckSum(Counter_UDP_CheckSum downto Counter_UDP_CheckSum - 7);
						IF Counter_UDP_CheckSum > 7 THEN
							Counter_UDP_CheckSum	<=	Counter_UDP_CheckSum	-	8;
						ELSE
							UDP_NextState 		<= Data_13;							
						END IF;	
					--==**==--
					WHEN	Data_13	=> 
						CRCGen_In_Data			<= In_Data;
						Current_Byte			<= In_Data;
						IF Counter_Data_Array > 0 THEN
							Out_NextByte_Req  <= '1';	
							Counter_Data_Array		<=	Counter_Data_Array	-	1;
						ELSE
							UDP_NextState 			<= Data_14;							
						END IF;	
					--==**==--
					WHEN	Data_14	=> 
						UDP_NextState 			<= CRC_15;							
						CRCGenerator_In_Enabled	<=	'0';
						Out_NextByte_Req  <= '0';	
					--==**==--
					WHEN	CRC_15	=> 
						Old_Byte			<= Value_CRC( Counter_MAC_CRC+7 downto Counter_MAC_CRC);
						Current_Byte	<= Value_CRC( Counter_MAC_CRC+15 downto Counter_MAC_CRC+8);
						IF Counter_MAC_CRC < 16 THEN
							Counter_MAC_CRC			<= Counter_MAC_CRC + 8;
						ELSE								
							UDP_NextState 			<= Off_1;
						END IF;
				END CASE;
				
			END IF; -- END OF In_Load
		END IF; -- END OF Rising_Edge(CLKMaker_CLK_12)
	END PROCESS Clocked_PROCESS;
END Behavioral;

