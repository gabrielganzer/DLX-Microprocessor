library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.globals.all;
use work.all;

entity datapath is
  port (
  -- inputs
    -- control signals
    clk     : in  std_logic;  -- clock
    rst     : in  std_logic;  -- reset: active-low
    -- stage 1
    en0     : in  std_logic;
    ir      : in  std_logic_vector(instruction_size - 1 downto 0);
    pc_in   : in  std_logic_vector(word_size - 1 downto 0);
    -- stage 2
    en1     : in  std_logic;  -- enables the register file and the pipeline registers
    rf1     : in  std_logic;  -- enables the read port 1 of the register file
    rf2     : in  std_logic;  -- enables the read port 2 of the register file
    -- stage 3
    en2     : in  std_logic;  -- enables the pipe registers
    s1      : in  std_logic;  -- input selection of the first multiplexer
    s2      : in  std_logic;  -- input selection of the second multiplexer
    alu1    : in  std_logic;  -- alu control bit 1
    alu2    : in  std_logic;  -- alu control bit 2
    alu3    : in  std_logic;  -- alu control bit 3
    alu4    : in  std_logic;  -- alu control bit 4
    eq_cond : in  std_logic;
    jump_en : in  std_logic;
    -- stage 4
    en3     : in  std_logic;  -- enables the dram and the pipeline register
    rw      : in  std_logic;  -- enables the read-out (1) or the write-in (0) of the memory
    den     : in  std_logic;
    dram_data_in    : in std_logic_vector(word_size - 1 downto 0);      -- from dram output
    dram_rw_en      : out std_logic;
    dram_enable     : out std_logic;
    dram_data_out   : out  std_logic_vector(word_size - 1 downto 0);      -- from dram output
    dram_addr       : out std_logic_vector(dram_addr_size - 1 downto 0); -- to dram address
    -- dram_wr_data : out std_logic_vector(word_size - 1 downto 0);      -- to dram input
    pc_out          : out std_logic_vector(word_size - 1 downto 0);
    -- stage 5
    s3    : in  std_logic;  -- input selection of the multiplexer
    wf1   : in  std_logic   -- enables the write port of the register ﬁle
  );
end entity; -- datapath

