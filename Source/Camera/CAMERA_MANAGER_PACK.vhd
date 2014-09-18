library ieee;
use ieee.std_logic_1164.all;     
use ieee.std_logic_arith.all;


package CAMERA_MANAGER_PACK is


constant COMMAND_start_test_pattern:	STD_LOGIC_VECTOR(7 downto 0):=X"01";
constant COMMAND_stop_test_pattern:		STD_LOGIC_VECTOR(7 downto 0):=X"02";
constant COMMAND_send_right_picture:	STD_LOGIC_VECTOR(7 downto 0):=X"03";
constant COMMAND_send_left_picture:		STD_LOGIC_VECTOR(7 downto 0):=X"04";
constant COMMAND_send_both_picture:		STD_LOGIC_VECTOR(7 downto 0):=X"05";
constant COMMAND_set_camera_speed_1:	STD_LOGIC_VECTOR(7 downto 0):=X"06";
constant COMMAND_set_camera_speed_2:	STD_LOGIC_VECTOR(7 downto 0):=X"07";
constant COMMAND_set_camera_speed_4:	STD_LOGIC_VECTOR(7 downto 0):=X"08";
constant COMMAND_set_camera_speed_8:	STD_LOGIC_VECTOR(7 downto 0):=X"09";
constant COMMAND_set_camera_speed_16:	STD_LOGIC_VECTOR(7 downto 0):=X"0A";
constant COMMAND_set_camera_speed_32:	STD_LOGIC_VECTOR(7 downto 0):=X"0B";
constant COMMAND_set_camera_speed_64:	STD_LOGIC_VECTOR(7 downto 0):=X"0C";
constant COMMAND_set_camera_speed_128:	STD_LOGIC_VECTOR(7 downto 0):=X"0D";


constant CAMERA_REG_Chip_Version:				std_logic_vector(7 downto 0) := X"00";
constant CAMERA_REG_Row_Start:					std_logic_vector(7 downto 0) := X"01";
constant CAMERA_REG_Column_Start:				std_logic_vector(7 downto 0) := X"02";
constant CAMERA_REG_Row_Size:					std_logic_vector(7 downto 0) := X"03";
constant CAMERA_REG_Column_Size:				std_logic_vector(7 downto 0) := X"04";
constant CAMERA_REG_Horizontal_Blank:			std_logic_vector(7 downto 0) := X"05";
constant CAMERA_REG_Vertical_Blank:				std_logic_vector(7 downto 0) := X"06";
constant CAMERA_REG_Output_Control:				std_logic_vector(7 downto 0) := X"07";
constant CAMERA_REG_Shutter_Width_Upper:		std_logic_vector(7 downto 0) := X"08";
constant CAMERA_REG_Shutter_Width_Lower:		std_logic_vector(7 downto 0) := X"09";
constant CAMERA_REG_Pixel_Clock_Control:		std_logic_vector(7 downto 0) := X"0A";
constant CAMERA_REG_Restart:					std_logic_vector(7 downto 0) := X"0B";
constant CAMERA_REG_Shutter_Delay:				std_logic_vector(7 downto 0) := X"0C";
constant CAMERA_REG_Reset:						std_logic_vector(7 downto 0) := X"0D";
constant CAMERA_REG_PLL_Control:				std_logic_vector(7 downto 0) := X"10";
constant CAMERA_REG_PLL_Config_1:				std_logic_vector(7 downto 0) := X"11";
constant CAMERA_REG_PLL_Config_2:				std_logic_vector(7 downto 0) := X"12";
constant CAMERA_REG_Read_Mode_1:				std_logic_vector(7 downto 0) := X"1E";
constant CAMERA_REG_Read_Mode_2:				std_logic_vector(7 downto 0) := X"20";
constant CAMERA_REG_Row_Address_Mode:			std_logic_vector(7 downto 0) := X"22";
constant CAMERA_REG_Column_Address_Mode:		std_logic_vector(7 downto 0) := X"23";
constant CAMERA_REG_Green1_Gain:				std_logic_vector(7 downto 0) := X"2B";
constant CAMERA_REG_Blue_Gain:					std_logic_vector(7 downto 0) := X"2C";
constant CAMERA_REG_Red_Gain:					std_logic_vector(7 downto 0) := X"2D";
constant CAMERA_REG_Green2_Gain:				std_logic_vector(7 downto 0) := X"2E";
constant CAMERA_REG_Global_Gain:				std_logic_vector(7 downto 0) := X"35";
constant CAMERA_REG_Row_Black_Target:			std_logic_vector(7 downto 0) := X"49";
constant CAMERA_REG_Row_Black_Default_Offset:	std_logic_vector(7 downto 0) := X"4B";
constant CAMERA_REG_BLC_Sample_Size:			std_logic_vector(7 downto 0) := X"5B";
constant CAMERA_REG_BLC_Tune_1:					std_logic_vector(7 downto 0) := X"5C";
constant CAMERA_REG_BLC_Delta_Thresholds:		std_logic_vector(7 downto 0) := X"5D";
constant CAMERA_REG_BLC_Tune_2:					std_logic_vector(7 downto 0) := X"5E";
constant CAMERA_REG_BLC_Target_Thresholds:		std_logic_vector(7 downto 0) := X"5F";
constant CAMERA_REG_Green1_Offset:				std_logic_vector(7 downto 0) := X"60";
constant CAMERA_REG_Green2_Offset:				std_logic_vector(7 downto 0) := X"61";
constant CAMERA_REG_Black_Level_Calibration:	std_logic_vector(7 downto 0) := X"62";
constant CAMERA_REG_Red_Offset:					std_logic_vector(7 downto 0) := X"63";
constant CAMERA_REG_Blue_Offset:				std_logic_vector(7 downto 0) := X"64";
constant CAMERA_REG_Test_Pattern_Control:		std_logic_vector(7 downto 0) := X"A0";
constant CAMERA_REG_Test_Pattern_Green:			std_logic_vector(7 downto 0) := X"A1";
constant CAMERA_REG_Test_Pattern_Red:			std_logic_vector(7 downto 0) := X"A2";
constant CAMERA_REG_Test_Pattern_Blue:			std_logic_vector(7 downto 0) := X"A3";
constant CAMERA_REG_Test_Pattern_Bar_Width:		std_logic_vector(7 downto 0) := X"A4";
constant CAMERA_REG_Chip_Version_Alt:			std_logic_vector(7 downto 0) := X"FF";

