(*  ID:         $Id$
    Author:     Klaus Aehlig, Tobias Nipkow
    Work in progress
*)

theory NBE imports Main Executable_Set begin

ML"set quick_and_dirty"

declare Let_def[simp]

consts_code undefined ("(raise Match)")

(*typedecl const_name*)
types lam_var_name = nat
      ml_var_name = nat
      const_name = nat

datatype tm = Ct const_name | Vt lam_var_name | Lam tm | At tm tm
            | term_of ml (* function 'to_term' *)
and ml = (* rep of universal datatype *)
          C const_name "ml list" | V lam_var_name "ml list"
        | Fun ml "ml list" nat
        | "apply" ml ml (* function 'apply' *)
          (* ML *)
        | V_ML ml_var_name | A_ML ml "ml list" | Lam_ML ml
        | CC const_name (* ref to compiled code *)

lemma [simp]: "x \<in> set vs \<Longrightarrow> size x < Suc (ml_list_size1 vs)"
by (induct vs) auto
lemma [simp]: "x \<in> set vs \<Longrightarrow> size x < Suc (ml_list_size2 vs)"
by (induct vs) auto
lemma [simp]:"x \<in> set vs \<Longrightarrow> size x < Suc (size v + ml_list_size3 vs)"
by (induct vs) auto
lemma [simp]: "x \<in> set vs \<Longrightarrow> size x < Suc (size v + ml_list_size4 vs)"
by (induct vs) auto

locale Vars =
 fixes r s t:: tm
 and rs ss ts :: "tm list"
 and u v w :: ml
 and us vs ws :: "ml list"
 and nm :: const_name
 and x :: lam_var_name
 and X :: ml_var_name

inductive_set Pure_tms :: "tm set"
where
  "Ct s : Pure_tms"
| "Vt x : Pure_tms"
| "t : Pure_tms ==> Lam t : Pure_tms"
| "s : Pure_tms ==> t : Pure_tms ==> At s t : Pure_tms"

consts
  R :: "(const_name * tm list * tm)set" (* reduction rules *)
  compR :: "(const_name * ml list * ml)set" (* compiled reduction rules *)

fun
  lift_tm :: "nat \<Rightarrow> tm \<Rightarrow> tm" ("lift") and
  lift_ml :: "nat \<Rightarrow> ml \<Rightarrow> ml" ("lift")
where
"lift i (Ct nm) = Ct nm" |
"lift i (Vt x) = Vt(if x < i then x else x+1)" |
"lift i (Lam t) = Lam (lift (i+1) t)" |
"lift i (At s t) = At (lift i s) (lift i t)" |
"lift i (term_of v) = term_of (lift i v)" |

"lift i (C nm vs) = C nm (map (lift i) vs)" |
"lift i (V x vs) = V (if x < i then x else x+1) (map (lift i) vs)" |
"lift i (Fun v vs n) = Fun (lift i v) (map (lift i) vs) n" |
"lift i (apply u v) = apply (lift i u) (lift i v)" |
"lift i (V_ML X) = V_ML X" |
"lift i (A_ML v vs) = A_ML (lift i v) (map (lift i) vs)" |
"lift i (Lam_ML v) = Lam_ML (lift i v)" |
"lift i (CC nm) = CC nm"
(*
termination
apply (relation "measure (sum_case (%(i,t). size t) (%(i,v). size v))")
apply auto
*)

fun
  lift_tm_ML :: "nat \<Rightarrow> tm \<Rightarrow> tm" ("lift\<^bsub>ML\<^esub>") and
  lift_ml_ML :: "nat \<Rightarrow> ml \<Rightarrow> ml" ("lift\<^bsub>ML\<^esub>")
where
"lift\<^bsub>ML\<^esub> i (Ct nm) = Ct nm" |
"lift\<^bsub>ML\<^esub> i (Vt x) = Vt x" |
"lift\<^bsub>ML\<^esub> i (Lam t) = Lam (lift\<^bsub>ML\<^esub> i t)" |
"lift\<^bsub>ML\<^esub> i (At s t) = At (lift\<^bsub>ML\<^esub> i s) (lift\<^bsub>ML\<^esub> i t)" |
"lift\<^bsub>ML\<^esub> i (term_of v) = term_of (lift\<^bsub>ML\<^esub> i v)" |

"lift\<^bsub>ML\<^esub> i (C nm vs) = C nm (map (lift\<^bsub>ML\<^esub> i) vs)" |
"lift\<^bsub>ML\<^esub> i (V x vs) = V x (map (lift\<^bsub>ML\<^esub> i) vs)" |
"lift\<^bsub>ML\<^esub> i (Fun v vs n) = Fun (lift\<^bsub>ML\<^esub> i v) (map (lift\<^bsub>ML\<^esub> i) vs) n" |
"lift\<^bsub>ML\<^esub> i (apply u v) = apply (lift\<^bsub>ML\<^esub> i u) (lift\<^bsub>ML\<^esub> i v)" |
"lift\<^bsub>ML\<^esub> i (V_ML X) = V_ML (if X < i then X else X+1)" |
"lift\<^bsub>ML\<^esub> i (A_ML v vs) = A_ML (lift\<^bsub>ML\<^esub> i v) (map (lift\<^bsub>ML\<^esub> i) vs)" |
"lift\<^bsub>ML\<^esub> i (Lam_ML v) = Lam_ML (lift\<^bsub>ML\<^esub> (i+1) v)" |
"lift\<^bsub>ML\<^esub> i (CC nm) = CC nm"
(*
termination
  by (relation "measure (sum_case (%(i,t). size t) (%(i,v). size v))") auto
*)
constdefs
 cons :: "tm \<Rightarrow> (nat \<Rightarrow> tm) \<Rightarrow> (nat \<Rightarrow> tm)" (infix "##" 65)
"t##f \<equiv> \<lambda>i. case i of 0 \<Rightarrow> t | Suc j \<Rightarrow> lift 0 (f j)"
 cons_ML :: "ml \<Rightarrow> (nat \<Rightarrow> ml) \<Rightarrow> (nat \<Rightarrow> ml)" (infix "##" 65)
