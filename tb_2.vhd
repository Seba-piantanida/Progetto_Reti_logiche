
-- TB EXAMPLE PFRL 2022-2023

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

    CONSTANT SCENARIOLENGTH : INTEGER := 690; -- 5 + 3 + 20 + 7   (RST) + (CH2-MEM[1]) + 20 CYCLES + (CH1-MEM[6])
    SIGNAL scenario_rst : unsigned(0 TO SCENARIOLENGTH - 1)     :=  "00110" & "000" & "00000000000000000000" & "0000000" & "00000000000000000000" & "0000" & "00000000000000000000"
    & "110000000000000000000"
    & "00000000000000000000"
    & "000000000000000000"
    & "00000000000000000000"
    & "000000000000000000"
    & "00000000000000000000"
    & "000000000000000000"
    & "00000000000000000000"
    & "000000000000000000"
    & "00000000000000000000"
    & "000000000000000000"
    & "00000000000000000000"
    & "000000000000000000"
    & "00000000000000000000"
    & "000000000000000000"
    & "00000000000000000000"
    & "000000000000000000"
    & "00000000000000000000"
    & "000000000000000000"
    & "00000000000000000000"
    & "000000000000000000"
    & "00000000000000000000"
    & "000000000000000000"
    & "00000000000000000000"
    & "000000000000000000"
    & "00000000000000000000"
    & "000000000000000000"
    & "00000000000000000000"
    & "000000000000000000"
    & "00000000000000000000"
    & "000000000000000000"
    & "00000000000000000000";

    SIGNAL scenario_start : unsigned(0 TO SCENARIOLENGTH - 1)   := "00000" & "111" & "00000000000000000000" & "1111100" & "00000000000000000000" & "1110" & "00000000000000000000"
    & "000111111111111111111"
    & "00000000000000000000"
    & "111111111111111111"
    & "00000000000000000000"
    & "111111111111111111"
    & "00000000000000000000"
    & "111111111111111111"
    & "00000000000000000000"
    & "111111111111111111"
    & "00000000000000000000"
    & "111111111111111111"
    & "00000000000000000000"
    & "111111111111111111"
    & "00000000000000000000"
    & "111111111111111111"
    & "00000000000000000000"
    & "111111111111111111"
    & "00000000000000000000"
    & "111111111111111111"
    & "00000000000000000000"
    & "111111111111111111"
    & "00000000000000000000"
    & "111111111111111111"
    & "00000000000000000000"
    & "111111111111111111"
    & "00000000000000000000"
    & "111111111111111111"
    & "00000000000000000000"
    & "111111111111111111"
    & "00000000000000000000"
    & "111111111111111111"
    & "00000000000000000000";
    
    SIGNAL scenario_w : unsigned(0 TO SCENARIOLENGTH - 1)       := "00000" & "101" & "00000000000000000000" & "0111000" & "00000000000000000000" & "1011" & "00000000000000000000"
    & "000111110101001100000"
    & "00000000000000000000"
    & "111110101111000011"
    & "00000000000000000000"
    & "111110101111001001"
    & "00000000000000000000"
    & "101110110011101011"
    & "00000000000000000000"
    & "101111000001100011"
    & "00000000000000000000"
    & "111111001110010001"
    & "00000000000000000000"
    & "111111011100000000"
    & "00000000000000000000"
    & "011111101010100000"
    & "00000000000000000000"
    & "111111111000011101"
    & "00000000000000000000"
    & "101111101101111000"
    & "00000000000000000000"
    & "011111110101011111"
    & "00000000000000000000"
    & "101111111010100001"--
    & "00000000000000000000"
    & "111111111010110111"
    & "00000000000000000000"
    & "111111111110100010"
    & "00000000000000000000"
    & "111111110001001111"
    & "00000000000000000000"
    & "101111111010111100"
    & "00000000000000000000";
    --360bit

    -- Channel 2 -> MEM[1] -> 162
    -- Channel 1 -> MEM[2] -> 75

    TYPE ram_type IS ARRAY (65535 DOWNTO 0) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL RAM : ram_type := (  0 => STD_LOGIC_VECTOR(to_unsigned(2, 8)),
                                1 => STD_LOGIC_VECTOR(to_unsigned(2, 8)),
                                2 => STD_LOGIC_VECTOR(to_unsigned(75, 8)),
                                3 => STD_LOGIC_VECTOR(to_unsigned(175, 8)),
                                6 => STD_LOGIC_VECTOR(to_unsigned(88, 8)),
                                338 => STD_LOGIC_VECTOR(to_unsigned(204, 8)),
                                1115 => STD_LOGIC_VECTOR(to_unsigned(161, 8)),
                                1873 => STD_LOGIC_VECTOR(to_unsigned(126, 8)),
                                1970 => STD_LOGIC_VECTOR(to_unsigned(105, 8)),
                                2648 => STD_LOGIC_VECTOR(to_unsigned(123, 8)),
                                2844 => STD_LOGIC_VECTOR(to_unsigned(172, 8)),
                                3580 => STD_LOGIC_VECTOR(to_unsigned(234, 8)),
                                4133 => STD_LOGIC_VECTOR(to_unsigned(3, 8)),
                                4917 => STD_LOGIC_VECTOR(to_unsigned(216, 8)),
                                5637 => STD_LOGIC_VECTOR(to_unsigned(79, 8)),
                                60000 => STD_LOGIC_VECTOR(to_unsigned(4, 8)),
                                60355 => STD_LOGIC_VECTOR(to_unsigned(89, 8)),
                                60361 => STD_LOGIC_VECTOR(to_unsigned(102, 8)),
                                60651 => STD_LOGIC_VECTOR(to_unsigned(238, 8)),
                                61539 => STD_LOGIC_VECTOR(to_unsigned(46, 8)),
                                62353 => STD_LOGIC_VECTOR(to_unsigned(148, 8)),
                                63232 => STD_LOGIC_VECTOR(to_unsigned(58, 8)),
                                64160 => STD_LOGIC_VECTOR(to_unsigned(82, 8)),
                                65053 => STD_LOGIC_VECTOR(to_unsigned(20, 8)),
                                64376 => STD_LOGIC_VECTOR(to_unsigned(244, 8)),
                                64863 => STD_LOGIC_VECTOR(to_unsigned(67, 8)),
                                65185 => STD_LOGIC_VECTOR(to_unsigned(31, 8)),
                                65207 => STD_LOGIC_VECTOR(to_unsigned(230, 8)),
                                65442 => STD_LOGIC_VECTOR(to_unsigned(134, 8)),
                                64591 => STD_LOGIC_VECTOR(to_unsigned(228, 8)),
                                65212 => STD_LOGIC_VECTOR(to_unsigned(49, 8)),
                                1000 => STD_LOGIC_VECTOR(to_unsigned(22, 8)),
                                8566 => STD_LOGIC_VECTOR(to_unsigned(218, 8)),
                                14451 => STD_LOGIC_VECTOR(to_unsigned(235, 8)),
                                18781 => STD_LOGIC_VECTOR(to_unsigned(227, 8)),
                                27866 => STD_LOGIC_VECTOR(to_unsigned(137, 8)),
                                35880 => STD_LOGIC_VECTOR(to_unsigned(36, 8)),
                                39487 => STD_LOGIC_VECTOR(to_unsigned(77, 8)),
                                45660 => STD_LOGIC_VECTOR(to_unsigned(75, 8)),
                                52141 => STD_LOGIC_VECTOR(to_unsigned(187, 8)),
                                53762 => STD_LOGIC_VECTOR(to_unsigned(93, 8)),
                                54050 => STD_LOGIC_VECTOR(to_unsigned(115, 8)),
                                58678 => STD_LOGIC_VECTOR(to_unsigned(223, 8)),
                                63104 => STD_LOGIC_VECTOR(to_unsigned(199, 8)),
                                60318 => STD_LOGIC_VECTOR(to_unsigned(201, 8)),
                                51599 => STD_LOGIC_VECTOR(to_unsigned(129, 8)),
                                53114 => STD_LOGIC_VECTOR(to_unsigned(11, 8)),
                                
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
        --WAIT UNTIL rising_edge(tb_clk);
        WAIT FOR CLOCK_PERIOD/2;
        ASSERT tb_z2 = std_logic_vector(to_unsigned(2, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        WAIT UNTIL tb_done = '0';
        ASSERT tb_z0 = "00000000" REPORT "TEST FALLITO (postdone Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z0))) severity failure; 
        ASSERT tb_z1 = "00000000" REPORT "TEST FALLITO (postdone Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z1))) severity failure; 
        ASSERT tb_z2 = "00000000" REPORT "TEST FALLITO (postdone Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; 
        ASSERT tb_z3 = "00000000" REPORT "TEST FALLITO (postdone Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z3))) severity failure; 
        WAIT UNTIL tb_start = '1';
        WAIT UNTIL tb_done = '1';
        
        --WAIT UNTIL rising_edge(tb_clk);
        WAIT FOR CLOCK_PERIOD/2;

        ASSERT tb_z1 = std_logic_vector(to_unsigned(88, 8))  REPORT "TEST FALLITO (Z1 ---) found " & integer'image(to_integer(unsigned(tb_z1))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z2 = std_logic_vector(to_unsigned(2, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        
        WAIT UNTIL tb_start = '1';
        ASSERT tb_z0 = "00000000" REPORT "TEST FALLITO (poststart Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z0))) severity failure; 
        ASSERT tb_z1 = "00000000" REPORT "TEST FALLITO (poststart Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z1))) severity failure; 
        ASSERT tb_z2 = "00000000" REPORT "TEST FALLITO (poststart Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; 
        ASSERT tb_z3 = "00000000" REPORT "TEST FALLITO (poststart Z0--Z3 != 0 ) found " & integer'image(to_integer(unsigned(tb_z3))) severity failure; 
        
        
        --inizio test esempio 2
        WAIT UNTIL tb_rst = '1';
        wait until tb_done = '1';
        --WAIT UNTIL rising_edge(tb_clk);
        WAIT FOR CLOCK_PERIOD/2; -- 00 00 00 04
        ASSERT tb_z0 = std_logic_vector(to_unsigned(0, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z0))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z1 = std_logic_vector(to_unsigned(0, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z1))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z2 = std_logic_vector(to_unsigned(0, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z3 = std_logic_vector(to_unsigned(4, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z3))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;

        WAIT UNTIL tb_done = '1';
        WAIT FOR CLOCK_PERIOD/2; --00 00 00 59
        ASSERT tb_z0 = std_logic_vector(to_unsigned(0, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z0))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z1 = std_logic_vector(to_unsigned(0, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z1))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z2 = std_logic_vector(to_unsigned(0, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z3 = std_logic_vector(to_unsigned(89, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z3))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;

        WAIT UNTIL tb_done = '1';
        WAIT FOR CLOCK_PERIOD/2; -- 00 00 00 66
        ASSERT tb_z0 = std_logic_vector(to_unsigned(0, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z0))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z1 = std_logic_vector(to_unsigned(0, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z1))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z2 = std_logic_vector(to_unsigned(0, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z3 = std_logic_vector(to_unsigned(102, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z3))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;

        WAIT UNTIL tb_done = '1';
        WAIT FOR CLOCK_PERIOD/2; --00 00 ee 66
        ASSERT tb_z0 = std_logic_vector(to_unsigned(0, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z1 = std_logic_vector(to_unsigned(0, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z2 = std_logic_vector(to_unsigned(238, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z3 = std_logic_vector(to_unsigned(102, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;

        WAIT UNTIL tb_done = '1';
        WAIT FOR CLOCK_PERIOD/2; --00 00 2e 66
        ASSERT tb_z0 = std_logic_vector(to_unsigned(0, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z1 = std_logic_vector(to_unsigned(0, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z2 = std_logic_vector(to_unsigned(46, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z3 = std_logic_vector(to_unsigned(102, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;

        WAIT UNTIL tb_done = '1';
        WAIT FOR CLOCK_PERIOD/2;-- 00 00 2e 94
        ASSERT tb_z0 = std_logic_vector(to_unsigned(0, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z1 = std_logic_vector(to_unsigned(0, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z2 = std_logic_vector(to_unsigned(46, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z3 = std_logic_vector(to_unsigned(148, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;

        WAIT UNTIL tb_done = '1';
        WAIT FOR CLOCK_PERIOD/2; -- 00 00 2e 3a
        ASSERT tb_z0 = std_logic_vector(to_unsigned(0, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z1 = std_logic_vector(to_unsigned(0, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z2 = std_logic_vector(to_unsigned(46, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z3 = std_logic_vector(to_unsigned(58, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;

        WAIT UNTIL tb_done = '1';
        WAIT FOR CLOCK_PERIOD/2;--00 52 2e 3a
        ASSERT tb_z0 = std_logic_vector(to_unsigned(0, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z1 = std_logic_vector(to_unsigned(82, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z2 = std_logic_vector(to_unsigned(46, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z3 = std_logic_vector(to_unsigned(58, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;

        WAIT UNTIL tb_done = '1';
        WAIT FOR CLOCK_PERIOD/2;--00 52 2e 14
        ASSERT tb_z0 = std_logic_vector(to_unsigned(0, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z1 = std_logic_vector(to_unsigned(82, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z2 = std_logic_vector(to_unsigned(46, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z3 = std_logic_vector(to_unsigned(20, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;

        WAIT UNTIL tb_done = '1';
        WAIT FOR CLOCK_PERIOD/2;--00 52 f4 14
        ASSERT tb_z0 = std_logic_vector(to_unsigned(0, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z1 = std_logic_vector(to_unsigned(82, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z2 = std_logic_vector(to_unsigned(244, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z3 = std_logic_vector(to_unsigned(20, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;

        WAIT UNTIL tb_done = '1';
        WAIT FOR CLOCK_PERIOD/2;--00 43 f4 14
        ASSERT tb_z0 = std_logic_vector(to_unsigned(0, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z1 = std_logic_vector(to_unsigned(67, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z2 = std_logic_vector(to_unsigned(244, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z3 = std_logic_vector(to_unsigned(20, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        
        WAIT UNTIL tb_done = '1';
        WAIT FOR CLOCK_PERIOD/2;--00 43 1f 14
        ASSERT tb_z0 = std_logic_vector(to_unsigned(0, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z1 = std_logic_vector(to_unsigned(67, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z2 = std_logic_vector(to_unsigned(31, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z3 = std_logic_vector(to_unsigned(20, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        
        WAIT UNTIL tb_done = '1';
        WAIT FOR CLOCK_PERIOD/2;--00 43 1f e6
        ASSERT tb_z0 = std_logic_vector(to_unsigned(0, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z1 = std_logic_vector(to_unsigned(67, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z2 = std_logic_vector(to_unsigned(31, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z3 = std_logic_vector(to_unsigned(230, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        
        WAIT UNTIL tb_done = '1';
        WAIT FOR CLOCK_PERIOD/2;--00 43 1f 86
        ASSERT tb_z0 = std_logic_vector(to_unsigned(0, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z1 = std_logic_vector(to_unsigned(67, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z2 = std_logic_vector(to_unsigned(31, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z3 = std_logic_vector(to_unsigned(134, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        
        WAIT UNTIL tb_done = '1';
        WAIT FOR CLOCK_PERIOD/2;--00 43 1f e4
        ASSERT tb_z0 = std_logic_vector(to_unsigned(0, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z1 = std_logic_vector(to_unsigned(67, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z2 = std_logic_vector(to_unsigned(31, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z3 = std_logic_vector(to_unsigned(228, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        
        WAIT UNTIL tb_done = '1';
        WAIT FOR CLOCK_PERIOD/2;--00 43 31 e4
        ASSERT tb_z0 = std_logic_vector(to_unsigned(0, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z1 = std_logic_vector(to_unsigned(67, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z2 = std_logic_vector(to_unsigned(49, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        ASSERT tb_z3 = std_logic_vector(to_unsigned(228, 8))  REPORT "TEST FALLITO (Z2 ---) found " & integer'image(to_integer(unsigned(tb_z2))) severity failure; --. Expected  209  found " & integer'image(tb_z0))))  severity failure;
        

        --fine test 1
       

        ASSERT false REPORT "Simulation Ended! TEST PASSATO (EXAMPLE)" SEVERITY failure;
    END PROCESS testRoutine;

END projecttb;