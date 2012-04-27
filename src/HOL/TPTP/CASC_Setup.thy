(*  Title:      HOL/TPTP/CASC_Setup.thy
    Author:     Jasmin Blanchette
    Copyright   2011

Setup for Isabelle, Nitpick, and Refute for participating at CASC in the THF and
TNT divisions. This theory file should be loaded by the Isabelle theory files
generated by Geoff Sutcliffe's TPTP2X tool from the original THF0 files.
*)

theory CASC_Setup
imports Complex_Main
uses "sledgehammer_tactics.ML"
begin

consts
  is_int :: "'a \<Rightarrow> bool"
  is_rat :: "'a \<Rightarrow> bool"

overloading rat_is_int \<equiv> "is_int :: rat \<Rightarrow> bool"
begin
  definition "rat_is_int (q\<Colon>rat) \<longleftrightarrow> (\<exists>n\<Colon>int. q = of_int n)"
end

overloading real_is_int \<equiv> "is_int :: real \<Rightarrow> bool"
begin
  definition "real_is_int (x\<Colon>real) \<longleftrightarrow> x \<in> \<int>"
end

overloading real_is_rat \<equiv> "is_rat :: real \<Rightarrow> bool"
begin
  definition "real_is_rat (x\<Colon>real) \<longleftrightarrow> x \<in> \<rat>"
end

consts
  to_int :: "'a \<Rightarrow> int"
  to_rat :: "'a \<Rightarrow> rat"
  to_real :: "'a \<Rightarrow> real"

overloading rat_to_int \<equiv> "to_int :: rat \<Rightarrow> int"
begin
  definition "rat_to_int (q\<Colon>rat) = floor q"
end

overloading real_to_int \<equiv> "to_int :: real \<Rightarrow> int"
begin
  definition "real_to_int (x\<Colon>real) = floor x"
end

overloading int_to_rat \<equiv> "to_rat :: int \<Rightarrow> rat"
begin
  definition "int_to_rat (n\<Colon>int) = (of_int n\<Colon>rat)"
end

overloading real_to_rat \<equiv> "to_rat :: real \<Rightarrow> rat"
begin
  definition "real_to_rat (x\<Colon>real) = (inv real x\<Colon>rat)"
end

overloading int_to_real \<equiv> "to_real :: int \<Rightarrow> real"
begin
  definition "int_to_real (n\<Colon>int) = real n"
end

overloading rat_to_real \<equiv> "to_real :: rat \<Rightarrow> real"
begin
  definition "rat_to_real (x\<Colon>rat) = (of_rat x\<Colon>real)"
end

declare
  rat_is_int_def [simp]
  real_is_int_def [simp]
  real_is_rat_def [simp]
  rat_to_int_def [simp]
  real_to_int_def [simp]
  int_to_rat_def [simp]
  real_to_rat_def [simp]
  int_to_real_def [simp]
  rat_to_real_def [simp]

lemma to_rat_is_int [intro, simp]: "is_int (to_rat (n\<Colon>int))"
by (metis int_to_rat_def rat_is_int_def)

lemma to_real_is_int [intro, simp]: "is_int (to_real (n\<Colon>int))"
by (metis Ints_real_of_int int_to_real_def real_is_int_def)

lemma to_real_is_rat [intro, simp]: "is_rat (to_real (q\<Colon>rat))"
by (metis Rats_of_rat rat_to_real_def real_is_rat_def)

lemma inj_of_rat [intro, simp]: "inj (of_rat\<Colon>rat\<Rightarrow>real)"
by (metis injI of_rat_eq_iff rat_to_real_def)

declare [[smt_oracle]]

refute_params [maxtime = 10000, no_assms, expect = genuine]
nitpick_params [timeout = none, card = 1-50, verbose, dont_box, no_assms,
                batch_size = 1, expect = genuine]

ML {* Proofterm.proofs := 0 *}

ML {*
fun SOLVE_TIMEOUT seconds name tac st =
  let
    val result =
      TimeLimit.timeLimit (Time.fromSeconds seconds)
        (fn () => SINGLE (SOLVE tac) st) ()
      handle TimeLimit.TimeOut => NONE
        | ERROR _ => NONE
  in
    (case result of
      NONE => (warning ("FAILURE: " ^ name); Seq.empty)
    | SOME st' => (warning ("SUCCESS: " ^ name); Seq.single st'))
  end
*}

ML {*
fun isabellep_tac ctxt max_secs =
   SOLVE_TIMEOUT (max_secs div 10) "smt" (ALLGOALS (SMT_Solver.smt_tac ctxt []))
   ORELSE
   SOLVE_TIMEOUT (max_secs div 5) "sledgehammer"
       (ALLGOALS (Sledgehammer_Tactics.sledgehammer_as_oracle_tac ctxt []
                      Sledgehammer_Filter.no_relevance_override))
   ORELSE
   SOLVE_TIMEOUT (max_secs div 10) "simp" (ALLGOALS (asm_full_simp_tac (simpset_of ctxt)))
   ORELSE
   SOLVE_TIMEOUT (max_secs div 20) "blast" (ALLGOALS (blast_tac ctxt))
   ORELSE
   SOLVE_TIMEOUT (max_secs div 10) "auto" (auto_tac ctxt
       THEN ALLGOALS (Sledgehammer_Tactics.sledgehammer_as_oracle_tac ctxt []
                          Sledgehammer_Filter.no_relevance_override))
   ORELSE
   SOLVE_TIMEOUT (max_secs div 10) "metis"
       (ALLGOALS (Metis_Tactic.metis_tac [] ATP_Problem_Generate.liftingN ctxt []))
   ORELSE
   SOLVE_TIMEOUT (max_secs div 10) "fast" (ALLGOALS (fast_tac ctxt))
   ORELSE
   SOLVE_TIMEOUT (max_secs div 20) "best" (ALLGOALS (best_tac ctxt))
   ORELSE
   SOLVE_TIMEOUT (max_secs div 20) "arith" (ALLGOALS (Arith_Data.arith_tac ctxt))
   ORELSE
   SOLVE_TIMEOUT (max_secs div 10) "force" (ALLGOALS (force_tac ctxt))
   ORELSE
   SOLVE_TIMEOUT max_secs "fastforce" (ALLGOALS (fast_force_tac ctxt))
*}

method_setup isabellep = {*
  Scan.lift (Scan.optional Parse.nat 6000) >>
    (fn m => fn ctxt => SIMPLE_METHOD (isabellep_tac ctxt m))
*} "combination of Isabelle provers and oracles for CASC"

end
