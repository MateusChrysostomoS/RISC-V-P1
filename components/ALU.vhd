library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.ALL;

entity ALU is
    port(
        A, B      : in  std_logic_vector(31 downto 0);
        control   : in  std_logic_vector(3 downto 0);
        result    : out std_logic_vector(31 downto 0);
        zero      : out std_logic;
        -- NOVO PARA O P1: Exportação de estado interno exigido pelo pdf
        carry_out : out std_logic 
    );
end ALU;

architecture Behavioral of ALU is
    signal result_out : std_logic_vector(31 downto 0);
    signal sum_temp   : std_logic_vector(32 downto 0); -- 33 bits para segurar o carry
    signal shamt      : integer;
begin
    -- RISC-V usa os 5 bits menos significativos para quantidade de deslocamento
    shamt <= to_integer(unsigned(B(4 downto 0)));

    -- Bloco de soma/subtração com captura do Carry
    process(A, B, control)
    begin
        if control = "0110" then -- SUB
            sum_temp <= std_logic_vector(resize(unsigned(A), 33) - resize(unsigned(B), 33));
        else -- ADD (usado por padrão ou quando control = "0010")
            sum_temp <= std_logic_vector(resize(unsigned(A), 33) + resize(unsigned(B), 33));
        end if;
    end process;

    -- Exporta o bit 32 (o vai-um) para o pino externo
    carry_out <= sum_temp(32);

    -- Multiplexador de controle da ALU com as instruções do P1
    result_out <= sum_temp(31 downto 0)                          when control = "0010" else -- add / addi / lw / sw / jal
                  sum_temp(31 downto 0)                          when control = "0110" else -- sub / beq / bne
                  (A and B)                                      when control = "0000" else -- and / andi
                  (A or B)                                       when control = "0001" else -- or / ori
                  (A xor B)                                      when control = "0101" else -- xor / xori
                  std_logic_vector(shift_left(unsigned(A), shamt))  when control = "0011" else -- sll / slli
                  std_logic_vector(shift_right(unsigned(A), shamt)) when control = "0111" else -- srl / srli
                  (others => '0');

    result <= result_out;
    zero <= '1' when result_out = x"00000000" else '0';
end Behavioral;