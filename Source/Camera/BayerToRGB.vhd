library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity BayerToRGB is
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

end entity;

architecture rtl of BayerToRGB is


--type BayerPattern is
--	record
--		R: std_logic_vector(IMAGE_DATA_WIDTH-1 downto 0);
--		G1: std_logic_vector(IMAGE_DATA_WIDTH-1 downto 0);
--		G2: std_logic_vector(IMAGE_DATA_WIDTH-1 downto 0);
--		B: std_logic_vector(IMAGE_DATA_WIDTH-1 downto 0);
--	end record;
--type BayerArray is array (0 to IMAGE_WIDTH_MAX-1) of BayerPattern;
--signal PixelBayer:BayerArray;


type BayerArray is array (0 to IMAGE_WIDTH_MAX-1) of std_logic_vector(IMAGE_DATA_WIDTH-1 downto 0);
signal BayerR: BayerArray;
signal BayerG1: BayerArray;
signal BayerG2: BayerArray;
signal BayerB: BayerArray;



signal Line_done:std_logic;

begin





fill:
block
	type STATE_TYPE is (
						IDLE_state,
						START_WORK_state,
						PROCESS_FRAME_state,
						STOP_WORK_state
						);
	signal state:STATE_TYPE;
	
	
	signal flag: std_logic;
	signal bayerArrayIndex: integer range 0 to IMAGE_WIDTH_MAX-1;
	signal bayerInternalIndex: integer range 0 to 3;
	signal counterX: std_logic_vector(10 downto 0);
	signal counterY: std_logic;
	
	
begin
	
	
	bayerArrayIndex<=conv_integer(counterX(10 downto 1));
	bayerInternalIndex<=conv_integer(counterY & counterX(0));
	
	
	process(clk)
	begin 
		if falling_edge(clk) then
			case state is
			when IDLE_state=>
				counterX<=(others=>'0');
				counterY<='0';
				flag<='0';
				Line_done<='0';
				RDV<='0';
				
				
				if (CALL='0') then
					state<=IDLE_state;
				else
					state<=START_WORK_state;
				end if;
				
			when START_WORK_state=>
				if (FRAME_VALID='1') then
					state<=PROCESS_FRAME_state;
				else
					state<=START_WORK_state;
				end if;
			
			
			when PROCESS_FRAME_state =>
				if (FRAME_VALID='1') then
					if (LINE_VALID='1') then
						Line_done<='0';
						flag<='1';
						
						
--						case bayerInternalIndex is
--						when 0 => PixelBayer(bayerArrayIndex).G1<=CAMERA_DATA;
--						when 1 => PixelBayer(bayerArrayIndex).R<=CAMERA_DATA;
--						when 2 => PixelBayer(bayerArrayIndex).B<=CAMERA_DATA;
--						when 3 => PixelBayer(bayerArrayIndex).G2<=CAMERA_DATA;
--						end case;
						
						case bayerInternalIndex is
						when 0 => BayerG1(bayerArrayIndex)<=CAMERA_DATA;
						when 1 => BayerR(bayerArrayIndex)<=CAMERA_DATA;
						when 2 => BayerB(bayerArrayIndex)<=CAMERA_DATA;
						when 3 => BayerG2(bayerArrayIndex)<=CAMERA_DATA;
						end case;
						
						counterX<=counterX+'1';
						state<=PROCESS_FRAME_state;
					else
						counterX<=(others=>'0');
						if (flag='1') then
							if (counterY='0') then
								counterY<='1';
							else
								counterY<='0';
								Line_done<='1';
							end if;
							flag<='0';
						end if;
					end if;
				else
					Line_done<='0';
					state<=STOP_WORK_state;
				end if;
					
	
	
	
			when STOP_WORK_state=>
				
				if (CALL='1') then
					RDV<='1';
					state<=STOP_WORK_state;
				else
					RDV<='0';
					state<=IDLE_state;
				end if;
	
	
			when others=>
				state<=IDLE_state;
			end case;
		end if;
	end process;
end block;




send:
block
	type SEND_STATE_TYPE is (
						IDLE_state,
						SENDING_state);
	signal send_state:SEND_STATE_TYPE;
	
	constant COUNTER_MAX:natural:=IMAGE_WIDTH_MAX-1;
	signal counter:integer range 0 to COUNTER_MAX;
	
	signal clock_out:std_logic;
	
begin



process(clk)
variable calcG:std_logic_vector(IMAGE_DATA_WIDTH downto 0);
variable calcG1:std_logic_vector(IMAGE_DATA_WIDTH downto 0);
variable calcG2:std_logic_vector(IMAGE_DATA_WIDTH downto 0);
begin
	PixelClk<=clk and clock_out;
	if falling_edge(clk) then
		case send_state is
		when IDLE_state =>
			counter<=0;
			clock_out<='0';
			if Line_done='1' then
				send_state<=SENDING_state;
			else
				send_state<=IDLE_state;
			end if;
			
		when SENDING_state =>
		
		
--			PixelR<=PixelBayer(counter).R;
--			PixelB<=PixelBayer(counter).B;
--			calcG1:='0' & PixelBayer(counter).G1;
--			calcG2:='0' & PixelBayer(counter).G2;
--			calcG:= calcG1 + calcG2;
--			PixelG<=calcG(IMAGE_DATA_WIDTH downto 1);
			
			PixelR<=BayerR(counter);
			PixelB<=BayerB(counter);
			calcG1:='0' & BayerG1(counter);
			calcG2:='0' & BayerG2(counter);
			calcG:= calcG1 + calcG2;
			PixelG<=calcG(IMAGE_DATA_WIDTH downto 1);
			
			clock_out<='1';
			if (counter<COUNTER_MAX) then
				counter<=counter+1;
				send_state<=SENDING_state;
			else
				counter<=0;
				send_state<=IDLE_state;
			end if;
			
		end case;
	end if;
end process;





end block;


end rtl;
