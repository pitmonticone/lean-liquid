import topology.category.Profinite.as_limit
import topology.continuous_function.algebra
import locally_constant.SemiNormedGroup
import locally_constant.completion
import analysis.special_functions.pow
import topology.algebra.module.weak_dual

open_locale nnreal big_operators classical

noncomputable theory

open category_theory
open category_theory.limits
open topological_space

local attribute [instance]
  locally_constant.seminormed_add_comm_group
  locally_constant.pseudo_metric_space

lemma real.pow_nnnorm_sum_le
  {ι : Type*} [fintype ι] (r : ι → ℝ)
  (p : ℝ≥0) [fact (0 < p)] [fact (p ≤ 1)] :
  ∥ ∑ i, r i ∥₊^(p : ℝ) ≤ ∑ i, ∥ r i ∥₊^(p : ℝ) := sorry

namespace locally_constant

instance normed_space (X : Type*)
  [topological_space X] [compact_space X] [t2_space X] :
  normed_space ℝ (locally_constant X ℝ) :=
{ norm_smul_le := sorry,
  ..(infer_instance : module ℝ _) }

lemma nnnorm_apply_le_nnnorm (X : Type*)
  [topological_space X] [compact_space X] [t2_space X]
  (e : locally_constant X ℝ) (x : X) :
  ∥ e x ∥₊ ≤ ∥ e ∥₊ := sorry

end locally_constant

namespace topological_space.clopens

def indicator {X : Type*} [topological_space X] (U : clopens X) :
  C(X,ℝ) :=
{ to_fun := set.indicator U 1,
  continuous_to_fun := sorry }

def indicator_LC {X : Type*} [topological_space X] (U : clopens X) :
  locally_constant X ℝ :=
{ to_fun := set.indicator U 1,
  is_locally_constant := sorry }

lemma indicator_apply {X : Type*} [topological_space X] (U : clopens X) (x) :
  U.indicator x = if x ∈ U then 1 else 0 := rfl

lemma indicator_LC_apply {X : Type*} [topological_space X] (U : clopens X) (x) :
  U.indicator_LC x = if x ∈ U then 1 else 0 := rfl

end topological_space.clopens

namespace discrete_quotient

