(* -*- coding: utf-8 -*- *)

Require Import UniMath.Foundations.FiniteSets.
Unset Automatic Introduction.
Require Import UniMath.Foundations.FunctionalExtensionality.
Local Open Scope poset.

(* types and univalence *)

Theorem UU_rect (X Y : UU) (P : X ≃ Y -> UU) :
  (∀ e : X=Y, P (univalence _ _ e)) -> ∀ f, P f.
Proof.
  intros ? ? ? ih ?.
  set (p := ih (invmap (univalence _ _) f)).
  set (h := homotweqinvweq (univalence _ _) f).
  exact (transportf P h p).
Defined.

Ltac type_induction f e := generalize f; apply UU_rect; intro e; clear f.

Definition weqbandf' { X Y : UU } (w : X ≃ Y ) (P:X -> UU) (Q: Y -> UU) ( fw : ∀ x:X, P x ≃ Q (w x) ) :
  (Σ x, P x) ≃ (Σ y, Q y).
Proof.
  intros.
  generalize w.
  apply UU_rect; intro e.
  (* this is a case where applying UU_rect is not as good as induction would be... *)
Abort.

Theorem hSet_rect (X Y : hSet) (P : X ≃ Y -> UU) :
  (∀ e : X=Y, P (hSet_univalence _ _ e)) -> ∀ f, P f.
Proof.
  intros ? ? ? ih ?.
  Set Printing Coercions.
  set (p := ih (invmap (hSet_univalence _ _) f)).
  set (h := homotweqinvweq (hSet_univalence _ _) f).
  exact (transportf P h p).
  Unset Printing Coercions.
Defined.

Ltac hSet_induction f e := generalize f; apply UU_rect; intro e; clear f.

(** partially ordered sets and ordered sets *)

Definition Poset_univalence_map {X Y:Poset} : X=Y -> PosetEquivalence X Y.
Proof. intros ? ? e. induction e. apply identityPosetEquivalence.
Defined.

Local Arguments isPosetEquivalence : clear implicits.
Local Arguments isaposetmorphism : clear implicits.

Lemma posetStructureIdentity {X:hSet} (R S:po X) :
  @isPosetEquivalence (X,,R) (X,,S) (idweq X) -> R=S.
