library ieee;
use ieee.std_logic_1164.all;

entity ReadPic is
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

end entity;

architecture rtl of ReadPic is

component BayerToRGB
	generic
	(
		IMAGE_WIDTH_MAX : natural := 4;
		IMAGE_DATA_WIDTH : natural := 4
	);

	port 
	(
		clk		: in std_logic;
		nReset	: in std_logic;
		
		CALL	: in std_logic;
		RDV		: out std_logic;
		
		
		FRAME_VALID	: in std_logic;
		LINE_VALID	: in std_logic;
		CAMERA_DATA	: in std_logic_vector(IMAGE_DATA_WIDTH-1 downto 0);
		
		PixelR	: out std_logic_vector(IMAGE_DATA_WIDTH-1 downto 0);
		PixelG	: out std_logic_vector(IMAGE_DATA_WIDTH-1 downto 0);
		PixelB	: out std_logic_vector(IMAGE_DATA_WIDTH-1 downto 0);
		PixelClk: out std_logic
		
	);
end component;
component BayerToRGB_dummy
	generic
	(
		IMAGE_WIDTH_MAX : natural := 4;
		IMAGE_DATA_WIDTH : natural := 4
	);

	port 
	(
		clk		: in std_logic;
		nReset	: in std_logic;
		
		CALL	: in std_logic;
		RDV		: out std_logic;
		
		
		FRAME_VALID	: in std_logic;
		LINE_VALID	: in std_logic;
		CAMERA_DATA	: in std_logic_vector(IMAGE_DATA_WIDTH-1 downto 0);
		
		PixelR	: out std_logic_vector(IMAGE_DATA_WIDTH-1 downto 0);
		PixelG	: out std_logic_vector(IMAGE_DATA_WIDTH-1 downto 0);
		PixelB	: out std_logic_vector(IMAGE_DATA_WIDTH-1 downto 0);
		PixelClk: out std_logic
		
	);
end component;



constant TRIGGER_OFF:std_logic:='1';
constant TRIGGER_ON:std_logic:='0';

signal CALL_ReadPic_to_RGB_converter: std_logic;
signal RDV_RGB_converter_to_ReadPic: std_logic;

type STATE_TYPE is (IDLE_state,
					START_CAMERA_state,
					WAIT_FOR_CAMAERA_state,
					STOP_FOR_CAMERA_state,
					DONE_CAMERA);
signal state:STATE_TYPE;
constant RDV_WAIT_VALUE:natural:= 31;
signal RDV_wait: integer range 0 to RDV_WAIT_VALUE;
begin


process(clk)

begin
	if rising_edge(clk) then
		if (nReset='0') then
			state<=IDLE_state;
		else
			case state is
			when IDLE_state =>
				RDV_wait<=RDV_WAIT_VALUE;
				Trigger<=TRIGGER_OFF;
				if (CALL='1') then
					state<=START_CAMERA_state;
				else
					state<=IDLE_state;
				end if;
				
				
				
				
				
				
				
			when START_CAMERA_state =>
				CALL_ReadPic_to_RGB_converter<='1';
				if (FRAME_VALID='0') then
					Trigger<=TRIGGER_ON;
					state<=START_CAMERA_state;
				else
					Trigger<=TRIGGER_OFF;
					state<=WAIT_FOR_CAMAERA_state;
				end if;
			
	
			
			when WAIT_FOR_CAMAERA_state=>
				if (RDV_RGB_converter_to_ReadPic='1') then
					state<=STOP_FOR_CAMERA_state;
				else
					state<=WAIT_FOR_CAMAERA_state;
				end if;
					
			when STOP_FOR_CAMERA_state=>
				CALL_ReadPic_to_RGB_converter<='0';
				if (RDV_RGB_converter_to_ReadPic<='0') then
					state<=DONE_CAMERA;
				else
					state<=STOP_FOR_CAMERA_state;
				end if;
				
				
			when DONE_CAMERA=>
				if (RDV_wait>0) then
					RDV_wait<=RDV_wait-1;
				else
					if (CALL='1') then
						RDV<='1';
						state<=DONE_CAMERA;
					else
						RDV<='0';
						state<=IDLE_state;
					end if;
				end if;
					
			
			
			when others =>
				state<=IDLE_state;
			end case;
		end if;
	end if;
end process;








small:if (DEBUG='1') generate
RGB_converter :BayerToRGB
	generic map(4,4)
	port map 
	(
		PIXCLK,
		nReset,
		
		CALL_ReadPic_to_RGB_converter,
		RDV_RGB_converter_to_ReadPic,
		
		FRAME_VALID,
		LINE_VALID,
		CAMERA_DATA(3 downto 0),
		
		PixelR(3 downto 0),
		PixelG(3 downto 0),
		PixelB(3 downto 0),
		PixelClk
	);
end generate;

large:if (DEBUG='0') generate
RGB_converter :BayerToRGB
	generic map(1024,12)
	port map 
	(
		PIXCLK,
		nReset,
		
		CALL_ReadPic_to_RGB_converter,
		RDV_RGB_converter_to_ReadPic,
		
		FRAME_VALID,
		LINE_VALID,
		CAMERA_DATA,
		
		PixelR,
		PixelG,
		PixelB,
		PixelClk
	);
end generate;


end rtl;
