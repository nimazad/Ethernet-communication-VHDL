----------------------------------------------------------------------------------
-- Company:	 Mälardalen University - Robotic project
-- EngIneer: Mostafa - Nima
-- 
-- Create Date:    15:29:27 05/11/2010 
-- Design Name: 
-- Module Name:    Communication - Behavioral 
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

entity Communication is
PORT (
		In_CLK_50								: 	     In STD_LOGIC;							-- Should be 50 for RMII	
  		
  		-- Communication with Top Layer
  		In_Reply								: 		 In STD_LOGIC_VECTOR(71  downto 0);
  		In_Data									: 		 In STD_LOGIC_VECTOR(71  downto 0);
  		In_DataValid							: 		 In STD_LOGIC;
  		In_ReplyValid							: 		 In STD_LOGIC;

  		Out_Data								: 		 Out STD_LOGIC_VECTOR(71  downto 0);
  		Out_Data_Ready							: 		 Out STD_LOGIC;
  		Out_Command_Ready						: 		 Out STD_LOGIC;
		
		-- PHYPins for Send and Receive	via Ethernet
        In_PHY_RX								:		 In STD_LOGIC_VECTOR(1  downto 0);
        In_PHY_CRS_DV							:		 In STD_LOGIC;
        Out_PHY_TX								:		 Out STD_LOGIC_VECTOR(1  downto 0):=(Others=>'Z');
		Out_PHY_TX_Enable						:		 Out STD_LOGIC:= 'Z';
		Out_Is_Sending							: 		 Out STD_LOGIC
	);
end Communication;

architecture Behavioral of Communication is


--====================================== Define Components

Component UDP_Sender is
PORT (
		  In_CLK_50								: 	     In STD_LOGIC;										-- Should be 50 for RMII	
	  	  In_Load								: 		 In STD_LOGIC;										-- Load the input Data_8
		  In_Length								: 		 In STD_LOGIC_VECTOR(15 downto 0);					-- Length of packet
  		  In_Data								: 		 In STD_LOGIC_VECTOR(7  downto 0);					-- Series of most significant byte of data
		  Out_PHY_TX							:		 Out STD_LOGIC_VECTOR(1  downto 0):=(Others=>'Z');							
          Out_PHY_TX_Enable						:		 Out STD_LOGIC:= 'Z';							
          Out_NextByte_Req						:		 Out STD_LOGIC:= '0';								-- When component IS ready for reading next byte
		  Out_IsActive							: 		 Out STD_LOGIC:= '0'; 								-- When component IS active this pin goes high
		  Out_CLK_12_Load						: 		 Out STD_LOGIC:= '0' 								-- Clock of UDP state manager process
	);
end Component;

Component UDP_Receiver IS
PORT (
		  In_CLK_50								: 	     In STD_LOGIC;							-- Should be 50 for RMII	
		  In_PHY_RX								:		 In STD_LOGIC_VECTOR(1  downto 0);
		  In_PHY_CRS_DV							:		 In STD_LOGIC;	
		  
		  Out_Data_Ready		  				: 		 Out STD_LOGIC; 
		  Out_Data								: 		 Out STD_LOGIC_VECTOR(7  downto 0);		--	Clock of UDP state manager process
		  Out_DataFrame							: 		 Out STD_LOGIC 							--	When Data is valid
		 );
end Component UDP_Receiver;
--====================================================================================
--====== Define Signals needed for controlling the program                 ===========
--====================================================================================
--Signals For UDP_Sender
SIGNAL		UDP_Sender_In_Load				: 		 STD_LOGIC;								-- Load the input Data_8
Constant 	UDP_Sender_In_Length			: 		 STD_LOGIC_VECTOR(15 downto 0):=x"006B";
Constant 	Reply_Header_Byte			: 		 STD_LOGIC_VECTOR(7 downto 0):=x"F1";
Constant 	Data_Header_Byte			: 		 STD_LOGIC_VECTOR(7 downto 0):=x"00";

SIGNAL 		UDP_Sender_In_Data				: 		 STD_LOGIC_VECTOR(7 downto 0);	
SIGNAL 		UDP_Sender_Out_NextByte_Req		:		 STD_LOGIC;
SIGNAL 		UDP_Sender_Out_IsActive			:		 STD_LOGIC;
SIGNAL 		UDP_Sender_CLK_12_Load			:		 STD_LOGIC;

--Signals For UDP_Receiver
SIGNAL UDP_Receiver_Out_Data_Ready			:		 STD_LOGIC;
SIGNAL UDP_Receiver_Out_Data				:		 STD_LOGIC_VECTOR(7 downto 0);
SIGNAL UDP_Receiver_Out_DataFrame			:		 STD_LOGIC;


