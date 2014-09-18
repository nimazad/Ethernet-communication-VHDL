library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.CAMERA_MANAGER_PACK.all;

entity Camera_Manager is
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
end Camera_Manager;

architecture Behavioral of Camera_Manager is


component dual_camera_I2C_controller
	generic
	(
		input_frequency	: positive  :=	125_000_000;
		output_frequency: positive  :=	400_000;
		DEBUG: bit:='1'
	);
	port 
	(
		clk,nReset	: in std_logic;
		
		ADDRESS	    : in std_logic_vector(7 downto 0);
		DATA_R		: out std_logic_vector(15 downto 0);
		DATA_W		: in std_logic_vector(15 downto 0);
		Read_nWrite	: in std_logic;
		CALL		: in std_logic;
		RDV		: out std_logic:='0';
		Error		: out std_logic:='0';
		
		SDA_L			: inout std_logic;
		SCL_L			: inout std_logic;
		SDA_R			: inout std_logic;
		SCL_R			: inout std_logic;
		
		
		current_camera: in std_logic
		
		
	);
end component;



component ReadPicture
	generic
	(
		SHARED_CONTROLLER:bit:='0';
		DEBUG:bit:='1'
	);
	port 
	(
		clk		: in std_logic;
		nReset	: in std_logic;
		CALL	: in std_logic;
		RDV		: out std_logic;
		
		R_SELECT_CAM: in std_logic;
		L_SELECT_CAM: in std_logic;
		
		R_TRIGGER		: out std_logic;
		R_PIXCLK		: in std_logic;
		R_FRAME_VALID	: in std_logic;
		R_LINE_VALID	: in std_logic;
		R_CAMERA_DATA	: in std_logic_vector(11 downto 0);

		L_TRIGGER		: out std_logic;
		L_PIXCLK		: in std_logic;
		L_FRAME_VALID	: in std_logic;
		L_LINE_VALID	: in std_logic;
		L_CAMERA_DATA	: in std_logic_vector(11 downto 0);
		
		R_PixelR	: out std_logic_vector(11 downto 0);
		R_PixelG	: out std_logic_vector(11 downto 0);
		R_PixelB	: out std_logic_vector(11 downto 0);
		R_PixelClk: out std_logic;
		
		L_PixelR	: out std_logic_vector(11 downto 0);
		L_PixelG	: out std_logic_vector(11 downto 0);
		L_PixelB	: out std_logic_vector(11 downto 0);
		L_PixelClk: out std_logic
	);
end component;



signal I2C_current_camera:	std_logic; --0 = left     1 = right
signal I2C_CALL		: std_logic;
signal I2C_address	: std_logic_vector(7 downto 0);
signal I2C_dataW		: std_logic_vector(15 downto 0);
signal I2C_RDV		: std_logic;
signal I2C_dataR		: std_logic_vector(15 downto 0);
signal I2C_Read_nWrite: std_logic;
signal I2C_Error		: std_logic;


signal ReadPicture_CALL		: std_logic;
signal ReadPicture_RDV		: std_logic;
signal ReadPicture_camera_L : std_logic;
signal ReadPicture_camera_R : std_logic;


signal Unsync_Out_DataR_R		: STD_LOGIC_Vector(11 downto 0);
signal Unsync_Out_DataR_G		: STD_LOGIC_Vector(11 downto 0);
signal Unsync_Out_DataR_B		: STD_LOGIC_Vector(11 downto 0);
signal Unsync_Out_PixelR_CLK	: std_logic;
signal Unsync_R_TRIGGER			: std_logic;
		
signal Unsync_Out_DataL_R		: STD_LOGIC_Vector(11 downto 0);
signal Unsync_Out_DataL_G 		: STD_LOGIC_Vector(11 downto 0);
signal Unsync_Out_DataL_B		: STD_LOGIC_Vector(11 downto 0);
signal Unsync_Out_PixelL_CLK	: std_logic;
signal Unsync_L_TRIGGER			: std_logic;


