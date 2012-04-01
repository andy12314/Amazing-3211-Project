---------------------------------------------------------------------------
-- adder_16b.vhd - 16-bit Adder Implementation
--
--
-- Copyright (C) 2006 by Lih Wen Koh (lwkoh@cse.unsw.edu.au)
-- All Rights Reserved. 
--
-- The single-cycle processor core is provided AS IS, with no warranty of 
-- any kind, express or implied. The user of the program accepts full 
-- responsibility for the application of the program and the use of any 
-- results. This work may be downloaded, compiled, executed, copied, and 
-- modified solely for nonprofit, educational, noncommercial research, and 
-- noncommercial scholarship purposes provided that this notice in its 
-- entirety accompanies all copies. Copies of the modified software can be 
-- delivered to persons who use it solely for nonprofit, educational, 
-- noncommercial research, and noncommercial scholarship purposes provided 
-- that this notice in its entirety accompanies all copies.
--
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity adder_16b is
    port ( ALUcontrol : in std_logic; --just one bit for now to control add/sub
           src_a     : in  std_logic_vector(15 downto 0);
           src_b     : in  std_logic_vector(15 downto 0);
           sum       : out std_logic_vector(15 downto 0);
           carry_out : out std_logic;
           zero      : out std_logic ); --TRUE is subtraction led to 0
end adder_16b;


architecture behavioural of adder_16b is

signal sig_result : std_logic_vector(16 downto 0);

begin
    with (ALUcontrol) SELECT
    sig_result <= ('0' & src_a) + ('0' & src_b) WHEN '0',
                  ('0' & src_a) - ('0' & src_b) WHEN OTHERS;
    
    sum        <= sig_result(15 downto 0);
    carry_out  <= sig_result(16);
    zero       <=  NOT( sig_result(15) OR sig_result(14) OR sig_result(13) OR 
                    sig_result(12) OR sig_result(11) OR sig_result(10) OR
                    sig_result(09) OR sig_result(08) OR sig_result(07) OR
                    sig_result(06) OR sig_result(05) OR sig_result(04) OR
                    sig_result(03) OR sig_result(02) OR sig_result(01) OR
                    sig_result(0));
    
end behavioural;