"v##f \<equiv> \<lambda>i. case i of 0 \<Rightarrow> v::ml | Suc j \<Rightarrow> lift\<^bsub>ML\<^esub> 0 (f j)"

(* Only for pure terms! *)
consts subst :: "(nat \<Rightarrow> tm) \<Rightarrow> tm \<Rightarrow> tm"
primrec
"subst f (Ct nm) = Ct nm"
"subst f (Vt x) = f x"
"subst f (Lam t) = Lam (subst (Vt 0 ## f) t)"
"subst f (At s t) = At (subst f s) (subst f t)"

lemma size_lift[simp]: shows
 "size(lift i t) = size(t::tm)" and "size(lift i (v::ml)) = size v"
and "ml_list_size1 (map (lift i) vs) = ml_list_size1 vs"
and "ml_list_size2 (map (lift i) vs) = ml_list_size2 vs"
and "ml_list_size3 (map (lift i) vs) = ml_list_size3 vs"
and "ml_list_size4 (map (lift i) vs) = ml_list_size4 vs"
by (induct arbitrary: i and i and i and i and i and i rule: tm_ml.inducts)
   simp_all

lemma size_lift_ML[simp]: shows
 "size(lift\<^bsub>ML\<^esub> i t) = size(t::tm)" and "size(lift\<^bsub>ML\<^esub> i (v::ml)) = size v"
and "ml_list_size1 (map (lift\<^bsub>ML\<^esub> i) vs) = ml_list_size1 vs"
and "ml_list_size2 (map (lift\<^bsub>ML\<^esub> i) vs) = ml_list_size2 vs"
and "ml_list_size3 (map (lift\<^bsub>ML\<^esub> i) vs) = ml_list_size3 vs"
and "ml_list_size4 (map (lift\<^bsub>ML\<^esub> i) vs) = ml_list_size4 vs"
by (induct arbitrary: i and i and i and i and i and i rule: tm_ml.inducts)
   simp_all

fun
  subst_ml_ML :: "(nat \<Rightarrow> ml) \<Rightarrow> ml \<Rightarrow> ml" ("subst\<^bsub>ML\<^esub>") and
  subst_tm_ML :: "(nat \<Rightarrow> ml) \<Rightarrow> tm \<Rightarrow> tm" ("subst\<^bsub>ML\<^esub>")
where
"subst\<^bsub>ML\<^esub> f (Ct nm) = Ct nm" |
"subst\<^bsub>ML\<^esub> f (Vt x) = Vt x" |
"subst\<^bsub>ML\<^esub> f (Lam t) = Lam (subst\<^bsub>ML\<^esub> (lift 0 o f) t)" |
"subst\<^bsub>ML\<^esub> f (At s t) = At (subst\<^bsub>ML\<^esub> f s) (subst\<^bsub>ML\<^esub> f t)" |
"subst\<^bsub>ML\<^esub> f (term_of v) = term_of (subst\<^bsub>ML\<^esub> f v)" |

"subst\<^bsub>ML\<^esub> f (C nm vs) = C nm (map (subst\<^bsub>ML\<^esub> f) vs)" |
"subst\<^bsub>ML\<^esub> f (V x vs) = V x (map (subst\<^bsub>ML\<^esub> f) vs)" |
"subst\<^bsub>ML\<^esub> f (Fun v vs n) = Fun (subst\<^bsub>ML\<^esub> f v) (map (subst\<^bsub>ML\<^esub> f) vs) n" |
"subst\<^bsub>ML\<^esub> f (apply u v) = apply (subst\<^bsub>ML\<^esub> f u) (subst\<^bsub>ML\<^esub> f v)" |
"subst\<^bsub>ML\<^esub> f (V_ML X) = f X" |
"subst\<^bsub>ML\<^esub> f (A_ML v vs) = A_ML (subst\<^bsub>ML\<^esub> f v) (map (subst\<^bsub>ML\<^esub> f) vs)" |
"subst\<^bsub>ML\<^esub> f (Lam_ML v) = Lam_ML (subst\<^bsub>ML\<^esub> (V_ML 0 ## f) v)" |
"subst\<^bsub>ML\<^esub> f (CC nm) = CC nm"

(* FIXME currrently needed for code generator *)
lemmas [code] = lift_tm_ML.simps lift_ml_ML.simps
lemmas [code] = lift_tm.simps lift_ml.simps
lemmas [code] = subst_tm_ML.simps subst_ml_ML.simps

abbreviation
  subst_decr :: "nat \<Rightarrow> tm \<Rightarrow> nat \<Rightarrow> tm" where
 "subst_decr k t == %n. if n<k then Vt n else if n=k then t else Vt(n - 1)"
abbreviation
  subst_decr_ML :: "nat \<Rightarrow> ml \<Rightarrow> nat \<Rightarrow> ml" where
 "subst_decr_ML k v == %n. if n<k then V_ML n else if n=k then v else V_ML(n - 1)"
abbreviation
  subst1 :: "tm \<Rightarrow> tm \<Rightarrow> nat \<Rightarrow> tm" ("(_/[_'/_])" [300, 0, 0] 300) where
 "s[t/k] == subst (subst_decr k t) s"
abbreviation
  subst1_ML :: "ml \<Rightarrow> ml \<Rightarrow> nat \<Rightarrow> ml" ("(_/[_'/_])" [300, 0, 0] 300) where
 "u[v/k] == subst\<^bsub>ML\<^esub> (subst_decr_ML k v) u"


lemma size_subst_ML[simp]: shows 
 "(!x. size(f x) = 0) \<longrightarrow> size(subst\<^bsub>ML\<^esub> f t) = size(t::tm)" and
"(!x. size(f x) = 0) \<longrightarrow> size(subst\<^bsub>ML\<^esub> f (v::ml)) = size v"
and "(!x. size(f x) = 0) \<longrightarrow> ml_list_size1 (map (subst\<^bsub>ML\<^esub> f) vs) = ml_list_size1 vs"
and "(!x. size(f x) = 0) \<longrightarrow> ml_list_size2 (map (subst\<^bsub>ML\<^esub> f) vs) = ml_list_size2 vs"
and "(!x. size(f x) = 0) \<longrightarrow> ml_list_size3 (map (subst\<^bsub>ML\<^esub> f) vs) = ml_list_size3 vs"
and "(!x. size(f x) = 0) \<longrightarrow> ml_list_size4 (map (subst\<^bsub>ML\<^esub> f) vs) = ml_list_size4 vs"
apply (induct arbitrary: f and f and f and f and f and f rule: tm_ml.inducts)
apply (simp_all add:cons_ML_def split:nat.split)
done

