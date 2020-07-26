/*******************************************************************
 *
 * A Common Lisp compiler/interpretor, written in Prolog
 *
 * (lisp_compiler.pl)
 *
 *
 * Douglas'' Notes:
 *
 * (c) Douglas Miles, 2017
 *
 * The program is a *HUGE* common-lisp compiler/interpreter. It is written for YAP/SWI-Prolog .
 *
 * Changes since 2001:
 *
 *
 *******************************************************************/
:- module(gr0v, []).
:- set_module(class(library)).

% wl:body_compiled/1 symbols considered fboundp (compile_body does the work)
% Also means we *might* not always notice 'defmacros' of these
wl:body_compiled(multiple_value_bind).  wl:body_compiled(multiple_value_call).  wl:body_compiled(multiple_value_list).  
wl:body_compiled(values).  wl:body_compiled(values_list).  
wl:body_compiled(let).  wl:body_compiled(let_xx). 
wl:body_compiled(sys_letf).  wl:body_compiled(sys_letf_xx).  
wl:body_compiled(eval). wl:body_compiled(apply). 
wl:body_compiled(function). wl:body_compiled(lambda).
wl:body_compiled(macrolet). wl:body_compiled(flet). wl:body_compiled(labels). 
wl:body_compiled(or).  wl:body_compiled(and). wl:body_compiled(sys_xor).
wl:body_compiled(progn).  wl:body_compiled(prog).  
wl:body_compiled(prog1).  wl:body_compiled(prog2).  wl:body_compiled(progv). 
wl:body_compiled(tagbody). wl:body_compiled(go).
wl:body_compiled(block). wl:body_compiled(return). wl:body_compiled(return_from).
wl:body_compiled(if). wl:body_compiled(cond).  wl:body_compiled(unless). wl:body_compiled(when).  
wl:body_compiled(while).  wl:body_compiled(do). wl:body_compiled(dolist).  
wl:body_compiled(typecase). wl:body_compiled(ctypecase). wl:body_compiled(etypecase). 
wl:body_compiled(case). wl:body_compiled(ccase). wl:body_compiled(ecase). 
wl:body_compiled(quote).  

wl:body_compiled(setq). 

:- assertz(wl:interned_eval(call(define_body_compiled))).


define_body_compiled:- forall(wl:body_compiled(Symbol),define_body_compiled(Symbol)).

% TODO
define_body_compiled(_Op). 



was_pkg_prefix(sys,pkg_sys).
was_pkg_prefix(u,pkg_user).
was_pkg_prefix(clos,pkg_sys):- \+  current_prolog_flag(wamcl_pcl,true).
was_pkg_prefix(clos,pkg_clos):- current_prolog_flag(wamcl_pcl,true).
was_pkg_prefix(Prfx,Package):- package_symbol_prefix(Prfx_,Package),atom_concat(Prfx,'_',Prfx_).

% grovel_system_symbols:-!.
grovel_system_symbols:- prolog_load_context(source,File),assertz(wl:interned_eval(call(grovel_system_symbols(File)))).


grovel_system_symbols(File):- 
 ignore(((source_file(M:P,File),functor(P,F,A), A>0,  
 atomic_list_concat([MF,Pkg|HC],'_',F),
  memberchk(MF,['sf','f','mf']),
 once(always((
  guess_function_symbol(MF,[Pkg|HC],Symbol),
  known_symbol(Symbol,Package),f_export(Symbol,Package,_),
  (get_opv(Symbol,symbol_function,F)-> true ;show_call_trace(set_opv(Symbol,symbol_function,F))),
  pl_symbol_name(Symbol,String),
  dmsg((grovelled_source_file_symbols(String,Package,Symbol,M,F)))))),fail))).

pkg_search_order(Package):- package_use_list(pkg_user, Package).

known_symbol(Symbol):- known_symbol(Symbol,_Package).
known_symbol(Symbol,Package):- package_external_symbols(Package,_,Symbol).
known_symbol(Symbol,Package):- get_opv_iiii(Symbol,type_of,symbol),get_opv_iiii(Symbol,symbol_package,Package).
known_symbol(Symbol,Package):- package_internal_symbols(Package,_,Symbol).

guess_function_symbol(_MF,[Pkg|HC],Symbol):- atomic_list_concat([Pkg|HC],'_',Symbol),known_symbol(Symbol).
guess_function_symbol(_MF,[Pkg|HC],Symbol):- was_pkg_prefix(Pkg,Package),!,
   into_symbol_name(HC,String),f_intern(String,Package,Symbol).
guess_function_symbol(_MF,HC,Symbol):- 
   pkg_search_order(Package),
   was_pkg_prefix(Pkg,Package),
   atomic_list_concat([Pkg|HC],'_',Symbol),
   known_symbol(Symbol,Package).
guess_function_symbol(MF,HC,Symbol):- 
   into_symbol_name(HC,String),
   guess_named_symbol(MF,String,Symbol).

guess_named_symbol(_MF,String,Symbol):- 
   pkg_search_order(Package),
   package_find_symbol(String,Package,Symbol,_),!.
guess_named_symbol(_MF,String,Symbol):-
   reading_package(Package),
   f_intern(String,Package,Symbol).


list_lisp_undefined(Pkg):- 
 ignore(((get_opv(X,symbol_package,Pkg),once((Y=symbol_function,get_opv(X,Y,F),get_opv(X,symbol_name,Str),
   \+ current_predicate(F/_))),
  wdmsg(lisp_undefined(Pkg,X,Str,Y,F))),fail)).



grovel_preds(M):-
 %module_property(M,file(File)),
 
 doall((
  source_file(M:P,_File),
  %current_predicate(_,M:P), \+ predicate_property(M:P,imported_from(_)),
  %predicate_property(M:P,module(M)),
  functor(P,F,A),
  once(forall(clause(wl:grovel_pred(M,F,A),B),call(B))),
  fail)).

wl:grovel_pred(M,F,1):-
  atom(F),atom(M),
  atom_concat_or_rtrace('is_',R,F),atom_concat(_,'p',R),
  doall(((get_opv_iiii(_Sym,symbol_function,SF),
  (atom(SF),atom_concat(Prefix,R,SF),
   \+ atomic_list_concat([_,_,_|_],'_',Prefix),
   Head=..[SF,N,RetVal],
   PBody=..[F,N],
   (assert_lsp(user:Head :- t_or_nil(M:PBody,RetVal))))),fail)).


make_special_operator(Symbol):-
  atom_concat('sf_',Symbol,SF),
  set_opv(Symbol,symbol_function,SF),
  set_opv(SF,type_of,sys_special_operator).

make_special_operator_symbols:- forall(cl_special_form(Symbol),make_special_operator(Symbol)).

cl_special_form(block).
cl_special_form(let_xx).
cl_special_form(return_from).
cl_special_form(catch).
cl_special_form(load_time_value).
cl_special_form(setq).
cl_special_form(eval_when).
cl_special_form(locally).
cl_special_form(symbol_macrolet).
cl_special_form(flet).
cl_special_form(macrolet).
cl_special_form(tagbody).
cl_special_form(function).
cl_special_form(multiple_value_call).
cl_special_form(the).
cl_special_form(go).
cl_special_form(multiple_value_prog1).
cl_special_form(throw).
cl_special_form(if).
cl_special_form(progn).
cl_special_form(unwind_protect).
cl_special_form(labels).
cl_special_form(progv).
cl_special_form(let).
cl_special_form(quote).
 
:- assertz(wl:interned_eval(call(make_special_operator_symbols))).

:- fixup_exports.

:- include('./header').

end_of_file.