type I2C_STATEMENTS is
	record
		I2C_addr:  std_logic_vector(7 downto 0);
		I2C_value: std_logic_vector(15 downto 0);
	end record;

type STATEMENT_ARRAY is array(natural range <>) of I2C_STATEMENTS;





constant INIT_STATEMENT:STATEMENT_ARRAY:=(
--0=>(CAMERA_REG_Pixel_Clock_Control,X"0000"),--div = 1
--0=>(CAMERA_REG_Pixel_Clock_Control,X"0001"),--div = 2
--0=>(CAMERA_REG_Pixel_Clock_Control,X"0002"),--div = 4
--0=>(CAMERA_REG_Pixel_Clock_Control,X"0004"),--div = 8
--0=>(CAMERA_REG_Pixel_Clock_Control,X"0008"),--div = 16
--0=>(CAMERA_REG_Pixel_Clock_Control,X"0010"),--div = 32
--0=>(CAMERA_REG_Pixel_Clock_Control,X"0020"),--div = 64
0=>(CAMERA_REG_Pixel_Clock_Control,X"0040"),--div = 128

1=>(CAMERA_REG_Read_Mode_1,X"4106"),--enable snapshot

--640x480 resolution
2=>(CAMERA_REG_Column_Size,			CONV_STD_LOGIC_VECTOR(639,16)),
3=>(CAMERA_REG_Row_Size,				CONV_STD_LOGIC_VECTOR(479,16)),
4=>(CAMERA_REG_Shutter_Width_Lower,	CONV_STD_LOGIC_VECTOR(400,16)),
5=>(CAMERA_REG_Row_Address_Mode,		CONV_STD_LOGIC_VECTOR(0,16)),
6=>(CAMERA_REG_Column_Address_Mode,	CONV_STD_LOGIC_VECTOR(0,16))
);




constant START_TEST_STATEMENT:STATEMENT_ARRAY:=(
0=>(CAMERA_REG_Test_Pattern_Control,B"000000000_0000_00_1")--color field
--0=>(CAMERA_REG_Test_Pattern_Control,B"000000000_0001_00_1")--horizontal gradient
--0=>(CAMERA_REG_Test_Pattern_Control,B"000000000_0010_00_1")--vertical gradient
--0=>(CAMERA_REG_Test_Pattern_Control,B"000000000_0011_00_1")--diagonal
--0=>(CAMERA_REG_Test_Pattern_Control,B"000000000_0100_00_1")--classic
--0=>(CAMERA_REG_Test_Pattern_Control,B"000000000_0101_00_1")--marching ones
--0=>(CAMERA_REG_Test_Pattern_Control,B"000000000_0110_00_1")--monochrome horizontal bars
--0=>(CAMERA_REG_Test_Pattern_Control,B"000000000_0111_00_1")--monochrome vertical bars
--0=>(CAMERA_REG_Test_Pattern_Control,B"000000000_1000_00_1")--vertical color bars
);

constant STOP_TEST_STATEMENT:STATEMENT_ARRAY:=(
0=>(CAMERA_REG_Test_Pattern_Control,X"0000")
);