signal sync_R_PIXCLK		: std_logic;
signal sync_R_FRAME_VALID	: std_logic;
signal sync_R_LINE_VALID	: std_logic;
signal sync_R_CAMERA_DATA	: std_logic_vector(11 downto 0);

signal sync_L_PIXCLK		: std_logic;
signal sync_L_FRAME_VALID	: std_logic;
signal sync_L_LINE_VALID	: std_logic;
signal sync_L_CAMERA_DATA	: std_logic_vector(11 downto 0);





begin


Main:
block
	type MAIN_STATES is (
				INIT_state,
				INIT1_state,
				INIT2_state,
				

				
				SEND_RIGHT_PICTURE_state,
				SEND_LEFT_PICTURE_state,
				SEND_BOTH_PICTURE_state,
				SEND_PICTURE1_state,
				SEND_PICTURE2_state,
				
				
				
				
				START_TEST_PATTERN_state,
				START_TEST_PATTERN2_state,
				STOP_TEST_PATTERN_state,
				STOP_TEST_PATTERN2_state,
				
				CAMERA_SPEED_1_PATTERN_state,
				CAMERA_SPEED_1_PATTERN2_state,
				
				CAMERA_SPEED_2_PATTERN_state,
				CAMERA_SPEED_2_PATTERN2_state,
				
				CAMERA_SPEED_4_PATTERN_state,
				CAMERA_SPEED_4_PATTERN2_state,
				
				CAMERA_SPEED_8_PATTERN_state,
				CAMERA_SPEED_8_PATTERN2_state,
				
				CAMERA_SPEED_16_PATTERN_state,
				CAMERA_SPEED_16_PATTERN2_state,
				
				CAMERA_SPEED_32_PATTERN_state,
				CAMERA_SPEED_32_PATTERN2_state,
				
				CAMERA_SPEED_64_PATTERN_state,
				CAMERA_SPEED_64_PATTERN2_state,
				
				CAMERA_SPEED_128_PATTERN_state,
				CAMERA_SPEED_128_PATTERN2_state,

				
				DISABLE_state,
				ERROR_state,
				DONE_state,
				IDLE_state);
	signal state: MAIN_STATES;
	signal counter:natural range 0 to counter_max;

	begin
	
	Out_IsActive<='0' when (state=IDLE_state) or (state=DISABLE_state) else '1';

	
	process(In_CLK)
	
	begin
	if rising_edge(In_CLK) then
		if (In_Reset='1') then
			I2C_current_camera<='0';
			ReadPicture_camera_L<='0';
			ReadPicture_camera_R<='0';

			I2C_CALL<='0';
			ReadPicture_CALL<='0';
			Out_Error<='0';
			counter<=counter_max;
			state<=INIT_state;
		else
			case state is
			
			
			when DISABLE_state =>
				if (In_Enable='1') then
					state<=IDLE_state;
				else
					state<=DISABLE_state;
				end if;
				
			when DONE_state=>
				if (In_CALL='1') then
					Out_RDV<='1';
				else
					Out_RDV<='0';
					state<=IDLE_state;
				end if;
			
			when ERROR_state=>
				Out_Error<='1';
				state<=ERROR_state;
				
				
				
				
				
			when IDLE_state =>
				I2C_current_camera<='0';
				counter<=0;
				if (In_Enable='0') then
					state<=DISABLE_state;
				elsif (In_Call='1') then
					case In_Command is
					when COMMAND_send_right_picture =>	state<=SEND_RIGHT_PICTURE_state;
					when COMMAND_send_left_picture =>	state<=SEND_LEFT_PICTURE_state;
					when COMMAND_send_both_picture =>	state<=SEND_BOTH_PICTURE_state;
					when COMMAND_set_camera_speed_1=>	state<=CAMERA_SPEED_1_PATTERN_state;
					when COMMAND_set_camera_speed_2=>	state<=CAMERA_SPEED_2_PATTERN_state;
					when COMMAND_set_camera_speed_4=>	state<=CAMERA_SPEED_4_PATTERN_state;
					when COMMAND_set_camera_speed_8=>	state<=CAMERA_SPEED_8_PATTERN_state;
					when COMMAND_set_camera_speed_16=>	state<=CAMERA_SPEED_16_PATTERN_state;
					when COMMAND_set_camera_speed_32=>	state<=CAMERA_SPEED_32_PATTERN_state;
					when COMMAND_set_camera_speed_64=>	state<=CAMERA_SPEED_64_PATTERN_state;
					when COMMAND_set_camera_speed_128=>	state<=CAMERA_SPEED_128_PATTERN_state;
					when COMMAND_start_test_pattern =>	state<=START_TEST_PATTERN_state;	
					when COMMAND_stop_test_pattern =>	state<=STOP_TEST_PATTERN_state;
					when others =>						state<=ERROR_state;
					end case;
				else
					state<=IDLE_state;
				end if;
			
			
			
			
			
			
			
			
			
			
			
			when INIT_state=>
				I2C_current_camera<='0';	
				state<=INIT1_state;
			
			when INIT1_state=>
				I2C_address<=INIT_STATEMENT(counter).I2C_addr;
				I2C_dataW<=INIT_STATEMENT(counter).I2C_value;
				I2C_Read_nWrite<='0';
				I2C_CALL<='1';
				if (I2C_RDV='1') then
					if (I2C_error='0') then
						counter<=counter+1;
						state<=INIT2_state;
					else
						state<=ERROR_state;
					end if;
				else
					state<=INIT1_state;
				end if;
				
			when INIT2_state=>
				I2C_CALL<='0';
				if (I2C_RDV='0') then
					if (counter=INIT_STATEMENT'LENGTH) then
						counter<=0;
						if (I2C_current_camera='0') then
							I2C_current_camera<='1';
							state<=INIT1_state;
						else
							state<=DISABLE_state;
						end if;
					else
						state<=INIT1_state;
					end if;
				else
					state<=INIT2_state;
				end if;
				
			


			
			
			when SEND_RIGHT_PICTURE_state =>
				ReadPicture_camera_L<='0';
				ReadPicture_camera_R<='1';
				state<=SEND_PICTURE1_state;
			when SEND_LEFT_PICTURE_state =>
				ReadPicture_camera_L<='1';
				ReadPicture_camera_R<='0';
				state<=SEND_PICTURE1_state;
			when SEND_BOTH_PICTURE_state =>
				ReadPicture_camera_L<='1';
				ReadPicture_camera_R<='1';
				state<=SEND_PICTURE1_state;
			
			
			
			
			
			when SEND_PICTURE1_state =>
				ReadPicture_CALL<='1';
				if (ReadPicture_RDV='1') then
					state<=SEND_PICTURE2_state;
				else
					state<=SEND_PICTURE1_state;
				end if;
			
			when SEND_PICTURE2_state =>
				ReadPicture_CALL<='0';
				if (ReadPicture_RDV='0') then
					state<=DONE_state;
				else
					state<=SEND_PICTURE2_state;
				end if;
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			when START_TEST_PATTERN_state=>
				I2C_address<=START_TEST_STATEMENT(counter).I2C_addr;
				I2C_dataW<=START_TEST_STATEMENT(counter).I2C_value;
				I2C_Read_nWrite<='0';
				I2C_CALL<='1';
				if (I2C_RDV='1') then
					if (I2C_error='0') then
						counter<=counter+1;
						state<=START_TEST_PATTERN2_state;
					else
						state<=ERROR_state;
					end if;
				else
					state<=START_TEST_PATTERN_state;
				end if;
				
			when START_TEST_PATTERN2_state=>
				I2C_CALL<='0';
				if (I2C_RDV='0') then
					if (counter=START_TEST_STATEMENT'LENGTH) then
						counter<=0;
						if (I2C_current_camera='0') then
							I2C_current_camera<='1';
							state<=START_TEST_PATTERN_state;
						else
							state<=DONE_state;
						end if;
					else
						state<=START_TEST_PATTERN_state;
					end if;
				else
					state<=START_TEST_PATTERN2_state;
				end if;
				
				
			when STOP_TEST_PATTERN_state=>
				I2C_address<=STOP_TEST_STATEMENT(counter).I2C_addr;
				I2C_dataW<=STOP_TEST_STATEMENT(counter).I2C_value;
				I2C_Read_nWrite<='0';
				I2C_CALL<='1';
				if (I2C_RDV='1') then
					if (I2C_error='0') then
						counter<=counter+1;
						state<=STOP_TEST_PATTERN2_state;
					else
						state<=ERROR_state;
					end if;
				else
					state<=STOP_TEST_PATTERN_state;
				end if;
				
			when STOP_TEST_PATTERN2_state=>
				I2C_CALL<='0';
				if (I2C_RDV='0') then
					if (counter=STOP_TEST_STATEMENT'LENGTH) then
						counter<=0;
						if (I2C_current_camera='0') then
							I2C_current_camera<='1';
							state<=STOP_TEST_PATTERN_state;
						else
							state<=DONE_state;
						end if;
					else
						state<=STOP_TEST_PATTERN_state;
					end if;
				else
					state<=STOP_TEST_PATTERN2_state;
				end if;
						
						
						
			when CAMERA_SPEED_1_PATTERN_state=>			
				I2C_address<=CAMERA_SPEED_1_STATEMENT(counter).I2C_addr;		
				I2C_dataW<=CAMERA_SPEED_1_STATEMENT(counter).I2C_value;		
				I2C_Read_nWrite<='0';		
				I2C_CALL<='1';		
				if (I2C_RDV='1') then		
					if (I2C_error='0') then	
						counter<=counter+1;
						state<=CAMERA_SPEED_1_PATTERN2_state;
					else	
						state<=ERROR_state;
					end if;	
				else		
					state<=CAMERA_SPEED_1_PATTERN_state;	
				end if;		
						
			when CAMERA_SPEED_1_PATTERN2_state=>			
				I2C_CALL<='0';		
				if (I2C_RDV='0') then		
					if (counter=CAMERA_SPEED_1_STATEMENT'LENGTH) then	
						counter<=0;
						if (I2C_current_camera='0') then
						
						
						else
						
						end if;
					else	
						state<=CAMERA_SPEED_1_PATTERN_state;
					end if;	
				else		
					state<=CAMERA_SPEED_1_PATTERN2_state;	
				end if;		
			when CAMERA_SPEED_2_PATTERN_state=>			
				I2C_address<=CAMERA_SPEED_2_STATEMENT(counter).I2C_addr;		
				I2C_dataW<=CAMERA_SPEED_2_STATEMENT(counter).I2C_value;		
				I2C_Read_nWrite<='0';		
				I2C_CALL<='1';		
				if (I2C_RDV='1') then		
					if (I2C_error='0') then	
						counter<=counter+1;
						state<=CAMERA_SPEED_2_PATTERN2_state;
					else	
						state<=ERROR_state;
					end if;	
				else		
					state<=CAMERA_SPEED_2_PATTERN_state;	
				end if;		
						
			when CAMERA_SPEED_2_PATTERN2_state=>			
				I2C_CALL<='0';		
				if (I2C_RDV='0') then		
					if (counter=CAMERA_SPEED_2_STATEMENT'LENGTH) then	
						counter<=0;
						if (I2C_current_camera='0') then
						
						
						else
						
						end if;
					else	
						state<=CAMERA_SPEED_2_PATTERN_state;
					end if;	
				else		
					state<=CAMERA_SPEED_2_PATTERN2_state;	
				end if;		
			when CAMERA_SPEED_4_PATTERN_state=>			
				I2C_address<=CAMERA_SPEED_4_STATEMENT(counter).I2C_addr;		
				I2C_dataW<=CAMERA_SPEED_4_STATEMENT(counter).I2C_value;		
				I2C_Read_nWrite<='0';		
				I2C_CALL<='1';		
				if (I2C_RDV='1') then		
					if (I2C_error='0') then	
						counter<=counter+1;
						state<=CAMERA_SPEED_4_PATTERN2_state;
					else	
						state<=ERROR_state;
					end if;	
				else		
					state<=CAMERA_SPEED_4_PATTERN_state;	
				end if;		
						
			when CAMERA_SPEED_4_PATTERN2_state=>			
				I2C_CALL<='0';		
				if (I2C_RDV='0') then		
					if (counter=CAMERA_SPEED_4_STATEMENT'LENGTH) then	
						counter<=0;
						if (I2C_current_camera='0') then
						
						
						else
						
						end if;
					else	
						state<=CAMERA_SPEED_4_PATTERN_state;
					end if;	
				else		
					state<=CAMERA_SPEED_4_PATTERN2_state;	
				end if;		
			when CAMERA_SPEED_8_PATTERN_state=>			
				I2C_address<=CAMERA_SPEED_8_STATEMENT(counter).I2C_addr;		
				I2C_dataW<=CAMERA_SPEED_8_STATEMENT(counter).I2C_value;		
				I2C_Read_nWrite<='0';		
				I2C_CALL<='1';		
				if (I2C_RDV='1') then		
					if (I2C_error='0') then	
						counter<=counter+1;
						state<=CAMERA_SPEED_8_PATTERN2_state;
					else	
						state<=ERROR_state;
					end if;	
				else		
					state<=CAMERA_SPEED_8_PATTERN_state;	
				end if;		
						
			when CAMERA_SPEED_8_PATTERN2_state=>			
				I2C_CALL<='0';		
				if (I2C_RDV='0') then		
					if (counter=CAMERA_SPEED_8_STATEMENT'LENGTH) then	
						counter<=0;
						if (I2C_current_camera='0') then
						
						
						else
						
						end if;
					else	
						state<=CAMERA_SPEED_8_PATTERN_state;
					end if;	
				else		
					state<=CAMERA_SPEED_8_PATTERN2_state;	
				end if;		
			when CAMERA_SPEED_16_PATTERN_state=>			
				I2C_address<=CAMERA_SPEED_16_STATEMENT(counter).I2C_addr;		
				I2C_dataW<=CAMERA_SPEED_16_STATEMENT(counter).I2C_value;		
				I2C_Read_nWrite<='0';		
				I2C_CALL<='1';		
				if (I2C_RDV='1') then		
					if (I2C_error='0') then	
						counter<=counter+1;
						state<=CAMERA_SPEED_16_PATTERN2_state;
					else	
						state<=ERROR_state;
					end if;	
				else		
					state<=CAMERA_SPEED_16_PATTERN_state;	
				end if;		
						
			when CAMERA_SPEED_16_PATTERN2_state=>			
				I2C_CALL<='0';		
				if (I2C_RDV='0') then		
					if (counter=CAMERA_SPEED_16_STATEMENT'LENGTH) then	
						counter<=0;
						if (I2C_current_camera='0') then
						
						
						else
						
						end if;
					else	
						state<=CAMERA_SPEED_16_PATTERN_state;
					end if;	
				else		
					state<=CAMERA_SPEED_16_PATTERN2_state;	
				end if;		
			when CAMERA_SPEED_32_PATTERN_state=>			
				I2C_address<=CAMERA_SPEED_32_STATEMENT(counter).I2C_addr;		
				I2C_dataW<=CAMERA_SPEED_32_STATEMENT(counter).I2C_value;		
				I2C_Read_nWrite<='0';		
				I2C_CALL<='1';		
				if (I2C_RDV='1') then		
					if (I2C_error='0') then	
						counter<=counter+1;
						state<=CAMERA_SPEED_32_PATTERN2_state;
					else	
						state<=ERROR_state;
					end if;	
				else		
					state<=CAMERA_SPEED_32_PATTERN_state;	
				end if;		
						
			when CAMERA_SPEED_32_PATTERN2_state=>			
				I2C_CALL<='0';		
				if (I2C_RDV='0') then		
					if (counter=CAMERA_SPEED_32_STATEMENT'LENGTH) then	
						counter<=0;
						if (I2C_current_camera='0') then
						
						
						else
						
						end if;
					else	
						state<=CAMERA_SPEED_32_PATTERN_state;
					end if;	
				else		
					state<=CAMERA_SPEED_32_PATTERN2_state;	
				end if;		
			when CAMERA_SPEED_64_PATTERN_state=>			
				I2C_address<=CAMERA_SPEED_64_STATEMENT(counter).I2C_addr;		
				I2C_dataW<=CAMERA_SPEED_64_STATEMENT(counter).I2C_value;		
				I2C_Read_nWrite<='0';		
				I2C_CALL<='1';		
				if (I2C_RDV='1') then		
					if (I2C_error='0') then	
						counter<=counter+1;
						state<=CAMERA_SPEED_64_PATTERN2_state;
					else	
						state<=ERROR_state;
					end if;	
				else		
					state<=CAMERA_SPEED_64_PATTERN_state;	
				end if;		
						
			when CAMERA_SPEED_64_PATTERN2_state=>			
				I2C_CALL<='0';		
				if (I2C_RDV='0') then		
					if (counter=CAMERA_SPEED_64_STATEMENT'LENGTH) then	
						counter<=0;
						if (I2C_current_camera='0') then
						
						
						else
						
						end if;
					else	
						state<=CAMERA_SPEED_64_PATTERN_state;
					end if;	
				else		
					state<=CAMERA_SPEED_64_PATTERN2_state;	
				end if;		
			when CAMERA_SPEED_128_PATTERN_state=>			
				I2C_address<=CAMERA_SPEED_128_STATEMENT(counter).I2C_addr;		
				I2C_dataW<=CAMERA_SPEED_128_STATEMENT(counter).I2C_value;		
				I2C_Read_nWrite<='0';		
				I2C_CALL<='1';		
				if (I2C_RDV='1') then		
					if (I2C_error='0') then	
						counter<=counter+1;
						state<=CAMERA_SPEED_128_PATTERN2_state;
					else	
						state<=ERROR_state;
					end if;	
				else		
					state<=CAMERA_SPEED_128_PATTERN_state;	
				end if;		
						
			when CAMERA_SPEED_128_PATTERN2_state=>			
				I2C_CALL<='0';		
				if (I2C_RDV='0') then		
					if (counter=CAMERA_SPEED_128_STATEMENT'LENGTH) then	
						counter<=0;
						if (I2C_current_camera='0') then
						
						
						else
						
						end if;
					else	
						state<=CAMERA_SPEED_128_PATTERN_state;
					end if;	
				else		
					state<=CAMERA_SPEED_128_PATTERN2_state;	
				end if;		

						
					
					
			
		
			when others=>
				state<=INIT1_state;
			end case;	
			
			
		end if;
	end if;
	end process;
end block;










	dual_I2C: dual_camera_I2C_controller
	generic map	(input_frequency,400_000,DEBUG)
	port map (
		In_CLK,
		not In_Reset,
		I2C_address,
		I2C_dataR,
		I2C_dataW,
		I2C_Read_nWrite,
		I2C_CALL,
		I2C_RDV,
		I2C_Error,
		InOut_I2C_L_SDA,InOut_I2C_L_SCL,
		InOut_I2C_R_SDA,InOut_I2C_R_SCL,
		I2C_current_camera
	);
  

  Reader:ReadPicture
  generic map(SHARED_CONTROLLER,DEBUG)
  port map(
	In_CLK,
	not In_Reset,
	ReadPicture_CALL,
	ReadPicture_RDV,

	ReadPicture_camera_R,
	ReadPicture_camera_L,

	Unsync_R_TRIGGER,
	sync_R_PIXCLK,
	sync_R_FRAME_VALID,
	sync_R_LINE_VALID,
	sync_R_CAMERA_DATA,

	Unsync_L_TRIGGER,
	sync_L_PIXCLK,
	sync_L_FRAME_VALID,
	sync_L_LINE_VALID,
	sync_L_CAMERA_DATA,
		
	Unsync_Out_DataR_R,
	Unsync_Out_DataR_G,
	Unsync_Out_DataR_B,
	Unsync_Out_PixelR_CLK,
	
	Unsync_Out_DataL_R,
	Unsync_Out_DataL_G,
	Unsync_Out_DataL_B,
	Unsync_Out_PixelL_CLK);



	input_sync:
	if (SYNCHRONIZE_INPUT='1') generate
		process(In_CLK)
		begin
			if rising_edge(In_CLK) then
				sync_R_PIXCLK		<=R_PIXCLK;
				sync_R_FRAME_VALID	<=R_FRAME_VALID;
				sync_R_LINE_VALID	<=R_LINE_VALID;
				sync_R_CAMERA_DATA	<=R_CAM_DATA;
				sync_L_PIXCLK		<=L_PIXCLK;
				sync_L_FRAME_VALID	<=L_FRAME_VALID;
				sync_L_LINE_VALID	<=L_LINE_VALID;
				sync_L_CAMERA_DATA	<=L_CAM_DATA;
			end if;
		end process;
	end generate;
	
	no_input_sync:
	if (SYNCHRONIZE_INPUT='0') generate
		sync_R_PIXCLK		<=R_PIXCLK;
		sync_R_FRAME_VALID	<=R_FRAME_VALID;
		sync_R_LINE_VALID	<=R_LINE_VALID;
		sync_R_CAMERA_DATA	<=R_CAM_DATA;
		sync_L_PIXCLK		<=L_PIXCLK;
		sync_L_FRAME_VALID	<=L_FRAME_VALID;
		sync_L_LINE_VALID	<=L_LINE_VALID;
		sync_L_CAMERA_DATA	<=L_CAM_DATA;
	end generate;
	
	
	
	
	
	output_sync:
	if (SYNCHRONIZE_OUTPUT='1') generate
		process(In_CLK)
		begin
			if rising_edge(In_CLK) then
				Out_DataR_R			<=Unsync_Out_DataR_R;
				Out_DataR_G			<=Unsync_Out_DataR_G;
				Out_DataR_B			<=Unsync_Out_DataR_B;
				Out_PixelR_CLK		<=Unsync_Out_PixelR_CLK;
					
				Out_DataL_R			<=Unsync_Out_DataL_R;
				Out_DataL_G			<=Unsync_Out_DataL_G;
				Out_DataL_B			<=Unsync_Out_DataL_B;
				Out_PixelL_CLK		<=Unsync_Out_PixelL_CLK;
				L_TRIGGER			<=Unsync_L_TRIGGER;
				R_TRIGGER			<=Unsync_R_TRIGGER;
			end if;
		end process;
	end generate;
	no_output_sync:
	if (SYNCHRONIZE_OUTPUT='0') generate
		Out_DataR_R			<=Unsync_Out_DataR_R;
		Out_DataR_G			<=Unsync_Out_DataR_G;
		Out_DataR_B			<=Unsync_Out_DataR_B;
		Out_PixelR_CLK		<=Unsync_Out_PixelR_CLK;
			
		Out_DataL_R			<=Unsync_Out_DataL_R;
		Out_DataL_G			<=Unsync_Out_DataL_G;
		Out_DataL_B			<=Unsync_Out_DataL_B;
		Out_PixelL_CLK		<=Unsync_Out_PixelL_CLK;
		L_TRIGGER			<=Unsync_L_TRIGGER;
		R_TRIGGER			<=Unsync_R_TRIGGER;
	end generate;
		
end Behavioral;