architecture structural of datapath is

  component alu is
    generic(nbit : integer := 32);
    port (
      a, b      : in  std_logic_vector(nbit - 1 downto 0); -- operands
      unit_sel  : in  std_logic_vector(3 downto 0);     -- ALU's unit selector
      y         : out std_logic_vector(nbit - 1 downto 0) -- operation result
    );
  end component;

  component rca_n is
    generic(n : integer := 1);
    port(
      a, b  : in  std_logic_vector(n - 1 downto 0);
      c_in  : in  std_logic;
      sum   : out std_logic_vector(n - 1 downto 0);
      c_out : out std_logic
    );
  end component;

  component register_file is
    generic (n : natural := 32);
    port (
      -- inputs
      clk     : in  std_logic;
      reset   : in  std_logic;
      enable  : in  std_logic;
      rd1     : in  std_logic;
      rd2     : in  std_logic;
      wr      : in  std_logic;
      add_wr  : in  std_logic_vector(4 downto 0);
      add_rd1 : in  std_logic_vector(4 downto 0);
      add_rd2 : in  std_logic_vector(4 downto 0);
      datain  : in  std_logic_vector(word_size - 1 downto 0);
      -- outputs
      out1    : out std_logic_vector(word_size - 1 downto 0);
      out2    : out std_logic_vector(word_size - 1 downto 0)
    );
  end component;

  component mux21_generic is
    generic(n : integer := 1);
    port (
      a   : in  std_logic_vector(n - 1 downto 0);
      b   : in  std_logic_vector(n - 1 downto 0);
      sel : in  std_logic;
      y   : out std_logic_vector(n - 1 downto 0)
    );
  end component;

  component ffd_async is
    port (
  		clk   :	in	std_logic;
  		reset :	in	std_logic;
  		en 		: in  std_logic;
  		d     : in	std_logic;
  		q     : out	std_logic
  	);
  end component;

  component reg_n is
    generic(n : integer := 1);
    port (
      clock  : in  std_logic;
      reset  : in  std_logic;
      enable : in  std_logic;
      x      : in  std_logic_vector (n - 1 downto 0);
      y      : out std_logic_vector (n - 1 downto 0)
    );
  end component; -- reg_n

  component zero_comp is
    generic(n : integer := 1);
    port (
      x : in  std_logic_vector (n - 1 downto 0);
      y : out std_logic
    );
  end component; -- zero_comp

  component sign_extension is
    generic(s : integer := 2; f : integer := 3);
    port(
      x : in  std_logic_vector(s - 1 downto 0);
      y : out std_logic_vector(f - 1 downto 0)
    );
  end component; -- end sign_extension

  component and_2 is
    port(
      a, b : in  std_logic;
      y    : out std_logic
    );
  end component;

  component xor_2 is
    port(
      a, b : in  std_logic;
      y    : out std_logic
    );
  end component;

  -- signals stage 1
  constant c4    : std_logic_vector (3 downto 0) := X"1";
  signal four    : std_logic_vector (word_size - 1 downto 0) := (others => '0');
  -- signal next_pc : std_logic_vector (word_size - 1 downto 0); -- Adder output
  signal npc     : std_logic_vector (word_size - 1 downto 0); -- Adder output delayed
  signal ir_st1  : std_logic_vector (word_size - 1 downto 0);

  -- signals stage 2
  signal data_out, rf_out1, rf_out2, out_a, out_b, inp2_32, imm_st2 : std_logic_vector(word_size - 1 downto 0);
  signal rd1, rd2, rd : std_logic_vector(add_size - 1 downto 0);
  signal inp2         : std_logic_vector(inp2_up downto 0);
  signal out_rd1      : std_logic_vector(add_size - 1 downto 0);

  -- signals stage 3
  signal out_mux1, out_mux2, out_alu, alu_st3, out_me : std_logic_vector(word_size - 1 downto 0);
  signal out_rd2  : std_logic_vector(add_size - 1 downto 0);
  signal alu_bit  : std_logic_vector(3 downto 0);
  signal z, cond_xor, cond : std_logic; -- zero comparator output

  -- signals stage 4
  signal alu_st4, out_dram, dram_rd_data : std_logic_vector(word_size - 1 downto 0);
  signal out_rd3 : std_logic_vector(add_size - 1 downto 0);

  -- signals stage 5
  signal wb : std_logic_vector(word_size - 1 downto 0);

  -- signals to delay the control word
  -- stage 1->2
  signal en1_st1  : std_logic;

  signal en2_st1  : std_logic;
  signal  s1_st1  : std_logic;
  signal  s2_st1  : std_logic;

  signal alu1_st1 : std_logic;
  signal alu2_st1 : std_logic;
  signal alu3_st1 : std_logic;
  signal alu4_st1 : std_logic;
  signal eq_cond_st1 : std_logic;
  signal jump_en_st1 : std_logic;

  signal en3_st1  : std_logic;
  signal  rw_st1  : std_logic;
  signal den_st1  : std_logic;

  signal  s3_st1  : std_logic;
  signal wf1_st1  : std_logic;

  -- stage 2->3
  signal en2_st2  : std_logic;
  signal  s1_st2  : std_logic;
  signal  s2_st2  : std_logic;

  signal alu1_st2 : std_logic;
  signal alu2_st2 : std_logic;
  signal alu3_st2 : std_logic;
  signal alu4_st2 : std_logic;
  signal eq_cond_st2 : std_logic;
  signal jump_en_st2 : std_logic;

  signal en3_st2  : std_logic;
  signal  rw_st2  : std_logic;
  signal den_st2  : std_logic;

  signal  s3_st2  : std_logic;
  signal wf1_st2  : std_logic;

  -- stage 3->4
  signal en3_st3  : std_logic;
  signal  rw_st3  : std_logic;
  signal den_st3  : std_logic;

  signal  s3_st3  : std_logic;
  signal wf1_st3  : std_logic;

  -- stage 4->5
  signal  s3_st4  : std_logic;
  signal wf1_st4  : std_logic;


begin

-----------------------------------------------------------------------------------------
-- stage 1
-----------------------------------------------------------------------------------------

  ir_ff : reg_n
  generic map (instruction_size)
  port map (clk, rst, en0, ir, ir_st1);

  four(3 downto 0) <=  c4;

  pc_add : rca_n
  generic map (word_size)
  port map (pc_in, four, '0', npc);
  -- port map (pc_in, four, '0', next_pc);

  -- npc_reg : reg_n
  -- generic map (word_size)
  -- port map (clk, rst, '1', next_pc, npc);

