library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- ============================================================================
-- PCSrc_Control
-- ----------------------------------------------------------------------------
-- Logica combinacional pura que decide a origem do proximo PC.
-- Gera um seletor para o MUX de proximo-PC a partir dos sinais de controle
-- de branch (ja atrasados pelo IDEX, vindos do Splitter do Mout no estagio EX)
-- e da flag 'zero' da ALU.
--
-- Regra de desvio:
--   beq  tomado  = Branch      AND      zero   (registradores iguais)
--   bne  tomado  = BranchNotEq AND (NOT zero)  (registradores diferentes)
--   jal/jalr     = BrIncond               (salto incondicional, sempre)
--
-- Saida principal:
--   pcsrc : '0' = proximo PC e PC+4 (fluxo normal)
--           '1' = proximo PC e o alvo de desvio (somador de branch / jal)
--
-- Saidas de depuracao (o enunciado pede que estados internos sejam aferiveis):
--   take_cond    : 1 se um branch CONDICIONAL foi tomado (beq/bne)
--   take_uncond  : 1 se e um salto incondicional (jal/jalr)
--
-- OBS sobre jalr: este modulo apenas sinaliza "houve salto". A distincao entre
-- o alvo de jal (PC+imm, vem do somador de branch) e o de jalr (rs1+imm, vem
-- da ALU) e feita no MUX de proximo-PC, nao aqui. Se voce for tratar jalr com
-- alvo proprio, precisara de um bit adicional (jalr_sel) e de uma 3a entrada
-- no MUX -- ver observacao no relatorio.
-- ============================================================================

entity PCSrc_Control is
    port(
        Branch      : in  std_logic;   -- do Splitter do Mout (bit de Branch)
        BranchNotEq : in  std_logic;   -- do Splitter do Mout (bit de BranchNotEq)
        BrIncond    : in  std_logic;   -- do Splitter do Mout (bit de BrIncond, jal/jalr)
        zero        : in  std_logic;   -- direto da ALU (flag zero)

        pcsrc       : out std_logic;   -- seletor do MUX de proximo-PC
        take_cond   : out std_logic;   -- depuracao: branch condicional tomado
        take_uncond : out std_logic    -- depuracao: salto incondicional
        );
end PCSrc_Control;

architecture TypeArchitecture of PCSrc_Control is
    signal beq_taken   : std_logic;
    signal bne_taken   : std_logic;
    signal cond_taken  : std_logic;
begin
    -- beq: desvia quando Branch=1 e os operandos sao iguais (zero=1)
    beq_taken  <= Branch and zero;

    -- bne: desvia quando BranchNotEq=1 e os operandos sao diferentes (zero=0)
    bne_taken  <= BranchNotEq and (not zero);

    -- qualquer branch condicional tomado
    cond_taken <= beq_taken or bne_taken;

    -- saidas
    pcsrc       <= cond_taken or BrIncond;
    take_cond   <= cond_taken;
    take_uncond <= BrIncond;

end TypeArchitecture;