lemma lift_lift: includes Vars shows
    "i < k+1 \<Longrightarrow> lift (Suc k) (lift i t) = lift i (lift k t)"
and "i < k+1 \<Longrightarrow> lift (Suc k) (lift i v) = lift i (lift k v)"
apply(induct t and v arbitrary: i and i rule:lift_tm_lift_ml.induct)
apply(simp_all add:map_compose[symmetric])
done

corollary lift_o_lift: shows
 "i < k+1 \<Longrightarrow> lift_tm (Suc k) o (lift_tm i) = lift_tm i o lift_tm k" and
 "i < k+1 \<Longrightarrow> lift_ml (Suc k) o (lift_ml i) = lift_ml i o lift_ml k"
by(rule ext, simp add:lift_lift)+

lemma lift_lift_ML: includes Vars shows
    "i < k+1 \<Longrightarrow> lift\<^bsub>ML\<^esub> (Suc k) (lift\<^bsub>ML\<^esub> i t) = lift\<^bsub>ML\<^esub> i (lift\<^bsub>ML\<^esub> k t)"
and "i < k+1 \<Longrightarrow> lift\<^bsub>ML\<^esub> (Suc k) (lift\<^bsub>ML\<^esub> i v) = lift\<^bsub>ML\<^esub> i (lift\<^bsub>ML\<^esub> k v)"
apply(induct t and v arbitrary: i and i rule:lift_tm_ML_lift_ml_ML.induct)
apply(simp_all add:map_compose[symmetric])
done


lemma lift_lift_ML_comm: includes Vars shows
 "lift j (lift\<^bsub>ML\<^esub> i t) = lift\<^bsub>ML\<^esub> i (lift j t)" and
 "lift j (lift\<^bsub>ML\<^esub> i v) = lift\<^bsub>ML\<^esub> i (lift j v)"
apply(induct t and v arbitrary: i j and i j rule:lift_tm_ML_lift_ml_ML.induct)
apply(simp_all add:map_compose[symmetric])
done

lemma [simp]:
 "V_ML 0 ## subst_decr_ML k v = subst_decr_ML (Suc k) (lift\<^bsub>ML\<^esub> 0 v)"
by(rule ext)(simp add:cons_ML_def split:nat.split)

lemma [simp]: "lift 0 o subst_decr_ML k v = subst_decr_ML k (lift 0 v)"
by(rule ext)(simp add:cons_ML_def split:nat.split)

lemma subst_lift_id[simp]: includes Vars shows
 "subst\<^bsub>ML\<^esub> (subst_decr_ML k v) (lift\<^bsub>ML\<^esub> k t) = t" and "(lift\<^bsub>ML\<^esub> k u)[v/k] = u"
apply(induct k t and k u arbitrary: v and v rule: lift_tm_ML_lift_ml_ML.induct)
apply (simp_all add:map_idI map_compose[symmetric])
apply (simp cong:if_cong)
done

inductive_set
  tRed :: "(tm * tm)set" (* beta + R reduction on pure terms *)
  and tred :: "[tm, tm] => bool"  (infixl "\<rightarrow>" 50)
where
  "s \<rightarrow> t == (s, t) \<in> tRed"
| "At (Lam t) s \<rightarrow> t[s/0]"
| "(nm,ts,t) : R ==> foldl At (Ct nm) (map (subst rs) ts) \<rightarrow> subst rs t"
| "t \<rightarrow> t' ==> Lam t \<rightarrow> Lam t'"
| "s \<rightarrow> s' ==> At s t \<rightarrow> At s' t"
| "t \<rightarrow> t' ==> At s t \<rightarrow> At s t'"

abbreviation
  treds :: "[tm, tm] => bool"  (infixl "\<rightarrow>*" 50) where
  "s \<rightarrow>* t == (s, t) \<in> tRed^*"

inductive_set
  tRed_list :: "(tm list * tm list) set"
  and treds_list :: "[tm list, tm list] \<Rightarrow> bool" (infixl "\<rightarrow>*" 50)
where
  "ss \<rightarrow>* ts == (ss, ts) \<in> tRed_list"
| "[] \<rightarrow>* []"
| "ts \<rightarrow>* ts' ==> t \<rightarrow>* t' ==> t#ts \<rightarrow>* t'#ts'"

declare tRed_list.intros[simp]

lemma tRed_list_refl[simp]: includes Vars shows "ts \<rightarrow>* ts"
by(induct ts) auto


fun ML_closed :: "nat \<Rightarrow> ml \<Rightarrow> bool"
and ML_closed_t :: "nat \<Rightarrow> tm \<Rightarrow> bool" where
"ML_closed i (C nm vs) = (ALL v:set vs. ML_closed i v)" |
"ML_closed i (V nm vs) = (ALL v:set vs. ML_closed i v)" |
"ML_closed i (Fun f vs n) = (ML_closed i f & (ALL v:set vs. ML_closed i v))" |
"ML_closed i (A_ML v vs) = (ML_closed i v & (ALL v:set vs. ML_closed i v))" |
"ML_closed i (apply v w) = (ML_closed i v & ML_closed i w)" |
"ML_closed i (CC nm) = True" |
"ML_closed i (V_ML X) = (X<i)"  |
"ML_closed i (Lam_ML v) = ML_closed (i+1) v" |
"ML_closed_t i (term_of v) = ML_closed i v" |
"ML_closed_t i (At r s) = (ML_closed_t i r & ML_closed_t i s)" |
"ML_closed_t i (Lam t) = (ML_closed_t i t)" |
"ML_closed_t i v = True"
thm ML_closed.simps ML_closed_t.simps

