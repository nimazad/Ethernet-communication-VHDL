----------------------------------------------------------------------------------
-- Company:	 Mälardalen University - Robotic project
-- EngIneer: Mostafa - Nima
-- 
-- Create Date:    12:55:11 04/14/2010 
-- Design Name: 
-- Module Name:    	Top - Behavioral 
-- Project Name: 		Ethernet Comunication
-- Target Devices: 	Two Camera board
-- Tool versions: 	ISE 10.1
-- Description: 
--
-- Dependencies: 
-- 
-- Revision: 
-- Revision 0.01 - File Created 
-- Additional Comments: TODOI

----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Top is
PORT (

		  ------------------------------------------ In ports
		  In_CLK_50_Ref_E1			: 	    In STD_LOGIC;	
		  In_PHY_RX0_J9  			: 	    In STD_LOGIC;	
		  In_PHY_RX1_J8				: 	    In STD_LOGIC;	
		  In_PHY_CRS_G13			:		 In STD_LOGIC;						--PHY CRS
		  
		  Out_PHY_DATA_0_D3 		:		 Out STD_LOGIC;					--PHY Data	
		  Out_PHY_DATA_1_F4 		:		 Out STD_LOGIC;					--PHY Data	
		  Out_PHY_TXEN_E4 			:		 Out STD_LOGIC;					--PHY Transmit Enabled
		  Out_PHY_MDIO_J7			:		 InOut STD_LOGIC;
		  Out_PHY_MDC_H6			:		 Out STD_LOGIC;
		  Out_PHY_Reset_J6			:		 Out STD_LOGIC;

		   -- Control LEDS
		  Out_LED_C0_AC1			:		 Out STD_LOGIC;					--For LED Used! for CommandCounter
		  Out_LED_C1_AB1			:		 Out STD_LOGIC;					--For LED Used! for CommandCounter
		  Out_LED_C2_W6				:		 Out STD_LOGIC;	 				--For LED Used! for CommandCounter

  		  -- Control PInS Rescue PAD
  		  Out_RP6_AF14				: 	    Out STD_LOGIC;
  		  Out_RP4_AD15				: 	    Out STD_LOGIC;
  		  Out_RP8_AE14				: 	    Out STD_LOGIC;
  		  Out_RP9_AF13				: 	    Out STD_LOGIC;
  		  Out_RP18_P1				: 	    Out STD_LOGIC;	
		  Out_RP17_M2				:      Out STD_LOGIC;
		  --Picture data
		   R_EXTCLK_A14			: Out STD_LOGIC;
			R_FRAME_VALID_F20		: in STD_LOGIC;								-- Shows the valid period
			R_LINE_VALID_F19		: in STD_LOGIC;								-- Rising shows the valid Data.
			R_PIXCLK_C16			: in STD_LOGIC;
			R_TRIGGER_A15			: out std_logic;
			R_CAM_DATA0_C22			: in STD_LOGIC;
			R_CAM_DATA1_D22			: in STD_LOGIC;
			R_CAM_DATA2_C23			: in STD_LOGIC;
			R_CAM_DATA3_D23			: in STD_LOGIC;
			R_CAM_DATA4_A22			: in STD_LOGIC;
			R_CAM_DATA5_B23			: in STD_LOGIC;
			R_CAM_DATA6_G17			: in STD_LOGIC;
			R_CAM_DATA7_H17			: in STD_LOGIC;
			R_CAM_DATA8_B21			: in STD_LOGIC;
			R_CAM_DATA9_C21			: in STD_LOGIC;
			R_CAM_DATA10_D21		: in STD_LOGIC;
			R_CAM_DATA11_E21		: in STD_LOGIC;
						
		   L_EXTCLK_B13			: Out STD_LOGIC;
			L_FRAME_VALID_F12		: in STD_LOGIC;								-- Shows the valid period
			L_LINE_VALID_C11		: in STD_LOGIC;								-- Rising shows the valid Data.
			L_PIXCLK_K11			: in STD_LOGIC;
			L_TRIGGER_G10			: out std_logic;
			L_CAM_DATA0_B10			: in STD_LOGIC;
			L_CAM_DATA1_A10			: in STD_LOGIC;
			L_CAM_DATA2_D10			: in STD_LOGIC;
			L_CAM_DATA3_C10			: in STD_LOGIC;
			L_CAM_DATA4_H12			: in STD_LOGIC;
			L_CAM_DATA5_G12			: in STD_LOGIC;
			L_CAM_DATA6_B9			: in STD_LOGIC;
			L_CAM_DATA7_A9			: in STD_LOGIC;
			L_CAM_DATA8_D9			: in STD_LOGIC;
			L_CAM_DATA9_E10			: in STD_LOGIC;
			L_CAM_DATA10_B8			: in STD_LOGIC;
			L_CAM_DATA11_C7			: in STD_LOGIC;	
			--I2C pins
			InOut_I2C_L_SDA_B15		: inout std_logic:='Z';
			InOut_I2C_L_SCL_F14		: inout std_logic:='Z';
			InOut_I2C_R_SDA_G9		: inout std_logic:='Z';
			InOut_I2C_R_SCL_F7		: inout std_logic:='Z'
);


