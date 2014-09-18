-- Quartus II VHDL Template
-- Basic Shift Register

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;


entity dual_camera_I2C_controller is
	generic
	(
		input_frequency	: positive  :=	125_000_000;
		output_frequency: positive  :=	400_000;
		DEBUG: bit:='0'
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

end entity;

architecture rtl of dual_camera_I2C_controller is
	
	
	component I2C
	generic
	(
		input_frequency	: positive  :=	125_000_000;
		output_frequency: positive  :=	400_000
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
		
		SDA			: inout std_logic;
		SCL			: inout std_logic
	);
	end component;
	
	
	
	type I2C_STATES is (IDLE_state,
					 SENDING_L1_state,
					 SENDING_L2_state,
					 
					 SENDING_R1_state,
					 SENDING_R2_state,
					 
					 RECEIVING_L1_state,
					 RECEIVING_L2_state,
					 RECEIVING_R1_state,
					 RECEIVING_R2_state,
					 
					 WAIT_FOR_RDV_LOW_L_state,
					 WAIT_FOR_RDV_LOW_R_state,
					 
					 DONE_state
					);
	signal i2c_state: I2C_STATES;


	signal I2C_L_CALL		: std_logic;
	signal I2C_L_address	: std_logic_vector(7 downto 0);
	signal I2C_L_dataW		: std_logic_vector(15 downto 0);
	signal I2C_L_Read_nWrite: std_logic;
	
	signal I2C_L_RDV		: std_logic;
	signal I2C_L_dataR		: std_logic_vector(15 downto 0);
	signal I2C_L_Error		: std_logic;
	
	signal I2C_R_CALL		: std_logic;
	signal I2C_R_address	: std_logic_vector(7 downto 0);
	signal I2C_R_dataW		: std_logic_vector(15 downto 0);
	signal I2C_R_Read_nWrite: std_logic;
	
	signal I2C_R_RDV		: std_logic;
	signal I2C_R_dataR		: std_logic_vector(15 downto 0);
	signal I2C_R_Error		: std_logic;
	
	begin


	process (clk)
	variable IDLE_state_variable: std_logic_vector(1 downto 0);
	begin
		if rising_edge(clk) then
		if (nReset='0' ) then
			i2c_state<=IDLE_state;
			I2C_L_CALL<='0';
			I2C_R_CALL<='0';
			
			RDV<='0';
			error<='0';
		else
			IDLE_state_variable:=current_camera & Read_nWrite;
			case i2c_state is
			when IDLE_state=>
				if (CALL='1') then
					case IDLE_state_variable is
						when "00" => i2c_state<=SENDING_L1_state;
						when "01" => i2c_state<=RECEIVING_L1_state;
						when "10" => i2c_state<=SENDING_R1_state;
						when "11" => i2c_state<=RECEIVING_R1_state;
						when others    => null;
					end case;
				else
					i2c_state<=IDLE_state;
				end if;
				
			
			
			
			
			when SENDING_L1_state =>
				I2C_L_address<=ADDRESS;
				I2C_L_dataW<=DATA_W;
				I2C_L_Read_nWrite<='0';
				i2c_state<=SENDING_L2_state;
				
			when SENDING_L2_state =>
				if (I2C_L_RDV='1') then
					error<=I2C_L_error;
					I2C_L_CALL<='0';
					i2c_state<=WAIT_FOR_RDV_LOW_L_state;
				else
					I2C_L_CALL<='1';		
					i2c_state<=SENDING_L2_state;
				end if;
			
			
			
			when SENDING_R1_state =>
				I2C_R_address<=ADDRESS;
				I2C_R_dataW<=DATA_W;
				I2C_R_Read_nWrite<='0';
				i2c_state<=SENDING_R2_state;
				
			when SENDING_R2_state =>			
				if (I2C_R_RDV='1') then
					error<=I2C_R_error;
					I2C_R_CALL<='0';
					i2c_state<=WAIT_FOR_RDV_LOW_R_state;
				else
					I2C_R_CALL<='1';		
					i2c_state<=SENDING_R2_state;
				end if;
				
				
				
				
				
			
			when RECEIVING_L1_state =>
				I2C_L_address<=ADDRESS;
				I2C_L_Read_nWrite<='1';
				i2c_state<=RECEIVING_L2_state;
			
			when RECEIVING_L2_state =>			
				if (I2C_L_RDV='1') then
					error<=I2C_L_error;
					DATA_R<=I2C_L_dataR;
					I2C_L_CALL<='0';
					i2c_state<=WAIT_FOR_RDV_LOW_L_state;
				else
					I2C_L_CALL<='1';		
					i2c_state<=RECEIVING_L2_state;
				end if;
				
			
			
			
			when RECEIVING_R1_state =>
				I2C_R_address<=ADDRESS;
				I2C_R_Read_nWrite<='1';
				i2c_state<=RECEIVING_R2_state;
			
			when RECEIVING_R2_state =>			
				if (I2C_R_RDV='1') then
					error<=I2C_R_error;
					DATA_R<=I2C_R_dataR;
					I2C_R_CALL<='0';
					i2c_state<=WAIT_FOR_RDV_LOW_R_state;
				else
					I2C_R_CALL<='1';		
					i2c_state<=RECEIVING_R2_state;
				end if;
			
			
			
			
		
			
			
			
			
			
			
			when WAIT_FOR_RDV_LOW_L_state =>			
				if (I2C_L_RDV='0') then
					i2c_state<=DONE_state;
				else
					i2c_state<=WAIT_FOR_RDV_LOW_L_state;
				end if;
				
			when WAIT_FOR_RDV_LOW_R_state =>			
				if (I2C_R_RDV='0') then
					i2c_state<=DONE_state;
				else
					i2c_state<=WAIT_FOR_RDV_LOW_L_state;
				end if;
			
			when DONE_state =>	
				RDV<='1';
				if (CALL='0') then
					i2c_state<=IDLE_state;
					RDV<='0';
				else
					i2c_state<=DONE_state;
				end if;
			
				
				
			when others=>
				i2c_state<=IDLE_state;
				I2C_L_CALL<='0';
				I2C_R_CALL<='0';
				
				RDV<='0';
				error<='0';
			
			end case;
		
	
		end if;
		end if;
	end process;
	








	I2C_L: I2C
	generic map(input_frequency,output_frequency)
	port map (
		clk,
		nReset,
		I2C_L_address,
		I2C_L_dataR,
		I2C_L_dataW,
		I2C_L_Read_nWrite,
		I2C_L_CALL,
		I2C_L_RDV,
		I2C_L_Error,
		SDA_L,SCL_L
	);
	
	I2C_R: I2C
	generic map(input_frequency,output_frequency)
	port map (
		clk,
		nReset,
		I2C_R_address,
		I2C_R_dataR,
		I2C_R_dataW,
		I2C_R_Read_nWrite,
		I2C_R_CALL,
		I2C_R_RDV,
		I2C_R_Error,
		SDA_R,SCL_R
	);

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
--	case DEBUG generate
--	when '1' =>
--		I2C_L: I2C_dummy
--		generic map(input_frequency,output_frequency)
--		port map (
--			clk,
--			nReset,
--			I2C_L_address,
--			I2C_L_dataR,
--			I2C_L_dataW,
--			I2C_L_Read_nWrite,
--			I2C_L_CALL,
--			I2C_L_RDV,
--			I2C_L_Error,
--			SDA_L,SCL_L
--		);
--		
--		I2C_R: I2C_dummy
--		generic map(input_frequency,output_frequency)
--		port map (
--			clk,
--			nReset,
--			I2C_R_address,
--			I2C_R_dataR,
--			I2C_R_dataW,
--			I2C_R_Read_nWrite,
--			I2C_R_CALL,
--			I2C_R_RDV,
--			I2C_R_Error,
--			SDA_R,SCL_R
--		);
--	when others =>
--		I2C_L: I2C
--		generic map(input_frequency,output_frequency)
--		port map (
--			clk,
--			nReset,
--			I2C_L_address,
--			I2C_L_dataR,
--			I2C_L_dataW,
--			I2C_L_Read_nWrite,
--			I2C_L_CALL,
--			I2C_L_RDV,
--			I2C_L_Error,
--			SDA_L,SCL_L
--		);
--		
--		I2C_R: I2C
--		generic map(input_frequency,output_frequency)
--		port map (
--			clk,
--			nReset,
--			I2C_R_address,
--			I2C_R_dataR,
--			I2C_R_dataW,
--			I2C_R_Read_nWrite,
--			I2C_R_CALL,
--			I2C_R_RDV,
--			I2C_R_Error,
--			SDA_R,SCL_R
--		);
--	end generate;	
end;