-- Signals for UDP
Constant 	Constant_Index_Data_Max_71		: 		 INTEGER:= 71;
Constant 	Constant_Data_In_Max_719		: 		 INTEGER:= 719;
Constant 	Constant_Command_In_Max_791		: 		 INTEGER:= 791;

-- UDP Signals for send and receive
TYPE 		Status_Sender 				IS 	(Set_1, Data_2,Wait_3, End_4); 
SIGNAL 		sts_Sender					: 	Status_Sender:= Set_1;
SIGNAL  	Is_SendingPacket			:	STD_LOGIC:='0';
SIGNAL  	Data_Ready					:	STD_LOGIC:='0';
SIGNAL  	IsCommand					:	STD_LOGIC:='0';
SIGNAL  	Buffer_Data_Full			:	STD_LOGIC:='0';
SIGNAL  	Buffer_Reply_Full			:	STD_LOGIC:='0';
SIGNAL  	Reply_Picked				:	STD_LOGIC:='0';
SIGNAL  	Data_Picked					:	STD_LOGIC:='0';
SIGNAL  	Command_Ready				:	STD_LOGIC:='0';
SIGNAL	 	Total_PACK					:	INTEGER:=0;
Signal 		Data_Received				:	STD_LOGIC_VECTOR(71 downto 0);

Signal 		Index_Data_Recieved			:	Integer range 791 downto 0;
Signal 		Buffer_Data					:	STD_LOGIC_VECTOR(791 downto 0):=(Others => '0');
Signal 		Buffer_Reply				:	STD_LOGIC_VECTOR(71 downto 0);
Signal 		Data_Is_Sending				:	STD_LOGIC_VECTOR(791 downto 0):=(Others => '0');

Signal  	Index_Sending				: 	Integer range 783 downto 0;
Signal  	Index_Data_Buffered			: 	Integer range 719 downto 0 := 719;
Signal  	Counter_Packet				: 	STD_LOGIC_VECTOR(63 downto 0):=(Others => '0');
 

begin

-- Port Maps
Out_Is_Sending  	<= Is_SendingPacket;
Out_Data_Ready		<= Data_Ready 		;
Out_Command_Ready	<= Command_Ready 	;

-- Instance of UDP_Sender component
Instance_UDP_Sender		:		UDP_Sender 		PORT map	
								( 
		  In_CLK_50								=> In_CLK_50,
		  In_Load								=> UDP_Sender_In_Load,
		  In_Length								=> UDP_Sender_In_Length,		  
		  In_Data								=> UDP_Sender_In_Data,
		  Out_PHY_TX							=> Out_PHY_TX,
		  Out_PHY_TX_Enable						=> Out_PHY_TX_Enable,
		  Out_NextByte_Req						=> UDP_Sender_Out_NextByte_Req,
		  Out_IsActive							=> UDP_Sender_Out_IsActive,
		  Out_CLK_12_Load						=> UDP_Sender_CLK_12_Load
								);
								
Instance_UDP_Receiver		:		UDP_Receiver 		PORT MAP
								(
		  In_CLK_50								=> In_CLK_50,
		  In_PHY_RX								=> In_PHY_RX,
		  In_PHY_CRS_DV							=> In_PHY_CRS_DV,		  
		  Out_Data_Ready		  				=> UDP_Receiver_Out_Data_Ready,
		  Out_Data								=> UDP_Receiver_Out_Data,
		  Out_DataFrame							=> UDP_Receiver_Out_DataFrame
								);	
								
									
--================================  Process for receiving UDPs. 
PROCESS(In_CLK_50, UDP_Receiver_Out_Data_Ready, UDP_Receiver_Out_DataFrame)
	BEGIN		
		IF UDP_Receiver_Out_DataFrame = '0' THEN
			Index_Data_Recieved <= Constant_Index_Data_Max_71;
			Total_PACK <= 0;
			Data_Ready		<= '0';
			Command_Ready	<= '0';		
		ELSIF rising_edge(UDP_Receiver_Out_Data_Ready) AND UDP_Receiver_Out_DataFrame = '1' THEN			
			Data_Ready		<= '0';
			Command_Ready	<= '0';
		
			
			-- Save Bytes
			Data_Received(Index_Data_Recieved downto Index_Data_Recieved -7) <= UDP_Receiver_Out_Data;
			
			IF ( Total_PACK  = 0 AND Index_Data_Recieved = Constant_Index_Data_Max_71 ) THEN -- Should decide on Data Value or Command Value	
				IsCommand <= UDP_Receiver_Out_Data(7);
			END IF;
			
			
						
			IF Index_Data_Recieved >7 THEN
				Index_Data_Recieved <= Index_Data_Recieved-8;
			ELSE		-- Received One pack of 72 bits
				Out_Data <= Data_Received(71 downto 8) & UDP_Receiver_Out_Data;
				Total_PACK <= Total_PACK +1;
				Index_Data_Recieved <= Constant_Index_Data_Max_71;				
				CASE IsCommand IS				
					WHEN '1'	=> -- Data
						IF Total_PACK = 0 THEN
							Data_Ready		<= '0';
							Command_Ready	<= '1';
						END IF;
					When Others	=> -- Command						
						Data_Ready		<= '1';
						Command_Ready	<= '0';
				ENd Case;
			END IF;
		END IF;		
	END PROCESS;