end Top;

architecture Behavioral of Top is

--====== Define Components

Component PHY_Manager IS
PORT (
		In_CLK_50				: 	    In STD_LOGIC;	
        Out_PHY_MDIO			:		 InOut STD_LOGIC;				-- PHY Data	
        Out_PHY_MDC				:		 Out STD_LOGIC;					-- PHY Clock
  		Out_IsActive			: 		 Out STD_LOGIC					--WHEN Component is active
    );
END Component;

Component Communication is
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
end Component;


Component Camera_Manager is
generic
(
	input_frequency	: positive  :=	125_000_000;
	SHARED_CONTROLLER:bit:='0';
	SYNCHRONIZE_INPUT:bit:='1';
	SYNCHRONIZE_OUTPUT:bit:='0';
	DEBUG: bit:='0'
	
);
PORT (
		-- maintenence pins
		In_Enable		: In STD_LOGIC;		-- It shoudl workd when Enabled
		In_Reset		: In STD_LOGIC;		
		In_CLK			: In STD_LOGIC;		-- The clock should be less than 50 to be able to work with Ethernet
  		Out_IsActive	: Out STD_LOGIC;		-- Do not receive Commands then
		
		--Communication
		In_Command		: In STD_LOGIC_Vector(7 downto 0);	--control data to manager
		In_Call			: In STD_LOGIC;			--command to start process command
		Out_Error		: Out STD_LOGIC;			--Error occurred during command processing
		Out_RDV			: Out STD_LOGIC;			--(Rendezvous) command is processed
		
		--RGB output
		Out_DataR_R		: Out STD_LOGIC_Vector(11 downto 0);
		Out_DataR_G		: Out STD_LOGIC_Vector(11 downto 0);
		Out_DataR_B		: Out STD_LOGIC_Vector(11 downto 0);
		Out_PixelR_CLK	: out std_logic;
		
		Out_DataL_R		: Out STD_LOGIC_Vector(11 downto 0);
		Out_DataL_G 	: Out STD_LOGIC_Vector(11 downto 0);
		Out_DataL_B		: Out STD_LOGIC_Vector(11 downto 0);
		Out_PixelL_CLK	: out std_logic;
	
		--Picture data
		R_FRAME_VALID	: in STD_LOGIC;								-- Shows the valid period
		R_LINE_VALID	: in STD_LOGIC;								-- Rising shows the valid Data.
		R_PIXCLK		: in STD_LOGIC;
		R_TRIGGER		: out std_logic;
		R_CAM_DATA		: in STD_LOGIC_VECTOR(11 downto 0);
		
		L_FRAME_VALID	: in STD_LOGIC;								-- Shows the valid period
		L_LINE_VALID	: in STD_LOGIC;								-- Rising shows the valid Data.
		L_PIXCLK		: in STD_LOGIC;
		L_TRIGGER		: out std_logic;
		L_CAM_DATA		: in STD_LOGIC_VECTOR(11 downto 0);
			
		--I2C pins
		InOut_I2C_L_SDA: inout std_logic:='Z';
		InOut_I2C_L_SCL: inout std_logic:='Z';
		InOut_I2C_R_SDA: inout std_logic:='Z';
		InOut_I2C_R_SCL: inout std_logic:='Z'
    );
end Component;


--====================================== Define Signals needed for controlling the program 

