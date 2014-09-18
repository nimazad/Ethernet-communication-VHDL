----------------------------------------------------------------------------------
-- Company:	 Mälardalen University - Robotic project
-- Engineer: Mostafa - Nima
-- 
-- Create Date:    	17:27:55 04/13/2010 
-- Module Name:    	PHY_I2C - Behavioral 
-- Project Name: 		Ethernet Comunication
-- Target Devices: 	Two Camera board
-- Tool versions: 	ISE 10.1
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


--====================================================================================
--====== Generate Clock based on devider value and input clock             ===========
--====================================================================================
entity ClockMaker IS
PORT(
        In_CLK								: In 	STD_LOGIC;								-- Input clock
        In_Divider						: in 	STD_LOGIC_Vector(35 downto 0);	-- Divider value
        Out_CLK							: Out STD_LOGIC								-- output clock 
    );
END ClockMaker;


architecture Behavioral of ClockMaker IS

      signal cntTmp      			: STD_LOGIC_Vector(35 downto 0):= (Others=>'0');
		SIGNAL generated_Clock    	: STD_LOGIC:='1';

BEGIN
		Out_CLK <= generated_Clock;
		PROCESS (In_CLK)
		BEGIN
            IF rising_edge(In_CLK) THEN
                IF cntTmp = In_Divider -1 THEN
						   cntTmp <= (OTHERS => '0');
								  generated_Clock <= NOT generated_Clock; 									 
                ELSE
							cntTmp <= cntTmp + 1;
					 END IF;           
				END IF;		
		END PROCESS;
END Behavioral;