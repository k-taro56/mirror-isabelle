;;
;; Keyword classification tables for Isabelle/Isar.
;; This file was generated by Isabelle/HOLCF/IOA -- DO NOT EDIT!
;;
;; $Id$
;;

(defconst isar-keywords-major
  '("\\."
    "\\.\\."
    "ML"
    "ML_command"
    "ML_setup"
    "ProofGeneral\\.inform_file_processed"
    "ProofGeneral\\.inform_file_retracted"
    "ProofGeneral\\.kill_proof"
    "ProofGeneral\\.process_pgip"
    "ProofGeneral\\.restart"
    "ProofGeneral\\.undo"
    "abbreviation"
    "also"
    "apply"
    "apply_end"
    "arities"
    "assume"
    "automaton"
    "ax_specification"
    "axclass"
    "axiomatization"
    "axioms"
    "back"
    "by"
    "cannot_undo"
    "case"
    "cd"
    "chapter"
    "class"
    "class_deps"
    "classes"
    "classrel"
    "code_abstype"
    "code_axioms"
    "code_class"
    "code_const"
    "code_datatype"
    "code_deps"
    "code_gen"
    "code_instance"
    "code_library"
    "code_module"
    "code_modulename"
    "code_moduleprolog"
    "code_monad"
    "code_reserved"
    "code_thms"
    "code_type"
    "coinductive"
    "coinductive_set"
    "commit"
    "constdefs"
    "consts"
    "consts_code"
    "context"
    "corollary"
    "cpodef"
    "datatype"
    "declaration"
    "declare"
    "def"
    "defaultsort"
    "defer"
    "defer_recdef"
    "definition"
    "defs"
    "disable_pr"
    "display_drafts"
    "domain"
    "done"
    "enable_pr"
    "end"
    "exit"
    "extract"
    "extract_type"
    "finalconsts"
    "finally"
    "find_theorems"
    "fix"
    "fixpat"
    "fixrec"
    "from"
    "full_prf"
    "fun"
    "function"
    "global"
    "guess"
    "have"
    "header"
    "help"
    "hence"
    "hide"
    "inductive"
    "inductive_cases"
    "inductive_set"
    "init_toplevel"
    "instance"
    "interpret"
    "interpretation"
    "invoke"
    "judgment"
    "kill"
    "kill_thy"
    "lemma"
    "lemmas"
    "let"
    "local"
    "locale"
    "method_setup"
    "moreover"
    "next"
    "no_syntax"
    "no_translations"
    "nonterminals"
    "normal_form"
    "notation"
    "note"
    "obtain"
    "oops"
    "oracle"
    "parse_ast_translation"
    "parse_translation"
    "pcpodef"
    "pr"
    "prefer"
    "presume"
    "pretty_setmargin"
    "prf"
    "primrec"
    "print_abbrevs"
    "print_antiquotations"
    "print_ast_translation"
    "print_attributes"
    "print_binds"
    "print_cases"
    "print_claset"
    "print_classes"
    "print_codesetup"
    "print_commands"
    "print_context"
    "print_drafts"
    "print_facts"
    "print_induct_rules"
    "print_interps"
    "print_locale"
    "print_locales"
    "print_methods"
    "print_options"
    "print_rules"
    "print_simpset"
    "print_statement"
    "print_syntax"
    "print_theorems"
    "print_theory"
    "print_trans_rules"
    "print_translation"
    "proof"
    "prop"
    "pwd"
    "qed"
    "quickcheck"
    "quickcheck_params"
    "quit"
    "realizability"
    "realizers"
    "recdef"
    "recdef_tc"
    "record"
    "redo"
    "refute"
    "refute_params"
    "remove_thy"
    "rep_datatype"
    "sect"
    "section"
    "setup"
    "show"
    "simproc_setup"
    "sledgehammer"
    "sorry"
    "specification"
    "subsect"
    "subsection"
    "subsubsect"
    "subsubsection"
    "syntax"
    "term"
    "termination"
    "text"
    "text_raw"
    "then"
    "theorem"
    "theorems"
    "theory"
    "thm"
    "thm_deps"
    "thus"
    "thy_deps"
    "token_translation"
    "touch_all_thys"
    "touch_child_thys"
    "touch_thy"
    "translations"
    "txt"
    "txt_raw"
    "typ"
    "typed_print_translation"
    "typedecl"
    "typedef"
    "types"
    "types_code"
    "ultimately"
    "undo"
    "undos_proof"
    "unfolding"
    "update_thy"
    "use"
    "use_thy"
    "using"
    "value"
    "welcome"
    "with"
    "{"
    "}"))

(defconst isar-keywords-minor
  '("actions"
    "advanced"
    "and"
    "assumes"
    "attach"
    "begin"
    "binder"
    "compose"
    "concl"
    "congs"
    "constrains"
    "contains"
    "defines"
    "distinct"
    "file"
    "fixes"
    "for"
    "hide_action"
    "hints"
    "identifier"
    "if"
    "imports"
    "in"
    "includes"
    "induction"
    "infix"
    "infixl"
    "infixr"
    "initially"
    "inject"
    "inputs"
    "internals"
    "is"
    "lazy"
    "monos"
    "morphisms"
    "notes"
    "obtains"
    "open"
    "otherwise"
    "output"
    "outputs"
    "overloaded"
    "permissive"
    "post"
    "pre"
    "rename"
    "restrict"
    "sequential"
    "shows"
    "signature"
    "states"
    "structure"
    "to"
    "transitions"
    "transrel"
    "unchecked"
    "uses"
    "where"))

