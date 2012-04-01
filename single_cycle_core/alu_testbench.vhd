-------------------------------------------------------------------------
---- Simulation Tutorial
----
---- Description: Top Level TestBench combining Procedures and File IO
----
---- Author: Lingkan Gong
----
---- Date: 23/02/2011
----
----
-------------------------------------------------------------------------

library IEEE;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity ALUTestBench is
    -- no portmap, no IO
end ALUTestBench;

architecture TBusingMixed of ALUTestBench is

    signal clk           : std_logic:= '0'; -- initial value of clock
    signal rst           : std_logic:= '1'; -- initial value of reset

    signal alucontrol     : std_logic_vector(1 downto 0);
    signal src_a          : std_logic_vector(15 downto 0);
    signal src_b          : std_logic_vector(15 downto 0);
    signal res            : std_logic_vector(15 downto 0);
    signal zero           : std_logic; --TRUE if subtraction led to 0


    signal pass_or_fail  : std_logic;

    component alu is
        port (  alucontrol: in std_logic_vector(1 downto 0); 
                src_a     : in  std_logic_vector(15 downto 0);
                src_b     : in  std_logic_vector(15 downto 0);
                res       : out std_logic_vector(15 downto 0);
                zero      : out std_logic ); --TRUE if subtraction led to 0
    end component;

    --------------------------------------------
    -- procedure to print info on the screen
    --------------------------------------------
    file stdout : text open write_mode is "STD_OUTPUT";
    
    procedure print_info(
        info                       : in string;
        constant expected,actual   : in std_logic_vector(3 downto 0)
    ) is
        variable info_buff : line;
    begin
        write(info_buff,  info);
        
        hwrite(info_buff, expected);
        hwrite(info_buff, actual);
        
        writeline(stdout, info_buff);
    end;

    --------------------------------------------
    -- stimuli and expected results file
    --------------------------------------------
    file stimuli_file : text open read_mode is "stimuli.txt";
    file results_file : text open read_mode is "expected_results.txt";
    
    --------------------------------------------
    -- procedure to drive the alu
    --------------------------------------------
    procedure drive_alu(
        constant in_a : in std_logic_vector(15 downto 0);
        constant in_b : in std_logic_vector(15 downto 0);
        constant aluctl: in std_logic_vector(1 downto 0); 
        signal alucontrol : out std_logic_vector(1 downto 0);
        signal src_a     : out  std_logic_vector(15 downto 0);
        signal src_b     : out  std_logic_vector(15 downto 0);
        signal res       : out std_logic_vector(15 downto 0);
        signal zero      : out std_logic ; --TRUE if subtraction led to 0   
        signal   clk               : in  std_logic
    ) is begin

        -- clean up all the signals
        zero <= '0';
        res   <= (others => '0');
        
        -- generate handshake waveform and drive the DUT
        wait until clk'event and clk = '1';
        src_a <= in_a;
        src_b <= in_b;
        alucontrol <= aluctl;
        
       -- wait for 10 ns;
        
        
        -- !!!! important, should wait until the DUT has finished
        -- !!!! before returning to the caller
        wait until clk'event and clk = '1';

    end procedure drive_alu;

    --------------------------------------------
    -- procedure to check the sequential adder
    --------------------------------------------
    procedure check_alu(
        constant cout_ref          : in  std_logic;
        constant res_ref           : in  std_logic_vector(15 downto 0);
        signal   cout              : in  std_logic;
        signal   res               : in  std_logic_vector(15 downto 0);
        signal   clk               : in  std_logic;
        signal   pass_or_fail      : out std_logic
    ) is begin
        
        pass_or_fail <= '0'; -- pass
        
        -- !!!! important, should wait until the DUT has finished
        -- !!!! before comparing the results
        wait until clk'event and clk = '1';
        
        if (cout /= cout_ref) then
            pass_or_fail <= '1'; -- fail
          --  print_info("[error] cout fails", conv_std_logic_vector(cout_ref, 4), "000" & cout); 
        end if;

        if (res /= res_ref) then
            pass_or_fail <= '1'; -- fail
         --   print_info("[error] sum fails", res_ref, res); 
        end if;
        
    end procedure check_alu;
    
begin

    --------------------------------------------
    -- clock and reset
    --------------------------------------------
    clk <= not clk after 20 ns;
    rst <= '0' after 25 ns;
    
    --------------------------------------------
    -- stimuli generation
    --------------------------------------------
    stimuli_gen_fileio: process
       variable x_buf    : std_logic_vector(15 downto 0);
       variable y_buf    : std_logic_vector(15 downto 0);
       variable aluctl_buf: std_logic_vector(3 downto 0);
       variable line_buf : line;
    begin
        -- wait for reset and clock signals
        if rst = '1' then
            wait until rst = '0';
        end if;
        wait until clk'event and clk = '1';

        -- read and drive 
        if not endfile(stimuli_file) then

            -- read from file
            readline(stimuli_file, line_buf);
            hread(line_buf, x_buf);
            hread(line_buf, y_buf);
            hread(line_buf, aluctl_buf);

            -- drive the DUT
            drive_alu(x_buf, y_buf, aluctl_buf(1 downto 0), alucontrol, src_a, src_b, res, zero, clk);
            
        end if;

    end process;
    
    --------------------------------------------
    -- results checking
    --------------------------------------------
    results_chk_fileio: process
       variable cout_buf : std_logic_vector(3 downto 0);
       variable res_buf  : std_logic_vector(15 downto 0);
       variable line_buf : line;
    begin
        -- wait for reset and clock signals
        if rst = '1' then
            wait until rst = '0';
        end if;
        wait until clk'event and clk = '1';

        -- read and check 
        if not endfile(results_file) then

            -- read from file
            readline(results_file, line_buf);
            hread(line_buf, cout_buf);
            hread(line_buf, res_buf);

            -- check the DUT
            check_alu(cout_buf(0), res_buf, zero, res, clk, pass_or_fail);
            
        end if;

    end process;

    --------------------------------------------
    -- instantiate the dut
    --     the inputs of the sequential adder comes from the procedure
    --------------------------------------------
    i_dut: alu
        port map(
            alucontrol     => alucontrol,
            src_a      => src_a,
            src_b      => src_b,
            res      => res,
            zero     => zero
        );

End TBusingMixed;