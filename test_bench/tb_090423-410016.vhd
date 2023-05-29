
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;
USE std.textio.ALL;

ENTITY project_tb IS
END project_tb;

ARCHITECTURE projecttb OF project_tb IS
    CONSTANT CLOCK_PERIOD : TIME := 100 ns;
    SIGNAL tb_done : STD_LOGIC;
    SIGNAL mem_address : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tb_rst : STD_LOGIC := '0';
    SIGNAL tb_start : STD_LOGIC := '0';
    SIGNAL tb_clk : STD_LOGIC := '0';
    SIGNAL mem_o_data, mem_i_data : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL enable_wire : STD_LOGIC;
    SIGNAL mem_we : STD_LOGIC;
    SIGNAL tb_z0, tb_z1, tb_z2, tb_z3 : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL tb_w : STD_LOGIC;

    CONSTANT SCENARIOLENGTH : INTEGER := 354; -- 5 + 3 + 20 + 7   (RST) + (CH2-MEM[1]) + 20 CYCLES + (CH1-MEM[6])
    SIGNAL scenario_rst : unsigned(0 TO SCENARIOLENGTH - 1)     := "00110" & 
		"00000000000000000" &
		"00000000000000000000" &
		"000000000000000000" &
		"00000000000000000000" &
		"000000000000000000" &
		"00000000000000000000" &
		"000000000000000000" &
		"00000000000000000000" &
		"00000000000000000" &
		"00000000000000000000" &
		"00000000000000000" &
		"00000000000000000000" &
		"00000000000000" &
		"00000000000000000000" &
		"00000000000000000" &
		"00000000000000000000" &
		"000000000000000000" &
		"00000000000000000000" &
		"000000000000000" &
		"00000000000000000000" ;

    SIGNAL scenario_start : unsigned(0 TO SCENARIOLENGTH - 1)   := "00000" & 
		"11111111111111111" &
		"00000000000000000000" &
		"111111111111111111" &
		"00000000000000000000" &
		"111111111111111111" &
		"00000000000000000000" &
		"111111111111111111" &
		"00000000000000000000" &
		"11111111111111111" &
		"00000000000000000000" &
		"11111111111111111" &
		"00000000000000000000" &
		"11111111111111" &
		"00000000000000000000" &
		"11111111111111111" &
		"00000000000000000000" &
		"111111111111111111" &
		"00000000000000000000" &
		"111111111111111" &
		"00000000000000000000" ;

    SIGNAL scenario_w : unsigned(0 TO SCENARIOLENGTH - 1)       := "00000" & 
		"11110010110101011" &
		"00000000000000000000" &
		"001001100010011001" &
		"00000000000000000000" &
		"011011000110110010" &
		"00000000000000000000" &
		"001100010001111011" &
		"00000000000000000000" &
		"01110100011001011" &
		"00000000000000000000" &
		"01111001010100011" &
		"00000000000000000000" &
		"11101100101001" &
		"00000000000000000000" &
		"00110011011100001" &
		"00000000000000000000" &
		"001101101110011111" &
		"00000000000000000000" &
		"101100011111011" &
		"00000000000000000000" ;

    -- Channel 2 -> MEM[1] -> 162
    -- Channel 1 -> MEM[2] -> 75

    TYPE ram_type IS ARRAY (65535 DOWNTO 0) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL RAM : ram_type := (
				26027 => STD_LOGIC_VECTOR(to_unsigned(25, 8)),
				39065 => STD_LOGIC_VECTOR(to_unsigned(202, 8)),
				45490 => STD_LOGIC_VECTOR(to_unsigned(175, 8)),
				50299 => STD_LOGIC_VECTOR(to_unsigned(187, 8)),
				26827 => STD_LOGIC_VECTOR(to_unsigned(120, 8)),
				29347 => STD_LOGIC_VECTOR(to_unsigned(241, 8)),
				2857 => STD_LOGIC_VECTOR(to_unsigned(154, 8)),
				26337 => STD_LOGIC_VECTOR(to_unsigned(65, 8)),
				56223 => STD_LOGIC_VECTOR(to_unsigned(111, 8)),
				6395 => STD_LOGIC_VECTOR(to_unsigned(127, 8)),

                              
                                
                                OTHERS => "00000000"-- (OTHERS => '0')
                            );
                    
    COMPONENT project_reti_logiche IS
        PORT (
            i_clk : IN STD_LOGIC;
            i_rst : IN STD_LOGIC;
            i_start : IN STD_LOGIC;
            i_w : IN STD_LOGIC;

            o_z0 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            o_z1 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            o_z2 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            o_z3 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            o_done : OUT STD_LOGIC;

            o_mem_addr : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            i_mem_data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            o_mem_we : OUT STD_LOGIC;
            o_mem_en : OUT STD_LOGIC
        );
    END COMPONENT project_reti_logiche;