Proof.
  intros ? ? ? e.
  apply total2_paths_second_isaprop. { apply isaprop_ispo. }
  induction R as [R r]; induction S as [S s]; simpl.
  apply funextfun; intro x; apply funextfun; intro y.
  unfold isPosetEquivalence in e.
  unfold isaposetmorphism in e; simpl in e.
  induction e as [e e'].
  unfold posetRelation in *. unfold invmap in *; simpl in *.
  apply uahp. { apply e. } { apply e'. }
Defined.

Lemma poTransport_logeq {X Y:hSet} (R:po X) (S:po Y) (f:X=Y) :
  @isPosetEquivalence (X,,R) (Y,,S) (hSet_univalence_map _ _ f)
  <-> transportf (po∘pr1hSet) f R = S.
Proof.
  split.
  { intros i. induction f. apply posetStructureIdentity. apply i. }
  { intros e. induction f. induction e. apply isPosetEquivalence_idweq. }
Defined.

Corollary poTransport_weq {X Y:hSet} (R:po X) (S:po Y) (f:X=Y) :
  @isPosetEquivalence (X,,R) (Y,,S) (hSet_univalence_map _ _ f)
  ≃ transportf (po∘pr1hSet) f R = S.
Proof.
  intros. apply weqimplimpl.
  { apply (pr1 (poTransport_logeq _ _ _)). }
  { apply (pr2 (poTransport_logeq _ _ _)). }
  { apply isaprop_isPosetEquivalence. }
  { apply isaset_po. }
Defined.

Local Lemma posetTransport_weq (X Y:Poset) : X≡Y ≃ X≅Y.
Proof.
  intros.
  refine (weqbandf _ _ _ _).
  { apply hSet_univalence. }
  intros e. apply invweq. apply poTransport_weq.
Defined.

Theorem Poset_univalence (X Y:Poset) : X=Y ≃ X≅Y.
Proof.
  intros.
  set (f := @Poset_univalence_map X Y).
  set (g := total2_paths_equiv _ X Y).
  set (h := posetTransport_weq X Y).
  set (f' := weqcomp g h).
  assert (k : pr1weq f' ~ f).
  try reflexivity.              (* this doesn't work *)
  { intro e. apply isinj_pr1_PosetEquivalence. induction e. reflexivity. }
  assert (l : isweq f).
  { apply (isweqhomot f'). exact k. apply weqproperty. }
  exact (f,,l).
Defined.

Definition Poset_univalence_compute {X Y:Poset} (e:X=Y) :
  Poset_univalence X Y e = Poset_univalence_map e.
Proof. reflexivity. Defined.

(* now we try to mimic this construction:

    Inductive PosetEquivalence (X Y:Poset) : Type := 
                  pathToEq : (X=Y) -> PosetEquivalence X Y.

    PosetEquivalence_rect
         : ∀ (X Y : Poset) (P : PosetEquivalence X Y -> Type),
           (∀ e : X = Y, P (pathToEq X Y e)) ->
           ∀ p : PosetEquivalence X Y, P p

*)

Theorem PosetEquivalence_rect (X Y : Poset) (P : X ≅ Y -> UU) :
  (∀ e : X = Y, P (Poset_univalence_map e)) -> ∀ f, P f.
Proof.
  intros ? ? ? ih ?.
  set (p := ih (invmap (Poset_univalence _ _) f)).
  set (h := homotweqinvweq (Poset_univalence _ _) f).
  exact (transportf P h p).
Defined.

Ltac poset_induction f e :=
  generalize f; apply PosetEquivalence_rect; intro e; clear f.

(* applications of poset equivalence induction: *)

Lemma isMinimal_preserved {X Y:Poset} {x:X} (is:isMinimal x) (f:X ≅ Y) :
  isMinimal (f x).
Proof.
  intros.
  (* Anders says " induction f. " should look for PosetEquivalence_rect.  
     Why doesn't it? *)
  poset_induction f e. induction e. simpl. exact is.
Defined.

Lemma isMaximal_preserved {X Y:Poset} {x:X} (is:isMaximal x) (f:X ≅ Y) :
  isMaximal (f x).
Proof. intros. poset_induction f e. induction e. simpl. exact is.
Defined.

Lemma consecutive_preserved {X Y:Poset} {x y:X} (is:consecutive x y) (f:X ≅ Y) : consecutive (f x) (f y).
Proof. intros. poset_induction f e. induction e. simpl. exact is.
Defined.

(** * Ordered sets *)

(** see Bourbaki, Set Theory, III.1, where they are called totally ordered sets *)


Definition isOrdered (X:Poset) := istotal (pr1 (pr2 X)) × isantisymm (pr1 (pr2 X)).

Lemma isaprop_isOrdered (X:Poset) : isaprop (isOrdered X).
Proof.
  intros. apply isapropdirprod. { apply isaprop_istotal. } { apply isaprop_isantisymm. }
Defined.

Definition OrderedSet := Σ X, isOrdered X.

Local Definition underlyingPoset (X:OrderedSet) : Poset := pr1 X.
Coercion underlyingPoset : OrderedSet >-> Poset.

Local Definition underlyingRelation (X:OrderedSet) := pr1 (pr2 (pr1 X)).

Delimit Scope oset with oset. 

Notation "X ≅ Y" := (PosetEquivalence X Y) (at level 60, no associativity) : oset.
Notation "m ≤ n" := (underlyingRelation _ m n) (no associativity, at level 70) : oset.
Notation "m < n" := (m ≤ n × m != n)%oset (only parsing) :oset.

Close Scope poset.
Local Open Scope oset.

Lemma isincl_underlyingPoset : isincl underlyingPoset.
Proof.
  apply isinclpr1. intros X. apply isaprop_isOrdered.
Defined.

Lemma isinj_underlyingPoset : isinj underlyingPoset.
Proof.
  apply invmaponpathsincl. apply isincl_underlyingPoset.
Defined.

Definition underlyingPoset_weq (X Y:OrderedSet) :
  X=Y ≃ (underlyingPoset X)=(underlyingPoset Y).
Proof.
  Set Printing Coercions.
  intros. refine (weqpair _ _).
  { apply maponpaths. }
  apply isweqonpathsincl. apply isincl_underlyingPoset.
  Unset Printing Coercions.
Defined.

Theorem OrderedSet_univalence (X Y:OrderedSet) : X=Y ≃ X≅Y.
Proof. intros. exact ((Poset_univalence _ _) ∘ (underlyingPoset_weq _ _))%weq.
Defined.

Theorem OrderedSetEquivalence_rect (X Y : OrderedSet) (P : X ≅ Y -> UU) :
  (∀ e : X = Y, P (OrderedSet_univalence _ _ e)) -> ∀ f, P f.
Proof.
  intros ? ? ? ih ?.
  set (p := ih (invmap (OrderedSet_univalence _ _) f)).
  set (h := homotweqinvweq (OrderedSet_univalence _ _) f).
  exact (transportf P h p).
Defined.

Ltac oset_induction f e := generalize f; apply OrderedSetEquivalence_rect; intro e; clear f.
  
(* standard ordered sets *)

Definition FiniteOrderedSet := Σ X:OrderedSet, isfinite X.
Definition underlyingOrderedSet (X:FiniteOrderedSet) : OrderedSet := pr1 X.
Coercion underlyingOrderedSet : FiniteOrderedSet >-> OrderedSet.
Definition finitenessProperty (X:FiniteOrderedSet) : isfinite X := pr2 X.

Definition standardFiniteOrderedSet (n:nat) : FiniteOrderedSet.
Proof.
  intros.
  refine (_,,_).
  { exists (stnposet n). split.
    { intros x y. apply istotalnatleh. }
    intros ? ? ? ?. apply isinjstntonat. now apply isantisymmnatleh. }
  { apply isfinitestn. }
Defined.

Local Notation "⟦ n ⟧" := (standardFiniteOrderedSet n) (at level 0). (* in agda-mode \[[ n \]] *)

Definition FiniteStructure (X:OrderedSet) := Σ n, ⟦ n ⟧ ≅ X.

(* Definition characteristicFunction {X}  *)

Lemma subset_finiteness {X} (P : hsubtypes X) :
  (∀ x, isdecprop (P x)) -> isfinite X -> isfinite P.
Proof.
  intros ? ? isdec isfin.
  apply isfin; intro fin; clear isfin.
  unfold finstruct in fin.
  induction fin as [m w].
  unfold nelstruct in w.
  type_induction w e.
  induction e.
  apply hinhpr.
  unfold finstruct.
  unfold hsubtypes in P.



Abort.

Local Lemma std_auto n : iscontr (⟦ n ⟧ ≅ ⟦ n ⟧).
Proof.
  intros. exists (identityPosetEquivalence _). intros f.
  apply total2_paths_isaprop.
  { intros g. apply isaprop_isPosetEquivalence. }
  simpl. apply isinjpr1weq. simpl. apply funextfun. intros i.
    

Abort.

Lemma isapropFiniteStructure X : isaprop (FiniteStructure X).
Proof.
  intros.
  apply invproofirrelevance; intros r s.
  destruct r as [m p].
  destruct s as [n q].
  apply total2_paths2_second_isaprop.
  { 
    apply weqtoeqstn.
    exact (weqcomp (pr1 p) (invweq (pr1 q))).
  }
  {
    intros k.
    apply invproofirrelevance; intros [[r b] i] [[s c] j]; simpl in r,s,i,j.
    apply total2_paths2_second_isaprop.
    { 
      apply total2_paths2_second_isaprop.
      { 
        
        
        
        admit. }
      apply isapropisweq. }
    apply isaprop_isPosetEquivalence.
  }
Abort.

Theorem enumeration_FiniteOrderedSet (X:FiniteOrderedSet) : iscontr (FiniteStructure X).
Proof.
  intros.
  refine (_,,_).
  { exists (fincard (finitenessProperty X)).

Abort.