(defconst isar-keywords-control
  '("ProofGeneral\\.inform_file_processed"
    "ProofGeneral\\.inform_file_retracted"
    "ProofGeneral\\.kill_proof"
    "ProofGeneral\\.process_pgip"
    "ProofGeneral\\.restart"
    "ProofGeneral\\.undo"
    "cannot_undo"
    "exit"
    "init_toplevel"
    "kill"
    "quit"
    "redo"
    "undo"
    "undos_proof"))

(defconst isar-keywords-diag
  '("ML"
    "ML_command"
    "cd"
    "class_deps"
    "code_deps"
    "code_gen"
    "code_thms"
    "commit"
    "disable_pr"
    "display_drafts"
    "enable_pr"
    "find_theorems"
    "full_prf"
    "header"
    "help"
    "kill_thy"
    "normal_form"
    "pr"
    "pretty_setmargin"
    "prf"
    "print_abbrevs"
    "print_antiquotations"
    "print_attributes"
    "print_binds"
    "print_cases"
    "print_claset"
    "print_classes"
    "print_codesetup"
    "print_commands"
    "print_context"
    "print_drafts"
    "print_facts"
    "print_induct_rules"
    "print_interps"
    "print_locale"
    "print_locales"
    "print_methods"
    "print_options"
    "print_rules"
    "print_simpset"
    "print_statement"
    "print_syntax"
    "print_theorems"
    "print_theory"
    "print_trans_rules"
    "prop"
    "pwd"
    "quickcheck"
    "refute"
    "remove_thy"
    "sledgehammer"
    "term"
    "thm"
    "thm_deps"
    "thy_deps"
    "touch_all_thys"
    "touch_child_thys"
    "touch_thy"
    "typ"
    "update_thy"
    "use"
    "use_thy"
    "value"
    "welcome"))

(defconst isar-keywords-theory-begin
  '("theory"))

(defconst isar-keywords-theory-switch
  '())

(defconst isar-keywords-theory-end
  '("end"))

(defconst isar-keywords-theory-heading
  '("chapter"
    "section"
    "subsection"
    "subsubsection"))

(defconst isar-keywords-theory-decl
  '("ML_setup"
    "abbreviation"
    "arities"
    "automaton"
    "axclass"
    "axiomatization"
    "axioms"
    "class"
    "classes"
    "classrel"
    "code_abstype"
    "code_axioms"
    "code_class"
    "code_const"
    "code_datatype"
    "code_instance"
    "code_library"
    "code_module"
    "code_modulename"
    "code_moduleprolog"
    "code_monad"
    "code_reserved"
    "code_type"
    "coinductive"
    "coinductive_set"
    "constdefs"
    "consts"
    "consts_code"
    "context"
    "datatype"
    "declaration"
    "declare"
    "defaultsort"
    "defer_recdef"
    "definition"
    "defs"
    "domain"
    "extract"
    "extract_type"
    "finalconsts"
    "fixpat"
    "fixrec"
    "fun"
    "global"
    "hide"
    "inductive"
    "inductive_set"
    "judgment"
    "lemmas"
    "local"
    "locale"
    "method_setup"
    "no_syntax"
    "no_translations"
    "nonterminals"
    "notation"
    "oracle"
    "parse_ast_translation"
    "parse_translation"
    "primrec"
    "print_ast_translation"
    "print_translation"
    "quickcheck_params"
    "realizability"
    "realizers"
    "recdef"
    "record"
    "refute_params"
    "rep_datatype"
    "setup"
    "simproc_setup"
    "syntax"
    "text"
    "text_raw"
    "theorems"
    "token_translation"
    "translations"
    "typed_print_translation"
    "typedecl"
    "types"
    "types_code"))

(defconst isar-keywords-theory-script
  '("inductive_cases"))

(defconst isar-keywords-theory-goal
  '("ax_specification"
    "corollary"
    "cpodef"
    "function"
    "instance"
    "interpretation"
    "lemma"
    "pcpodef"
    "recdef_tc"
    "specification"
    "termination"
    "theorem"
    "typedef"))

(defconst isar-keywords-qed
  '("\\."
    "\\.\\."
    "by"
    "done"
    "sorry"))

(defconst isar-keywords-qed-block
  '("qed"))

(defconst isar-keywords-qed-global
  '("oops"))

(defconst isar-keywords-proof-heading
  '("sect"
    "subsect"
    "subsubsect"))

(defconst isar-keywords-proof-goal
  '("have"
    "hence"
    "interpret"
    "invoke"))

(defconst isar-keywords-proof-block
  '("next"
    "proof"))

(defconst isar-keywords-proof-open
  '("{"))

(defconst isar-keywords-proof-close
  '("}"))

(defconst isar-keywords-proof-chain
  '("finally"
    "from"
    "then"
    "ultimately"
    "with"))

(defconst isar-keywords-proof-decl
  '("also"
    "let"
    "moreover"
    "note"
    "txt"
    "txt_raw"
    "unfolding"
    "using"))

(defconst isar-keywords-proof-asm
  '("assume"
    "case"
    "def"
    "fix"
    "presume"))

(defconst isar-keywords-proof-asm-goal
  '("guess"
    "obtain"
    "show"
    "thus"))

(defconst isar-keywords-proof-script
  '("apply"
    "apply_end"
    "back"
    "defer"
    "prefer"))

(provide 'isar-keywords)
