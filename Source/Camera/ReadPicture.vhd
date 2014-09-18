library ieee;
use ieee.std_logic_1164.all;

entity ReadPicture is
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

end entity;

architecture rtl of ReadPicture is

component ReadPic
	generic
	(
		DEBUG:bit:='1'
	);

	port 
	(
		clk		: in std_logic;
		nReset	: in std_logic;
		
		CALL	: in std_logic;
		RDV		: out std_logic;
		
		TRIGGER		: out std_logic;
		PIXCLK		: in std_logic;
		FRAME_VALID	: in std_logic;
		LINE_VALID	: in std_logic;
		CAMERA_DATA	: in std_logic_vector(11 downto 0);
		
		PixelR	: out std_logic_vector(11 downto 0);
		PixelG	: out std_logic_vector(11 downto 0);
		PixelB	: out std_logic_vector(11 downto 0);
		PixelClk: out std_logic
	);

end component;

begin

no_shared_C:if SHARED_CONTROLLER='0' generate

no_shared_block:block
signal CALL_R:std_logic;
signal RDV_R:std_logic;
signal CALL_L:std_logic;
signal RDV_L:std_logic;
signal selected_camera:std_logic_vector(1 downto 0);
type STATE_TYPE is (
				IDLE_state,
				WAIT_FOR_L_RDV_state,
				WAIT_FOR_R_RDV_state,
				WAIT_FOR_RDV_state,
				DONE_state);
signal state:STATE_TYPE;

begin
	selected_camera<=R_SELECT_CAM & L_SELECT_CAM;
	
	process(clk)
	begin
		if rising_edge(clk) then
			if nReset='0' then
				state<=IDLE_STATE;
				CALL_L<='0';
				CALL_R<='0';
			else
				case state is
				when IDLE_STATE =>
					if CALL='1' then
						case selected_camera is
						when "01" =>
							state<=WAIT_FOR_L_RDV_state;
							CALL_L<='1';
						when "10" =>
							state<=WAIT_FOR_R_RDV_state;
							CALL_R<='1';
						when "11" =>
							state<=WAIT_FOR_RDV_state;
							CALL_R<='1';
							CALL_L<='1';
						when others=>
							state<=IDLE_state;
						end case;
					else
						state<=IDLE_STATE;
					end if;
				
				when WAIT_FOR_L_RDV_state=>
					if (RDV_L='1') then
						CALL_L<='0';
						state<=DONE_state;
					else
						CALL_L<='1';
						state<=WAIT_FOR_L_RDV_state;
					end if;
				
				when WAIT_FOR_R_RDV_state=>
					if (RDV_R='1') then
						CALL_R<='0';
						state<=DONE_state;
					else
						CALL_R<='1';
						state<=WAIT_FOR_R_RDV_state;
					end if;
				
				when WAIT_FOR_RDV_state=>
					if ((RDV_L='1') and (RDV_R='1')) then
						CALL_L<='0';
						CALL_R<='0';
						state<=DONE_state;
					else
						CALL_L<='1';
						CALL_R<='1';
						state<=WAIT_FOR_RDV_state;
					end if;
				
				when DONE_state=>
					if (CALL='1') then
						RDV<='1';
						state<=DONE_state;
					else
						RDV<='0';
						state<=IDLE_state;
					end if;
				
				when others=> state<=IDLE_state;
				end case;
			end if;
		end if;
	end process;

	
	
	
	L_CAM:ReadPic
	generic map(DEBUG)
	port map(
		clk,
		nReset,
		
		CALL_L,
		RDV_L,
		
		L_TRIGGER,
		L_PIXCLK,
		L_FRAME_VALID,
		L_LINE_VALID,
		L_CAMERA_DATA,
		
		L_PixelR,
		L_PixelG,
		L_PixelB,
		L_PixelClk
	);
	R_CAM:ReadPic
	generic map(DEBUG)
	port map(
		clk,
		nReset,
		
		CALL_R,
		RDV_R,
		
		R_TRIGGER,
		R_PIXCLK,
		R_FRAME_VALID,
		R_LINE_VALID,
		R_CAMERA_DATA,
		
		R_PixelR,
		R_PixelG,
		R_PixelB,
		R_PixelClk
	);

end block;end generate;


shared_C:if SHARED_CONTROLLER='1' generate

shared_block:block

type READPIC_INPUT_COLLECTION is
	record
	PIXCLK		: std_logic;
	FRAME_VALID	: std_logic;
	LINE_VALID	: std_logic;
	CAMERA_DATA	: std_logic_vector(11 downto 0);
	end record;
	
signal ReadPic_inputs: READPIC_INPUT_COLLECTION;
signal ReadPic_inputs_L: READPIC_INPUT_COLLECTION;
signal ReadPic_inputs_R: READPIC_INPUT_COLLECTION;

type READPIC_OUTPUT_COLLECTION is
	record
	PixelR	: std_logic_vector(11 downto 0);
	PixelG	: std_logic_vector(11 downto 0);
	PixelB	: std_logic_vector(11 downto 0);
	PixelClk: std_logic;
	TRIGGER	: std_logic;
	end record;
	
