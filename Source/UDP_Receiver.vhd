-- EngIneer: Mostafa - Nima
-- 
-- Create Date:    09:18:34 04/15/2010 
-- Design Name: 
-- Module Name:    UDP_Receiver - Behavioral 
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

entity UDP_Receiver IS
PORT (
		  In_CLK_50								: 	     In STD_LOGIC;								-- Should be 50 for RMII	
		  In_PHY_RX								:		 In STD_LOGIC_VECTOR(1  downto 0);
          In_PHY_CRS_DV							:		 In STD_LOGIC;	
		  
		  Out_Data_Ready		  				: 		 Out STD_LOGIC; 
		  Out_Data								: 		 Out STD_LOGIC_VECTOR(7  downto 0);		--	Clock of Mac state manager process
		  Out_DataFrame							: 		 Out STD_LOGIC :='0' 						--	When Data is valid
		 );
end UDP_Receiver;

architecture Behavioral of UDP_Receiver IS
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
TYPE 		Status	 IS (Off_1, WrongPacket_2, Preamble_3, DesUDP_4, SrcUDP_5,UDPHeader_6, Length_7,	UDPCheckSum_8, Data_9, CRC_10, CRC_Check); 
TYPE 		BS_Status IS ( BS_1_Pair, BS_2_Pair, BS_3_Pair, BS_4_Pair); 
SIGNAL 	UDP_State    	: Status	:= Off_1;
SIGNAL 	BS_State_Current : BS_Status:= BS_1_Pair;

-- Counters are in c++ lang. Means they are reduced by one so 0 means 1
SIGNAL 	Counter_DesMac						: 		INTEGER:=0;
SIGNAL 	Counter_SourceMac					: 		INTEGER:=0;
SIGNAL 	Counter_UDPHeader					: 		INTEGER:=0;
SIGNAL 	Counter_Length						: 		INTEGER:=0;
SIGNAL 	Counter_UDPCheckSum				: 		INTEGER:=0;					
SIGNAL 	Counter_Data						: 		STD_LOGIC_VECTOR(15 downto 0):= x"002E";
SIGNAL 	Counter_CRC							: 		INTEGER:=0;				

SIGNAL 		Value_DesMac					: 		STD_LOGIC_VECTOR(47 downto 0);
SIGNAL 		Value_SrcMac					: 		STD_LOGIC_VECTOR(47 downto 0);
SIGNAL 		Value_Length					: 		STD_LOGIC_VECTOR(15 downto 0);
SIGNAL 		Value_CRC_Input				: 		STD_LOGIC_VECTOR(31 downto 0);
SIGNAL 	Tmp_Byte								: 		STD_LOGIC_VECTOR(5  downto 0);
SIGNAL 	Received_Byte						: 		STD_LOGIC_VECTOR(7  downto 0);
SIGNAL 	CRCGenerator_In_Enabled 		:		STD_LOGIC:='0';
SIGNAL 	CLKMaker_CLK_12					: 		STD_LOGIC:='0';
SIGNAL 	CRCGen_In_Data						: 		STD_LOGIC_VECTOR(7  downto 0):=(Others=>'Z');
SIGNAL 	CRCGen_In_NewFram					: 		STD_LOGIC;
-- TODO
SIGNAL 	PickByte					: 		STD_LOGIC:='0';

SIGNAL 	Value_CRC_Gen						: 		STD_LOGIC_VECTOR(31 downto 0):= (Others=>'0');
SIGNAL 	CRCGenerator_In_rst				: 		STD_LOGIC:='0';
SIGNAL 	Reset_Byte							: 		STD_LOGIC:='0';
SIGNAL 	bit0									: 		STD_LOGIC:='0';
SIGNAL 	bit1									: 		STD_LOGIC:='0';