inductive_set
  Red :: "(ml * ml)set"
  and Redt :: "(tm * tm)set"
  and Redl :: "(ml list * ml list)set"
  and red :: "[ml, ml] => bool"  (infixl "\<Rightarrow>" 50)
  and redl :: "[ml list, ml list] => bool"  (infixl "\<Rightarrow>" 50)
  and redt :: "[tm, tm] => bool"  (infixl "\<Rightarrow>" 50)
  and reds :: "[ml, ml] => bool"  (infixl "\<Rightarrow>*" 50)
  and redts :: "[tm, tm] => bool"  (infixl "\<Rightarrow>*" 50)
where
  "s \<Rightarrow> t == (s, t) \<in> Red"
| "s \<Rightarrow> t == (s, t) \<in> Redl"
| "s \<Rightarrow> t == (s, t) \<in> Redt"
| "s \<Rightarrow>* t == (s, t) \<in> Red^*"
| "s \<Rightarrow>* t == (s, t) \<in> Redt^*"
(* ML *)
| "A_ML (Lam_ML u) [v] \<Rightarrow> u[v/0]"
(* compiled rules *)
| "(nm,vs,v) : compR ==> ALL i. ML_closed 0 (f i) \<Longrightarrow> A_ML (CC nm) (map (subst\<^bsub>ML\<^esub> f) vs) \<Rightarrow> subst\<^bsub>ML\<^esub> f v"
(* apply *)
| apply_Fun1: "apply (Fun f vs (Suc 0)) v \<Rightarrow> A_ML f (vs @ [v])"
| apply_Fun2: "n > 0 ==>
 apply (Fun f vs (Suc n)) v \<Rightarrow> Fun f (vs @ [v]) n"
| apply_C: "apply (C nm vs) v \<Rightarrow> C nm (vs @ [v])"
| apply_V: "apply (V x vs) v \<Rightarrow> V x (vs @ [v])"
(* term_of *)
| term_of_C: "term_of (C nm vs) \<Rightarrow> foldl At (Ct nm) (map term_of vs)"
| term_of_V: "term_of (V x vs) \<Rightarrow> foldl At (Vt x) (map term_of vs)"
| term_of_Fun: "term_of(Fun vf vs n) \<Rightarrow>
 Lam (term_of ((apply (lift 0 (Fun vf vs n)) (V_ML 0))[V 0 []/0]))"
(* Context *)
| ctxt_Lam: "t \<Rightarrow> t' ==> Lam t \<Rightarrow> Lam t'"
| ctxt_At1: "s \<Rightarrow> s' ==> At s t \<Rightarrow> At s' t"
| ctxt_At2: "t \<Rightarrow> t' ==> At s t \<Rightarrow> At s t'"
| ctxt_term_of: "v \<Rightarrow> v' ==> term_of v \<Rightarrow> term_of v'"
| ctxt_C: "vs \<Rightarrow> vs' ==> C nm vs \<Rightarrow> C nm vs'"
| ctxt_V: "vs \<Rightarrow> vs' ==> V x vs \<Rightarrow> V x vs'"
| ctxt_Fun1: "f \<Rightarrow> f'   ==> Fun f vs n \<Rightarrow> Fun f' vs n"
| ctxt_Fun3: "vs \<Rightarrow> vs' ==> Fun f vs n \<Rightarrow> Fun f vs' n"
| ctxt_apply1: "s \<Rightarrow> s'   ==> apply s t \<Rightarrow> apply s' t"
| ctxt_apply2: "t \<Rightarrow> t'   ==> apply s t \<Rightarrow> apply s t'"
| ctxt_A_ML1: "f \<Rightarrow> f'   ==> A_ML f vs \<Rightarrow> A_ML f' vs"
| ctxt_A_ML2: "vs \<Rightarrow> vs' ==> A_ML f vs \<Rightarrow> A_ML f vs'"
| ctxt_list1: "v \<Rightarrow> v'   ==> v#vs \<Rightarrow> v'#vs"
| ctxt_list2: "vs \<Rightarrow> vs' ==> v#vs \<Rightarrow> v#vs'"


consts
 ar :: "const_name \<Rightarrow> nat"

axioms
ar_pos: "ar nm > 0"

types env = "ml list"

consts eval :: "tm \<Rightarrow> env \<Rightarrow> ml"
primrec
"eval (Vt x) e = e!x"
"eval (Ct nm) e = Fun (CC nm) [] (ar nm)"
"eval (At s t) e = apply (eval s e) (eval t e)"
"eval (Lam t) e = Fun (Lam_ML (eval t ((V_ML 0) # map (lift\<^bsub>ML\<^esub> 0) e))) [] 1"

fun size' :: "ml \<Rightarrow> nat" where
"size' (C nm vs) = (\<Sum>v\<leftarrow>vs. size' v)+1" |
"size' (V nm vs) = (\<Sum>v\<leftarrow>vs. size' v)+1" |
"size' (Fun f vs n) = (size' f + (\<Sum>v\<leftarrow>vs. size' v))+1" |
"size' (A_ML v vs) = (size' v + (\<Sum>v\<leftarrow>vs. size' v))+1" |
"size' (apply v w) = (size' v + size' w)+1" |
"size' (CC nm) = 1" |
"size' (V_ML X) = 1"  |
"size' (Lam_ML v) = size' v + 1"

lemma listsum_size'[simp]:
 "v \<in> set vs \<Longrightarrow> size' v < Suc(listsum (map size' vs))"
sorry

corollary cor_listsum_size'[simp]:
 "v \<in> set vs \<Longrightarrow> size' v < Suc(m + listsum (map size' vs))"
using listsum_size'[of v vs] by arith

lemma
size_subst_ML[simp]: includes Vars assumes A: "!i. size(f i) = 0"
shows "size(subst\<^bsub>ML\<^esub> f t) = size(t)"
and "size(subst\<^bsub>ML\<^esub> f v) = size(v)"
and "ml_list_size1 (map (subst\<^bsub>ML\<^esub> f) vs) = ml_list_size1 vs"
and "ml_list_size2 (map (subst\<^bsub>ML\<^esub> f) vs) = ml_list_size2 vs"
and "ml_list_size3 (map (subst\<^bsub>ML\<^esub> f) vs) = ml_list_size3 vs"
and "ml_list_size4 (map (subst\<^bsub>ML\<^esub> f) vs) = ml_list_size4 vs"
by (induct rule: tm_ml.inducts) (simp_all add: A cons_ML_def split:nat.split)