constant ReadPic_outputs_default:READPIC_OUTPUT_COLLECTION:=
((others=>'0'),(others=>'0'),(others=>'0'),'0','1');





signal ReadPic_outputs: READPIC_OUTPUT_COLLECTION;
signal ReadPic_outputs_L: READPIC_OUTPUT_COLLECTION;
signal ReadPic_outputs_R: READPIC_OUTPUT_COLLECTION;


signal ReadPic_CALL:std_logic;
signal ReadPic_RDV:std_logic;




signal current_camera:std_logic;
begin

ReadPic_inputs_L.PIXCLK			<=L_PIXCLK;
ReadPic_inputs_L.FRAME_VALID	<=L_FRAME_VALID;
ReadPic_inputs_L.LINE_VALID		<=L_LINE_VALID;
ReadPic_inputs_L.CAMERA_DATA	<=L_CAMERA_DATA;

ReadPic_inputs_R.PIXCLK			<=R_PIXCLK;
ReadPic_inputs_R.FRAME_VALID	<=R_FRAME_VALID;
ReadPic_inputs_R.LINE_VALID		<=R_LINE_VALID;
ReadPic_inputs_R.CAMERA_DATA	<=R_CAMERA_DATA;

L_PixelR	<=ReadPic_outputs_L.PixelR;
L_PixelG	<=ReadPic_outputs_L.PixelG;
L_PixelB	<=ReadPic_outputs_L.PixelB;
L_PixelClk	<=ReadPic_outputs_L.PixelClk;
L_TRIGGER	<=ReadPic_outputs_L.TRIGGER;

R_PixelR	<=ReadPic_outputs_R.PixelR;
R_PixelG	<=ReadPic_outputs_R.PixelG;
R_PixelB	<=ReadPic_outputs_R.PixelB;
R_PixelClk	<=ReadPic_outputs_R.PixelClk;
R_TRIGGER	<=ReadPic_outputs_R.TRIGGER;


ReadPic_inputs<=ReadPic_inputs_L when current_camera='0' else ReadPic_inputs_R;
ReadPic_outputs_L<=ReadPic_outputs when current_camera='0' else ReadPic_outputs_default;
ReadPic_outputs_R<=ReadPic_outputs when current_camera='1' else ReadPic_outputs_default;


Reader:ReadPic
	generic map (DEBUG)
	port map(
		clk,
		nReset,
		
		ReadPic_CALL,
		ReadPic_RDV,
		
		ReadPic_outputs.TRIGGER,
		ReadPic_inputs.PIXCLK,
		ReadPic_inputs.FRAME_VALID,
		ReadPic_inputs.LINE_VALID,
		ReadPic_inputs.CAMERA_DATA,
		
		ReadPic_outputs.PixelR,
		ReadPic_outputs.PixelG,
		ReadPic_outputs.PixelB,
		ReadPic_outputs.PixelClk
	);




state_machine:block
type STATE_TYPE is (IDLE_state,WAIT_FOR_SETTETLING_state,WAITING_FOR_RDV_state,DONE_state);
signal state:STATE_TYPE;
constant WAIT_AMOUNT:integer:=20;
signal counter: integer range 0 to WAIT_AMOUNT;
begin
	
process(clk)
variable selected_camera:std_logic_vector(1 downto 0);
begin
	if rising_edge(clk) then
		if nReset='0' then
			state<=IDLE_state;
			counter<=0;
			ReadPic_CALL<='0';
		else
			case state is
			when IDLE_state=>
				counter<=0;
				if CALL='1' then
					selected_camera:=L_SELECT_CAM & R_SELECT_CAM;
					case (selected_camera) is
					when "01"=>
						state<=WAIT_FOR_SETTETLING_state;
						current_camera<='1';
					when "10"=>
						state<=WAIT_FOR_SETTETLING_state;
						current_camera<='0';
					when others=>
						state<=DONE_state;
					end case;
				else
					state<=IDLE_state;
				end if;
					
			when WAIT_FOR_SETTETLING_state=>
				if (counter=WAIT_AMOUNT) then
					state<=WAITING_FOR_RDV_state;
					ReadPic_CALL<='1';
				else
					counter<=counter+1;
					state<=WAIT_FOR_SETTETLING_state;
				end if;
			
			when WAITING_FOR_RDV_state=>
				if (ReadPic_RDV='0') then
					ReadPic_CALL<='1';
					state<=WAITING_FOR_RDV_state;
				else
					ReadPic_CALL<='0';
					state<=DONE_state;
				end if;
			
			when DONE_state=>
				if CALL='1' then
					RDV<='1';
					state<=DONE_state;
				else
					RDV<='0';
					state<=IDLE_state;
				end if;
			
			when others=>state<=IDLE_state;
			end case;
		end if;
	end if;
end process;
end block;end block;end generate;









end rtl;