def fibre {X : Type*} [topological_space X] (T : discrete_quotient X)
  (t : T) : clopens X :=
{ carrier := T.proj ⁻¹' {t},
  clopen' := sorry }

def equiv_bot {X : Type*} [topological_space X] [discrete_topology X] :
  X ≃ (⊥ : discrete_quotient X) :=
equiv.of_bijective (discrete_quotient.proj _)
⟨λ x y h, quotient.exact' h, discrete_quotient.proj_surjective _⟩

lemma mem_fibre_iff {X : Type*} [topological_space X] [compact_space X] [t2_space X]
  (T : discrete_quotient X) (a : T) (b : X) :
  T.proj b ∈ discrete_quotient.fibre _ (equiv_bot a) ↔
  b ∈ discrete_quotient.fibre T a :=
begin
  obtain ⟨a,rfl⟩ := discrete_quotient.proj_surjective _ a,
  dsimp [fibre, equiv_bot],
  let TT : discrete_quotient T := ⊥,
  change T.proj b ∈ equiv_bot ⁻¹' {equiv_bot (T.proj a)} ↔ T.proj b ∈ {T.proj a},
  simp,
end

lemma mem_fibre_iff' {X : Type*} [topological_space X] [compact_space X] [t2_space X]
  (T : discrete_quotient X) (a : (⊥ : discrete_quotient T)) (b : X) :
  T.proj b ∈ discrete_quotient.fibre _ a ↔
  b ∈ discrete_quotient.fibre T (equiv_bot.symm a) :=
begin
  rw [← equiv_bot.apply_symm_apply a, mem_fibre_iff],
  simp,
end

end discrete_quotient

lemma locally_constant.eq_sum {X : Type*} [topological_space X] [compact_space X] [t2_space X]
  (e : locally_constant X ℝ) :
  e = ∑ t : e.discrete_quotient,
    e.locally_constant_lift t • (e.discrete_quotient.fibre t).indicator_LC :=
sorry

lemma locally_constant.nnnorm_eq {X : Type*} [topological_space X] [compact_space X] [t2_space X]
  (e : locally_constant X ℝ) :
  ∥ e ∥₊ = ⨆ t : e.discrete_quotient, ∥ e.locally_constant_lift t ∥₊ :=
sorry

def continuous_map.comap {X Y : Type*}
  [topological_space X] [topological_space Y]
  (f : C(X,Y)) : C(Y,ℝ) →L[ℝ] C(X,ℝ) :=
{ to_fun := λ g, g.comp f,
  map_add' := λ _ _, rfl,
  map_smul' := λ _ _, rfl,
  cont := by refine continuous_map.continuous_comp_left f }

def continuous_map.comap_LC {X Y : Type*}
  [topological_space X] [compact_space X] [t2_space X]
  [topological_space Y] [compact_space Y] [t2_space Y]
  (f : C(X,Y)) : locally_constant Y ℝ →L[ℝ] locally_constant X ℝ :=
{ to_fun := λ g,
  { to_fun := g ∘ f,
    is_locally_constant := λ S,
      by { rw set.preimage_comp, apply is_open.preimage f.2, apply g.2, } },
  map_add' := λ _ _, rfl,
  map_smul' := λ _ _, rfl,
  cont := sorry }

def lc_to_c (X : Type*)
  [topological_space X] [compact_space X] [t2_space X] :
  locally_constant X ℝ →L[ℝ] C(X,ℝ) :=
{ to_fun := λ f, f.to_continuous_map,
  map_add' := λ _ _, rfl,
  map_smul' := λ _ _, rfl,
  cont := sorry }

namespace weak_dual

def comap {A B : Type*}
  [add_comm_group A] [module ℝ A] [topological_space A]
  [add_comm_group B] [module ℝ B] [topological_space B]
  (f : A →L[ℝ] B) :
  weak_dual ℝ B →L[ℝ] weak_dual ℝ A :=
{ to_fun := λ g, g.comp f,
  map_add' := λ _ _, rfl,
  map_smul' := λ _ _, rfl,
  cont := begin
    apply weak_dual.continuous_of_continuous_eval,
    intros a,
    apply weak_dual.eval_continuous,
  end }

def bdd {X : Type*} [topological_space X] [compact_space X]
  (μ : weak_dual ℝ C(X,ℝ)) (p c : ℝ≥0) : Prop :=
∀ (T : discrete_quotient X),
  ∑ t : T, ∥ μ (T.fibre t).indicator ∥₊^(p : ℝ) ≤ c

def bdd_LC {X : Type*} [topological_space X] [compact_space X]
  (μ : weak_dual ℝ (locally_constant X ℝ)) (p c : ℝ≥0) : Prop :=
∀ (T : discrete_quotient X),
  ∑ t : T, ∥ μ (T.fibre t).indicator_LC ∥₊^(p : ℝ) ≤ c

lemma bdd_comap {X Y : Type*} {p c : ℝ≥0}
  [topological_space X] [compact_space X] [t2_space X]
  [topological_space Y] [compact_space Y] [t2_space Y]
  (μ : weak_dual ℝ C(X,ℝ)) (hμ : μ.bdd p c) (f : C(X,Y)) :
  (weak_dual.comap f.comap μ).bdd p c :=
sorry

lemma bdd_LC_comap {X Y : Type*} {p c : ℝ≥0}
  [topological_space X] [compact_space X] [t2_space X]
  [topological_space Y] [compact_space Y] [t2_space Y]
  (μ : weak_dual ℝ (locally_constant X ℝ)) (hμ : μ.bdd_LC p c) (f : C(X,Y)) :
  (weak_dual.comap f.comap_LC μ).bdd_LC p c :=
sorry

end weak_dual

namespace Profinite

@[derive topological_space]
def Radon (X : Profinite.{0}) (p c : ℝ≥0) [fact (0 < p)] [fact (p ≤ 1)] :
  Top.{0} :=
Top.of { μ : weak_dual ℝ C(X,ℝ) // μ.bdd p c }

@[derive topological_space]
def Radon_LC (X : Profinite.{0}) (p c : ℝ≥0) [fact (0 < p)] [fact (p ≤ 1)] :
  Top.{0} :=
Top.of { μ : weak_dual ℝ (locally_constant X ℝ) // μ.bdd_LC p c }

def map_Radon {X Y : Profinite.{0}} (f : X ⟶ Y)
  (p c : ℝ≥0) [fact (0 < p)] [fact (p ≤ 1)] :
  X.Radon p c ⟶ Y.Radon p c :=
{ to_fun := λ μ, ⟨weak_dual.comap f.comap μ.1,
    weak_dual.bdd_comap _ μ.2 _⟩,
  continuous_to_fun := begin
    apply continuous_subtype_mk,
    refine continuous.comp _ continuous_subtype_coe,
    exact continuous_linear_map.continuous _,
  end }

def map_Radon_LC {X Y : Profinite.{0}} (f : X ⟶ Y)
  (p c : ℝ≥0) [fact (0 < p)] [fact (p ≤ 1)] :
  X.Radon_LC p c ⟶ Y.Radon_LC p c :=
{ to_fun := λ μ, ⟨weak_dual.comap f.comap_LC μ.1,
    weak_dual.bdd_LC_comap _ μ.2 _⟩,
  continuous_to_fun := begin
    apply continuous_subtype_mk,
    refine continuous.comp _ continuous_subtype_coe,
    exact continuous_linear_map.continuous _,
  end }

def Radon_functor (p c : ℝ≥0) [fact (0 < p)] [fact (p ≤ 1)] :
  Profinite.{0} ⥤ Top.{0} :=
{ obj := λ X, X.Radon p c,
  map := λ X Y f, map_Radon f _ _,
  map_id' := λ X, by { ext, dsimp [map_Radon, weak_dual.comap], congr' 1,
    ext, refl },
  map_comp' := λ X Y Z f g, by { ext, refl } }

def Radon_LC_functor (p c : ℝ≥0) [fact (0 < p)] [fact (p ≤ 1)] :
  Profinite.{0} ⥤ Top.{0} :=
{ obj := λ X, X.Radon_LC p c,
  map := λ X Y f, map_Radon_LC f _ _,
  map_id' := λ X,
    by { ext, dsimp [map_Radon_LC, weak_dual.comap], congr' 1, ext, refl },
  map_comp' := λ X Y Z f g, by { ext, refl } }

.

def weak_dual_C_to_LC (X : Profinite.{0}) :
  weak_dual ℝ C(X,ℝ) →L[ℝ] weak_dual ℝ (locally_constant X ℝ) :=
weak_dual.comap $ lc_to_c _

def weak_dual_LC_to_C (X : Profinite.{0}) :
  weak_dual ℝ (locally_constant X ℝ) →L[ℝ] weak_dual ℝ C(X,ℝ) :=
{ to_fun := λ f,
  { to_fun := (locally_constant.pkg X ℝ).extend f,
    map_add' := sorry,
    map_smul' := sorry,
    cont := (locally_constant.pkg X ℝ).continuous_extend },
  map_add' := sorry,
  map_smul' := sorry,
  cont := sorry }

def weak_dual_C_equiv_LC (X : Profinite.{0}) :
  weak_dual ℝ C(X,ℝ) ≃L[ℝ] weak_dual ℝ (locally_constant X ℝ) :=
{ inv_fun := X.weak_dual_LC_to_C,
  left_inv := sorry,
  right_inv := sorry,
  continuous_to_fun := continuous_linear_map.continuous _,
  continuous_inv_fun := continuous_linear_map.continuous _,
  ..(X.weak_dual_C_to_LC) }

def Radon_to_Radon_LC (X : Profinite.{0}) (p c : ℝ≥0)
  [fact (0 < p)] [fact (p ≤ 1)]:
  X.Radon p c ⟶ X.Radon_LC p c :=
{ to_fun := λ μ, ⟨weak_dual_C_to_LC _ μ.1, μ.2⟩,
  continuous_to_fun := begin
    apply continuous_subtype_mk,
    refine continuous.comp _ continuous_subtype_coe,
    exact continuous_linear_map.continuous _,
  end }

def Radon_LC_to_Radon (X : Profinite.{0}) (p c : ℝ≥0)
  [fact (0 < p)] [fact (p ≤ 1)]:
  X.Radon_LC p c ⟶ X.Radon p c :=
{ to_fun := λ μ, ⟨weak_dual_LC_to_C _ μ.1, begin
    change (weak_dual_C_to_LC _ (weak_dual_LC_to_C _ μ.1)).bdd_LC p c,
    erw X.weak_dual_C_equiv_LC.apply_symm_apply,
    exact μ.2,
  end⟩,
  continuous_to_fun := begin
    apply continuous_subtype_mk,
    refine continuous.comp _ continuous_subtype_coe,
    exact continuous_linear_map.continuous _,
  end }

def Radon_iso_Radon_LC (X : Profinite.{0}) (p c : ℝ≥0)
  [fact (0 < p)] [fact (p ≤ 1)]:
  X.Radon p c ≅ X.Radon_LC p c :=
{ hom := X.Radon_to_Radon_LC p c,
  inv := X.Radon_LC_to_Radon p c,
  hom_inv_id' := begin
    ext t : 2,
    apply X.weak_dual_C_equiv_LC.symm_apply_apply,
  end,
  inv_hom_id' := begin
    ext t : 2,
    apply X.weak_dual_C_equiv_LC.apply_symm_apply,
  end } .

def Radon_LC_cone (X : Profinite.{0}) (p c : ℝ≥0) [fact (0 < p)] [fact (p ≤ 1)] :
  cone (X.diagram ⋙ Radon_LC_functor p c) :=
(Radon_LC_functor p c).map_cone X.as_limit_cone

namespace is_limit_Radon_LC_cone

variables (X : Profinite.{0}) (p c : ℝ≥0) [fact (0 < p)] [fact (p ≤ 1)]

def linear_map (S : cone (X.diagram ⋙ Radon_LC_functor p c)) (t : S.X) :
  locally_constant X ℝ →ₗ[ℝ] ℝ :=
{ to_fun := λ e, (S.π.app e.discrete_quotient t).1 e.locally_constant_lift,
  map_add' := begin
    intros e₁ e₂,
    let W₁ := e₁.discrete_quotient,
    let W₂ := e₂.discrete_quotient,
    let W₁₂ := (e₁ + e₂).discrete_quotient,
    let W := W₁ ⊓ W₂ ⊓ W₁₂,
    let π₁ : W ⟶ W₁ := hom_of_le (le_trans inf_le_left inf_le_left),
    let π₂ : W ⟶ W₂ := hom_of_le (le_trans inf_le_left inf_le_right),
    let π₁₂ : W ⟶ W₁₂ := hom_of_le inf_le_right,
    rw [← S.w π₁, ← S.w π₂, ← S.w π₁₂],
    dsimp [Radon_LC_functor, map_Radon_LC, weak_dual.comap, continuous_map.comap_LC],
    erw ← ((S.π.app W) t).1.map_add, congr' 1,
    ext ⟨⟩, refl
  end,
  map_smul' := begin
    intros r e,
    let W₁ := e.discrete_quotient,
    let W₂ := (r • e).discrete_quotient,
    let W := W₁ ⊓ W₂,
    let π₁ : W ⟶ W₁ := hom_of_le inf_le_left,
    let π₂ : W ⟶ W₂ := hom_of_le inf_le_right,
    rw [← S.w π₁, ← S.w π₂],
    dsimp [Radon_LC_functor, map_Radon_LC, weak_dual.comap, continuous_map.comap_LC],
    rw ← smul_eq_mul,
    erw ← ((S.π.app W) t).1.map_smul, congr' 1,
    ext ⟨⟩, refl
  end }

def weak_dual (S : cone (X.diagram ⋙ Radon_LC_functor p c)) (t : S.X) :
  weak_dual ℝ (locally_constant X ℝ) :=
linear_map.mk_continuous_of_exists_bound (linear_map X p c S t)
begin
  use c^(1/(p : ℝ)),
  intros e,
  suffices : ∥ linear_map X p c S t e ∥₊ ≤ c^(1/(p : ℝ)) * ∥ e ∥₊,
    by exact_mod_cast this,
  have hp : 0 < (p : ℝ) := by exact_mod_cast (fact.out (0 < p)),
  have hp' : (p : ℝ) ≠ 0,
  { exact ne_of_gt hp },
  rw [← nnreal.rpow_le_rpow_iff hp, nnreal.mul_rpow, ← nnreal.rpow_mul],
  rw [(show 1 / (p : ℝ) * p = 1, by field_simp), nnreal.rpow_one],
  have H := ((S.π.app e.discrete_quotient) t).2 ⊥,
  replace H := mul_le_mul H (le_refl (∥e∥₊^(p : ℝ))) (zero_le _) (zero_le _),
  refine le_trans _ H,
  rw [mul_comm, finset.mul_sum],
  nth_rewrite 0 e.eq_sum,
  simp_rw [linear_map.map_sum, linear_map.map_smul],
  refine le_trans (real.pow_nnnorm_sum_le _ _) _,
  have : ∑ (x : (⊥ : discrete_quotient e.discrete_quotient)),
    ∥e∥₊ ^ (p : ℝ) * ∥(((S.π.app e.discrete_quotient) t).val)
    ((⊥ : discrete_quotient e.discrete_quotient).fibre x).indicator_LC∥₊ ^ (p : ℝ) =
    ∑ (x : e.discrete_quotient), ∥e∥₊^(p : ℝ) *
      ∥ (linear_map X p c S t) (e.discrete_quotient.fibre x).indicator_LC ∥₊^(p : ℝ),
  { fapply finset.sum_bij',
    { intros a _, exact discrete_quotient.equiv_bot.symm a },
    { intros, exact finset.mem_univ _ },
    { intros, congr' 3, dsimp [linear_map],
      let T₁ := e.discrete_quotient,
      let T₂ := (e.discrete_quotient.fibre
        ((discrete_quotient.equiv_bot.symm) a)).indicator_LC.discrete_quotient,
      let T := T₁ ⊓ T₂,
      let π₁ : T ⟶ T₁ := hom_of_le inf_le_left,
      let π₂ : T ⟶ T₂ := hom_of_le inf_le_right,
      rw [← S.w π₁, ← S.w π₂],
      dsimp [Radon_LC_functor, map_Radon_LC, weak_dual.comap],
      congr' 1,
      ext b, obtain ⟨b,rfl⟩ := discrete_quotient.proj_surjective _ b,
      dsimp [continuous_map.comap_LC],
      change _ =
        (e.discrete_quotient.fibre ((discrete_quotient.equiv_bot.symm) a)).indicator_LC b,
      dsimp only [topological_space.clopens.indicator_LC_apply],
      rw (show X.fintype_diagram.map π₁ (T.proj b) = T₁.proj b, by refl),
      erw discrete_quotient.mem_fibre_iff' },
    { intros a _, exact discrete_quotient.equiv_bot a },
    { intros, exact finset.mem_univ _ },
    { intros, apply equiv.apply_symm_apply },
    { intros, apply equiv.symm_apply_apply } },
  rw this, clear this,
  apply finset.sum_le_sum, rintros x -,
  rw [smul_eq_mul, nnnorm_mul, nnreal.mul_rpow],
  refine mul_le_mul _ (le_refl _) (zero_le _) (zero_le _),
  apply nnreal.rpow_le_rpow _ (le_of_lt hp),
  obtain ⟨x,rfl⟩ := discrete_quotient.proj_surjective _ x,
  change ∥ e x ∥₊ ≤ _,
  apply locally_constant.nnnorm_apply_le_nnnorm,
end

def Radon_LC (S : cone (X.diagram ⋙ Radon_LC_functor p c)) (t : S.X) :
  X.Radon_LC p c :=
{ val := weak_dual X p c S t,
  property := begin
    intros T,
    dsimp [weak_dual, linear_map],
    convert (S.π.app T t).2 ⊥ using 1,
    fapply finset.sum_bij',
    { intros a _, exact discrete_quotient.equiv_bot a },
    { intros, apply finset.mem_univ },
    { intros a ha, congr' 2,
      let W := (T.fibre a).indicator_LC.discrete_quotient,
      let E := T ⊓ W,
      let π₁ : E ⟶ T := hom_of_le inf_le_left,
      let π₂ : E ⟶ W := hom_of_le inf_le_right,
      rw [← S.w π₁, ← S.w π₂],
      dsimp [Radon_LC_functor, map_Radon_LC, weak_dual.comap,
        continuous_map.comap_LC],
      congr' 1, ext b, obtain ⟨b,rfl⟩ := discrete_quotient.proj_surjective _ b,
      change (T.fibre a).indicator_LC b = _,
      dsimp [topological_space.clopens.indicator_LC_apply],
      erw discrete_quotient.mem_fibre_iff },
    { intros a _, exact discrete_quotient.equiv_bot.symm a },
    { intros, apply finset.mem_univ },
    { intros, apply equiv.symm_apply_apply },
    { intros, apply equiv.apply_symm_apply }
  end }

lemma continuous_Radon_LC (S : cone (X.diagram ⋙ Radon_LC_functor p c)) :
  continuous (Radon_LC X p c S) :=
begin
  apply continuous_subtype_mk,
  apply weak_dual.continuous_of_continuous_eval,
  intros e, dsimp [weak_dual, linear_map],
  refine continuous.comp (weak_dual.eval_continuous _) _,
  refine continuous.comp continuous_subtype_coe (continuous_map.continuous _),
end

end is_limit_Radon_LC_cone

def is_limit_Raon_LC_cone (X : Profinite.{0}) (p c : ℝ≥0) [fact (0 < p)] [fact (p ≤ 1)] :
  is_limit (X.Radon_LC_cone p c) :=
{ lift := λ S, ⟨is_limit_Radon_LC_cone.Radon_LC X p c S,
    is_limit_Radon_LC_cone.continuous_Radon_LC X p c S⟩,
  fac' := begin
    intros S T, ext t e,
    dsimp [Radon_LC_cone, Radon_LC_functor, map_Radon_LC,
      is_limit_Radon_LC_cone.weak_dual, is_limit_Radon_LC_cone.Radon_LC,
      weak_dual.comap, is_limit_Radon_LC_cone.linear_map],
    let W₁ := ((continuous_map.comap_LC (X.as_limit_cone.π.app T)) e).discrete_quotient,
    let W := W₁ ⊓ T,
    let π₁ : W ⟶ W₁ := hom_of_le inf_le_left,
    let π₂ : W ⟶ T := hom_of_le inf_le_right,
    rw [← S.w π₁, ← S.w π₂],
    dsimp [Radon_LC_functor, map_Radon_LC, weak_dual.comap],
    congr' 1, ext ⟨⟩, refl,
  end,
  uniq' := begin
    intros S m hm,
    ext t T,
    specialize hm T.discrete_quotient,
    apply_fun (λ e, (e t).1 T.locally_constant_lift) at hm,
    convert hm using 1,
    dsimp [is_limit_Radon_LC_cone.Radon_LC, is_limit_Radon_LC_cone.weak_dual,
      Radon_LC_cone, Radon_LC_functor, map_Radon_LC, weak_dual.comap],
    congr' 1, ext, refl,
  end }

end Profinite