attribute keep : string;
--For simulating CommunicationReceiver:
Signal tmp_rx0							:		 STD_LOGIC:='0';
Signal tmp_rx1							:		 STD_LOGIC:='0';
Constant IsSimulation					:		 STD_LOGIC:= '0'; -- TODOI

-- Signals for Control Program
Constant cns_PacketSize_367			: 	INTEGER:= 367;
Constant cns_Index_data_359			: 	INTEGER:= 359;
SIGNAL 	Counter_WR_Index_Buffered	: 	INTEGER;


-- Control The Server Loop with this counters
SIGNAL 		Init_Time					:	STD_LOGIC_Vector(30 downto 0):= (Others=>'0');
SIGNAL 		Init_Index					:	INTEGER range 28 downto 0;
SIGNAL 		Server_Time					:	STD_LOGIC_Vector(20 downto 0):= (Others=>'0');
SIGNAL 		Wait_Time					:	STD_LOGIC_Vector(3 downto 0):= (Others=>'0');
Constant 	Constant_Server_Index		:	INTEGER 	:= 1;
SIGNAL 		Ethernet_Pack_Count			:	STD_LOGIC_Vector(31 downto 0):= (Others=>'0');
SIGNAL 		Counter_img_From_Ethernet	:	STD_LOGIC_Vector(31 downto 0):= (Others=>'0');

SIGNAL 		Pixel_Count					:	INTEGER	:= 0;

-- For Receiver
SIGNAL	Index_Data_Recieved			:	INTEGER;
SIGNAL 	Pick_Command				:	STD_LOGIC;

--Signals For Communication
		  
SIGNAL 	Communication_In_Data				: 	STD_LOGIC_VECTOR(71  downto 0);	
SIGNAL  Communication_In_Reply				: 	STD_LOGIC_VECTOR(71  downto 0):= (Others =>'0');
SIGNAL  Communication_In_DataValid			: 	STD_LOGIC;
SIGNAL  Communication_In_ReplyValid			: 	STD_LOGIC:='0';
SIGNAL  Communication_Out_Data				: 	STD_LOGIC_VECTOR(71  downto 0);	
SIGNAL  Communication_Out_Data_Ready		: 	STD_LOGIC;
SIGNAL  Communication_Out_Command_Ready		: 	STD_LOGIC;
SIGNAL  Communication_Out_Is_Sending		: 	STD_LOGIC;
SIGNAL	Communication_Out_PHY_TX_Enable		:	STD_LOGIC;
SIGNAL 	Communication_Out_PHY_TX			:	STD_LOGIC_VECTOR(1  downto 0);	
SIGNAL 	Communication_In_PHY_RX				:	STD_LOGIC_VECTOR(1  downto 0);	
SIGNAL 	Communication_In_PHY_CRS_G13		:	STD_LOGIC;	


-- Signals for Camera_Manager
SIGNAL Camera_Manager_Out_RDV				: 	     STD_LOGIC;
SIGNAL Camera_Manager_In_Command			: 	     STD_LOGIC_Vector(7 downto 0);
--SIGNAL Camera_Manager_In_PickCommand		: 	     STD_LOGIC;
SIGNAL Camera_Manager_In_Enable				: 	     STD_LOGIC;		
SIGNAL Camera_Manager_In_Reset				: 	     STD_LOGIC;		  
SIGNAL Camera_Manager_Out_Error				: 	     STD_LOGIC;								
SIGNAL Camera_Manager_In_Call				: 	     STD_LOGIC;		
SIGNAL Camera_Manager_Out_DataL_R			: 	     STD_LOGIC_Vector(11 downto 0);
SIGNAL Camera_Manager_Out_DataL_G			: 	     STD_LOGIC_Vector(11 downto 0);
SIGNAL Camera_Manager_Out_DataL_B			: 	     STD_LOGIC_Vector(11 downto 0);
SIGNAL Camera_Manager_Out_DataR_R			: 	     STD_LOGIC_Vector(11 downto 0);
SIGNAL Camera_Manager_Out_DataR_G 			: 	     STD_LOGIC_Vector(11 downto 0);
SIGNAL Camera_Manager_Out_DataR_B			: 	     STD_LOGIC_Vector(11 downto 0);
SIGNAL Camera_Manager_Out_IsActive			: 	     STD_LOGIC;
SIGNAL Camera_Manager_Out_PixelL_CLK		: 	     STD_LOGIC;
SIGNAL Camera_Manager_Out_PixelR_CLK		: 	     STD_LOGIC;

