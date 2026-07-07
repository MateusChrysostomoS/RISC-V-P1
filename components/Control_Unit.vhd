library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Control_Unit is
    port(
        opcode                     : IN  std_logic_vector(6 downto 0);
        funct3                     : IN  std_logic_vector(2 downto 0); 
        AluSrc, blockA, RegWrite   : OUT std_logic;
        MemRead, MemWrite, Branch  : OUT std_logic;
        BranchNotEq, BrIncond      : OUT std_logic;
        regToPC                    : OUT std_logic;
        AluOp, regSrc              : OUT std_logic_vector(1 downto 0)
        );
end Control_Unit;

architecture TypeArchitecture of Control_Unit is
begin
    process(opcode, funct3)
    begin
        -- Valores default para evitar latch
        AluSrc      <= '0';
        blockA      <= '0';
        RegWrite    <= '0';
        MemRead     <= '0';
        MemWrite    <= '0';
        Branch      <= '0';
        AluOp       <= "00";
        regSrc      <= "00";
        BranchNotEq <= '0';
        BrIncond    <= '0';
        regToPC     <= '0';

        case opcode is
            when "0110011" =>  -- R-Type (add, sub, and, or, xor, sll, srl)
                AluSrc      <= '0';
                RegWrite    <= '1';
                AluOp       <= "10";
                regSrc      <= "00";

            when "0010011" =>  -- I-Type (addi, andi, ori, xori, slli, srli)
                AluSrc      <= '1';
                RegWrite    <= '1';
                AluOp       <= "11";
                regSrc      <= "00";

            when "0000011" =>  -- I-Type load (lw)
                AluSrc      <= '1';
                RegWrite    <= '1';
                MemRead     <= '1';
                AluOp       <= "00";
                regSrc      <= "01";

            when "1100111" =>  -- I-Type (jalr)
                AluSrc      <= '1';
                RegWrite    <= '1';
                AluOp       <= "00";
                regToPC     <= '1';
                BrIncond    <= '1';
                regSrc      <= "10";

            when "0100011" =>  -- S-Type (sw)
                AluSrc      <= '1';
                MemWrite    <= '1';
                AluOp       <= "00";

            when "1100011" =>  -- SB-Type (beq/bne)
                Branch      <= '1';
                AluOp       <= "01";
                if funct3 = "001" then
                    BranchNotEq <= '1'; -- bne
                else
                    BranchNotEq <= '0'; -- beq
                end if;

            when "1101111" =>  -- UJ-Type (jal)
                RegWrite    <= '1';
                BrIncond    <= '1';
                regToPC     <= '1';
                regSrc      <= "10";

            when "0110111" =>  -- U-Type (lui)
                RegWrite    <= '1';
                blockA      <= '1';
                AluSrc      <= '1';
                AluOp       <= "00";

            when "0010111" =>  -- U-Type (auipc)
                RegWrite    <= '1';
                AluSrc      <= '1';
                AluOp       <= "00";
                regSrc      <= "11";

            when others =>
                null;
        end case;
    end process;
end TypeArchitecture;