-- Process for Casching Data
PROCESS(In_CLK_50,In_DataValid,Index_Data_Buffered,Data_Picked)
	BEGIN
		IF Data_Picked='1' THEN   -- Wait for PICKED
				Buffer_Data_Full <= '0';		
		ELSIF falling_Edge(In_DataValid) THEN			
			IF Buffer_Data_Full = '0' THEN
				Buffer_Data (Index_Data_Buffered downto  Index_Data_Buffered-71)	<= In_Data;
				
				IF(Index_Data_Buffered = 71 ) THEN -- We have one 800 bit ready for sending
					Counter_Packet 																<= Counter_Packet+1;
					Buffer_Data_Full       														<=  '1';				
					Index_Data_Buffered															<= Constant_Data_In_Max_719;			
					Buffer_Data (Constant_Command_In_Max_791 downto  Constant_Command_In_Max_791-71)	<= Data_Header_Byte & Counter_Packet;
				ELSE				
					Index_Data_Buffered <= Index_Data_Buffered -72;
				End IF;
			END IF;						
		END IF;	
	END PRocess;
	
--  Process for Casching Command
PROCESS(In_CLK_50,In_ReplyValid,In_Reply,Reply_Picked)
	BEGIN	
		IF Reply_Picked='1' THEN   -- Wait for PICKED
				Buffer_Reply_Full <= '0';
		ELSIF falling_Edge(In_ReplyValid) THEN			
			IF Buffer_Reply_Full = '0' THEN
				Buffer_Reply 		   <= 	In_Reply;
				Buffer_Reply_Full      <=  '1';	
			END IF;				
		END IF;			
	END PRocess;

-- Process for sending through UDP Sender	
PROCESS(In_CLK_50, UDP_Sender_CLK_12_Load,In_ReplyValid,In_DataValid,Index_Sending)
	BEGIN				
		IF (Buffer_Data_Full = '1' or Buffer_Reply_Full='1') and UDP_Sender_Out_IsActive = '0' and Is_SendingPacket='0'  THEN				
			Is_SendingPacket		<= '1';
			sts_Sender				<= Set_1;			
		ELSIF  falling_edge(UDP_Sender_CLK_12_Load) AND Is_SendingPacket='1' THEN	
				CASE sts_Sender IS 	
						--==**==--
						WHEN Set_1	=>
							IF Buffer_Data_Full='1' THEN
								Data_Is_Sending 	<= Buffer_Data;
								UDP_Sender_In_Data  <= Buffer_Data(Constant_Command_In_Max_791 downto Constant_Command_In_Max_791-7);
								Data_Picked			<= '1';
							ELSE
								Data_Is_Sending(Constant_Command_In_Max_791 downto Constant_Command_In_Max_791-79) 	<= Reply_Header_Byte & Buffer_Reply;
								Data_Is_Sending(Constant_Command_In_Max_791-80 downto 0)<= (Others => '0');
								UDP_Sender_In_Data  <= Reply_Header_Byte ;
								Reply_Picked		<= '1';
							END IF;							
							UDP_Sender_In_Load		<=	'1';
							Index_Sending 			<= 	Constant_Command_In_Max_791 - 8;
							sts_Sender				<=	Data_2;							
										
						--==**==--
						WHEN Data_2	=>
							Reply_Picked <= '0';
							Data_Picked	 <= '0';
							UDP_Sender_In_Load		<=	'0';
							IF UDP_Sender_Out_NextByte_Req = '1' THEN			-- Next Data series should be send
							UDP_Sender_In_Data	<= Data_Is_Sending ( Index_Sending downto Index_Sending -7);
								IF Index_Sending > 7 THEN
									Index_Sending 	<= Index_Sending -8;
								ELSE
									sts_Sender			<= Wait_3;
								END IF;
							END IF;
						--==**==--
						--==**==--
						WHEN Wait_3	=>
							IF UDP_Sender_Out_IsActive	=	'0'	THEN
									sts_Sender			<=	End_4;
							END IF;
						--==**==--
						WHEN End_4	=>
							Is_SendingPacket	<=	'0';
				END CASE;

		END IF;
	END PROCESS;

end Behavioral;