--PHY Manager
SIGNAL 	PHY_Manager_Out_MDC				:		 STD_LOGIC;
SIGNAL 	PHY_Manager_Out_MDIO			:		 STD_LOGIC;
SIGNAL 	PHY_Manager_Out_IsActive		:		 STD_LOGIC;

--
-- LEDs
SIGNAL LED0					:		 STD_LOGIC:= '0';
SIGNAL LED1					:		 STD_LOGIC:= '0';
SIGNAL LED2					:		 STD_LOGIC:= '0';

-- Test Pins 
SIGNAL PIN_0				:		 STD_LOGIC:= '0';
SIGNAL PIN_1				:		 STD_LOGIC:= '1';
SIGNAL PIN_2				:		 STD_LOGIC:= '0';
SIGNAL PIN_3				:		 STD_LOGIC:= '1';
SIGNAL PIN_5				:		 STD_LOGIC:= '0';
SIGNAL PIN_6				:		 STD_LOGIC:= '1';

-- State for Control 
TYPE 	Status_Control 		IS ( Server, Init_1, Start_Ethernet_Image_1, Right_Camera_GetPic_2); 
SIGNAL 	sts_Control    		: Status_Control	:= Init_1;

TYPE 	Status_Init			IS ( Init_Start, Init_Set, Init_Finish );
SIGNAL 	sts_Init		    	: Status_Init	:= Init_Start;

TYPE 	Status_GetPic			IS ( Reset_Camera_Controler, Enable_Camera_Controler, Send_Command, Wait_ForRDV, Read_Data );
SIGNAL 	sts_GetPic		    	: Status_GetPic	:= Reset_Camera_Controler;


SIGNAL TEMP:std_logic;


BEGIN


--====================== Map ports and signals 
Out_LED_C0_AC1				<= NOT LED0;
Out_LED_C1_AB1		 		<= NOT LED1;
Out_LED_C2_W6		 		<= NOT LED2;
Out_PHY_MDC_H6				<= PHY_Manager_Out_MDC;
Out_PHY_MDIO_J7				<= PHY_Manager_Out_MDIO;
Out_PHY_Reset_J6			<=	'1';

---- Communication
Out_PHY_DATA_0_D3			<=	Communication_Out_PHY_TX(0);	
Out_PHY_DATA_1_F4			<=	Communication_Out_PHY_TX(1);
Out_PHY_TXEN_E4				<=  Communication_Out_PHY_TX_Enable;

-- Rescue Pins
PIN_0 				<= '0';--PHY_Manager_Out_MDC;
PIN_1 				<= '0';--PHY_Manager_Out_MDIO;
PIN_2 				<= '0';
PIN_3 				<= '0';--TEMP;
PIN_5 				<= Camera_Manager_Out_RDV;
PIN_6 				<= Camera_Manager_Out_PixelR_CLK;

-- Control PINS
OUT_RP6_AF14		<= PIN_0;
OUT_RP4_AD15		<= PIN_1;
OUT_RP8_AE14		<= PIN_2;
OUT_RP9_AF13		<= PIN_3;
OUT_RP18_P1			<= PIN_5;
OUT_RP17_M2			<= PIN_6;

--Camera
R_EXTCLK_A14	<=In_CLK_50_Ref_E1;
L_EXTCLK_B13	<=In_CLK_50_Ref_E1;
--=================================  Instance of components

Instance_PHY_Manager		:	PHY_Manager PORT MAP
				(
		  In_CLK_50					=> In_CLK_50_Ref_E1,	
		  Out_PHY_MDIO				=>	PHY_Manager_Out_MDIO,
		  Out_PHY_MDC				=>	PHY_Manager_Out_MDC,					
		  Out_IsActive				=> PHY_Manager_Out_IsActive
				 );

