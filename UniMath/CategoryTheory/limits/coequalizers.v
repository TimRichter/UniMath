(* Direct implementation of coequalizers. *)
Require Import UniMath.Foundations.Basics.PartD.
Require Import UniMath.Foundations.Basics.Propositions.
Require Import UniMath.Foundations.Basics.Sets.

Require Import UniMath.CategoryTheory.precategories.
Require Import UniMath.CategoryTheory.UnicodeNotations.
Require Import UniMath.CategoryTheory.Epis.

Section def_coequalizers.

  Context {C : precategory}.

  (** Definition and construction of isCoequalizer. *)
  Definition isCoequalizer {x y z : C} (f g : x --> y) (e : y --> z)
             (H : f ;; e = g ;; e) : UU :=
    Π (w : C) (h : y --> w) (H : f ;; h = g ;; h),
      iscontr (Σ φ : z --> w, e ;; φ  = h).

  Definition mk_isCoequalizer {y z w : C} (f g : y --> z) (e : z --> w)
             (H : f ;; e = g ;; e) :
    (Π (w0 : C) (h : z --> w0) (H' : f ;; h = g ;; h),
        iscontr (Σ ψ : w --> w0, e ;; ψ = h)) -> isCoequalizer f g e H.
  Proof.
    intros X. unfold isCoequalizer. exact X.
  Defined.

  Lemma isaprop_isCoequalizer {y z w : C} (f g : y --> z) (e : z --> w)
        (H : f ;; e = g ;; e) :
    isaprop (isCoequalizer f g e H).
  Proof.
    repeat (apply impred; intro).
    apply isapropiscontr.
  Defined.

  (** Proves that the arrow from the coequalizer object with the right
    commutativity property is unique. *)
  Lemma isCoequalizerOutUnique {y z w: C} (f g : y --> z) (e : z --> w)
        (H : f ;; e = g ;; e) (E : isCoequalizer f g e H)
        (w0 : C) (h : z --> w0) (H' : f ;; h = g ;; h)
        (φ : w --> w0) (H'' : e ;; φ = h) :
    φ = (pr1 (pr1 (E w0 h H'))).
  Proof.
    set (T := tpair (fun ψ : w --> w0 => e ;; ψ = h) φ H'').
    set (T' := pr2 (E w0 h H') T).
    apply (base_paths _ _ T').
  Defined.

  (** Definition and construction of coequalizers. *)
  Definition Coequalizer {y z : C} (f g : y --> z) : UU :=
    Σ e : (Σ w : C, z --> w),
          (Σ H : f ;; (pr2 e) = g ;; (pr2 e), isCoequalizer f g (pr2 e) H).

  Definition mk_Coequalizer {y z w : C} (f g : y --> z) (e : z --> w)
             (H : f ;; e = g ;; e) (isE : isCoequalizer f g e H) :
    Coequalizer f g.
  Proof.
    simple refine (tpair _ _ _).
    - simple refine (tpair _ _ _).
      + apply w.
      + apply e.
    - simpl. refine (tpair _ H isE).
  Defined.

  (** Coequalizers in precategories. *)
  Definition Coequalizers := Π (y z : C) (f g : y --> z),
      Coequalizer f g.

  Definition hasCoequalizers := Π (y z : C) (f g : y --> z),
      ishinh (Coequalizer f g).

  (** Returns the coequalizer object. *)
  Definition CoequalizerObject {y z : C} {f g : y --> z} (E : Coequalizer f g) :
    C := pr1 (pr1 E).
  Coercion CoequalizerObject : Coequalizer >-> ob.

  (** Returns the coequalizer arrow. *)
  Definition CoequalizerArrow {y z : C} {f g : y --> z} (E : Coequalizer f g) :
    C⟦z, E⟧ := pr2 (pr1 E).

  (** The equality on morphisms that coequalizers must satisfy. *)
  Definition CoequalizerEqAr {y z : C} {f g : y --> z} (E : Coequalizer f g) :
    f ;; CoequalizerArrow E = g ;; CoequalizerArrow E := pr1 (pr2 E).

  (** Returns the property isCoequalizer from Coequalizer. *)
  Definition isCoequalizer_Coequalizer {y z : C} {f g : y --> z}
             (E : Coequalizer f g) :
    isCoequalizer f g (CoequalizerArrow E) (CoequalizerEqAr E) := pr2 (pr2 E).

  (** Every morphism which satisfy the coequalizer equality on morphism factors
    uniquely through the CoequalizerArrow. *)
  Definition CoequalizerOut {y z : C} {f g : y --> z} (E : Coequalizer f g)
             (w : C) (h : z --> w) (H : f ;; h = g ;; h) :
    C⟦E, w⟧ := pr1 (pr1 (isCoequalizer_Coequalizer E w h H)).

  Lemma CoequalizerCommutes {y z : C} {f g : y --> z} (E : Coequalizer f g)
        (w : C) (h : z --> w) (H : f ;; h = g ;; h) :
    (CoequalizerArrow E) ;; (CoequalizerOut E w h H) = h.
  Proof.
    exact (pr2 (pr1 ((isCoequalizer_Coequalizer E) w h H))).
  Defined.

  Lemma isCoequalizerOutsEq {y z w: C} {f g : y --> z} {e : z --> w}
        {H : f ;; e = g ;; e} (E : isCoequalizer f g e H)
        {w0 : C} (φ1 φ2: w --> w0) (H' : e ;; φ1 = e ;; φ2) : φ1 = φ2.
  Proof.
    assert (H'1 : f ;; e ;; φ1 = g ;; e ;; φ1).
    rewrite H. apply idpath.
    set (E' := mk_Coequalizer _ _ _ _ E).
    repeat rewrite <- assoc in H'1.
    set (E'ar := CoequalizerOut E' w0 (e ;; φ1) H'1).
    pathvia E'ar.
    apply isCoequalizerOutUnique. apply idpath.
    apply pathsinv0. apply isCoequalizerOutUnique. apply pathsinv0. apply H'.
  Defined.

  Lemma CoequalizerOutsEq {y z: C} {f g : y --> z} (E : Coequalizer f g)
        {w : C} (φ1 φ2: C⟦E, w⟧)
        (H' : (CoequalizerArrow E) ;; φ1 = (CoequalizerArrow E) ;; φ2) : φ1 = φ2.
  Proof.
    apply (isCoequalizerOutsEq (isCoequalizer_Coequalizer E) _ _ H').
  Defined.

  (** Morphisms between coequalizer objects with the right commutativity
    equalities. *)
  Definition identity_is_CoequalizerOut {y z : C} {f g : y --> z}
             (E : Coequalizer f g) :
    Σ φ : C⟦E, E⟧, (CoequalizerArrow E) ;; φ = (CoequalizerArrow E).
  Proof.
    exists (identity E).
    apply id_right.
  Defined.

  Lemma CoequalizerEndo_is_identity {y z : C} {f g : y --> z}
        {E : Coequalizer f g} (φ : C⟦E, E⟧)
        (H : (CoequalizerArrow E) ;; φ = CoequalizerArrow E) :
    identity E = φ.
  Proof.
    set (H1 := tpair ((fun φ' : C⟦E, E⟧ => _ ;; φ' = _)) φ H).
    assert (H2 : identity_is_CoequalizerOut E = H1).
    - apply proofirrelevance.
      apply isapropifcontr.
      apply (isCoequalizer_Coequalizer E).
      apply CoequalizerEqAr.
    - apply (base_paths _ _ H2).
  Defined.

  Definition from_Coequalizer_to_Coequalizer {y z : C} {f g : y --> z}
             (E E': Coequalizer f g) : C⟦E, E'⟧.
  Proof.
    apply (CoequalizerOut E E' (CoequalizerArrow E')).
    apply CoequalizerEqAr.
  Defined.

  Lemma are_inverses_from_Coequalizer_to_Coequalizer {y z : C} {f g : y --> z}
        {E E': Coequalizer f g} :
    is_inverse_in_precat (from_Coequalizer_to_Coequalizer E E')
                         (from_Coequalizer_to_Coequalizer E' E).
  Proof.
    split; apply pathsinv0; use CoequalizerEndo_is_identity;
    rewrite assoc; unfold from_Coequalizer_to_Coequalizer;
      repeat rewrite CoequalizerCommutes; apply idpath.
  Defined.

  Lemma isiso_from_Coequalizer_to_Coequalizer {y z : C} {f g : y --> z}
        (E E' : Coequalizer f g) :
    is_isomorphism (from_Coequalizer_to_Coequalizer E E').
  Proof.
    apply (is_iso_qinv _ (from_Coequalizer_to_Coequalizer E' E)).
    apply are_inverses_from_Coequalizer_to_Coequalizer.
  Defined.

  Definition iso_from_Coequalizer_to_Coequalizer {y z : C} {f g : y --> z}
             (E E' : Coequalizer f g) : iso E E' :=
    tpair _ _ (isiso_from_Coequalizer_to_Coequalizer E E').


  (** We prove that CoequalizerArrow is an epi. *)
  Lemma CoequalizerArrowisEpi {y z : C} {f g : y --> z} (E : Coequalizer f g ) :
    isEpi _ (CoequalizerArrow E).
  Proof.
    apply mk_isEpi.
    intros z0 g0 h X.
    apply (CoequalizerOutsEq E).
    apply X.
  Defined.

  Lemma CoequalizerArrowEpi {y z : C} {f g : y --> z} (E : Coequalizer f g ) :
    Epi _ z E.
  Proof.
    apply (mk_Epi _ (CoequalizerArrow E)).
    apply (CoequalizerArrowisEpi E).
  Defined.
End def_coequalizers.