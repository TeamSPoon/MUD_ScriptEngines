/*******************************************************************
 *
 * A Common Lisp compiler/interpretor, written in Prolog
 *
 * Douglas'' Notes:
 *
 * (c) Douglas Miles, 2017
 *
 * The program is a *HUGE* common-lisp compiler/interpreter. It is written for YAP/SWI-Prolog (YAP 4x faster).
 *
 * This codebase contains ideas from the examinations of  
 *   Neil Smith, Tim Finin, Markus Triska and the Straightforward Implementation of Scheme
 * 
 * Changes since 2001:
 *
 *
 *******************************************************************/


:- set_prolog_flag(generate_debug_info, true).

% :- require([colormsg1/1]).

:- system:use_module(library(apply),[exclude/3]).
:- system:use_module(library(apply),[maplist/2,maplist/3]).
:- system:use_module(library(error),[existence_error/2]).
:- system:use_module(library(gensym),[gensym/2]).
:- system:use_module(library(lists),[member/2,append/3,nth1/3,select/3]).
:- system:use_module(library(occurs),[sub_term/2,contains_var/2]).
:- system:use_module(library(backcomp)).
:- system:use_module(library(rbtrees)).
:- system:use_module(library(lists),[member/2,append/3,nth1/3,select/3]).

:- multifile(user:portray/1).
:- dynamic(user:portray/1).
:- discontiguous(user:portray/1).


:- if(current_prolog_flag(debug,false)).

%:- set_prolog_flag(last_call_optimisation,true).
:- set_prolog_flag(compile_meta_arguments,false).
%:- set_prolog_flag(access_level,system).

:- endif.

:- if(\+ current_module(sxpr)).
:- if(\+ current_module(sxpr_reader)).
:- ensure_loaded(sreader).
:- endif.
:- endif.

%:- use_module(library(logicmoo/portray_vars)).

:- multifile(wl:symbol_has_prop_set_get/4).
:- multifile(wl:symbol_has_prop_getter/3).
:- multifile(wl:symbol_has_prop_setter/3).
:- dynamic(wl:symbol_has_prop_get_set/4).
:- dynamic(wl:symbol_has_prop_getter/3).
:- dynamic(wl:symbol_has_prop_setter/3).
:- discontiguous(wl:symbol_has_prop_get_set/4).
:- discontiguous(wl:symbol_has_prop_getter/3).
:- discontiguous(wl:symbol_has_prop_setter/3).

:- dynamic(tst:is_local_test/1).
:- multifile(tst:is_local_test/1).
:- discontiguous(tst:is_local_test/1).
:- dynamic(tst:is_local_test/2).
:- multifile(tst:is_local_test/2).
:- discontiguous(tst:is_local_test/2).


:- dynamic(tst:is_local_test/3).
:- multifile(tst:is_local_test/3).
:- discontiguous(tst:is_local_test/3).

:- dynamic(shared_lisp_compiler:plugin_expand_function_body/5).
:- multifile(shared_lisp_compiler:plugin_expand_function_body/5).
:- discontiguous(shared_lisp_compiler:plugin_expand_function_body/5).

:- multifile(wl:op_replacement/2).
:- dynamic(wl:op_replacement/2).
:- discontiguous(wl:op_replacement/2).

:- multifile(wl:setf_inverse/2).
:- dynamic(wl:setf_inverse/2).
:- discontiguous(wl:setf_inverse/2).

:- multifile(wl:declared_as/2).
:- dynamic(wl:declared_as/2).
:- discontiguous(wl:declared_as/2).

:- multifile(wl:error_hook/2).
:- dynamic(wl:error_hook/2).
:- discontiguous(wl:error_hook/2).

:- multifile(wl:init_args/2).
:- dynamic(wl:init_args/2).
:- discontiguous(wl:init_args/2).

:- multifile(wl:uses_rest_only/1).
:- dynamic(wl:uses_rest_only/1).
:- discontiguous(wl:uses_rest_only/1).

:- multifile(wl:interned_eval/1).
:- dynamic(wl:interned_eval/1).
:- discontiguous(wl:interned_eval/1).

:- multifile(wl:plugin_expand_progbody/6).
:- dynamic(wl:plugin_expand_progbody/6).
:- discontiguous(wl:plugin_expand_progbody/6).

:- multifile(wl:plugin_expand_progbody_1st/6).
:- dynamic(wl:plugin_expand_progbody/6).
:- discontiguous(wl:plugin_expand_progbody_1st/6).