Instance_Communication		:		Communication 		PORT map
								(
		  In_CLK_50						=> In_CLK_50_Ref_E1,
		  In_Data						=> Communication_In_Data,
		  In_Reply						=> Communication_In_Reply,
		  In_DataValid					=> Communication_In_DataValid,
		  In_ReplyValid					=> Communication_In_ReplyValid,
		  
		  Out_Data						=> Communication_Out_Data,
		  Out_Data_Ready				=> Communication_Out_Data_Ready,
		  Out_Command_Ready				=> Communication_Out_Command_Ready,
		  
		  In_PHY_RX						=> Communication_In_PHY_RX,
		  In_PHY_CRS_DV				=> Communication_In_PHY_CRS_G13,
		  Out_PHY_TX					=> Communication_Out_PHY_TX,
		  Out_PHY_TX_Enable				=> Communication_Out_PHY_TX_Enable,
		  Out_Is_Sending				=> Communication_Out_Is_Sending
								); 
					 					
Instance_Camera_Manager	:	Camera_Manager 
					generic MAP
					(
						input_frequency		=>	50_000_000,
						SHARED_CONTROLLER		=> '0',
						SYNCHRONIZE_INPUT		=> '1',
						SYNCHRONIZE_OUTPUT	=> '0',
						DEBUG						=> '0'
						
					)

					PORT map
								(		  
		-- maintenence pins
		In_Enable			=> Camera_Manager_In_Enable,
		In_Reset				=> Camera_Manager_In_Reset,
		In_CLK				=> In_CLK_50_Ref_E1,
  		Out_IsActive		=> Camera_Manager_Out_IsActive,
		
		--Communication
		In_Command	 	   => Camera_Manager_In_Command,
		In_Call		 	   => Camera_Manager_In_Call,
		Out_Error			=> Camera_Manager_Out_Error,
		Out_RDV		 	   => Camera_Manager_Out_RDV,

		--Picture data
		Out_DataL_R			=> Camera_Manager_Out_DataL_R,
		Out_DataL_G			=> Camera_Manager_Out_DataL_G,
		Out_DataL_B			=> Camera_Manager_Out_DataL_B,
		Out_PixelL_CLK		=> Camera_Manager_Out_PixelL_CLK,
		
		Out_DataR_R			=> Camera_Manager_Out_DataR_R,
		Out_DataR_G 		=> Camera_Manager_Out_DataR_G,
		Out_DataR_B			=> Camera_Manager_Out_DataR_B,
		Out_PixelR_CLK		=> Camera_Manager_Out_PixelR_CLK,
		R_FRAME_VALID		=> R_FRAME_VALID_F20,
		R_LINE_VALID		=> R_LINE_VALID_F19,
		R_PIXCLK			=> R_PIXCLK_C16,
		--R_TRIGGER			=> R_TRIGGER_A15,
		R_TRIGGER			=> temp,
		R_CAM_DATA(0)		=> R_CAM_DATA0_C22,
		R_CAM_DATA(1)		=> R_CAM_DATA1_D22,
		R_CAM_DATA(2)		=> R_CAM_DATA2_C23,
		R_CAM_DATA(3)		=> R_CAM_DATA3_D23,
		R_CAM_DATA(4)		=> R_CAM_DATA4_A22,
		R_CAM_DATA(5)		=> R_CAM_DATA5_B23,
		R_CAM_DATA(6)		=> R_CAM_DATA6_G17,
		R_CAM_DATA(7)		=> R_CAM_DATA7_H17,
		R_CAM_DATA(8)		=> R_CAM_DATA8_B21,
		R_CAM_DATA(9)		=> R_CAM_DATA9_C21,
		R_CAM_DATA(10)		=> R_CAM_DATA10_D21,
		R_CAM_DATA(11)		=> R_CAM_DATA11_E21,
				
		L_FRAME_VALID		=> L_FRAME_VALID_F12,
		L_LINE_VALID		=> L_LINE_VALID_C11,
		L_PIXCLK			=> L_PIXCLK_K11,
		L_TRIGGER			=> L_TRIGGER_G10,
		L_CAM_DATA(0)		=> L_CAM_DATA0_B10,
		L_CAM_DATA(1)		=> L_CAM_DATA1_A10,
		L_CAM_DATA(2)		=> L_CAM_DATA2_D10,
		L_CAM_DATA(3)		=> L_CAM_DATA3_C10,
		L_CAM_DATA(4)		=> L_CAM_DATA4_H12,
		L_CAM_DATA(5)		=> L_CAM_DATA5_G12,
		L_CAM_DATA(6)		=> L_CAM_DATA6_B9,
		L_CAM_DATA(7)		=> L_CAM_DATA7_A9,
		L_CAM_DATA(8)		=> L_CAM_DATA8_D9,
		L_CAM_DATA(9)		=> L_CAM_DATA9_E10,	
		L_CAM_DATA(10)		=> L_CAM_DATA10_B8,
		L_CAM_DATA(11)		=> L_CAM_DATA11_C7,
		--I2C pins
		InOut_I2C_L_SDA		=> InOut_I2C_L_SDA_B15,
		InOut_I2C_L_SCL		=> InOut_I2C_L_SCL_F14,
		InOut_I2C_R_SDA		=> InOut_I2C_R_SDA_G9,
		InOut_I2C_R_SCL		=> InOut_I2C_R_SCL_F7
    );
 --Picture data
		
