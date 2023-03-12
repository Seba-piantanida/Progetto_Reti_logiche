
library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity project_reti_logiche_tb is
end;

architecture bench of project_reti_logiche_tb is

  component project_reti_logiche
      Port ( 
              i_clk : in STD_LOGIC;
              i_rst : in STD_LOGIC;
              i_start : in STD_LOGIC;
              i_w : in STD_LOGIC;
              o_z0 : out STD_LOGIC_VECTOR (7 downto 0);
              o_z1 : out STD_LOGIC_VECTOR (7 downto 0);
              o_z2 : out STD_LOGIC_VECTOR (7 downto 0);
              o_z3 : out STD_LOGIC_VECTOR (7 downto 0);
              o_done : out std_logic;
              o_mem_addr : out std_logic_vector (15 downto 0);
              i_mem_data : in std_logic_vector (7 downto 0);
              o_mem_we : out std_logic ;
              o_mem_en : out std_logic
           );
  end component;

  signal i_clk: STD_LOGIC;
  signal i_rst: STD_LOGIC;
  signal i_start: STD_LOGIC;
  signal i_w: STD_LOGIC;
  signal o_z0: STD_LOGIC_VECTOR (7 downto 0);
  signal o_z1: STD_LOGIC_VECTOR (7 downto 0);
  signal o_z2: STD_LOGIC_VECTOR (7 downto 0);
  signal o_z3: STD_LOGIC_VECTOR (7 downto 0);
  signal o_done: std_logic;
  signal o_mem_addr: std_logic_vector (15 downto 0);
  signal i_mem_data: std_logic_vector (7 downto 0);
  signal o_mem_we: std_logic;
  signal o_mem_en: std_logic ;

  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;

begin

  uut: project_reti_logiche port map ( i_clk      => i_clk,
                                       i_rst      => i_rst,
                                       i_start    => i_start,
                                       i_w        => i_w,
                                       o_z0       => o_z0,
                                       o_z1       => o_z1,
                                       o_z2       => o_z2,
                                       o_z3       => o_z3,
                                       o_done     => o_done,
                                       o_mem_addr => o_mem_addr,
                                       i_mem_data => i_mem_data,
                                       o_mem_we   => o_mem_we,
                                       o_mem_en   => o_mem_en );

  stimulus: process
  begin
  
    -- Put initialisation code here

    i_rst <= '1';
    wait for 5 ns;
    i_rst <= '0';
    wait for 5 ns;

    -- Put test bench stimulus code here

    stop_the_clock <= true;
    wait;
  end process;

  clocking: process
  begin
    while not stop_the_clock loop
      i_clk <= '0', '1' after clock_period / 2;
      wait for clock_period;
    end loop;
    wait;
  end process;

end;