% Ran at load
:- multifile(wl:interned_eval/1).
:- dynamic(wl:interned_eval/1).
:- discontiguous(wl:interned_eval/1).

% Ran at for rebuilding
:- multifile(wl:interned_eval_devel/1).
:- dynamic(wl:interned_eval_devel/1).
:- discontiguous(wl:interned_eval_devel/1).

:- multifile(wl:type_checked/1).
:- dynamic(wl:type_checked/1).
:- discontiguous(wl:type_checked/1).

:- dynamic(wl:pass_clause/3).
:- multifile(wl:pass_clause/3).
:- discontiguous(wl:pass_clause/3).

:- dynamic(wl:grovel_pred/3).
:- multifile(wl:grovel_pred/3).
:- discontiguous(wl:grovel_pred/3).


:- multifile(wl:coercion/3).
:- dynamic(wl:coercion/3).
:- discontiguous(wl:coercion/3).

:- discontiguous(wl:lambda_def/5).
:- dynamic(wl:lambda_def/5).
:- multifile(wl:lambda_def/5).
:- export(wl:lambda_def/5).
:- system:import(wl:lambda_def/5).

:- discontiguous(wl:arglist_info/5).
:- dynamic(wl:arglist_info/5).
:- multifile(wl:arglist_info/5).
:- export(wl:arglist_info/5).
:- system:import(wl:arglist_info/5).

:- discontiguous(wl:arglist_info/4).
:- dynamic(wl:arglist_info/4).
:- multifile(wl:arglist_info/4).
:- export(wl:arglist_info/4).
:- system:import(wl:arglist_info/4).

%:- dynamic(compile_assigns/4).
%:- multifile(compile_assigns/4).
%:- discontiguous(compile_assigns/4).

%:- dynamic(ssip_define/2).
:- multifile(ssip_define/2).
:- discontiguous(ssip_define/2).

:- use_module(library(logicmoo_common)).
:- user:ensure_loaded(library(logicmoo/portray_vars)).
:- ensure_loaded(eightball).
:- ensure_loaded('init').
:- ensure_loaded(utests).
:- ensure_loaded(places).
:- ensure_loaded(environs).
:- ensure_loaded(proclaim).
:- ensure_loaded(packages).
:- ensure_loaded(soops).
:- ensure_loaded(defmacro).
:- ensure_loaded(strings).
:- ensure_loaded(symbols).
:- ensure_loaded(lexvars).
:- ensure_loaded(condifs).
:- ensure_loaded(readers).

:- ensure_loaded(primitives).
:- ensure_loaded(conses).


:- ensure_loaded(arglists).
:- ensure_loaded(arrays).
:- ensure_loaded(backquote).
:- ensure_loaded(body).
:- ensure_loaded(prologfns).
:- ensure_loaded(compile).
:- ensure_loaded(conditions).
:- ensure_loaded(closures).
:- ensure_loaded(describe).
:- ensure_loaded(disassemble).
:- ensure_loaded(fileload).
:- ensure_loaded(threading).
:- ensure_loaded(funcall).
:- ensure_loaded(clstructs).

:- ensure_loaded(defun).
:- ensure_loaded(defgeneric).
:- ensure_loaded(hashtables).
:- ensure_loaded(interp).
:- ensure_loaded(mizepro).
:- ensure_loaded(namestrings).
:- ensure_loaded(numbers).
:- ensure_loaded(operatorfns).
:- ensure_loaded(pathnames).
:- ensure_loaded(printers).
:- ensure_loaded(readtables).
:- ensure_loaded(repl).
:- ensure_loaded(sequences).
:- ensure_loaded(streams).
:- ensure_loaded(block).
:- ensure_loaded(tagbody).
:- ensure_loaded(typecheck).
:- ensure_loaded(typeof).
:- ensure_loaded(loptions).
:- ensure_loaded(groveler).
:- ensure_loaded(paramfns).
:- ensure_loaded(socksrv).


/*
:- ensure_loaded(utils_for_swi).
:- ensure_loaded(utils_higher_order).
:- ensure_loaded(utils_list).
:- ensure_loaded(utils_oset).
:- ensure_loaded(utils_set).
:- ensure_loaded(utils_shortest_paths).
:- ensure_loaded(utils_writef).
%:- use_module(utils_list).
:- use_module(utils_higher_order).
*/

:- grovel_system_symbols.