constant CAMERA_SPEED_1_STATEMENT:STATEMENT_ARRAY:=(0=>(CAMERA_REG_Pixel_Clock_Control,X"0000"));
constant CAMERA_SPEED_2_STATEMENT:STATEMENT_ARRAY:=(0=>(CAMERA_REG_Pixel_Clock_Control,X"0001"));
constant CAMERA_SPEED_4_STATEMENT:STATEMENT_ARRAY:=(0=>(CAMERA_REG_Pixel_Clock_Control,X"0002"));
constant CAMERA_SPEED_8_STATEMENT:STATEMENT_ARRAY:=(0=>(CAMERA_REG_Pixel_Clock_Control,X"0004"));
constant CAMERA_SPEED_16_STATEMENT:STATEMENT_ARRAY:=(0=>(CAMERA_REG_Pixel_Clock_Control,X"0008"));
constant CAMERA_SPEED_32_STATEMENT:STATEMENT_ARRAY:=(0=>(CAMERA_REG_Pixel_Clock_Control,X"0010"));
constant CAMERA_SPEED_64_STATEMENT:STATEMENT_ARRAY:=(0=>(CAMERA_REG_Pixel_Clock_Control,X"0020"));
constant CAMERA_SPEED_128_STATEMENT:STATEMENT_ARRAY:=(0=>(CAMERA_REG_Pixel_Clock_Control,X"0040"));



constant CAMERA_RESOLUTION_640x480_STATEMENT:STATEMENT_ARRAY:=(
0=>(CAMERA_REG_Column_Size,			CONV_STD_LOGIC_VECTOR(639,16)),
1=>(CAMERA_REG_Row_Size,				CONV_STD_LOGIC_VECTOR(479,16)),
2=>(CAMERA_REG_Shutter_Width_Lower,	CONV_STD_LOGIC_VECTOR(400,16)),
3=>(CAMERA_REG_Row_Address_Mode,		CONV_STD_LOGIC_VECTOR(0,16)),
4=>(CAMERA_REG_Column_Address_Mode,	CONV_STD_LOGIC_VECTOR(0,16))
);

constant CAMERA_RESOLUTION_800x600_STATEMENT:STATEMENT_ARRAY:=(
0=>(CAMERA_REG_Column_Size,			CONV_STD_LOGIC_VECTOR(799,16)),
1=>(CAMERA_REG_Row_Size,				CONV_STD_LOGIC_VECTOR(599,16)),
2=>(CAMERA_REG_Shutter_Width_Lower,	CONV_STD_LOGIC_VECTOR(500,16)),
3=>(CAMERA_REG_Row_Address_Mode,		CONV_STD_LOGIC_VECTOR(0,16)),
4=>(CAMERA_REG_Column_Address_Mode,	CONV_STD_LOGIC_VECTOR(0,16))
);


constant CAMERA_RESOLUTION_1024x768_STATEMENT:STATEMENT_ARRAY:=(
0=>(CAMERA_REG_Column_Size,			CONV_STD_LOGIC_VECTOR(1023,16)),
1=>(CAMERA_REG_Row_Size,				CONV_STD_LOGIC_VECTOR(767,16)),
2=>(CAMERA_REG_Shutter_Width_Lower,	CONV_STD_LOGIC_VECTOR(700,16)),
3=>(CAMERA_REG_Row_Address_Mode,		CONV_STD_LOGIC_VECTOR(0,16)),
4=>(CAMERA_REG_Column_Address_Mode,	CONV_STD_LOGIC_VECTOR(0,16))
);











type int_arr is array (natural range <>) of integer;
function max(var: in int_arr) return integer;
constant counter_max:natural:=max((
								INIT_STATEMENT'LENGTH,
								START_TEST_STATEMENT'LENGTH,
								STOP_TEST_STATEMENT'LENGTH,
								CAMERA_SPEED_1_STATEMENT'LENGTH,
								CAMERA_SPEED_2_STATEMENT'LENGTH,
								CAMERA_SPEED_4_STATEMENT'LENGTH,
								CAMERA_SPEED_8_STATEMENT'LENGTH,
								CAMERA_SPEED_16_STATEMENT'LENGTH,
								CAMERA_SPEED_32_STATEMENT'LENGTH,
								CAMERA_SPEED_64_STATEMENT'LENGTH,
								CAMERA_SPEED_128_STATEMENT'LENGTH,
								CAMERA_RESOLUTION_640x480_STATEMENT'LENGTH,
								CAMERA_RESOLUTION_800x600_STATEMENT'LENGTH,
								CAMERA_RESOLUTION_1024x768_STATEMENT'LENGTH
								))-1;

end;
 
package body CAMERA_MANAGER_PACK is
	function max(var: in int_arr) return integer is
	variable m:integer:=0;
	begin

	for i in 0 to var'LENGTH-1 loop
		if (var(i)>m) then
			m:=var(i);
		end if;
	end loop;
	
	return m;
	end;

	
	
end;