begin
--====================================================================================
--====== Map ports and signals                                            ============
--====================================================================================
Out_Data_Ready 	<= PickByte;
Out_Data				<=Received_Byte;
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
												rst 			=> CRCGenerator_In_rst,
												enable_s 	=> CRCGenerator_In_Enabled,
												newframe_s 	=> CRCGen_In_NewFram,
												data_crc_s 	=> CRCGen_In_Data,
												crc_s 		=> Value_CRC_Gen
											);


ByteReceiver_PROCESS : PROCESS (In_CLK_50,In_PHY_CRS_DV)
	BEGIN
	
		IF rising_edge(In_CLK_50) THEN						
			bit0 <= In_PHY_RX(0);
			bit1 <= In_PHY_RX(1);

			IF Reset_Byte = '1' THEN 
				Tmp_Byte(0)			<= In_PHY_RX(0);
				Tmp_Byte(1)			<= In_PHY_RX(1);
				BS_State_Current	<= BS_2_Pair;
				PickByte				<= '0';
					
			ELSE
				CASE BS_State_Current	IS					
					--==**==--
					WHEN	BS_1_Pair	=> 							
							Tmp_Byte(0)		<= In_PHY_RX(0);
							Tmp_Byte(1)		<= In_PHY_RX(1);				
							BS_State_Current	<= BS_2_Pair;
							PickByte				<= '1';
					--==**==--
					--==**==--
					WHEN	BS_2_Pair	=> 
							Tmp_Byte(2)	<= In_PHY_RX(0);		
							Tmp_Byte(3)	<= In_PHY_RX(1);				
							BS_State_Current	<= BS_3_Pair;
							PickByte				<= '0';
					--==**==--
					--==**==--
					WHEN	BS_3_Pair	=> 
							Tmp_Byte(4)	<= In_PHY_RX(0);
							Tmp_Byte(5)	<= In_PHY_RX(1);							
							BS_State_Current 	<= BS_4_Pair;
					--==**==--
					--==**==--
					WHEN	BS_4_Pair	=> 
							BS_State_Current	<= BS_1_Pair;
							Received_Byte 		<= In_PHY_RX(1)& In_PHY_RX(0) & Tmp_Byte(5 downto 0 );		
					--==**==--			
				END CASE;
			END IF; --Reset_Byte = '1' 
		END IF;    --rising_edge(In_CLK_50)
	END PROCESS;
	