-----------------------------------------------------------------------------------------
-- stage 2
-----------------------------------------------------------------------------------------

  reg_assign : process(ir_st1)
  begin
    if ir_st1(opcode_up downto opcode_down) = RTYPE then
      rd1  <= ir_st1(r1_up downto r1_down);
      rd2  <= ir_st1(r2_up downto r2_down);
      rd   <= ir_st1(r3_up downto r3_down);
      inp2 <= (others => '0');
    elsif ir_st1(opcode_up downto opcode_down) = I_SW then
      rd1  <= ir_st1(r1_up downto r1_down);
      rd2  <= ir_st1(r2_up downto r2_down);
      rd   <= (others => '0');
      inp2 <= ir_st1(inp2_up downto inp2_down);
    else
      rd1  <= ir_st1(r1_up downto r1_down);
      rd   <= ir_st1(r2_up downto r2_down);
      rd2  <= (others => '0');
      inp2 <= ir_st1(inp2_up downto inp2_down);
    end if;
  end process; -- end reg_assign

  rf : register_file
  generic map (word_size)
  port map(clk, rst, en1, rf1, rf2, wf1_st4, out_rd3, rd1, rd2, wb, rf_out1, rf_out2);

  a : reg_n
  generic map(word_size)
  port map(clk, rst, en1, rf_out1, out_a);

  b : reg_n
  generic map(word_size)
  port map(clk, rst, en1, rf_out2, out_b);

  -- sign extension of immediate (16 to 32 bits)
  ext : sign_extension
  generic map(16, word_size)
  port map(inp2, inp2_32);

  in2 : reg_n
  generic map(word_size)
  port map(clk, rst, en1_st1, inp2_32, imm_st2);

  rd_1 : reg_n
  generic map(add_size)
  port map(clk, rst, en1_st1, rd, out_rd1);

-----------------------------------------------------------------------------------------
-- stage 3
-----------------------------------------------------------------------------------------
  alu_bit <= alu1_st2 & alu2_st2 & alu3_st2 & alu4_st2;

  cmp : zero_comp
  generic map(word_size)
  port map(out_a, z);

  eq_xor : xor_2
  port map(z, eq_cond_st2, cond_xor);

  and_j : and_2
  port map(cond_xor, jump_en_st2, cond);

  mux1_alu : mux21_generic
  generic map(word_size)
  port map(npc, out_a, s1_st2, out_mux1);

  mux2_alu : mux21_generic
  generic map(word_size)
  port map(out_b, imm_st2, s2_st2, out_mux2);

  arith_log_un : alu
  generic map(word_size)
  port map(out_mux1, out_mux2, alu_bit, out_alu);

  alu_out : reg_n
  generic map(word_size)
  port map(clk, rst, en2_st2, out_alu, alu_st3);

  me : reg_n
  generic map(word_size)
  port map(clk, rst, en2_st2, out_b, out_me);

  rd_2 : reg_n
  generic map(add_size)
  port map(clk, rst, en2_st2, out_rd1, out_rd2);

-----------------------------------------------------------------------------------------
-- stage 4
-----------------------------------------------------------------------------------------

  mux_j : mux21_generic
  generic map(word_size)
  port map(npc, alu_st3, cond, pc_out);

  dram_addr    <= alu_st3;
  dram_data_out <= out_me;
  dram_rd_data <= dram_data_in;

  --DRAM_inout : process(rw_st3, den_st3)
  --begin
  --  if den_st3 = '1' then
  --    if rw_st3 = '0' then  -- write
  --
  --    else                  -- read
  --
  --    end if; -- end if rw_st3 = '0' and den_st3 = '1'
  --  end if; -- end if den_st3 = '1'
  --end process; -- DRAM_inout
  ---- dram_wr_data <= out_me;

  dram_enable <= den_st3;
  dram_rw_en  <= rw_st3;

  out_value : reg_n
  generic map(word_size)
  port map(clk, rst, en3_st3, alu_st3, alu_st4);

  lmd : reg_n
  generic map(word_size)
  port map(clk, rst, en3_st3, dram_rd_data, out_dram);

  rd_3 : reg_n
  generic map(add_size)
  port map(clk, rst, en3_st3, out_rd2, out_rd3);

-----------------------------------------------------------------------------------------
-- stage 5
-----------------------------------------------------------------------------------------
  mux_out_sel : mux21_generic
  generic map(word_size)
  port map(out_dram, alu_st4, s3_st4, wb);