BEGIN
    UUT : project_reti_logiche
    PORT MAP(
        i_clk => tb_clk,
        i_start => tb_start,
        i_rst => tb_rst,
        i_w => tb_w,

        o_z0 => tb_z0,
        o_z1 => tb_z1,
        o_z2 => tb_z2,
        o_z3 => tb_z3,
        o_done => tb_done,

        o_mem_addr => mem_address,
        o_mem_en => enable_wire,
        o_mem_we => mem_we,
        i_mem_data => mem_o_data
    );


    -- Process for the clock generation
    CLK_GEN : PROCESS IS
    BEGIN
        WAIT FOR CLOCK_PERIOD/2;
        tb_clk <= NOT tb_clk;
    END PROCESS CLK_GEN;


    -- Process related to the memory
    MEM : PROCESS (tb_clk)
    BEGIN
        IF tb_clk'event AND tb_clk = '1' THEN
            IF enable_wire = '1' THEN
                IF mem_we = '1' THEN
                    RAM(conv_integer(mem_address)) <= mem_i_data;
                    mem_o_data <= mem_i_data AFTER 1 ns;
                ELSE
                    mem_o_data <= RAM(conv_integer(mem_address)) AFTER 1 ns; 
                END IF;
            END IF;
        END IF;
    END PROCESS;
    
    -- This process provides the correct scenario on the signal controlled by the TB
    createScenario : PROCESS (tb_clk)
    BEGIN
        IF tb_clk'event AND tb_clk = '0' THEN
            tb_rst <= scenario_rst(0);
            tb_w <= scenario_w(0);
            tb_start <= scenario_start(0);
            scenario_rst <= scenario_rst(1 TO SCENARIOLENGTH - 1) & '0';
            scenario_w <= scenario_w(1 TO SCENARIOLENGTH - 1) & '0';
            scenario_start <= scenario_start(1 TO SCENARIOLENGTH - 1) & '0';
        END IF;
    END PROCESS;

    -- Process without sensitivity list designed to test the actual component.
    testRoutine : PROCESS IS
    BEGIN
        mem_i_data <= "00000000";
        -- wait for 10000 ns;
        WAIT UNTIL tb_rst = '1';
        WAIT UNTIL tb_rst = '0';
        ASSERT tb_z0 = "00000000" REPORT "TEST FALLITO (postreset Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z0))) severity failure; 
        ASSERT tb_z1 = "00000000" REPORT "TEST FALLITO (postreset Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z1))) severity failure; 
        ASSERT tb_z2 = "00000000" REPORT "TEST FALLITO (postreset Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; 
        ASSERT tb_z3 = "00000000" REPORT "TEST FALLITO (postreset Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z3))) severity failure; 
        WAIT UNTIL tb_start = '1';
        ASSERT tb_z0 = "00000000" REPORT "TEST FALLITO (poststart Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z0))) severity failure; 
        ASSERT tb_z1 = "00000000" REPORT "TEST FALLITO (poststart Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z1))) severity failure; 
        ASSERT tb_z2 = "00000000" REPORT "TEST FALLITO (poststart Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; 
        ASSERT tb_z3 = "00000000" REPORT "TEST FALLITO (poststart Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z3))) severity failure;
        
 
        WAIT UNTIL tb_done = '1';
        WAIctor(to_unsigned(0, 8))  REPORT "TEST FALLITO (Z1 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  0
        ASSERT tb_z3 = std_logic_vector(to_unsigned(25, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z3))) severity failure; --. Expected  25
 
        WAIT UNTIL tb_done = '1';
        WAIT FOR CLOCK_PERIOD/2;

        ASSERT tb_z0 = std_logic_vector(to_unsigned(187, 8))  REPORT "TEST FALLITO (Z1 ---) found " & integer'image(to_integer(unsigned(tb_z0))) severity failure; --. Expected  187
        ASSERT tb_z1 = std_logic_vectorT FOR CLOCK_PERIOD/2;

        ASSERT tb_z0 = std_logic_vector(to_unsigned(0, 8))  REPORT "TEST FALLITO (Z1 ---) found " & integer'image(to_integer(unsigned(tb_z0))) severity failure; --. Expected  0
        ASSERT tb_z1 = std_logic_vector(to_unsigned(0, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z1))) severity failure; --. Expected  0
        ASSERT tb_z2 = std_logic_vector(to_unsigned(0, 8))  REPORT "TEST FALLITO (Z1 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  0
        ASSERT tb_z3 = std_logic_vector(to_unsigned(25, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z3))) severity failure; --. Expected  25
 
        WAIT UNTIL tb_done = '1';
        WAIT FOR CLOCK_PERIOD/2;

        ASSERT tb_z0 = std_logic_vector(to_unsigned(202, 8))  REPORT "TEST FALLITO (Z1 ---) found " & integer'image(to_integer(unsigned(tb_z0))) severity failure; --. Expected  202
        ASSERT tb_z1 = std_logic_vector(to_unsigned(0, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z1))) severity failure; --. Expected  0
        ASSERT tb_z2 = std_logic_vector(to_unsigned(0, 8))  REPORT "TEST FALLITO (Z1 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  0
        ASSERT tb_z3 = std_logic_vector(to_unsigned(25, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z3))) severity failure; --. Expected  25
 
        WAIT UNTIL tb_done = '1';
        WAIT FOR CLOCK_PERIOD/2;

        ASSERT tb_z0 = std_logic_vector(to_unsigned(202, 8))  REPORT "TEST FALLITO (Z1 ---) found " & integer'image(to_integer(unsigned(tb_z0))) severity failure; --. Expected  202
        ASSERT tb_z1 = std_logic_vector(to_unsigned(175, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z1))) severity failure; --. Expected  175
        ASSERT tb_z2 = std_logic_vector(to_unsigned(0, 8))  REPORT "TEST FALLITO (Z1 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  0
        ASSERT tb_z3 = std_logic_vector(to_unsigned(25, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z3))) severity failure; --. Expected  25
 
        WAIT UNTIL tb_done = '1';
        WAIT FOR CLOCK_PERIOD/2;

        ASSERT tb_z0 = std_logic_vector(to_unsigned(187, 8))  REPORT "TEST FALLITO (Z1 ---) found " & integer'image(to_integer(unsigned(tb_z0))) severity failure; --. Expected  187
        ASSERT tb_z1 = std_logic_vector(to_unsigned(175, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z1))) severity failure; --. Expected  175
        ASSERT tb_z2 = std_logic_ve(to_unsigned(120, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z1))) severity failure; --. Expected  120
        ASSERT tb_z2 = std_logic_vector(to_unsigned(0, 8))  REPORT "TEST FALLITO (Z1 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  0
        ASSERT tb_z3 = std_logic_vector(to_unsigned(25, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z3))) severity failure; --. Expected  25
 
        WAIT UNTIL tb_done = '1';
        WAIT FOR CLOCK_PERIOD/2;

        ASSERT tb_z0 = std_logic_vector(to_unsigned(187, 8))  REPORT "TEST FALLITO (Z1 ---) found " & integer'image(to_integer(unsigned(tb_z0))) severity failure; --. Expected  187
        ASSERT tb_z1 = std_logic_vector(to_unsigned(241, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z1))) severity failure; --. Expected  241
        ASSERT tb_z2 = std_logic_vector(to_unsigned(0, 8))  REPORT "TEST FALLITO (Z1 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  0
        ASSERT tb_z3 = std_logic_vector(to_unsigned(25, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z3))) severity failure; --. Expected  25
 
        WAIT UNTIL tb_done = '1';
        WAIT FOR CLOCK_PERIOD/2;

        ASSERT tb_z0 = std_logic_vector(to_unsigned(187, 8))  REPORT "TEST FALLITO (Z1 ---) found " & integer'image(to_integer(unsigned(tb_z0))) severity failure; --. Expected  187
        ASSERT tb_z1 = std_logic_vector(to_unsigned(241, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z1))) severity failure; --. Expected  241
        ASSERT tb_z2 = std_logic_vector(to_unsigned(0, 8))  REPORT "TEST FALLITO (Z1 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  0
        ASSERT tb_z3 = std_logic_vector(to_unsigned(154, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z3))) severity failure; --. Expected  154
 
        WAIT UNTIL tb_done = '1';
        WAIT FOR CLOCK_PERIOD/2;

        ASSERT tb_z0 = std_logic_vector(to_unsigned(65, 8))  REPORT "TEST FALLITO (Z1 ---) found " & integer'image(to_integer(unsigned(tb_z0))) severity failure; --. Expected  65
        ASSERT tb_z1 = std_logic_vector(to_unsigned(241, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z1))) severity failure; --. Expected  241
        ASSERT tb_z2 = std_logic_vector(to_unsigned(0, 8))  REPORT "TEST FALLITO (Z1 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  0
        ASSERT tb_z3 = std_logic_vector(to_unsigned(154, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z3))) severity failure; --. Expected  154
 
        WAIT UNTIL tb_done = '1';
        WAIT FOR CLOCK_PERIOD/2;

        ASSERT tb_z0 = std_logic_vector(to_unsigned(111, 8))  REPORT "TEST FALLITO (Z1 ---) found " & integer'image(to_integer(unsigned(tb_z0))) severity failure; --. Expected  111
        ASSERT tb_z1 = std_logic_vector(to_unsigned(241, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z1))) severity failure; --. Expected  241
        ASSERT tb_z2 = std_logic_vector(to_unsigned(0, 8))  REPORT "TEST FALLITO (Z1 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  0
        ASSERT tb_z3 = std_logic_vector(to_unsigned(154, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z3))) severity failure; --. Expected  154
 
        WAIT UNTIL tb_done = '1';
        WAIT FOR CLOCK_PERIOD/2;

        ASSERT tb_z0 = std_logic_vector(to_unsigned(111, 8))  REPORT "TEST FALLITO (Z1 ---) found " & integer'image(to_integer(unsigned(tb_z0))) severity failure; --. Expected  111
        ASSERT tb_z1 = std_logic_vector(to_unsigned(241, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z1))) severity failure; --. Expected  241
        ASSERT tb_z2 = std_logic_vector(to_unsigned(127, 8))  REPORT "TEST FALLITO (Z1 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  127
        ASSERT tb_z3 = std_logic_vector(to_unsigned(154, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z3))) severity failure; --. Expected  154
 
        
        ASSERT false REPORT "Simulation Ended! TEST PASSATO ()" SEVERITY failure;
    END PROCESS testRoutine;

END projecttb;
