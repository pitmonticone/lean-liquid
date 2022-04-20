-- import laurent_measures.functor
import analysis.special_functions.logb
import for_mathlib.pi_induced
import laurent_measures.thm69
-- import data.real.basic

/-
This files introduces the maps `Θ`, `Φ` (***and `Ψ` ???***), which are the "measurifications" of
`θ`, `ϕ` (*** and `ψ` ???***)
`laurent_measures.thm69`, they are morphisms in the right category.

We then prove in **???** that `θ_ϕ_exact` of `laurent_measures.thm69` becomes a short exact sequence
in the category **???**.
-/


noncomputable theory

universe u

namespace laurent_measures_ses

open laurent_measures pseudo_normed_group comphaus_filtered_pseudo_normed_group
open comphaus_filtered_pseudo_normed_group_hom
open_locale big_operators nnreal

section phi_to_hom

-- parameter {p : ℝ≥0}
-- variables [fact(0 < p)] [fact (p < 1)]
-- local notation `r` := @r p
-- local notation `ℳ` := real_measures p

variable {r : ℝ≥0}
variables [fact (0 < r)]
variable {S : Fintype}

local notation `ℒ` := laurent_measures r
local notation `ϖ` := Fintype.of punit

variables {M₁ M₂ : Type u} [comphaus_filtered_pseudo_normed_group M₁]
  [comphaus_filtered_pseudo_normed_group M₂]

def cfpng_hom_add (f g : comphaus_filtered_pseudo_normed_group_hom M₁ M₂) :
  (comphaus_filtered_pseudo_normed_group_hom M₁ M₂) :=
begin
  apply mk_of_bound (f.to_add_monoid_hom + g.to_add_monoid_hom) (f.bound.some + g.bound.some),
  intro c,
  refine ⟨_, _⟩,
  { intros x hx,
      simp only [comphaus_filtered_pseudo_normed_group_hom.coe_mk],
      simp only [add_monoid_hom.add_apply, coe_to_add_monoid_hom],
      convert pseudo_normed_group.add_mem_filtration (f.bound.some_spec hx) (g.bound.some_spec hx),
      rw add_mul, },
  let f₀ : filtration M₁ c → filtration M₂ (f.bound.some * c) := λ x, ⟨f x, f.bound.some_spec x.2⟩,
  have hf₀ : continuous f₀ := f.continuous _ (λ x, rfl),
  let g₀ : filtration M₁ c → filtration M₂ (g.bound.some * c) := λ x, ⟨g x, g.bound.some_spec x.2⟩,
  have hg₀ : continuous g₀ := g.continuous _ (λ x, rfl),
  simp only [add_monoid_hom.add_apply, coe_to_add_monoid_hom],
  haveI : fact ((f.bound.some * c + g.bound.some * c) ≤ ((f.bound.some + g.bound.some) * c) ) :=
    fact.mk (le_of_eq (add_mul _ _ _).symm),
  let ι : filtration M₂ (f.bound.some * c + g.bound.some * c) → filtration M₂
    ((f.bound.some + g.bound.some) * c) := cast_le,
  have hι : continuous ι := continuous_cast_le _ _,
  let S₀ : filtration M₂ (f.bound.some * c) × filtration M₂ (g.bound.some * c) →
    filtration M₂ (f.bound.some * c + g.bound.some * c) :=
      λ x, ⟨x.fst + x.snd, add_mem_filtration x.fst.2 x.snd.2⟩,
  have hS₀ := continuous_add' (f.bound.some * c) (g.bound.some * c),
  exact hι.comp (hS₀.comp (continuous.prod_mk hf₀ hg₀)),
end

def cfpng_hom_neg (f : comphaus_filtered_pseudo_normed_group_hom M₁ M₂) :
  (comphaus_filtered_pseudo_normed_group_hom M₁ M₂) :=