--		LED2<=TEMP;
		R_TRIGGER_A15<=TEMP;
		
		
		
		
-- Main Controller of the program
PROCESS (In_CLK_50_Ref_E1)
	BEGIN
		IF  falling_edge(In_CLK_50_Ref_E1)THEN	
		
		--Set to Default Values
		Communication_In_ReplyValid	<=	'0';
		Communication_In_DataValid		<= '0';
				CASE sts_Control IS
						WHEN Init_1	=>
							--Actions
							CASE sts_Init IS
								WHEN Init_Start	=>
									Init_Time  <=  ( Others=> '0');										
									
									-- Next Sub_State									
									sts_Init 		<= Init_Set;
								----------															
								WHEN Init_Set	=>	
																
									-- Next Sub_State									
									sts_Init 		<= Init_Finish;
								----------
								WHEN Init_Finish	=>
									
									-- Next State and Sub_State
									IF  Init_Time(Init_Index)= '1' THEN
										-- LEDS
										LED0 <= '1';
										LED1 <= '1';
										LED2 <= '1';
										IF Communication_Out_Is_Sending = '0' THEN -- IF all init process goes well then we need to send data											
											Communication_In_Reply		<= x"12345678FFFFFFFFFF";
											Communication_In_ReplyValid	<=	'1';											
											sts_Init <= Init_Start;
											sts_Control <= Server;
										END IF;											
									ELSE
										Init_Time <= Init_Time + 1;
									END IF;	
									
							END Case;						
						WHEN Server	=>								
							IF Communication_Out_Command_Ready = '1' THEN
								IF Server_Time(Constant_Server_Index) = '1' THEN -- Wait to not receive a massage twice
									
									CASE Communication_Out_Data(67 downto 64) IS									
										WHEN "0001" =>		
											Communication_In_Reply		<= x"01FFFFFFFF"&Communication_Out_Data(63 downto 32);
											Communication_In_ReplyValid	<=	'1';											
											sts_Control <= Start_Ethernet_Image_1; 
											Counter_img_From_Ethernet <=Communication_Out_Data(63 downto 32);
											-- LEDS
											LED0 <= '1';
											LED1 <= '0';
											LED2 <= '0';							
										WHEN "0010" =>	 
											sts_Control <= Right_Camera_GetPic_2;	
											IF Communication_Out_Is_Sending = '0' THEN 								
												Communication_In_Reply		<= x"300000000000000000";
												Communication_In_ReplyValid	<=	'1';
											END IF;
											-- LEDS
											LED0 <= '0';
											LED1 <= '1';
											LED2 <= '0';							
										when others =>    
											LED0 <= '0';
											LED1 <= '0';
											LED2 <= '0';
											Communication_In_Reply		<= x"1E0000000000000000";
											Communication_In_ReplyValid	<=	'1';
									END CASE;
									Server_Time <=	(Others =>'0');
								ELSE    
									Server_Time <= Server_Time + 1;								
								END IF;

							END IF;
						--==**==--

							
						-- Receive Images from Ethernet Instead of Cams
						WHEN Start_Ethernet_Image_1	=> 
							-- Actions							
							IF Communication_Out_Data_Ready = '1' THEN
								CASE Wait_Time IS
									WHEN x"0" => 
										Wait_Time <= Wait_Time + 1;
