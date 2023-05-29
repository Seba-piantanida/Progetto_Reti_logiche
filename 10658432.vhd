
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity project_reti_logiche is
    Port ( 
            i_clk : in STD_LOGIC;                               --segnale di clock dal TB
            i_rst : in STD_LOGIC;                               --segnale di reset dal TB (garantito prima del primo start)
            i_start : in STD_LOGIC;                             --segnale di start del TB
            i_w : in STD_LOGIC;                                 --segnale input da cui leggo orta di uscito e indirizzo di memoria

            o_z0 : out STD_LOGIC_VECTOR (7 downto 0);           --segnale uscita 00
            o_z1 : out STD_LOGIC_VECTOR (7 downto 0);           --segnale uscita 01
            o_z2 : out STD_LOGIC_VECTOR (7 downto 0);           --segnale uscita 10
            o_z3 : out STD_LOGIC_VECTOR (7 downto 0);           --segnale uscita 11
            o_done : out std_logic;

            o_mem_addr : out std_logic_vector (15 downto 0);    --indirizzo di memoria
            i_mem_data : in std_logic_vector (7 downto 0);      --ingressso dati letti in memoria
            o_mem_we : out std_logic ;                          --memory write enable
            o_mem_en : out std_logic                            --memory enable
         );
          
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
    type state_type is (s0, s1, s2, s3, s4, s5, s6, s7, s8);
    signal state: state_type;

    signal out_port: std_logic_vector(1 downto 0);
    signal temp_addr: std_logic_vector(15 downto 0);
    signal out_data: std_logic_vector(7 downto 0);

    signal temp_z0: std_logic_vector(7 downto 0);
    signal temp_z1: std_logic_vector(7 downto 0);
    signal temp_z2: std_logic_vector(7 downto 0);
    signal temp_z3: std_logic_vector(7 downto 0);
  
begin
    process(i_clk, i_rst)
    begin
    if i_rst = '1' then         --segnale di RESET --> inizializzo i segnali
        
        o_z0 <= (others => '0');     
        o_z1 <= (others => '0');     --inizializzo uscite a 0
        o_z2 <= (others => '0');
        o_z3 <= (others => '0');

        o_done <= '0';
        
        temp_z0 <= (others => '0');
        temp_z1 <= (others => '0');  --inizializzo memoria uscite a 0
        temp_z2 <= (others => '0');
        temp_z3 <= (others => '0');

        o_mem_we <= '0';
        o_mem_en <= '0';

        state <= s1;

        out_data <= (others => '0');

        temp_addr <= (others => '0');

        o_mem_addr <= (others => '0');
    
    elsif i_clk'event and i_clk = '1' then
        case state is
            when s1 =>                  --leggo primo bit porta di uscita

                if i_start = '1' then
                    out_port(1) <= i_w;
                    state <= s2;
                end if;
                
            when s2 =>                  --leggo secondo bit porta di uscita

                if i_start = '1' then 
                    out_port(0) <= i_w;
                    state <= s3;
                end if;

            when s3 =>                  --leggo indirizzo di memoria

                if i_start = '1' then
                    temp_addr <= temp_addr(14 downto 0) & i_w;
                elsif i_start = '0' then
                    state <= s4;
                    o_mem_en <= '1';
                    o_mem_addr <= temp_addr;
                end if;

            when s4 =>                  --abilito la memoria e inserisco l'indirizzo

                o_mem_en <= '1';
                o_mem_addr <= temp_addr;
                state <= s5;

            when s5 =>                  --leggo i dati dalla memoria

                out_data <= i_mem_data;
                state <= s6;
                o_mem_en <= '0';

            when s6 =>                  --salvo i dati sulla "memoria del uscita"
                
                case out_port is
                    when "00" =>
                        temp_z0 <= out_data;
                    when "01" =>
                        temp_z1 <= out_data;
                    when "10" =>
                        temp_z2 <= out_data;
                    when others =>
                        temp_z3 <= out_data;
                end case;
                
                state <= s7;

            when s7 =>              --mostro le uscite in output e porto done a 1

                o_done <= '1';
                o_z0  <= temp_z0;
                o_z1  <= temp_z1;
                o_z2  <= temp_z2;
                o_z3  <= temp_z3;

                state <= s8;

            when s8 =>              -- stato di reset
                
                o_z0  <= (others => '0');
                o_z1  <= (others => '0');
                o_z2  <= (others => '0');
                o_z3  <= (others => '0');

                o_done <= '0';
                
                o_mem_we <= '0';
                o_mem_en <= '0';
        
                out_data <= (others => '0');
                temp_addr <= (others => '0');
                state <= s1;

            when s0 => -- sato di idle finche il sistema non riceve il primo rst resta qui 
                state <= s0;

            end case;
          end if;
      end process;
                    

end Behavioral;