begin
  apply mk_of_bound (- f.to_add_monoid_hom) (f.bound.some),
  intro c,
  refine ⟨_, _⟩,
  { intros x hx,
    simp only [comphaus_filtered_pseudo_normed_group_hom.coe_mk],
    convert pseudo_normed_group.neg_mem_filtration (f.bound.some_spec hx) },
  let f₀ : filtration M₁ c → filtration M₂ (f.bound.some * c) := λ x, ⟨f x, f.bound.some_spec x.2⟩,
  have hf₀ : continuous f₀ := f.continuous _ (λ x, rfl),
  exact (continuous_neg' _).comp hf₀,
end

instance : add_comm_group (comphaus_filtered_pseudo_normed_group_hom M₁ M₂) :=
{ add := cfpng_hom_add,
  add_assoc := by {intros, ext, apply add_assoc},
  zero := 0,
  zero_add := by {intros, ext, apply zero_add},
  add_zero := by {intros, ext, apply add_zero},
  neg := cfpng_hom_neg,
  add_left_neg := by {intros, ext, apply add_left_neg},
  add_comm := by {intros, ext, apply add_comm} }

variable (S)

def Φ : comphaus_filtered_pseudo_normed_group_hom (ℒ S) (ℒ S) := 2 • shift (-1) - id
-- variable {S}

lemma Φ_eq_ϕ (F : ℒ S) : Φ S F = ϕ F := rfl

lemma Φ_bound_by_3 [fact (r ≤ 1)] :
  (Φ S : comphaus_filtered_pseudo_normed_group_hom (ℒ S) (ℒ S)).bound_by 3 :=
begin
  let sh : comphaus_filtered_pseudo_normed_group_hom (ℒ S) (ℒ S) := shift (-1),
  have Hsh : sh.bound_by 1,
  { refine (mk_of_bound_bound_by _ _ _).mono 1 _,
    rw [neg_neg], exact (pow_one r).le.trans (fact.out _) },
  suffices : (sh + sh + (-id)).bound_by (1 + 1 + 1),
  { convert this using 1, ext1, dsimp only [Φ_eq_ϕ, ϕ], erw two_nsmul, refl, },
  refine (Hsh.add Hsh).add (mk_of_bound_bound_by _ _ _).neg,
end

lemma Φ_natural (S T : Fintype) (f : S ⟶ T) (F : ℒ S) (t : T) (n : ℤ) :
  Φ T (map f F) t n = laurent_measures.map f (Φ S F) t n :=
begin
  simp only [Φ_eq_ϕ],
  dsimp only [ϕ],
  sorry,
end

end phi_to_hom

section theta

open theta real_measures

parameter (p : ℝ≥0)
local notation `r` := @r p
local notation `ℳ` := real_measures p
local notation `ℒ` := laurent_measures r

variable {S : Fintype.{u}}

local notation `ϖ` := Fintype.of (punit : Type u)

def seval_ℒ_c (c : ℝ≥0) (s : S) : filtration (ℒ S) c → (filtration (ℒ ϖ) c) :=
λ F,
begin
  refine ⟨seval_ℒ S s F, _⟩,
  have hF := F.2,
  simp only [filtration, set.mem_set_of_eq, seval_ℒ, nnnorm, laurent_measures.coe_mk,
    fintype.univ_punit, finset.sum_singleton] at ⊢ hF,
  have := finset.sum_le_sum_of_subset (finset.singleton_subset_iff.mpr $ finset.mem_univ_val _),
  rw finset.sum_singleton at this,
  apply le_trans this hF,
end

variable [fact (0 < p)]

lemma θ_zero : θ (0 : ℒ S) = 0 :=
begin
  dsimp only [θ, theta.ϑ],
  funext,
  simp only [laurent_measures.zero_apply, int.cast_zero, zero_mul, tsum_zero, real_measures.zero_apply],
end

variable [fact (p < 1)]

lemma θ_add (F G : ℒ S) : θ (F + G) = θ F + θ G :=
begin
  dsimp only [θ, theta.ϑ],
  funext,
  simp only [laurent_measures.add_apply, int.cast_add, one_div, inv_zpow', zpow_neg₀, real_measures.add_apply, tsum_add],
  rw ← tsum_add,
  { congr,
    funext,
    rw add_mul },
  all_goals {apply summable_of_summable_norm, simp_rw [norm_mul, norm_inv, norm_zpow, real.norm_two,
    ← inv_zpow₀, inv_eq_one_div] },
  exact aux_thm69.summable_smaller_radius_norm F.d r_half (F.summable s) (λ n, lt_d_eq_zero _ _ _),
  exact aux_thm69.summable_smaller_radius_norm G.d r_half (G.summable s) (λ n, lt_d_eq_zero _ _ _),
end

--for mathlib
lemma nnreal.rpow_int_cast (x : ℝ≥0) (n : ℤ) : x ^ n = x ^ (n : ℝ) := by {
  rw [← nnreal.coe_eq, nnreal.coe_zpow, ← real.rpow_int_cast, ← nnreal.coe_rpow] }

lemma nnreal.rpow_le_rpow_of_exponent_le {x : ℝ≥0} (x1 : 1 ≤ x) {y z : ℝ}
  (hyz : y ≤ z) :
  x ^ y ≤ x ^ z :=
by { cases x with x hx, exact real.rpow_le_rpow_of_exponent_le x1 hyz }

lemma nnreal.tsum_geom_arit_inequality (f: ℤ → ℝ) {r' : ℝ} (hr'1 : 0 < r') (hr'2 : r' ≤ 1)
  (hs1 : summable (λ n, f n)) (hs2 : summable (λ n, ∥(f n)∥₊ ^ r')) :
  ∥ tsum (λ n, f n) ∥₊ ^ r' ≤ tsum (λ n, ∥(f n)∥₊ ^ r' ) :=
begin
  rw ← summable_norm_iff at hs1,
  simp_rw ← _root_.coe_nnnorm at hs1,
  rw nnreal.summable_coe at hs1,
  refine le_trans (nnreal.rpow_le_rpow (nnnorm_tsum_le hs1) hr'1.le) _,
  have := λ s : finset ℤ, nnreal.rpow_sum_le_sum_rpow s (λ i, ∥f i∥₊) hr'1 hr'2,
  dsimp only at this,
  have s1' := filter.tendsto.comp (continuous.tendsto
    (nnreal.continuous_rpow_const hr'1.le) _) hs1.has_sum,
  dsimp [function.comp] at s1',
  apply tendsto_le_of_eventually_le s1' hs2.has_sum,
  delta filter.eventually_le,
  convert filter.univ_sets _,
  ext x,
  simp [this],
end


lemma aux_bound (F : ℒ S) (s : S) : ∀ (b : ℤ), ∥(F s b : ℝ) ∥₊ ^ (p : ℝ) *
  (2⁻¹ ^ (p : ℝ)) ^ (b : ℝ) ≤ ∥F s b∥₊ * r ^ b :=
begin
  intro b,
  rw [inv_eq_one_div, nnreal.rpow_int_cast],
  refine mul_le_mul_of_nonneg_right _ (real.rpow_nonneg_of_nonneg (nnreal.coe_nonneg _) _),
  have p_le_one : (p : ℝ) ≤ 1,
  { rw ← nnreal.coe_one,
    exact (nnreal.coe_lt_coe.mpr $ fact.out _).le },
  by_cases hF_nz : F s b = 0,
  { rw [hF_nz, int.cast_zero, nnnorm_zero, nnnorm_zero, nnreal.zero_rpow],
    rw [ne.def, ← nnreal.coe_zero, nnreal.coe_eq, ← ne.def],
    exact ne_of_gt (fact.out _) },
  { convert nnreal.rpow_le_rpow_of_exponent_le _ p_le_one,
    { rw nnreal.rpow_one,
      refl },
    { refine not_lt.mp (λ hf, hF_nz (int.eq_zero_iff_abs_lt_one.mp _)),
      suffices : (|F s b| : ℝ) < 1, exact_mod_cast this,
      rw ← int.norm_eq_abs,
      rwa [← nnreal.coe_lt_coe, ← nnnorm_norm, real.nnnorm_of_nonneg (norm_nonneg _)] at hf } }
end

lemma θ_bound : ∀ c : ℝ≥0, ∀ F : (ℒ S), F ∈ filtration (ℒ S) c → (θ F) ∈ filtration (ℳ S)
  (1 * c) :=
begin
  intros c F hF,
  rw laurent_measures.mem_filtration_iff at hF,
  dsimp only [laurent_measures.has_nnnorm] at hF,
  rw [one_mul, real_measures.mem_filtration_iff],
  dsimp only [real_measures.has_nnnorm, θ, theta.ϑ],
  let T := S.2.1,
  have ineq : ∀ (s ∈ T), ∥∑' (n : ℤ), ((F s n) : ℝ) * (1 / 2) ^ n∥₊ ^ (p : ℝ) ≤ ∑' (n : ℤ),
    ∥ ((F s n) : ℝ) * (1 / 2) ^ n∥₊ ^ (p : ℝ),
  { intros s hs,
    apply nnreal.tsum_geom_arit_inequality (λ n, ((F s n) * (1 / 2) ^ n)),
    { norm_num, exact fact.out _},
    { suffices : p ≤ 1, assumption_mod_cast, exact fact.out _},
    { dsimp only,
      obtain ⟨d, hd⟩ := exists_bdd_filtration (r_pos) (r_lt_one) F,
      apply aux_thm69.summable_smaller_radius d (F.summable s) (hd s) r_half },
    { dsimp only,
      simp_rw [nnnorm_mul, nnreal.mul_rpow],
      have := F.summable s,
      rw ← nnreal.summable_coe,
      apply summable_of_nonneg_of_le (λ i, _) _ this, apply nnreal.zero_le_coe,
      intro n,
      push_cast,
      apply mul_le_mul,
      { -- true because ∥integer∥ is either 0 or >= 1
        norm_cast,
        by_cases h : F s n = 0,
        { simp only [h, norm_zero],
          refine le_of_eq (real.zero_rpow _),
          norm_cast,
          exact ne_of_gt (fact.out _) },
        { nth_rewrite 1 (real.rpow_one (∥F s n∥)).symm,
          apply real.rpow_le_rpow_of_exponent_le,
          { rw [int.norm_eq_abs, le_abs'],
            norm_cast,
            rcases lt_trichotomy 0 (F s n) with (hF|hF|hF),
            { right, linarith },
            { exact false.elim (h hF.symm) },
            { left, change _ ≤ -(1 : ℤ), linarith, } },
          { norm_cast, exact fact.out _ } } },
      { apply le_of_eq,
        rw [← r_coe],
        rw real.norm_of_nonneg,
        { -- can't use pow_mul yet because one is int one is real
          rw [← real.rpow_int_cast, ← real.rpow_int_cast],
          rw [← real.rpow_mul, mul_comm, real.rpow_mul];
          norm_num },
        { apply zpow_nonneg,
          norm_num } },
      { refine (real.rpow_pos_of_pos _ _).le,
        rw norm_pos_iff,
        apply zpow_ne_zero,
        norm_num, },
      { apply norm_nonneg, } } },
  apply (finset.sum_le_sum ineq).trans,
  simp_rw [nnnorm_mul, ← inv_eq_one_div, nnnorm_zpow, nnnorm_inv, nnreal.mul_rpow, real.nnnorm_two,
    nnreal.rpow_int_cast, ← nnreal.rpow_mul (2 : ℝ≥0)⁻¹, mul_comm, nnreal.rpow_mul (2 : ℝ≥0)⁻¹],
  apply le_trans _ hF,
  apply finset.sum_le_sum,
  intros s hs,
  apply tsum_le_tsum,
  exact aux_bound p F s,
  refine nnreal.summable_of_le _ (F.2 s),
  exacts [aux_bound p F s, F.2 s],
end


lemma θ_bound' :  ∀ c : ℝ≥0, ∀ F : (ℒ S), F ∈ filtration (ℒ S) c → (θ F) ∈ filtration (ℳ S)
  c :=by { simpa [one_mul] using (θ_bound p)}

def θ_to_add : (ℒ S) →+ (ℳ S) :=
{ to_fun := λ F, θ F,
  map_zero' := θ_zero,
  map_add' := θ_add, }

variable (S)

open theta metric real_measures

def seval_ℳ_c (c : ℝ≥0) (s : S) : filtration (ℳ S) c → (filtration (ℳ ϖ) c) :=
λ x,
  begin
  refine ⟨(λ _, x.1 s), _⟩,
  have hx := x.2,
  simp only [filtration, set.mem_set_of_eq, nnnorm, laurent_measures.coe_mk,
    fintype.univ_punit, finset.sum_singleton] at ⊢ hx,
  have := finset.sum_le_sum_of_subset (finset.singleton_subset_iff.mpr $ finset.mem_univ_val _),
  rw finset.sum_singleton at this,
  apply le_trans this hx,
end

--not sure if these are needed
-- def cast_ℳ_c (c : ℝ≥0) : filtration (ℳ S) c → (S → {x : ℝ // ∥ x ∥ ^ (p : ℝ) ≤ c}) :=
-- begin
--   intros x s,
--   refine ⟨x.1 s, _⟩,
--   have hx := x.2,
--   simp only [filtration, set.mem_set_of_eq, seval_ℒ, nnnorm, laurent_measures.coe_mk,
--     fintype.univ_punit, finset.sum_singleton] at hx,
--   have := finset.sum_le_sum_of_subset (finset.singleton_subset_iff.mpr $ finset.mem_univ_val _),
--   rw finset.sum_singleton at this,
--   apply le_trans this hx,
-- end


-- **[FAE]** From here everything might be useless until `lemma inducing_cast_ℳ`: check
-- also the `variable (c : ℝ≥0)` issue; the idea is to replace cast_ℳ_c with α, for which
-- everything seems to work

variable (c : ℝ≥0)

def box := {F : (ℳ S) // ∀ s, ∥ F s ∥₊ ^ (p : ℝ) ≤ c }

instance : has_coe (box S c) (ℳ S) := by {dsimp only [box], apply_instance}
instance : topological_space (ℳ S) := by {dsimp only [real_measures], apply_instance}
instance : topological_space (box S c) := by {dsimp only [box], apply_instance}


def equiv_box_ϖ : (box S c) ≃ Π (s : S), (filtration (ℳ ϖ) c) :=
begin
  fconstructor,
  { intros F s,
    use seval_ℳ S s F.1,
    simp only [real_measures.mem_filtration_iff, nnnorm, fintype.univ_punit,
      finset.sum_singleton, seval_ℳ],
    exact F.2 s },
  { intro G,
    use λ s, (G s).1 punit.star,
    intro s,
    simpa only [real_measures.mem_filtration_iff, nnnorm, fintype.univ_punit,
      finset.sum_singleton, seval_ℳ] using (G s).2 },
  { intro _,
    ext s,
    simpa only [seval_ℳ] },
  { intro G,
    ext s,
    simp only [seval_ℳ, subtype.val_eq_coe, subtype.coe_mk],
    induction x,
    refl }
end

def homeo_box_ϖ : (box S c) ≃ₜ Π (s : S), (filtration (ℳ ϖ) c) :=
{ to_equiv := equiv_box_ϖ S c,
  continuous_to_fun := begin
    apply continuous_pi,
    intro s,
    dsimp only [equiv_box_ϖ, seval_ℳ],
    refine continuous_subtype_mk (λ (x : box p S c), equiv_box_ϖ._proof_3 p S c x s)
      (continuous_pi (λ (i : ↥(Fintype.of punit)), _)),
    exact continuous_pi_iff.mp continuous_induced_dom s,
  end,
  continuous_inv_fun :=
  begin
    dsimp only [equiv_box_ϖ, seval_ℳ],
    refine continuous_subtype_mk (λ (x : ↥S → ↥(filtration (real_measures p (Fintype.of punit)) c)),
      equiv_box_ϖ._proof_4 p S c x) _,
    apply continuous_pi,
    intro s,
    have h : continuous (λ (a : S → (filtration (ℳ ϖ) c)), (a s).val)
       := continuous.subtype_coe (continuous_apply s),
    have H := continuous_apply punit.star,
    exact H.comp h,
  end}


def α : filtration (ℳ S) c → box S c :=
begin
  intro x,
  use x,
  have hx := x.2,
  intro s,
  simp only [filtration, set.mem_set_of_eq, nnnorm, laurent_measures.coe_mk,
    fintype.univ_punit, finset.sum_singleton] at hx,
  have := finset.sum_le_sum_of_subset (finset.singleton_subset_iff.mpr $ finset.mem_univ_val _),
  rw finset.sum_singleton at this,
  apply le_trans this hx,
end


lemma coe_α_coe : (coe : (box S c) → (ℳ S)) ∘ (α S c) = coe := by {funext _, refl}

lemma inducing_α : inducing (α S c) :=
begin
  have ind_ind := @induced_compose _ _ (ℳ S) _ (α p S c) coe,
  rw [coe_α_coe p S c] at ind_ind,
  exact {induced := eq.symm ind_ind},
end


lemma seval_ℳ_α_commute (c : ℝ≥0) (s : S) :
 (λ F, ((homeo_box_ϖ S c) ∘ (α S c)) F s) = (λ F, seval_ℳ_c S c s F) := rfl

 lemma seval_ℳ_α_commute' {X : Type*} (c : ℝ≥0) {f : X → filtration (ℳ S) c} (s : S)  :
 (λ x, ((homeo_box_ϖ S c) ∘ (α S c)) (f x) s) = (λ x, seval_ℳ_c S c s (f x)) :=
 begin
  ext z,
  have h_commute := @seval_ℳ_α_commute p S _ _ c s,
  have := congr_fun h_commute (f z),
  simp only at this,
  rw this,
 end

@[nolint unused_arguments]
def seval_ℒ_bdd_c (c : ℝ≥0) (S : Fintype) (A : finset ℤ) (s : S) :
laurent_measures_bdd r S A c → laurent_measures_bdd r ϖ A c :=
begin
  intro F,
  use λ _, F s,
  have hF := F.2,
  simp only [filtration, set.mem_set_of_eq, seval_ℒ, nnnorm, laurent_measures.coe_mk,
    fintype.univ_punit, finset.sum_singleton] at ⊢ hF,
  have := finset.sum_le_sum_of_subset (finset.singleton_subset_iff.mpr $ finset.mem_univ_val _),
  rw finset.sum_singleton at this,
  apply le_trans this hF,
end

lemma continuous_seval_ℒ_c (c : ℝ≥0) (s : S) : continuous (seval_ℒ_c c s) :=
begin
  rw laurent_measures.continuous_iff,
  intro A,
  let := seval_ℒ_bdd_c p c S A s,
  have h_trunc : (@truncate r ϖ c A) ∘ (seval_ℒ_c p c s) =
    (seval_ℒ_bdd_c p c S A s) ∘ (@truncate r S c A),
  { ext ⟨F, hF⟩ π k,
    dsimp only [seval_ℒ_bdd_c, seval_ℒ_c],
    refl },
  rw h_trunc,
  apply continuous.comp,
  apply continuous_of_discrete_topology,
  apply truncate_continuous,
end

section topological_generalities

open metric set

-- **[FAE]** In this section, many results exist in two versions, with and without `'`. The first is
--  stated in terms of `Icc` and `Ioo`, the second in terms of `closed_ball` and `open_ball`; they
-- are equivalent, and I will need to get rid of the useless ones at the end
variables {X : Type*} [topological_space X]
--**[FAE]** Probably needed, but check before proving it!
-- lemma continuous_if_for_all_closed (c : ℝ≥0)
--   (f : X → closed_ball (0 : ℝ) c) (H : ∀ a : ℝ≥0, ∀ (H : a ≤ c), is_closed
--     (f⁻¹' ((closed_ball ⟨(0 : ℝ), (mem_closed_ball_self c.2)⟩ a) : set ((closed_ball (0 : ℝ) c)))))
--     : continuous f :=
--  begin
--    sorry,
--  end

lemma reduction_balls {c : ℝ≥0} (f : X → (Icc (-c : ℝ) c)) (H : ∀ y : (Icc (-c : ℝ) c), ∀ ε : ℝ,
  is_open (f⁻¹' (ball y ε))) : continuous f :=
begin
  rw continuous_def,
  intros _ hU,
  rw is_open_iff_forall_mem_open,
  intros x hx,
  obtain ⟨ε, h₀, hε⟩ := (is_open_iff.mp hU) (f x) (mem_preimage.mp hx),
  use f⁻¹' (ball (f x) ε),
  exact ⟨preimage_mono hε, H (f x) ε, mem_ball_self h₀⟩,
end


lemma reduction_balls' {c : ℝ≥0} (f : X → (closed_ball (0 : ℝ) c)) (H : ∀ y : (closed_ball 0 c),
  ∀ ε : ℝ, is_open (f⁻¹' (ball y ε))) : continuous f :=
begin
  rw continuous_def,
  intros _ hU,
  rw is_open_iff_forall_mem_open,
  intros x hx,
  obtain ⟨ε, h₀, hε⟩ := (is_open_iff.mp hU) (f x) (mem_preimage.mp hx),
  use f⁻¹' (ball (f x) ε),
  exact ⟨preimage_mono hε, H (f x) ε, mem_ball_self h₀⟩,
end

-- lemma complement_of_balls {c : ℝ≥0} (y : Icc (-c : ℝ) c) (ε : ℝ) : ∃ (x₁ x₂ : Icc (-c : ℝ) c),
--   ∃ (δ₁ δ₂ : ℝ), ball y ε = ((closed_ball x₁ δ₁) ∪ (closed_ball x₂ δ₂))ᶜ :=
-- begin
--   sorry
-- end


lemma aux_mem_left {y : (closed_ball (0 : ℝ) c)} {ε x : ℝ} (hx : x = (-ε + y - c) / 2)
  (hε : 0 < ε) (h_left : (- c : ℝ) ≤ - ε + y) : x ∈ closed_ball (0 : ℝ) c :=
begin
  simp only [mem_closed_ball_zero_iff, norm_div, real.norm_two, real.norm_eq_abs, abs_le],
  split,
  { linarith },
  { have h_yc : (y : ℝ) ≤ c,
    have hy := y.2,
    rw [mem_closed_ball_zero_iff, subtype.val_eq_coe, real.norm_eq_abs] at hy,
    exact (le_abs_self (y : ℝ)).trans hy,
    linarith },
end

lemma aux_mem_right {y : (closed_ball (0 : ℝ) c)} {ε x : ℝ} (hx : x = (ε + y + c) / 2)
  (hε : 0 < ε) (h_right : ε + y ≤ c) : x ∈ closed_ball (0 : ℝ) c :=
begin
  simp only [mem_closed_ball_zero_iff, norm_div, real.norm_two, real.norm_eq_abs, abs_le],
  split,
  { have h_yc : - (c : ℝ) ≤ (y : ℝ),
    have hy := y.2,
    rw [mem_closed_ball_zero_iff, subtype.val_eq_coe, real.norm_eq_abs] at hy,
    exact (abs_le.mp hy).1,
    linarith },
  { linarith },
end

lemma aux_dist_left {a y : closed_ball (0 : ℝ) c} {ε x: ℝ}  (ha : a ∈ ball y ε) (hε : 0 < ε)
  (hx : x = (-ε + y - c) / 2) : dist (a : ℝ) x = a - x :=
begin
  rw [real.dist_eq, abs_eq_self, sub_nonneg],
  rw [mem_ball, subtype.dist_eq, real.dist_eq, abs_lt, lt_sub_iff_add_lt] at ha,
  apply le_of_lt,
  have := a.2,
  rw [mem_closed_ball, subtype.val_eq_coe, real.dist_eq, sub_zero, abs_le] at this,
  calc x = (-ε + y - c) / 2 : by {exact hx}
     ... < (a - c) / 2 : by linarith
     ... ≤ a : by {rw [div_le_iff, sub_le, mul_two, ← sub_sub, sub_self, zero_sub, neg_le],
                    exact this.1, simp only [zero_lt_bit0, zero_lt_one]},
end

lemma aux_dist_right {a y : closed_ball (0 : ℝ) c} {ε x: ℝ}  (ha : a ∈ ball y ε) (hε : 0 < ε)
  (hx : x = (ε + y + c) / 2) : dist (a : ℝ) x = x - a :=
begin
  have h_neg : - ((a : ℝ) - x) = (x - a) := by {ring},
  rw [real.dist_eq, ← h_neg, abs_eq_neg_self, sub_nonpos],
  rw [mem_ball, subtype.dist_eq, real.dist_eq, abs_lt, lt_sub_iff_add_lt] at ha,
  apply le_of_lt,
  have := a.2,
  rw [mem_closed_ball, subtype.val_eq_coe, real.dist_eq, sub_zero, abs_le] at this,
  calc x = (ε + y + c) / 2 : by {exact hx}
      ... > (a + c) / 2 : by linarith
      ... ≥ a : by {rw [ge_iff_le, le_div_iff, ← sub_le_iff_le_add', mul_two, ← add_sub, sub_self,
        add_zero], exact this.2, simp only [zero_lt_bit0, zero_lt_one]},
end

lemma complement_of_balls_nonpos {c : ℝ≥0} (y : (closed_ball (0 : ℝ) c)) {ε : ℝ} (hε : ε ≤ 0):
 ∃ (x₁ x₂ : (closed_ball 0 c)), ∃ (δ₁ δ₂ : ℝ),
  ball y ε = ((closed_ball x₁ δ₁) ∪ (closed_ball x₂ δ₂))ᶜ :=
begin
  have := (@ball_eq_empty _ _ y ε).mpr hε,
  rw this,
  use [0, 0, c, c],
  simp only [union_self, bot_eq_empty],
  apply (compl_eq_bot.mpr _).symm,
  rw top_eq_univ,
  ext x,
  split;
  intro _,
  simp only [mem_univ],
  exact x.2,
end

lemma complement_of_balls_pos_Nleft {c : ℝ≥0} (y : (closed_ball (0 : ℝ) c)) {ε : ℝ} (hε : 0 < ε)
 (Nh_left : ¬ - (c : ℝ) ≤ -ε + y) (h_right : ε + y ≤ c) :
 ∃ (x₁ x₂ : (closed_ball 0 c)), ∃ (δ₁ δ₂ : ℝ),
  ball y ε = ((closed_ball x₁ δ₁) ∪ (closed_ball x₂ δ₂))ᶜ :=
begin
  set δ₂ := (-ε - y + c) / 2 with hδ₂,
  set x₂ := (ε + y + c) / 2 with hx₂,
  use [0, x₂, aux_mem_right c hx₂ hε h_right, -1, δ₂],
  simp only [compl_union],
  ext a,
  simp only [mem_inter_eq, mem_compl_iff, mem_closed_ball, not_le],
  split,
  { intro ha,
    apply and.intro (lt_of_lt_of_le neg_one_lt_zero dist_nonneg),
    rw [hδ₂, subtype.dist_eq, subtype.coe_mk, aux_dist_right c ha hε hx₂, hx₂, div_sub' _ _ _
          (@two_ne_zero ℝ _ _)],
    have : (c : ℝ) - 2 * a = - 2 * a + c := by ring,
    apply div_lt_div_of_lt _,
    rw [← add_sub, this, ← add_assoc],
    apply add_lt_add_right,
    rw [mem_ball, subtype.dist_eq, real.dist_eq, abs_sub_lt_iff] at ha,
    rw [sub_eq_add_neg, neg_add_lt_iff_lt_add, add_assoc, ← add_assoc ε ε _, ← two_mul,
      ← add_assoc, add_comm _ (y : ℝ), add_assoc, ← sub_lt_iff_lt_add', sub_eq_add_neg,
      ← two_mul, neg_mul, ← sub_eq_add_neg, mul_neg, neg_lt_sub_iff_lt_add, ← mul_add,
      mul_lt_mul_left, ← sub_lt_iff_lt_add'],
    exact ha.1,
    repeat {simp only [zero_lt_bit0, zero_lt_one]}},
  { rintros ⟨-, h₂⟩,
    have ha := a.2,
    rw [mem_closed_ball, subtype.val_eq_coe, real.dist_0_eq_abs, abs_le] at ha,
    rw [subtype.dist_eq, real.dist_eq, subtype.coe_mk, lt_abs] at h₂,
    have H₂ : x₂ - δ₂ = ε + y ∧ δ₂ + x₂ = c,
    { rw [hx₂, hδ₂, ← add_div, ← sub_div],
      split,
      repeat {ring}},
    replace h₂ : δ₂ < x₂ - a,
    { rw [neg_sub, lt_sub_iff_add_lt, H₂.2] at h₂,
      exact (or_iff_right (not_lt.mpr ha.2)).mp h₂ },
    rw [mem_ball, subtype.dist_eq, real.dist_eq, abs_lt, lt_sub_iff_add_lt],
    split;
    linarith }
end

lemma complement_of_balls_pos_Nright {c : ℝ≥0} (y : (closed_ball (0 : ℝ) c)) {ε : ℝ} (hε : 0 < ε)
  (h_left : - (c : ℝ) ≤ -ε + y) (Nh_right : ¬ ε + y ≤ c) :
 ∃ (x₁ x₂ : (closed_ball 0 c)), ∃ (δ₁ δ₂ : ℝ),
  ball y ε = ((closed_ball x₁ δ₁) ∪ (closed_ball x₂ δ₂))ᶜ :=
begin
  set δ₁ := (-ε + y + c) / 2 with hδ₁,
  set x₁ := (- ε + y - c) / 2 with hx₁,
  have := aux_mem_left c hx₁ hε h_left,
  use [x₁, aux_mem_left c hx₁ hε h_left, 0, δ₁, -1],
  simp only [compl_union],
  ext a,
  simp only [mem_inter_eq, mem_compl_iff, mem_closed_ball, not_le],
  split,
  { intro ha,
    apply and.intro _ (lt_of_lt_of_le neg_one_lt_zero dist_nonneg),
      { rw [hδ₁, subtype.dist_eq, subtype.coe_mk, aux_dist_left c ha hε hx₁, hx₁, sub_div' _ _ _
          (@two_ne_zero ℝ _ _)],
        apply div_lt_div_of_lt _,
        rw [sub_sub_assoc_swap, add_comm, add_comm _ (c : ℝ), add_sub_assoc],
        apply add_lt_add_left,
        rw [mem_ball, subtype.dist_eq, real.dist_eq, abs_sub_lt_iff] at ha,
        rw [sub_add_eq_sub_sub, sub_neg_eq_add, add_comm _ ε, ← add_sub, neg_add_lt_iff_lt_add,
          ← add_assoc, ← two_mul, add_sub, sub_eq_add_neg, lt_add_neg_iff_add_lt, ← two_mul,
          mul_comm _ (2 : ℝ), ← mul_add, mul_lt_mul_left, ← sub_lt_iff_lt_add],
        exact ha.2,
        repeat {simp only [zero_lt_bit0, zero_lt_one]}}},
  { rintros ⟨h₁, -⟩,
    have ha := a.2,
    rw [mem_closed_ball, subtype.val_eq_coe, real.dist_0_eq_abs, abs_le] at ha,
    rw [subtype.dist_eq, real.dist_eq, subtype.coe_mk, lt_abs] at h₁,
    have H₁ : x₁ + δ₁ = -ε + y ∧ x₁ - δ₁ = - c,
    { rw [hx₁, hδ₁, ← add_div, ← sub_div],
      split,
      repeat {ring}},
    replace h₁ :x₁ + δ₁ < a,
    { cases h₁ with hh₁,
      rwa lt_sub_iff_add_lt' at hh₁,
      rw [neg_sub, lt_sub, H₁.2] at h₁,
      linarith},
    rw [mem_ball, subtype.dist_eq, real.dist_eq, abs_lt, lt_sub_iff_add_lt, ← H₁.1],
    split,
    all_goals {linarith}}
end


-- ext x,
--   split;
--   intro _,
--   simp only [mem_univ],
--   exact x.2,

lemma complement_of_balls_pos_NN {c : ℝ≥0} (y : (closed_ball (0 : ℝ) c)) {ε : ℝ} (hε : 0 < ε)
  (Nh_left : ¬ - (c : ℝ) ≤ -ε + y) (Nh_right : ¬ ε + y ≤ c) :
 ∃ (x₁ x₂ : (closed_ball 0 c)), ∃ (δ₁ δ₂ : ℝ),
  ball y ε = ((closed_ball x₁ δ₁) ∪ (closed_ball x₂ δ₂))ᶜ :=
begin
  use [0, 0, -1, -1],
  rw [((@closed_ball_eq_empty _ _ (0 : closed_ball (0 : ℝ) c) (-1 : ℝ)).mpr neg_one_lt_zero),
    union_self, compl_empty],
  ext a,
  split,
  {intro _,
    simp only [mem_univ]},
  { rintro -,
    have := a.2,
    simp only [mem_closed_ball, subtype.val_eq_coe, top_eq_univ, mem_univ, mem_ball,
      forall_true_left, subtype.dist_eq, real.dist_eq, abs_le, abs_lt] at this ⊢,
    split;
    linarith}
end

lemma complement_of_balls_pos_centre {c : ℝ≥0} (y : (closed_ball (0 : ℝ) c)) {ε : ℝ} (hε : 0 < ε)
  (h_right : ε + y ≤ c) (h_left : - (c : ℝ) ≤ -ε + y) :
  ∃ (x₁ x₂ : (closed_ball 0 c)), ∃ (δ₁ δ₂ : ℝ),
  ball y ε = ((closed_ball x₁ δ₁) ∪ (closed_ball x₂ δ₂))ᶜ :=
begin
  set δ₁ := (-ε + y + c) / 2 with hδ₁,
  set x₁ := (- ε + y - c) / 2 with hx₁,
  set δ₂ := (-ε - y + c) / 2 with hδ₂,
  set x₂ := (ε + y + c) / 2 with hx₂,
  use [x₁, aux_mem_left c hx₁ hε h_left, x₂, aux_mem_right c hx₂ hε
      h_right, δ₁, δ₂],
    simp only [compl_union],
    ext a,
    simp only [mem_inter_eq, mem_compl_iff, mem_closed_ball, not_le],
    split,
    { intro ha,
      split,
      { rw [hδ₁, subtype.dist_eq, subtype.coe_mk, aux_dist_left c ha hε hx₁, hx₁, sub_div' _ _ _
          (@two_ne_zero ℝ _ _)],
        apply div_lt_div_of_lt _,
        rw [sub_sub_assoc_swap, add_comm, add_comm _ (c : ℝ), add_sub_assoc],
        apply add_lt_add_left,
        rw [mem_ball, subtype.dist_eq, real.dist_eq, abs_sub_lt_iff] at ha,
        rw [sub_add_eq_sub_sub, sub_neg_eq_add, add_comm _ ε, ← add_sub, neg_add_lt_iff_lt_add,
          ← add_assoc, ← two_mul, add_sub, sub_eq_add_neg, lt_add_neg_iff_add_lt, ← two_mul,
          mul_comm _ (2 : ℝ), ← mul_add, mul_lt_mul_left, ← sub_lt_iff_lt_add],
        exact ha.2,
        repeat {simp only [zero_lt_bit0, zero_lt_one]}},
      { rw [hδ₂, subtype.dist_eq, subtype.coe_mk, aux_dist_right c ha hε hx₂, hx₂, div_sub' _ _ _
          (@two_ne_zero ℝ _ _)],
        have : (c : ℝ) - 2 * a = - 2 * a + c := by ring,
        apply div_lt_div_of_lt _,
        rw [← add_sub, this, ← add_assoc],
        apply add_lt_add_right,
        rw [mem_ball, subtype.dist_eq, real.dist_eq, abs_sub_lt_iff] at ha,
        rw [sub_eq_add_neg, neg_add_lt_iff_lt_add, add_assoc, ← add_assoc ε ε _, ← two_mul,
          ← add_assoc, add_comm _ (y : ℝ), add_assoc, ← sub_lt_iff_lt_add', sub_eq_add_neg,
          ← two_mul, neg_mul, ← sub_eq_add_neg, mul_neg, neg_lt_sub_iff_lt_add, ← mul_add,
          mul_lt_mul_left, ← sub_lt_iff_lt_add'],
        exact ha.1,
        repeat {simp only [zero_lt_bit0, zero_lt_one]}}},
    { rintros ⟨h₁, h₂⟩,
      have ha := a.2,
      rw [mem_closed_ball, subtype.val_eq_coe, real.dist_0_eq_abs, abs_le] at ha,
      rw [subtype.dist_eq, real.dist_eq, subtype.coe_mk, lt_abs] at h₁ h₂,
      have H₁ : x₁ + δ₁ = -ε + y ∧ x₁ - δ₁ = - c,
      { rw [hx₁, hδ₁, ← add_div, ← sub_div],
        split,
        repeat {ring}},
      replace h₁ :x₁ + δ₁ < a,
      { cases h₁ with hh₁,-- [FAE] Need to split cases to avoid `result contains metavariable`
        rwa lt_sub_iff_add_lt' at hh₁,
        rw [neg_sub, lt_sub, H₁.2] at h₁,
        linarith},
      have H₂ : x₂ - δ₂ = ε + y ∧ δ₂ + x₂ = c,
      { rw [hx₂, hδ₂, ← add_div, ← sub_div],
        split,
        repeat {ring}},
      replace h₂ : δ₂ < x₂ - a,
      { rw [neg_sub, lt_sub_iff_add_lt, H₂.2] at h₂,
        exact (or_iff_right (not_lt.mpr ha.2)).mp h₂ },
        rw [mem_ball, subtype.dist_eq, real.dist_eq, abs_lt, lt_sub_iff_add_lt, ← H₁.1],
        split,
        all_goals {linarith} },
end

lemma complement_of_balls' {c : ℝ≥0} (y : (closed_ball (0 : ℝ) c)) (ε : ℝ) :
 ∃ (x₁ x₂ : (closed_ball 0 c)), ∃ (δ₁ δ₂ : ℝ),
  ball y ε = ((closed_ball x₁ δ₁) ∪ (closed_ball x₂ δ₂))ᶜ :=
begin
  by_cases hε : 0 < ε,
  { by_cases h_right : ε + y ≤ c,
    by_cases h_left : - (c : ℝ) ≤ - ε + y,
    { exact complement_of_balls_pos_centre y hε h_right h_left },
    { exact complement_of_balls_pos_Nleft y hε h_left h_right },
    { by_cases h_left : - (c : ℝ) ≤ - ε + y,
    { exact complement_of_balls_pos_Nright y hε h_left h_right, },
    { exact complement_of_balls_pos_NN y hε h_left h_right }}},
  { exact complement_of_balls_nonpos y (not_lt.mp hε) },
end


-- lemma continuous_if_preimage_closed {c : ℝ≥0} (f : X → (Icc (-c : ℝ) c))
--   (H : ∀ y : Icc (-c : ℝ) c, ∀ ε : ℝ, is_closed (f⁻¹' (closed_ball y ε))) : continuous f :=
-- begin
--   apply reduction_balls,
--   intros y ε,
--   obtain ⟨x₁,x₂,δ₁,δ₂,h⟩ := complement_of_balls y ε,
--   rw h,
--   simp only [compl_union, preimage_inter, preimage_compl],
--   apply is_open.inter,
--   all_goals {simp only [is_open_compl_iff], apply H},
-- end

lemma continuous_if_preimage_closed' {c : ℝ≥0} (f : X → (closed_ball (0 : ℝ) c))
  (H : ∀ y : (closed_ball (0 : ℝ) c), ∀ ε : ℝ, is_closed (f⁻¹' (closed_ball y ε))) : continuous f :=
begin
  apply reduction_balls',
  intros y ε,
  obtain ⟨x₁,x₂,δ₁,δ₂,h⟩ := complement_of_balls' y ε,
  rw h,
  simp only [compl_union, preimage_inter, preimage_compl],
  apply is_open.inter,
  all_goals {simp only [is_open_compl_iff], apply H},
end

-- instance (c : ℝ≥0) : has_zero (Icc (-c : ℝ) c):=
-- { zero := ⟨(0 : ℝ), by {simp only [mem_Icc, right.neg_nonpos_iff, nnreal.zero_le_coe, and_self]}⟩}

-- lemma continuous_if_preimage_closed₀ (c : ℝ≥0) (f : X → (Icc (-c : ℝ) c))
--   (H : ∀ ε : ℝ, is_closed (f⁻¹' (closed_ball 0 ε))) : continuous f :=
-- begin
--   sorry,
-- end


lemma continuous_if_preimage_closed₀' (c : ℝ≥0) (f : X → (closed_ball (0 : ℝ) c))
  (H : ∀ ε : ℝ≥0, ε ≤ c → is_closed (f⁻¹' (closed_ball 0  ε))) : continuous f :=
begin
  sorry,
end


end topological_generalities

def θ_c (c : ℝ≥0) (T : Fintype) : (filtration (laurent_measures r T) c) →
  (filtration (real_measures p T) c) :=
begin
  intro f,
  rw [← one_mul c],
  use ⟨θ f, θ_bound p c f f.2⟩,
end

lemma commute_seval_ℒ_ℳ (c : ℝ≥0) (s : S) :
  (θ_c c (Fintype.of punit)) ∘ (seval_ℒ_c c s) = (seval_ℳ_c S c s) ∘ (θ_c c S) := by simpa only
  [seval_ℳ_c, seval_ℒ_c, seval_ℒ, θ_c, one_mul, subtype.coe_mk, eq_mpr_eq_cast, set_coe_cast]


lemma continuous_of_seval_ℳ_comp_continuous (c : ℝ≥0) {X : Type*} [topological_space X]
  {f : X → (filtration (ℳ S) c)} : (∀ s, continuous ((seval_ℳ_c S c s) ∘ f)) → continuous f :=
begin
  intro H,
  replace H : ∀ (s : S), continuous (λ x : X, ((homeo_box_ϖ p S c) ∘ (α p S c)) (f x) s),
  { intro,
    rw [seval_ℳ_α_commute' p S c s],
    exact H s },
  rw ← continuous_pi_iff at H,
  convert_to (continuous (λ x, (homeo_box_ϖ p S c) (α p S c (f x)))) using 0,
  { apply eq_iff_iff.mpr,
    rw [homeomorph.comp_continuous_iff, (inducing_α p S c).continuous_iff] },
  exact H,
end



-- This is the main continuity property needed in `ses2.lean`
lemma continuous_θ_c (c : ℝ≥0) : continuous (θ_c c S) :=
begin
  apply continuous_of_seval_ℳ_comp_continuous,
  intro s,
  rw ← commute_seval_ℒ_ℳ,
  refine continuous.comp _ (continuous_seval_ℒ_c p S c s),
  dsimp only [θ_c],
  apply (homeo_filtration_ϖ_ball c).comp_continuous_iff.mp,
  apply continuous_if_preimage_closed₀' (c ^ (p⁻¹ : ℝ)),
  intros ε hε,
  replace hε : ε ^ (p : ℝ) ≤ c,
  { have := @nnreal.rpow_le_rpow ε (c ^ (p⁻¹ : ℝ)) p hε _,
    rw [← nnreal.rpow_mul, inv_mul_cancel, nnreal.rpow_one] at this,
    exacts [this, (nnreal.coe_ne_zero.mpr $ ne_of_gt $ fact.out _), by {rw [← nnreal.coe_zero, nnreal.coe_le_coe], exact (le_of_lt $fact.out _)}] },
  simp only [one_mul, eq_self_iff_true, eq_mpr_eq_cast, set_coe_cast],
  rw [set.preimage_comp, homeo_filtration_ϖ_ball_preimage hε],
  sorry,
end


variable {S}

end theta

end laurent_measures_ses