Clocked_PROCESS : PROCESS (In_CLK_50, PickByte)
	BEGIN
		IF falling_edge(In_CLK_50) THEN
			Reset_Byte		<= '0';			
			IF In_PHY_CRS_DV ='0' THEN
				--Counters are in c++ lang. Means they are reduced by one so 0 means 1
				UDP_State 				<= Off_1;		
				--Counter
				Counter_DesMac			<= 47;
				Counter_SourceMac		<= 47;
				Counter_UDPHeader		<=200;
				Counter_Length			<= 15;
				Counter_UDPCheckSum	<=15;
				Counter_CRC				<= 0;			
				Value_DesMac			<= (Others => '0');
				Value_SrcMac			<= (Others => '0');
				Value_Length			<= (Others => '0');
				Value_CRC_Input		<= (Others => '0');				
			ELSE
					
					CASE UDP_State	IS
						--==**==--
						WHEN	Off_1	=>		
							IF In_PHY_CRS_DV ='1' THEN
								UDP_State	<= Preamble_3;
							END IF;
						--==**==--
						WHEN	WrongPacket_2	=>		
							IF In_PHY_CRS_DV ='0' THEN
								UDP_State	<= Off_1;
							END IF;
						--==**==--
						WHEN	Preamble_3	=>
							CRCGenerator_In_rst	<='1';
							IF	bit0 = '1' AND bit1='1' THEN
								Reset_Byte	<= '1';
								UDP_State <= DesUDP_4;
								CRCGenerator_In_Enabled	<=	'1';
								CRCGen_In_NewFram			<= '1';
								CRCGenerator_In_rst		<=	'0';
							END IF;
						--==**==--
						WHEN	DesUDP_4	=> 
							IF PickByte = '1' THEN
								CRCGen_In_NewFram		<= '0';
								CRCGen_In_Data			<= Received_Byte;
								Value_DesMac(Counter_DesMac downto Counter_DesMac - 7)	<= Received_Byte;
								IF Counter_DesMac > 7 THEN
									Counter_DesMac		<= Counter_DesMac - 8;
								ELSE
									IF Value_DesMac(47 downto 8) & Received_Byte = x"010101010101" THEN
										UDP_State 			<= SrcUDP_5;		
									ELSE
										UDP_State 			<= WrongPacket_2;		
									END IF;
								END IF;								
							END IF;								
						--==**==--
						WHEN	SrcUDP_5	=> 
							IF PickByte = '1' THEN
								CRCGen_In_Data			<= Received_Byte;
								Value_SrcMac(Counter_SourceMac downto Counter_SourceMac - 7)<= Received_Byte;
								IF Counter_SourceMac > 7 THEN
									Counter_SourceMac		<= Counter_SourceMac - 8;
								ELSE
									UDP_State 			<= UDPHeader_6;		
								END IF;	
							END IF;	
						--==**==--
						WHEN	UDPHeader_6	=> 
							IF PickByte = '1' THEN
								CRCGen_In_Data			<= Received_Byte;
								IF Counter_UDPHeader > 7 THEN
									Counter_UDPHeader		<= Counter_UDPHeader - 8;
								ELSE
									UDP_State 			<= Length_7;		
								END IF;	
							END IF;
						--==**==--
						WHEN	Length_7	=> 
							IF PickByte = '1' THEN
								CRCGen_In_Data			<= Received_Byte;
								Value_Length(Counter_Length downto Counter_Length - 7)<= Received_Byte;
								IF Counter_Length > 7 THEN
									Counter_Length		<= Counter_Length - 8;
								ELSE
									UDP_State 			<= UDPCheckSum_8;									
									Counter_Data 		<= Value_Length(15 downto 8) & Received_Byte - 8;
								END IF;	
							END IF;	
						--==**==--
						WHEN	UDPCheckSum_8	=> 
							IF PickByte = '1' THEN
								CRCGen_In_Data			<= Received_Byte;
								IF Counter_UDPCheckSum > 7 THEN
									Counter_UDPCheckSum		<= Counter_UDPCheckSum - 8;
								ELSE
									UDP_State 			<= Data_9;		
								END IF;	
							END IF;
						--==**==--
						WHEN	Data_9	=> 
							Out_DataFrame	<= '1';
							IF PickByte = '1' THEN
								CRCGen_In_Data		<= Received_Byte;
								IF Counter_Data > x"01" THEN
									Counter_Data	<=	Counter_Data	-	1;
								ELSE
									UDP_State 			<= CRC_10;							
								END IF;	
							END IF;	
						--==**==--
						WHEN	CRC_10	=> 
							Out_DataFrame	<= '0';
							IF PickByte = '1' THEN								
								CRCGenerator_In_Enabled	<=	'0';
								Value_CRC_Input( Counter_CRC+7 downto Counter_CRC) <= Received_Byte;
								IF Counter_CRC < 23 THEN
									Counter_CRC			<= Counter_CRC + 8;
								ELSE								
									UDP_State 			<= CRC_Check;
								END IF;
							END IF;
						--==**==--
						WHEN	CRC_Check	=> 
							UDP_State 			<= Off_1;
--							IF Value_CRC_Input = Value_CRC_Gen THEN
--								Out_CRC_OK <= '1';
--							ELSE
--								Out_CRC_OK <= '0';
--							END IF;

					END CASE;				
			END IF; 			-- IF In_PHY_CRS_DV ='0' THEN
		END IF; 				-- END OF falling_Edge(In_CLK_50)
	END PROCESS Clocked_PROCESS;
END Behavioral;