lemma [simp]:
 "\<forall>i j. size'(f i) = size'(V_ML j) \<Longrightarrow> size' (subst\<^bsub>ML\<^esub> f v) = size' v"
sorry

lemma [simp]: "size' (lift i v) = size' v"
sorry

(* the kernel function as in Section 4.1 of "Operational aspects\<dots>" *)

function kernel  :: "ml \<Rightarrow> tm" ("_!" 300) where
"(C nm vs)! = foldl At (Ct nm) (map kernel vs)" |
"(Lam_ML v)! = Lam (((lift 0 v)[V 0 []/0])!)" |
"(Fun f vs n)! = foldl At (f!) (map kernel vs)" |
"(A_ML v vs)! = foldl At (v!) (map kernel vs)" |
"(apply v w)! = At (v!) (w!)" |
"(CC nm)! = Ct nm" |
"(V x vs)! = foldl At (Vt x) (map kernel vs)" |
"(V_ML X)! = undefined"
by pat_completeness auto
termination by(relation "measure size'") auto

consts kernelt :: "tm \<Rightarrow> tm" ("_!" 300)
primrec 
"(Ct nm)! = Ct nm"
"(term_of v)! = v!"
"(Vt x)! = Vt x"
"(At s t)! = At (s!) (t!)"
"(Lam t)! = Lam (t!)"

abbreviation
  kernels :: "ml list \<Rightarrow> tm list" ("_!" 300) where
  "vs ! == map kernel vs"

(* soundness of the code generator *)
axioms
compiler_correct:
"(nm, vs, v) : compR ==> ALL i. ML_closed 0 (f i) \<Longrightarrow> (nm, (map (subst\<^bsub>ML\<^esub> f) vs)!, (subst\<^bsub>ML\<^esub> f v)!) : R"


consts
  free_vars :: "tm \<Rightarrow> lam_var_name set"
primrec
"free_vars (Ct nm) = {}"
"free_vars (Vt x) = {x}"
"free_vars (Lam t) = {i. EX j : free_vars t. j = i+1}"
"free_vars (At s t) = free_vars s \<union> free_vars t"

lemma [simp]: "t : Pure_tms \<Longrightarrow> lift\<^bsub>ML\<^esub> k t = t"
by (erule Pure_tms.induct) simp_all

lemma kernel_pure: includes Vars assumes "t : Pure_tms" shows "t! = t"
using assms by (induct) simp_all

lemma lift_eval:
 "t : Pure_tms \<Longrightarrow> ALL e k. (ALL i : free_vars t. i < size e) --> lift k (eval t e) = eval t (map (lift k) e)"
apply(induct set:Pure_tms)
apply simp_all
apply clarsimp
apply(erule_tac x = "V_ML 0 # map (lift\<^bsub>ML\<^esub> 0) e" in allE)
apply simp
apply(erule impE)
 apply clarsimp
 apply(case_tac i)apply simp
 apply simp
apply (simp add: map_compose[symmetric])
apply (simp add: o_def lift_lift_ML_comm)
done

lemma lift_ML_eval[rule_format]:
 "t : Pure_tms \<Longrightarrow> ALL e k. (ALL i : free_vars t. i < size e) --> lift\<^bsub>ML\<^esub> k (eval t e) = eval t (map (lift\<^bsub>ML\<^esub> k) e)"
apply(induct set:Pure_tms)
apply simp_all
apply clarsimp
apply(erule_tac x = "V_ML 0 # map (lift\<^bsub>ML\<^esub> 0) e" in allE)
apply simp
apply(erule impE)
 apply clarsimp
 apply(case_tac i)apply simp
 apply simp
apply (simp add: map_compose[symmetric])
apply (simp add:o_def lift_lift_ML)
done

lemma [simp]: includes Vars shows "(v ## f) 0 = v"
by(simp add:cons_ML_def)

lemma [simp]:  includes Vars shows "(v ## f) (Suc n) = lift\<^bsub>ML\<^esub> 0 (f n)"
by(simp add:cons_ML_def)

lemma lift_o_shift: "lift k o (V_ML 0 ## f) = (V_ML 0 ## (lift k \<circ> f))"
apply(rule ext)
apply (simp add:cons_ML_def lift_lift_ML_comm split:nat.split)
done

lemma lift_subst_ML: shows
 "lift_tm k (subst\<^bsub>ML\<^esub> f t) = subst\<^bsub>ML\<^esub> (lift_ml k o f) (lift_tm k t)" and
 "lift_ml k (subst\<^bsub>ML\<^esub> f v) = subst\<^bsub>ML\<^esub> (lift_ml k o f) (lift_ml k v)"
apply (induct t and v arbitrary: f k and f k rule: lift_tm_lift_ml.induct)
apply (simp_all add:map_compose[symmetric] o_assoc lift_o_lift lift_o_shift)
done

corollary lift_subst_ML1: "\<forall>v k. lift_ml 0 (u[v/k]) = (lift_ml 0 u)[lift 0 v/k]"
apply(rule measure_induct[where f = "size" and a = u])
apply(case_tac x)
apply(simp_all add:lift_lift map_compose[symmetric] lift_subst_ML)
apply(subst lift_lift_ML_comm)apply simp
done

lemma lift_ML_lift_ML: includes Vars shows
    "i < k+1 \<Longrightarrow> lift\<^bsub>ML\<^esub> (Suc k) (lift\<^bsub>ML\<^esub> i t) = lift\<^bsub>ML\<^esub> i (lift\<^bsub>ML\<^esub> k t)"
and "i < k+1 \<Longrightarrow> lift\<^bsub>ML\<^esub> (Suc k) (lift\<^bsub>ML\<^esub> i v) = lift\<^bsub>ML\<^esub> i (lift\<^bsub>ML\<^esub> k v)"
apply (induct k t and k v arbitrary: i k and i k
       rule: lift_tm_ML_lift_ml_ML.induct)
apply(simp_all add:map_compose[symmetric])
done

corollary lift_ML_o_lift_ML: shows
 "i < k+1 \<Longrightarrow> lift_tm_ML (Suc k) o (lift_tm_ML i) = lift_tm_ML i o lift_tm_ML k" and
 "i < k+1 \<Longrightarrow> lift_ml_ML (Suc k) o (lift_ml_ML i) = lift_ml_ML i o lift_ml_ML k"
