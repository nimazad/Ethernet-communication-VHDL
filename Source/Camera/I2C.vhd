-- Quartus II VHDL Template
-- Basic Shift Register

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;


entity I2C is
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
		RDV		: out std_logic;
		Error		: out std_logic;
		
		SDA			: inout std_logic;
		SCL			: inout std_logic
		
		--SDA			: out std_logic;
		--SCL			: out std_logic;
		
		--SDAi		: in std_logic;
		--SDAo		: buffer std_logic;
		--SCLi		: in std_logic;
		--SCLo		: buffer std_logic
	);

end entity;

architecture rtl of I2C is
type STATE_TYPE is (	RESET_state,IDLE_state,ERROR_state,DONE_state,
						SEND_state,
						SEND1_state,
						SEND2_state,
						SEND3_state,
						SEND4_state,
						SEND5_state,
						
						RECEIVE_state,
						RECEIVE1_state,
						RECEIVE2_state,
						RECEIVE3_state,
						RECEIVE4_state,
						RECEIVE5_state,
						RECEIVE6_state,
						RECEIVE7_state,
						
						SEND_START_state,
						SEND_START1_state,
						SEND_START2_state,
						SEND_START3_state,
						SEND_START4_state,
						
						SEND_STOP_state,
						SEND_STOP1_state,
						SEND_STOP2_state,
						SEND_STOP3_state,
						SEND_STOP4_state,
							
						SEND_RECIEVE_BIT_state,
						SEND_RECIEVE_BIT1_state,
						SEND_RECIEVE_BIT2_state,
						SEND_RECIEVE_BIT3_state); 

signal state: STATE_TYPE:=RESET_state;
signal return_state: STATE_TYPE;

signal message:std_logic_vector(8 downto 0);
signal bits: integer range 0 to 8;

constant SLAVE_ACK:std_logic :='1';
constant MASTER_ACK:std_logic :='0';
constant MASTER_NACK:std_logic :='1';

constant COUNTER_CLK	: natural  :=	input_frequency/output_frequency;

constant COUNTER_START1	: natural  :=	COUNTER_CLK/4;
constant COUNTER_START2	: natural  :=	COUNTER_CLK/4;
constant COUNTER_START3	: natural  :=	COUNTER_CLK/4;
constant COUNTER_START4	: natural  :=	COUNTER_CLK/4;

constant COUNTER_STOP1	: natural  :=	COUNTER_CLK/4;
constant COUNTER_STOP2	: natural  :=	COUNTER_CLK/4;
constant COUNTER_STOP3	: natural  :=	COUNTER_CLK/4;
constant COUNTER_STOP4	: natural  :=	COUNTER_CLK/4;

constant COUNTER_SEND_RECIEVE1	: natural  :=	COUNTER_CLK/4;
constant COUNTER_SEND_RECIEVE2	: natural  :=	COUNTER_CLK/2;
constant COUNTER_SEND_RECIEVE3	: natural  :=	COUNTER_CLK/4;

signal counter: integer range 0 to COUNTER_CLK/2;

signal SDAi:std_logic;
signal SDAo:std_logic;
signal SCLi:std_logic;
signal SCLo:std_logic;



begin


--SDA<=SDAi and SDAo;
--SCL<=SCLi and SCLo;

SDA<= '0' when SDAo='0' else 'Z';
SCL<= '0' when SCLo='0' else 'Z';
SDAi<= '0' when SDA='0' else '1';
SCLi<= '0' when SCL='0' else '1';