-----------------------------------------------------------------------------------------

  -- FFs to delay the control word that arrives from the CU
  -- stage 1 -> 2
  --  en1_cw1  :  ffd_async
  -- port map(clk, rst, '1', en1, en1_st1);
  --  rf1_cw1  :  ffd_async
  -- port map(clk, rst, '1', rf1, rf1_st1);
  --  rf2_cw1  :  ffd_async
  -- port map(clk, rst, '1', rf2, rf2_st1);

   en2_cw1  :  ffd_async
  port map(clk, rst, '1', en2, en2_st1);
    s1_cw1  :  ffd_async
  port map(clk, rst, '1', s1, s1_st1);
    s2_cw1  :  ffd_async
  port map(clk, rst, '1', s2, s2_st1);

  alu1_cw1  :  ffd_async
  port map(clk, rst, '1', alu1, alu1_st1);
  alu2_cw1  :  ffd_async
  port map(clk, rst, '1', alu2, alu2_st1);
  alu3_cw1  :  ffd_async
  port map(clk, rst, '1', alu3, alu3_st1);
  alu4_cw1  :  ffd_async
  port map(clk, rst, '1', alu4, alu4_st1);
  eq_cond_cw1  :  ffd_async
  port map(clk, rst, '1', eq_cond, eq_cond_st1);
  jump_en_cw1  :  ffd_async
  port map(clk, rst, '1', jump_en, jump_en_st1);

   en3_cw1  :  ffd_async
  port map(clk, rst, '1', en3, en3_st1);
    rw_cw1  :  ffd_async
  port map(clk, rst, '1', rw, rw_st1);
   den_cw1  :  ffd_async
  port map(clk, rst, '1', den, den_st1);

    s3_cw1  :  ffd_async
  port map(clk, rst, '1', s3, s3_st1);
   wf1_cw1  :  ffd_async
  port map(clk, rst, '1', wf1, wf1_st1);

   -- stage 2 -> 3
   en2_cw2  :  ffd_async
  port map(clk, rst, '1', en2_st1, en2_st2);
    s1_cw2  :  ffd_async
  port map(clk, rst, '1', s1_st1, s1_st2);
    s2_cw2  :  ffd_async
  port map(clk, rst, '1', s2_st1, s2_st2);

  alu1_cw2  :  ffd_async
  port map(clk, rst, '1', alu1_st1, alu1_st2);
  alu2_cw2  :  ffd_async
  port map(clk, rst, '1', alu2_st1, alu2_st2);
  alu3_cw2  :  ffd_async
  port map(clk, rst, '1', alu3_st1, alu3_st2);
  alu4_cw2  :  ffd_async
  port map(clk, rst, '1', alu4_st1, alu4_st2);
  eq_cond_cw2  :  ffd_async
  port map(clk, rst, '1', eq_cond_st1, eq_cond_st2);
  jump_en_cw2  :  ffd_async
  port map(clk, rst, '1', jump_en_st1, jump_en_st2);

   en3_cw2  :  ffd_async
  port map(clk, rst, '1', en3_st1, en3_st2);
    rw_cw2  :  ffd_async
  port map(clk, rst, '1', rw_st1, rw_st2);
   den_cw2  :  ffd_async
  port map(clk, rst, '1', den_st1, den_st2);

    s3_cw2  :  ffd_async
  port map(clk, rst, '1', s3_st1, s3_st2);
   wf1_cw2  :  ffd_async
  port map(clk, rst, '1', wf1_st1, wf1_st2);

   -- stage 3 -> 4
   en3_cw3  :  ffd_async
  port map(clk, rst, '1', en3_st2, en3_st3);
    rw_cw3  :  ffd_async
  port map(clk, rst, '1', rw_st2, rw_st3);
   den_cw3  :  ffd_async
  port map(clk, rst, '1', den_st2, den_st3);

    s3_cw3  :  ffd_async
  port map(clk, rst, '1', s3_st2, s3_st3);
   wf1_cw3  :  ffd_async
  port map(clk, rst, '1', wf1_st2, wf1_st3);

   -- stage 4 -> 5
    s3_cw4  :  ffd_async
  port map(clk, rst, '1', s3_st3, s3_st4);
   wf1_cw4  :  ffd_async
  port map(clk, rst, '1', wf1_st3, wf1_st4);

end architecture; -- structural