by(rule ext, simp add:lift_ML_lift_ML)+

abbreviation insrt where
"insrt k f == (%i. if i<k then lift_ml_ML k (f i) else if i=k then V_ML k else lift_ml_ML k (f(i - 1)))"

lemma subst_insrt_lift: includes Vars shows
 "subst\<^bsub>ML\<^esub> (insrt k f) (lift\<^bsub>ML\<^esub> k t) = lift\<^bsub>ML\<^esub> k (subst\<^bsub>ML\<^esub> f t)" and
 "subst\<^bsub>ML\<^esub> (insrt k f) (lift\<^bsub>ML\<^esub> k v) = lift\<^bsub>ML\<^esub> k (subst\<^bsub>ML\<^esub> f v)"
apply (induct k t and k v arbitrary: f k and f k rule: lift_tm_ML_lift_ml_ML.induct)
apply (simp_all add:map_compose[symmetric] o_assoc lift_o_lift lift_o_shift)
  apply(subgoal_tac "lift 0 \<circ> insrt k f = insrt k (lift 0 \<circ> f)")
  apply simp
 apply(rule ext)
 apply (simp add:lift_lift_ML_comm)
apply(subgoal_tac "V_ML 0 ## insrt k f = insrt (Suc k) (V_ML 0 ## f)")
 apply simp
 apply(rule ext)
 apply (simp add:lift_ML_lift_ML cons_ML_def split:nat.split)
done

corollary subst_cons_lift: includes Vars shows
 "subst\<^bsub>ML\<^esub> (V_ML 0 ## f) o (lift_ml_ML 0) = lift_ml_ML 0 o (subst_ml_ML f)"
apply(rule ext)
apply(simp add: cons_ML_def subst_insrt_lift[symmetric])
apply(subgoal_tac "nat_case (V_ML 0) (\<lambda>j. lift\<^bsub>ML\<^esub> 0 (f j)) = (\<lambda>i. if i = 0 then V_ML 0 else lift\<^bsub>ML\<^esub> 0 (f (i - 1)))")
 apply simp
apply(rule ext, simp split:nat.split)
done

lemma subst_eval[rule_format]: "t : Pure_tms \<Longrightarrow>
 ALL f e. (ALL i : free_vars t. i < size e) \<longrightarrow> subst\<^bsub>ML\<^esub> f (eval t e) = eval t (map (subst\<^bsub>ML\<^esub> f) e)"
apply(induct set:Pure_tms)
apply simp_all
apply clarsimp
apply(erule_tac x="V_ML 0 ## f" in allE)
apply(erule_tac x= "(V_ML 0 # map (lift\<^bsub>ML\<^esub> 0) e)" in allE)
apply(erule impE)
 apply clarsimp
 apply(case_tac i)apply simp
 apply simp
apply (simp add:subst_cons_lift map_compose[symmetric])
done


theorem kernel_eval[rule_format]: includes Vars shows
 "t : Pure_tms ==>
 ALL e. (ALL i : free_vars t. i < size e) \<longrightarrow> (ALL i < size e. e!i = V i []) --> (eval t e)! =  t!"
apply(induct set:Pure_tms)
apply simp_all
apply clarsimp
apply(subst lift_eval) apply simp
 apply clarsimp
 apply(case_tac i)apply simp
 apply simp
apply(subst subst_eval) apply simp
 apply clarsimp
 apply(case_tac i)apply simp
 apply simp