--										Communication_In_Data		<= Ethernet_Pack_Count &x"FF"& Counter_img_From_Ethernet;
										Communication_In_Data		<= Communication_out_Data;
										Communication_In_DataValid	<= '1';
										IF Ethernet_Pack_Count = Counter_img_From_Ethernet -1 THEN
											sts_Control <= Server;
											LED0 <= '1';
											LED1 <= '1';
											LED2 <= '1';																	
											Ethernet_Pack_Count 		<= (Others=>'0');
										ELSE
											Ethernet_Pack_Count 		<= Ethernet_Pack_Count + 1;
										END IF;
									WHEN x"3" =>
										Wait_Time <= x"0";
									WHEN OTHERS =>
										Wait_Time <= Wait_Time + 1;
								END CASE;
								ELSE
									Wait_Time <= x"0";
							END IF;				
							
--============================================================================================---------						
						WHEN Right_Camera_GetPic_2	=> -- Send a packet if Fifo has more than 5 * 72 ,360 Data + 8 bit counter
							--Actions							
							IF Camera_Manager_Out_Error = '1' THEN 								
								Communication_In_Reply		<= x"EEEEEEEEEEEEEEEEEE";
								Communication_In_ReplyValid	<=	'1';
								sts_Control <= Server;
							END IF;
							
							CASE sts_GetPic IS
								WHEN Reset_Camera_Controler =>
									Camera_Manager_In_Reset	<='1';
									sts_GetPic					<=Enable_Camera_Controler;
								WHEN Enable_Camera_Controler =>
									Camera_Manager_In_Enable<='1';
									Camera_Manager_In_Reset	<='0';
--									LED1<='0';
--									LED2<=not LED2;
									sts_GetPic					<=Send_Command;
								WHEN Send_Command	=>
--									LED1<=not LED1;
--									LED2<='0';
									IF Communication_Out_Is_Sending = '0' THEN 	
										Pixel_Count	<= 0;
										Camera_Manager_In_Command	<=x"03";
										Camera_Manager_In_Call		<='1';
										sts_GetPic					<=Wait_ForRDV;
									END IF;
								WHEN Wait_ForRDV	=>
--									LED1<=not LED1;
--									LED2<=not LED2;
									IF Camera_Manager_Out_RDV = '1' THEN
										Camera_Manager_In_Call		<='0';
										sts_GetPic					<=Read_Data;
									END IF;
								WHEN Read_Data		=>
									IF Pixel_Count < 50 THEN
										Communication_In_DataValid			  <=Camera_Manager_Out_PixelR_CLK;
										Communication_In_Data(71 downto 36)<=Camera_Manager_Out_DataR_R & Camera_Manager_Out_DataR_G & Camera_Manager_Out_DataR_B;
										Pixel_Count	<= Pixel_Count + 1 ;
									ELSE
										Pixel_Count	<= 0;
										sts_GetPic	<=Reset_Camera_Controler;
										sts_Control <= Server;
									END IF;
							END CASE;
							
				END CASE;
		END IF;
	END PROCESS;




--For simulating CommunicationReciever Process
RX_Proc: Process(In_CLK_50_Ref_E1)
BEGIN
	IF falling_edge(In_CLK_50_Ref_E1) THEN
		IF IsSimulation = '1' THEN -- Delay rx from tx for 2
			tmp_rx0										<=	 Communication_Out_PHY_TX(0); 
			tmp_rx1										<=	 Communication_Out_PHY_TX(1);
			Communication_In_PHY_RX(0)				<=	 tmp_rx0; 
			Communication_In_PHY_RX(1)				<=	 tmp_rx1;		
		ELSE
			Communication_In_PHY_RX(0)				<=	 In_PHY_RX0_J9; 
			Communication_In_PHY_RX(1)				<=	 In_PHY_RX1_J8;		
		END IF;
	END IF;
END PROCESS;

--For simulating CommunicationReciever Process
RX_Proc2: Process(In_CLK_50_Ref_E1)
BEGIN
	IF rising_edge(In_CLK_50_Ref_E1) THEN
		IF IsSimulation = '1' THEN -- Delay rx from tx for 2
			Communication_In_PHY_CRS_G13						<=	 Communication_Out_PHY_TX_Enable;
			
			-- Server Loop Controls timing
			Init_Index <= 2;
		ELSE
			Communication_In_PHY_CRS_G13						<=	 In_PHY_CRS_G13;
			
			-- Server Loop Controls Timing
			Init_Index <= 27;
		END IF;
	END IF;
END PROCESS;
--END For simulating CommunicationReciever Test Process
end Behavioral; 