process (clk)
begin 
	if (rising_edge(clk)) then
		case state is
		when RESET_state =>
			if (nReset='0') then
				state<=RESET_state;
			else
				state<=IDLE_state;	
			end if;
			SDAo<='1';
			SCLo<='0';
			RDV<='0';
			Error<='0';
			DATA_R<= (others=>'0');
			
		when IDLE_state =>
			SDAo<='1';
			SCLo<='0';
			RDV<='0';
			
			if (nReset='0') then
				state<=RESET_state;
			elsif (CALL='1') then						
				state<=SEND_START_state;
				if (Read_nWrite='1') then
					return_state<=RECEIVE_state;
				else
					return_state<=SEND_state;
				end if;
			else
				state<=IDLE_state;
			end if;
	
	
		
		when ERROR_state =>
			SDAo<='1';
			SCLo<='0';
			if (nReset='0') then
				state<=RESET_state;
			elsif (CALL='1') then
				RDV<='1';
				Error<='1';			
				state<=ERROR_state;
			else
				RDV<='0';
				state<=IDLE_state;
			end if;				
			
			
		when DONE_state =>
			SDAo<='1';
			SCLo<='0';
			if (nReset='0') then
				state<=RESET_state;
			elsif (CALL='1') then
				RDV<='1';
				Error<='0';			
				state<=DONE_state;
			else
				RDV<='0';
				state<=IDLE_state;
			end if;	
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		when SEND_state =>
			SDAo<=SDAo;
			SCLo<=SCLo;
			if (nReset='0') then
				state<=RESET_state;
			else
				state<=SEND1_state;
			end if;
			
			
		when SEND1_state =>
			SDAo<=SDAo;
			SCLo<=SCLo;
			bits<=8;
			message<=X"BA" & SLAVE_ACK;
			if (nReset='0') then
				state<=RESET_state;
			else
				state<=SEND_RECIEVE_BIT_state;
				return_state<=SEND2_state;
			end if;
			
		when SEND2_state =>
			SDAo<=SDAo;
			SCLo<=SCLo;
			
			
			if (nReset='0') then
				state<=SEND_STOP_state;
				return_state<=RESET_state;
			elsif (message(0)='1') then
				state<=SEND_STOP_state;
				return_state<=ERROR_state;
			else
				bits<=8;
				message<=ADDRESS & SLAVE_ACK;

				state<=SEND_RECIEVE_BIT_state;
				return_state<=SEND3_state;
			end if;
		
		when SEND3_state =>
			SDAo<=SDAo;
			SCLo<=SCLo;
			if (nReset='0') then
				state<=SEND_STOP_state;
				return_state<=RESET_state;
			elsif (message(0)='1') then
				state<=SEND_STOP_state;
				return_state<=ERROR_state;
			else
				bits<=8;
				message<=DATA_W(15 downto 8) & SLAVE_ACK;
			
				state<=SEND_RECIEVE_BIT_state;
				return_state<=SEND4_state;
			end if;
		when SEND4_state =>
			SDAo<=SDAo;
			SCLo<=SCLo;
			if (nReset='0') then
				state<=SEND_STOP_state;
				return_state<=RESET_state;
			elsif (message(0)='1') then
				state<=SEND_STOP_state;
				return_state<=ERROR_state;
			else
				bits<=8;
				DATA_R(15 downto 8)<=message(8 downto 1);
				message<=DATA_W(7 downto 0) & SLAVE_ACK;

				state<=SEND_RECIEVE_BIT_state;
				return_state<=SEND5_state;
			end if;
			
		when SEND5_state =>
			SDAo<=SDAo;
			SCLo<=SCLo;
			DATA_R(7 downto 0)<=message(8 downto 1);
			
			state<=SEND_STOP_state;
			if (nReset='0') then
				return_state<=RESET_state;
			elsif (message(0)='1') then	
				return_state<=ERROR_state;
			else	
				return_state<=DONE_state;
			end if;
			
		
		
	
	
	
	
	
	
		when RECEIVE_state =>
			SDAo<=SDAo;
			SCLo<=SCLo;
			if (nReset='0') then
				state<=RESET_state;
			else
				state<=RECEIVE1_state;
			end if;
	
		when RECEIVE1_state =>
			SDAo<=SDAo;
			SCLo<=SCLo;
			bits<=8;
			message<=X"BA" & SLAVE_ACK;
			
			if (nReset='0') then
				state<=RESET_state;
			else
				state<=SEND_RECIEVE_BIT_state;
				return_state<=RECEIVE2_state;
			end if;
			
			
		when RECEIVE2_state =>
			SDAo<=SDAo;
			SCLo<=SCLo;
			
			if (nReset='0') then
				state<=SEND_STOP_state;
				return_state<=RESET_state;
			elsif (message(0)='1') then
				state<=SEND_STOP_state;
				return_state<=ERROR_state;
			else
				bits<=8;
				message<=ADDRESS & SLAVE_ACK;

				state<=SEND_RECIEVE_BIT_state;
				return_state<=RECEIVE3_state;
			end if;
		
		when RECEIVE3_state =>
			SDAo<=SDAo;
			SCLo<=SCLo;
			if (nReset='0') then
				state<=SEND_STOP_state;
				return_state<=RESET_state;
			elsif (message(0)='1') then
				state<=SEND_STOP_state;
				return_state<=ERROR_state;
			else
				state<=SEND_START_state;
				return_state<=RECEIVE4_state;
			end if;
		
		when RECEIVE4_state =>
			SDAo<=SDAo;
			SCLo<=SCLo;
			bits<=8;
			message<=X"BB" & SLAVE_ACK;
			if (nReset='0') then
				state<=SEND_STOP_state;
				return_state<=RESET_state;
			else
				state<=SEND_RECIEVE_BIT_state;
				return_state<=RECEIVE5_state;
			end if;
		
		when RECEIVE5_state =>
			SDAo<=SDAo;
			SCLo<=SCLo;
			if (nReset='0') then
				state<=SEND_STOP_state;
				return_state<=RESET_state;
			elsif (message(0)='1') then
				state<=SEND_STOP1_state;
				return_state<=ERROR_state;
			else
				bits<=8;
				message<="11111111" & MASTER_ACK;
				state<=SEND_RECIEVE_BIT_state;
				return_state<=RECEIVE6_state;
			end if;
				
		when RECEIVE6_state =>
			SDAo<=SDAo;
			SCLo<=SCLo;
			DATA_R(15 downto 8)<=message(8 downto 1);
					
			bits<=8;
			message<="11111111" & MASTER_NACK;
			if (nReset='0') then
				state<=SEND_STOP_state;
				return_state<=RESET_state;
			else
				state<=SEND_RECIEVE_BIT_state;
				return_state<=RECEIVE7_state;
			end if;
				
		when RECEIVE7_state =>
			SDAo<=SDAo;
			SCLo<=SCLo;
			DATA_R(7 downto 0)<=message(8 downto 1);
		
			state<=SEND_STOP_state;
			if (nReset='0') then
				return_state<=RESET_state;
			else
				return_state<=DONE_state;
			end if;
		
		
		
		
		
		
		
		
		
		
		when SEND_RECIEVE_BIT_state =>
			SDAo<=SDAo;
			SCLo<=SCLo;
			counter<=COUNTER_SEND_RECIEVE1;
			state<=SEND_RECIEVE_BIT1_state;
			
			
		when SEND_RECIEVE_BIT1_state =>
			SDAo<=message(8);
			SCLo<='0';
			if (counter=0) then
				counter<=COUNTER_SEND_RECIEVE2;
				state<=SEND_RECIEVE_BIT2_state;
			else
				counter<=counter-1;
			end if;
			
		when SEND_RECIEVE_BIT2_state =>
			SDAo<=SDAo;
			SCLo<='1';
			if (counter=0) then
				if (SCLi='1') then
					message<=message(7 downto 0) & SDAi;
					counter<=COUNTER_SEND_RECIEVE3;
					state<=SEND_RECIEVE_BIT3_state;
				end if;
			else
				counter<=counter-1;
			end if;
		when SEND_RECIEVE_BIT3_state =>
			SDAo<=SDAo;
			SCLo<='0';
			if (SCLi='0') then
				if (counter=0) then
					if (bits>0) then
						counter<=COUNTER_SEND_RECIEVE1;
						bits<=bits-1;
						state<=SEND_RECIEVE_BIT1_state;
					else
						state<=return_state;
					end if;
				else
					counter<=counter-1;
				end if;
			end if;

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
		when SEND_START_state =>
			SDAo<='1';
			SCLo<='0';
			counter<=COUNTER_START1;
			state<=SEND_START1_state;
	
		when SEND_START1_state =>
			SDAo<='1';
			SCLo<='0';
			
			if (counter=0) then
				counter<=COUNTER_START2;
				state<=SEND_START2_state;
			else
				counter<=counter-1;
			end if;

		when SEND_START2_state =>
			SDAo<='1';
			SCLo<='1';
			
			if (counter=0) then
				counter<=COUNTER_START3;
				state<=SEND_START3_state;
			else
				counter<=counter-1;
			end if;



		when SEND_START3_state =>
			SDAo<='0';
			SCLo<='1';
			
			if (counter=0) then
				counter<=COUNTER_START4;
				state<=SEND_START4_state;
			else
				counter<=counter-1;
			end if;

		when SEND_START4_state =>
			SDAo<='0';
			SCLo<='0';
			
			if (counter=0) then
				state<=return_state;
			else
				counter<=counter-1;
			end if;

		
		
		
		when SEND_STOP_state =>
			SDAo<='1';
			SCLo<='0';
			counter<=COUNTER_STOP1;
			state<=SEND_STOP1_state;
			
		when SEND_STOP1_state =>
			SDAo<='0';
			SCLo<='0';
			
			if (counter=0) then
				counter<=COUNTER_STOP2;
				state<=SEND_STOP2_state;
			else
				counter<=counter-1;
			end if;
		
		when SEND_STOP2_state =>
			SDAo<='0';
			SCLo<='1';
			if (SCLi='1') then
				if (counter=0) then
					counter<=COUNTER_STOP3;
					state<=SEND_STOP3_state;
				else
					counter<=counter-1;
				end if;
			end if;
			
		when SEND_STOP3_state =>
			SDAo<='1';
			SCLo<='1';
			
			if (counter=0) then
				counter<=COUNTER_STOP4;
				state<=SEND_STOP4_state;
			else
				counter<=counter-1;
			end if;
		
		when SEND_STOP4_state =>
			SDAo<='1';
			SCLo<='0';
			
			if (counter=0) then
				state<=return_state;
			else
				counter<=counter-1;
			end if;
		
		
		
			
			
		when others =>
			state<=RESET_state;
			SDAo<='1';
			SCLo<='0';
			
			
			
		end case;

	end if;
end process;
end rtl;