apply(erule_tac x="map (subst\<^bsub>ML\<^esub> (\<lambda>n. if n = 0 then V 0 [] else V_ML (n - 1)))
                (map (lift 0) (V_ML 0 # map (lift\<^bsub>ML\<^esub> 0) e))" in allE)
apply(erule impE)
apply(clarsimp)
 apply(case_tac i)apply simp
 apply simp
apply(erule impE)
apply(clarsimp)
 apply(case_tac i)apply simp
 apply simp
apply simp
done

(*
lemma subst_ML_compose:
  "subst_ml_ML f2 (subst_ml_ML f1 v) = subst_ml_ML (%i. subst_ml_ML f2 (f1 i)) v"
sorry
*)

lemma map_eq_iff_nth:
 "(map f xs = map g xs) = (!i<size xs. f(xs!i) = g(xs!i))"
sorry

lemma [simp]: includes Vars shows "ML_closed k v \<Longrightarrow> lift\<^bsub>ML\<^esub> k v = v"
sorry
lemma [simp]: includes Vars shows "ML_closed 0 v \<Longrightarrow> subst\<^bsub>ML\<^esub> f v = v"
sorry
lemma [simp]: includes Vars shows "ML_closed k v \<Longrightarrow> ML_closed k (lift m v)"
sorry

lemma red_Lam[simp]: includes Vars shows "t \<rightarrow>* t' ==> Lam t \<rightarrow>* Lam t'"
apply(induct rule:rtrancl_induct)
apply(simp_all)
apply(blast intro: rtrancl_into_rtrancl tRed.intros)
done

lemma red_At1[simp]: includes Vars shows "t \<rightarrow>* t' ==> At t s \<rightarrow>* At t' s"
apply(induct rule:rtrancl_induct)
apply(simp_all)
apply(blast intro: rtrancl_into_rtrancl tRed.intros)
done

lemma red_At2[simp]: includes Vars shows "t \<rightarrow>* t' ==> At s t \<rightarrow>* At s t'"
apply(induct rule:rtrancl_induct)
apply(simp_all)
apply(blast intro:rtrancl_into_rtrancl tRed.intros)
done

lemma tRed_list_foldl_At:
 "ts \<rightarrow>* ts' \<Longrightarrow> s \<rightarrow>* s' \<Longrightarrow> foldl At s ts \<rightarrow>* foldl At s' ts'"
apply(induct arbitrary:s s' rule:tRed_list.induct)
apply simp
apply simp
apply(blast dest: red_At1 red_At2 intro:rtrancl_trans)
done

lemma [trans]: "s = t \<Longrightarrow> t \<rightarrow> t' \<Longrightarrow> s \<rightarrow> t'"
by simp


lemma subst_foldl[simp]:
 "subst f (foldl At s ts) = foldl At (subst f s) (map (subst f) ts)"
by (induct ts arbitrary: s) auto


lemma foldl_At_size: "size ts = size ts' \<Longrightarrow>
 foldl At s ts = foldl At s' ts' \<longleftrightarrow> s = s' & ts = ts'"
by (induct arbitrary: s s' rule:list_induct2) simp_all

consts depth_At :: "tm \<Rightarrow> nat"
primrec
"depth_At(Ct cn) = 0"
"depth_At(Vt x) = 0"
"depth_At(Lam t) = 0"
"depth_At(At s t) = depth_At s + 1"
"depth_At(term_of v) = 0"

lemma depth_At_foldl:
 "depth_At(foldl At s ts) = depth_At s + size ts"
by (induct ts arbitrary: s) simp_all

lemma foldl_At_eq_length:
 "foldl At s ts = foldl At s ts' \<Longrightarrow> length ts = length ts'"
apply(subgoal_tac "depth_At(foldl At s ts) = depth_At(foldl At s ts')")
apply(erule thin_rl)
 apply (simp add:depth_At_foldl)
apply simp
done

lemma foldl_At_eq[simp]: "foldl At s ts = foldl At s ts' \<longleftrightarrow> ts = ts'"
apply(rule)
 prefer 2 apply simp
apply(blast dest:foldl_At_size foldl_At_eq_length)
done

lemma [simp]: "foldl At s ts ! = foldl At (s!) (map kernelt ts)"
by (induct ts arbitrary: s) simp_all

lemma [simp]: "(kernelt \<circ> term_of) = kernel"
by(rule ext) simp

lemma shift_subst_decr:
 "Vt 0 ## subst_decr k t = subst_decr (Suc k) (lift 0 t)"
apply(rule ext)
apply (simp add:cons_def split:nat.split)
done

lemma [simp]: "lift k (foldl At s ts) = foldl At (lift k s) (map (lift k) ts)"
by(induct ts arbitrary:s) simp_all

subsection "Horrible detour"

definition "liftn n == lift_ml 0 ^ n"

lemma [simp]: "liftn n (C i vs) = C i (map (liftn n) vs)"
apply(unfold liftn_def)
apply(induct n)
apply (simp_all add: map_compose[symmetric])
done

lemma [simp]: "liftn n (CC nm) = CC nm"
apply(unfold liftn_def)
apply(induct n)
apply (simp_all add: map_compose[symmetric])
done

lemma [simp]: "liftn n (apply v w) = apply (liftn n v) (liftn n w)"
apply(unfold liftn_def)
apply(induct n)
apply (simp_all add: map_compose[symmetric])
done

lemma [simp]: "liftn n (A_ML v vs) = A_ML (liftn n v) (map (liftn n) vs)"
apply(unfold liftn_def)
apply(induct n)
apply (simp_all add: map_compose[symmetric])
done

lemma [simp]:
 "liftn n (Fun v vs i) = Fun (liftn n v) (map (liftn n) vs) i"
apply(unfold liftn_def)
apply(induct n)
apply (simp_all add: map_compose[symmetric] id_def)
done

lemma [simp]: "liftn n (Lam_ML v) = Lam_ML (liftn n v)"
apply(unfold liftn_def)
apply(induct n)
apply (simp_all add: map_compose[symmetric] id_def)
done

lemma liftn_liftn_add: "liftn m (liftn n v) = liftn (m+n) v"
by(simp add:liftn_def funpow_add)

lemma [simp]: "liftn n (V_ML k) = V_ML k"
apply(unfold liftn_def)
apply(induct n)
apply (simp_all)
done

lemma liftn_lift_ML_comm: "liftn n (lift\<^bsub>ML\<^esub> 0 v) = lift\<^bsub>ML\<^esub> 0 (liftn n v)"
apply(unfold liftn_def)
apply(induct n)
apply (simp_all add:lift_lift_ML_comm)
done

lemma liftn_cons: "liftn n ((V_ML 0 ## f) x) = (V_ML 0 ## (liftn n o f)) x"
apply(simp add:cons_ML_def liftn_lift_ML_comm split:nat.split)
done

text{* End of horrible detour *}

lemma kernel_subst1:
"ML_closed 1 u \<Longrightarrow> ML_closed 0 v \<Longrightarrow> kernel( u[v/0]) = (kernel((lift 0 u)[V 0 []/0]))[kernel v/0]"
sorry

lemma includes Vars shows foldl_Pure[simp]:
 "t : Pure_tms \<Longrightarrow> \<forall>t\<in>set ts. t : Pure_tms \<Longrightarrow> 
 (!!s t. s : Pure_tms \<Longrightarrow> t : Pure_tms \<Longrightarrow> f s t : Pure_tms) \<Longrightarrow>
 foldl f t ts \<in> Pure_tms"
by(induct ts arbitrary: t) simp_all

declare Pure_tms.intros[simp]

lemma includes Vars shows "ML_closed 0 v \<Longrightarrow> kernel v : Pure_tms"
apply(induct rule:kernel.induct)
apply simp_all
apply(rule Pure_tms.intros);
(* "ML_closed (Suc k) v \<Longrightarrow> ML_closed k (lift 0 v)" *)
sorry

lemma subst_Vt: includes Vars shows "subst Vt = id"
sorry
(*
apply(rule ext)
apply(induct_tac x)
apply simp_all

done
*)
(* klappt noch nicht ganz *)
theorem Red_sound: includes Vars
 shows "v \<Rightarrow> v' \<Longrightarrow> ML_closed 0 v \<Longrightarrow> v! \<rightarrow>* v'! & ML_closed 0 v'"
    and "t \<Rightarrow> t' \<Longrightarrow> ML_closed_t 0 t \<Longrightarrow> kernelt t \<rightarrow>* kernelt t'  & ML_closed_t 0 t'"
    and "(vs :: ml list) \<Rightarrow> vs' \<Longrightarrow> !v : set vs . ML_closed 0 v \<Longrightarrow> map kernel vs \<rightarrow>* map kernel vs' & (! v':set vs'. ML_closed 0 v')"
proof(induct rule:Red_Redt_Redl.inducts)
  fix u v
  let ?v = "A_ML (Lam_ML u) [v]"
  assume cl: "ML_closed 0 (A_ML (Lam_ML u) [v])"
  let ?u' = "(lift_ml 0 u)[V 0 []/0]"
  have "?v! = At (Lam ((?u')!)) (v !)" by simp
  also have "\<dots> \<rightarrow> (?u' !)[v!/0]" (is "_ \<rightarrow> ?R") by(rule tRed.intros)
  also have "?R = u[v/0]!" using cl
apply(cut_tac u = "u" and v = "v" in kernel_subst1)
apply(simp_all)
done
  finally have "kernel(A_ML (Lam_ML u) [v]) \<rightarrow>* kernel(u[v/0])" (is ?A) by(rule r_into_rtrancl)
  moreover have "ML_closed 0 (u[v/0])" (is "?C") using cl apply simp sorry
  ultimately show "?A & ?C" ..
next
  case term_of_C thus ?case apply (auto simp:map_compose[symmetric])sorry
next
  fix f :: "nat \<Rightarrow> ml" and nm vs v
  assume f: "\<forall>i. ML_closed 0 (f i)"  and compR: "(nm, vs, v) \<in> compR"
  note tRed.intros(2)[OF compiler_correct[OF compR f], of Vt,simplified map_compose[symmetric]]
  hence red: "foldl At (Ct nm) (map (kernel o subst\<^bsub>ML\<^esub> f) vs) \<rightarrow>
         (subst\<^bsub>ML\<^esub> f v)!" (is "_ \<rightarrow> ?R") apply(simp add:map_compose) sorry
  have "A_ML (CC nm) (map (subst\<^bsub>ML\<^esub> f) vs)! =
       foldl At (Ct nm) (map (kernel o subst\<^bsub>ML\<^esub> f) vs)" by (simp add:map_compose)
  also(* have "map (kernel o subst\<^bsub>ML\<^esub> f) vs = map (subst (kernel o f)) (vs!)"
    using closed_subst_kernel(2)[OF compiled_V_free1[OF compR]]
    by (simp add:map_compose[symmetric])
  also*) note red
  (*also have "?R = subst\<^bsub>ML\<^esub> f v!"
    using closed_subst_kernel(2)[OF compiled_V_free2[OF compR]] by simp*)
  finally have "A_ML (CC nm) (map (subst\<^bsub>ML\<^esub> f) vs)! \<rightarrow>* subst\<^bsub>ML\<^esub> f v!" (is "?A")
    by(rule r_into_rtrancl) (*
  also have "?l = (subst\<^bsub>ML\<^esub> fa (A_ML (CC nm) (map (subst\<^bsub>ML\<^esub> f) vs)))!" (is "_ = ?l'") sorry
  also have "?r = subst\<^bsub>ML\<^esub> fa (subst\<^bsub>ML\<^esub> f v)!"  (is "_ = ?r'") sorry 
  finally have "?l' \<rightarrow>* ?r'" (is ?A) . *)
  moreover have "ML_closed 0 (subst\<^bsub>ML\<^esub> f v)" (is "?C") using prems sorry
  ultimately show "?A & ?C" ..
next
  case term_of_V thus ?case apply (auto simp:map_compose[symmetric]) sorry
next
  case (term_of_Fun vf vs n)
  hence "term_of (Fun vf vs n)! \<rightarrow>*
       Lam (term_of (apply (lift 0 (Fun vf vs n)) (V_ML 0)[V 0 []/0]))!" sorry
  moreover
  have "ML_closed_t 0
        (Lam (term_of (apply (lift 0 (Fun vf vs n)) (V_ML 0)[V 0 []/0])))" sorry
  ultimately show ?case ..
next
  case apply_Fun1 thus ?case by simp
next
  case apply_Fun2 thus ?case by simp
next
  case apply_C thus ?case by simp
next
  case apply_V thus ?case by simp
next
  case ctxt_Lam thus ?case by(auto)
next
  case ctxt_At1 thus ?case  by(auto)
next
  case ctxt_At2 thus ?case by (auto)
next
  case ctxt_term_of thus ?case by (auto)
next
  case ctxt_C thus ?case by (fastsimp simp:tRed_list_foldl_At)
next
  case ctxt_V thus ?case by (fastsimp simp:tRed_list_foldl_At)
next
  case ctxt_Fun1 thus ?case by (fastsimp simp:tRed_list_foldl_At)
next
  case ctxt_Fun3 thus ?case by (fastsimp simp:tRed_list_foldl_At)
next
  case ctxt_apply1 thus ?case by auto
next
  case ctxt_apply2 thus ?case  by auto
next
  case ctxt_A_ML1 thus ?case by (fastsimp simp:tRed_list_foldl_At)
next
  case ctxt_A_ML2 thus ?case by (fastsimp simp:tRed_list_foldl_At)
next
  case ctxt_list1 thus ?case by simp
next
  case ctxt_list2 thus ?case by simp
qed


inductive_cases tRedE: "Ct n \<rightarrow> u"
thm tRedE

lemma [simp]: "Ct n = foldl At t ts \<longleftrightarrow> t = Ct n & ts = []"
by (induct ts arbitrary:t) auto

corollary kernel_inv: includes Vars shows
 "(t :: tm) \<Rightarrow>* t' ==> ML_closed_t 0 t ==> t! \<rightarrow>* t'!"
sorry

theorem includes Vars
assumes t: "t : Pure_tms" and t': "t' : Pure_tms" and
 closed: "free_vars t = {}" and reds: "term_of (eval t []) \<Rightarrow>* t'"
 shows "t \<rightarrow>* t' "
proof -
  have ML_cl: "ML_closed_t 0 (term_of (eval t []))" sorry
  have "(eval t [])! = t!"
    using kernel_eval[OF t, where e="[]"] closed by simp
  hence "(term_of (eval t []))! = t!" by simp
  moreover have "term_of (eval t [])! \<rightarrow>* t'!"
    using kernel_inv[OF reds ML_cl] by auto
  ultimately have "t! \<rightarrow>* t'!" by simp
  thus  ?thesis using kernel_pure t t' by auto
qed

end
