(** * Zero Objects
  Zero objects are objects of precategory which are both initial objects and
  terminal object. *)

Require Import UniMath.Foundations.Basics.PartD.
Require Import UniMath.Foundations.Basics.Propositions.
Require Import UniMath.Foundations.Basics.Sets.

Require Import UniMath.CategoryTheory.total2_paths.
Require Import UniMath.CategoryTheory.precategories.
Require Import UniMath.CategoryTheory.UnicodeNotations.
Require Import UniMath.CategoryTheory.limits.graphs.colimits.
Require Import UniMath.CategoryTheory.limits.graphs.limits.
Require Import UniMath.CategoryTheory.limits.graphs.initial.
Require Import UniMath.CategoryTheory.limits.graphs.terminal.

Section def_zero.

  Context {C : precategory}.

  (** An object c is zero if it initial and terminal. *)
  Definition isZero (c : C) : UU := (isInitial C c) × (isTerminal C c).

  (** Construction of isZero for an object c from the conditions that the space
    of all morphisms from c to any object d is contractible and and the space of
    all morphisms from any object d to c is contractible. *)
  Definition mk_isZero (c : C) (H : (Π (d : C), iscontr (c --> d))
                                      × (Π (d : C), iscontr (d --> c))) :
    isZero c := mk_isInitial c (dirprod_pr1 H),,mk_isTerminal c (dirprod_pr2 H).

  (** Definition of Zero. *)
  Definition Zero : UU := Σ c : C, isZero c.
  Definition mk_Zero (c : C) (H : isZero c) : Zero := tpair _ c H.
  Definition ZeroObject (Z : Zero) : C := pr1 Z.

  (** Construction of Initial and Terminal from Zero. *)
  Definition Zero_to_Initial (Z : Zero) : Initial C :=
    mk_Initial (pr1 Z) (dirprod_pr1 (pr2 Z)).
  Definition Zero_to_Terminal (Z : Zero) : Terminal C :=
    mk_Terminal (pr1 Z) (dirprod_pr2 (pr2 Z)).

  (** The following lemmas show that the underlying objects of Initial
    and Terminal, constructed above, are equal to ZeroObject. *)
  Lemma ZeroObject_equals_InitialObject (Z : Zero) :
    ZeroObject Z = InitialObject (Zero_to_Initial Z).
  Proof.
    apply idpath.
  Defined.

  Lemma ZeroObject_equals_TerminalObject (Z : Zero) :
    ZeroObject Z = TerminalObject (Zero_to_Terminal Z).
  Proof.
    apply idpath.
  Defined.

  (** We construct morphisms from ZeroObject to any other object c and from any
    other object c to the ZeroObject. *)
  Definition ZeroArrowFrom (Z : Zero) (c : C) : C⟦ZeroObject Z, c⟧ :=
    InitialArrow (Zero_to_Initial Z) c.
  Definition ZeroArrowTo (Z : Zero) (c : C) : C⟦c, ZeroObject Z⟧ :=
    TerminalArrow (Zero_to_Terminal Z) c.

  (** In particular, we get a zero morphism between any objects. *)
  Definition ZeroArrow (Z : Zero) (c d : C) : C⟦c, d⟧ :=
    @compose C _ (ZeroObject Z) _ (ZeroArrowTo Z c) (ZeroArrowFrom Z d).

  (** We show that the above morphisms from ZeroObject and to ZeroObject are
    unique by using uniqueness of the morphism from InitialObject and uniqueness
    of the morphism to TerminalObject. *)
  Lemma ZeroArrowFromUnique (Z : Zero) (c : C) (f : C⟦ZeroObject Z, c⟧) :
    f = (ZeroArrowFrom Z c).
  Proof.
    apply (InitialArrowUnique (Zero_to_Initial Z) c f).
  Defined.

  Lemma ZeroArrowToUnique (Z : Zero) (c : C) (f : C⟦c, ZeroObject Z⟧) :
    f = (ZeroArrowTo Z c).
  Proof.
    apply (TerminalArrowUnique (Zero_to_Terminal Z) c f).
  Defined.

  (** Therefore, any two morphisms from the ZeroObject to an object c are
    equal and any two morphisms from an object c to the ZeroObject are equal. *)
  Corollary ArrowsFromZero (Z : Zero) (c : C) (f g : C⟦ZeroObject Z, c⟧) :
    f = g.
  Proof.
    eapply pathscomp0.
    apply (ZeroArrowFromUnique Z c f).
    apply pathsinv0.
    apply (ZeroArrowFromUnique Z c g).
  Defined.

  Corollary ArrowsToZero (Z : Zero) (c : C) (f g : C⟦c, ZeroObject Z⟧) :
    f = g.
  Proof.
    eapply pathscomp0.
    apply (ZeroArrowToUnique Z c f).
    apply pathsinv0.
    apply (ZeroArrowToUnique Z c g).
  Defined.

  (** It follows that any morphism which factors through 0 is the ZeroArrow. *)
  Corollary ZeroArrowUnique (Z : Zero) (c d : C) (f : C⟦c, ZeroObject Z⟧)
            (g : C⟦ZeroObject Z, d⟧) : f ;; g = ZeroArrow Z c d.
  Proof.
    rewrite (ZeroArrowToUnique Z c f).
    rewrite (ZeroArrowFromUnique Z d g).
    apply idpath.
  Defined.

  (** Compose any morphism with the ZeroArrow and you get the ZeroArrow. *)
  Lemma precomp_with_ZeroArrow (Z : Zero) (a b c : C) (f : C⟦a, b⟧) :
    f ;; ZeroArrow Z b c = ZeroArrow Z a c.
  Proof.
    unfold ZeroArrow at 1. rewrite assoc.
    apply ZeroArrowUnique.
  Defined.

  Lemma postcomp_with_ZeroArrow (Z : Zero) (a b c : C) (f : C⟦b, c⟧) :
    ZeroArrow Z a b ;; f = ZeroArrow Z a c.
  Proof.
    unfold ZeroArrow at 1. rewrite <- assoc.
    apply ZeroArrowUnique.
  Defined.

  (** An endomorphism of the ZeroObject is the identity morphism. *)
  Corollary ZeroEndo_is_identity (Z : Zero)
            (f : C⟦ZeroObject Z, ZeroObject Z⟧) :
    f = identity (ZeroObject Z).
  Proof.
    apply ArrowsFromZero.
  Defined.

  (** The morphism from ZeroObject to ZeroObject is an isomorphisms. *)
  Lemma isiso_from_Zero_to_Zero (Z Z' : Zero) :
    is_isomorphism (ZeroArrowFrom Z (ZeroObject Z')).
  Proof.
    apply (is_iso_qinv _ (ZeroArrowFrom Z' (ZeroObject Z))).
    split; apply ArrowsFromZero.
  Defined.

  (** Using the above lemma we can construct an isomorphisms between any two
    ZeroObjects. *)
  Definition iso_Zeros (Z Z' : Zero) : iso (ZeroObject Z) (ZeroObject Z') :=
    tpair _ (ZeroArrowFrom Z (ZeroObject Z')) (isiso_from_Zero_to_Zero Z Z').

  Definition hasZero := ishinh Zero.

  (** Construct Zero from Initial and Terminal for which the underlying objects
    are isomorphic. *)
  Definition Initial_and_Terminal_to_Zero
             (I : Initial C) (T : Terminal C)
             (e: iso (InitialObject I) (TerminalObject T)) : Zero.
  Proof.
    refine (mk_Zero (InitialObject I) _).
    split.
    - refine (mk_isInitial (InitialObject I) _); intro b.
      apply iscontrpair with (x := (InitialArrow I b)), InitialArrowUnique.
    - refine (mk_isTerminal (InitialObject I) _ ); intro a.
      apply (iscontrretract (postcomp_with (inv_from_iso e))
                            (postcomp_with (morphism_from_iso _ _ _  e))).
      intros y. unfold postcomp_with.
      rewrite <- assoc. rewrite (iso_inv_after_iso e).
      apply (remove_id_right _ _ _ y y _ (idpath _) (idpath _)).
      apply (iscontrpair (TerminalArrow T a)), TerminalArrowUnique.
  Defined.

  (** The following lemma verifies that the ZeroObject of the Zero,
    constructed from Initial and Terminal with InitialObject isomorphic to
    TerminalObject, is isomorphic to the InitialObject and isomorphic to the
    TerminalObject. *)
  Lemma Initial_and_Terminal_ob_equals_Zero_ob (I : Initial C)
        (T :Terminal C) (e : iso (InitialObject I) (TerminalObject T)) :
    (iso (InitialObject I) (ZeroObject (Initial_and_Terminal_to_Zero I T e)))
      × (iso (TerminalObject T)
             (ZeroObject (Initial_and_Terminal_to_Zero I T e))).
  Proof.
    exact(identity_iso (InitialObject I),,iso_inv_from_iso e).
  Defined.
End def_zero.

(** Following Initial and Terminal, we clear implicit arguments. *)
Arguments Zero : clear implicits.
Arguments isZero : clear implicits.
