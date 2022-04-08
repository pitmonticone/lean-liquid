import Lbar.functor
import laurent_measures.functor
import laurent_measures.aux_lemmas
import invpoly.functor
import condensed.condensify

.

/-!
The short exact sequence
```
0 → ℤ[T⁻¹] → ℳ(S, ℤ((T))_r') → ℳ-bar(S)_r' → 0
```
-/

-- move me
lemma int.coe_nat_injective : function.injective (coe : ℕ → ℤ) :=
λ m n h, int.coe_nat_inj h

lemma int.nat_abs_of_nonpos {a : ℤ} : a ≤ 0 → ↑(a.nat_abs) = -a :=
begin
  intro h,
  rw ← int.nat_abs_neg,
  apply int.nat_abs_of_nonneg,
  exact neg_nonneg.mpr h,
end


noncomputable theory

open aux_thm69
open_locale nnreal

variables (r' : ℝ≥0) [fact (0 < r')] (S : Fintype)

namespace invpoly

def to_laurent_measures_fun (F : invpoly r' S) : S → ℤ → ℤ
| s 0       := (F s).coeff 0
| s (n+1:ℕ) := 0
| s -[1+n]  := (F s).coeff (n+1)

lemma to_laurent_measures_fun_zero (F : invpoly r' S) (s : S) :
to_laurent_measures_fun r' S F s 0 = (F s).coeff 0 :=
rfl

lemma to_laurent_measures_fun_pos (F : invpoly r' S) (s : S) (n : ℕ) :
to_laurent_measures_fun r' S F s (n+1 : ℕ) = 0 :=
rfl

lemma to_laurent_measures_fun_pos' (F : invpoly r' S) (s : S) (n : ℕ) :
to_laurent_measures_fun r' S F s (n + 1) = 0 :=
rfl

lemma to_laurent_measures_fun_neg (F : invpoly r' S) (s : S) (n : ℕ) :
to_laurent_measures_fun r' S F s -[1+n] = (F s).coeff (n+1) :=
rfl

lemma to_laurent_measures_fun_neg' (F : invpoly r' S) (s : S) (n : ℕ) :
to_laurent_measures_fun r' S F s (-(n.succ)) = (F s).coeff (n+1) :=
rfl

lemma to_laurent_measures_fun_nonpos (F : invpoly r' S) (s : S) (n : ℕ) :
to_laurent_measures_fun r' S F s (-n) = (F s).coeff n :=
begin
  cases n,
  { exact to_laurent_measures_fun_zero r' S F s, },
  { exact to_laurent_measures_fun_neg r' S F s n, }
end

@[simps] def to_laurent_measures (F : invpoly r' S) : laurent_measures r' S :=
{ to_fun := to_laurent_measures_fun r' S F,
  summable' := λ s, begin
    rw ← nnreal.summable_coe,
    rw ← @summable_subtype_and_compl ℝ ℤ _ _ _ _ _ {n : ℤ | n ≤ 0},
    split,
    { have := F.nnreal_summable s,
      rw ← nnreal.summable_coe at this,
      convert (equiv.summable_iff (equiv.nonpos_ge_zero ℤ)).mpr _,
      rotate,
      { exact λ a, ((∥(F s).coeff (int.to_nat a)∥₊ * r' ^ (-(a.1))) : ℝ) },
      rotate,
      { apply funext,
        rintros ⟨x, hx⟩,
        rcases x with ⟨_ | x⟩ | x,
        { refl },
        { rw [int.of_nat_eq_coe, int.coe_nat_succ, set.mem_set_of_eq] at hx,
          refine (not_lt.mpr hx _).elim,
          exact int.add_pos_of_nonneg_of_pos (int.coe_zero_le x) zero_lt_one },
        { simp only [subtype.coe_mk, zpow_neg_succ_of_nat, nonneg.coe_mul, coe_nnnorm,
            nnreal.coe_pow, subtype.val_eq_coe, zpow_neg₀, function.comp_app, nnreal.coe_eq_zero,
            equiv.nonpos_ge_zero_eval, inv_inv, inv_eq_zero, pow_eq_zero_iff, nat.succ_pos'],
        congr } },
      { refine (equiv.summable_iff (int_subtype_nonneg_equiv.symm : ℕ ≃ {z : ℤ // 0 ≤ z})).mp _,
        simpa },
      /- setup equiv with `ℕ` using `k → -k` and use `F.nnreal_summable s` -/ },
    { convert summable_zero, ext ⟨((_|n)|n), hn⟩,
      { simp only [int.of_nat_eq_coe, int.coe_nat_zero, set.mem_compl_eq, set.mem_set_of_eq,
         le_refl, not_true] at hn,
        exact hn.elim },
      { erw [nnnorm_zero, zero_mul, nnreal.coe_zero], },
      { simp only [set.mem_compl_eq, set.mem_set_of_eq, not_le, int.neg_succ_not_pos] at hn,
        exact hn.elim }, },
  end }

lemma to_laurent_measures_injective : function.injective (to_laurent_measures r' S) :=
begin
  intros F G h,
  ext s (_|n),
  { apply_fun (λ F, F s 0) at h, exact h },
  { apply_fun (λ F, F s (-n.succ)) at h, exact h }
end

def to_laurent_measures_addhom : invpoly r' S →+ laurent_measures r' S :=
add_monoid_hom.mk' (to_laurent_measures r' S) $
begin
  intros F G, ext s ((_|n)|n),
  { simp only [to_laurent_measures_fun, add_apply, int.of_nat_zero,
      to_laurent_measures_to_fun, laurent_measures.add_apply, polynomial.coeff_add], },
  { refl, },
  { simp only [to_laurent_measures_fun, add_apply, to_laurent_measures_to_fun,
      laurent_measures.add_apply, polynomial.coeff_add], }
end

def to_laurent_measures_hom [fact (r' < 1)]: comphaus_filtered_pseudo_normed_group_with_Tinv_hom r'
  (invpoly r' S) (laurent_measures r' S) :=
{ strict' := begin
    rintros c p hp,
    simp only [add_monoid_hom.to_fun_eq_coe, laurent_measures.mem_filtration_iff],
    simp only [mem_filtration_iff] at hp,
    convert hp using 1,
    unfold nnnorm,
    congr',
    ext s,
    norm_cast,
    refine tsum_eq_tsum_of_ne_zero_bij (λ n, -((n.1 : ℕ) : ℤ)) _ _ _,
  { rintros ⟨x, _⟩ ⟨y, _⟩ h, simpa using h },
  { intros n hn,
    rw function.mem_support at hn,
    rw set.mem_range,
    rcases n with ((_|n)|n),
    { exact ⟨⟨0, hn⟩, rfl⟩ },
    { exfalso,
      simpa [to_laurent_measures_addhom, to_laurent_measures_fun_pos'] using hn },
    { exact ⟨⟨n+1, hn⟩, rfl⟩ } },
  { rintro ⟨n, hn⟩,
    simp only [to_laurent_measures_addhom, add_monoid_hom.mk'_apply, to_laurent_measures_to_fun, subtype.coe_mk, zpow_neg₀,
      zpow_coe_nat, mul_eq_mul_right_iff, subtype.mk_eq_mk, inv_eq_zero],
    left,
    cases n with n,
    { simp [to_laurent_measures_fun_zero], },
    { simp only [to_laurent_measures_fun_neg'], } },
  end,
  continuous' := λ c, continuous_bot,
  map_Tinv' := begin
    intro F,
    ext s z,
    change to_laurent_measures_fun r' S (λ (s : ↥S), polynomial.X * F s) s z =
      to_laurent_measures_fun r' S F s (z + 1),
    rcases lt_trichotomy 0 z with (hz | rfl | hz),
    { let n := (z - 1).nat_abs,
      have hn : z - 1 = n := int.eq_nat_abs_of_zero_le (int.le_sub_one_of_lt hz),
      rw sub_eq_iff_eq_add at hn,
      rw [hn, to_laurent_measures_fun_pos', (by norm_cast : (n : ℤ) + 1 = (n + 1 : ℕ)),
        to_laurent_measures_fun_pos'] },
    { rw [to_laurent_measures_fun_zero, (by norm_cast : (0 : ℤ) + 1 = (0 + 1 : ℕ)),
        to_laurent_measures_fun_pos],
      simp only [polynomial.mul_coeff_zero, polynomial.coeff_X_zero, zero_mul] },
    { let n := (z + 1).nat_abs,
      have hn : (n : ℤ) = -(z + 1) := int.nat_abs_of_nonpos (int.add_one_le_of_lt hz),
      rw eq_neg_iff_eq_neg at hn,
      rw hn,
      rw ← eq_sub_iff_add_eq at hn,
      rw [hn, to_laurent_measures_fun_nonpos, (by {simp, ring} : -(n : ℤ) - 1 = -(n + 1 : ℕ)),
        to_laurent_measures_fun_nonpos, polynomial.coeff_X_mul] },
  end,
  .. to_laurent_measures_addhom r' S }.

@[simps]
def to_laurent_measures_nat_trans [fact (r' < 1)]:
  invpoly.fintype_functor r' ⟶ laurent_measures.fintype_functor r' :=
{ app := λ S, to_laurent_measures_hom r' S,
  naturality' := λ S T f, begin
    ext p t n,
    classical,
    suffices : to_laurent_measures_fun r' T (map f p) t n =
      (finset.filter (λ (t_1 : S.α), f t_1 = t) finset.univ).sum (λ (x : S.α),
        to_laurent_measures_fun r' S p x n),
    simpa [to_laurent_measures_hom, to_laurent_measures_addhom],
    rcases n with ((_ | n) | n),
    { convert map_apply f p t 0, },
    { simp only [int.of_nat_eq_coe, to_laurent_measures_fun_pos, finset.sum_const_zero] },
    { convert map_apply f p t (n+1), }
  end }

end invpoly

namespace laurent_measures

@[simps] def to_Lbar (F : laurent_measures r' S) : Lbar r' S :=
{ to_fun := λ s n, if n = 0 then 0 else F s n,
  coeff_zero' := λ s, if_pos rfl,
  summable' := λ s, begin
    have := nnreal.summable_comp_injective (F.nnreal_summable s) int.coe_nat_injective,
    refine nnreal.summable_of_le _ this,
    intros n,
    split_ifs,
    { simp only [int.nat_abs_zero, nat.cast_zero, zero_mul, zero_le'] },
    { simp only [function.comp_app, nnreal.coe_nat_abs, zpow_coe_nat] }
  end }

lemma to_Lbar_surjective : function.surjective (to_Lbar r' S) :=
begin
  intro G,
  refine ⟨⟨λ s n, G s n.to_nat, λ s, _⟩, _⟩,
  { refine (nnreal.summable_iff_on_nat_less 0 (λ n n0, _)).mpr _,
    { simp [int.to_nat_of_nonpos n0.le] },
    { simp only [int.to_nat_coe_nat, zpow_coe_nat],
      simpa only [← nnreal.coe_nat_abs] using G.summable' s } },
  { ext s (_|n),
    { exact (G.coeff_zero s).symm },
    { show ite (n.succ = 0) 0 (G s (n + 1)) = G s n.succ, from if_neg n.succ_ne_zero } }
end

lemma nnnorm_to_Lbar (F : laurent_measures r' S) : ∥to_Lbar r' S F∥₊ ≤ ∥F∥₊ :=
begin
  rw [nnnorm_def, Lbar.nnnorm_def],
  refine finset.sum_le_sum (λ s hs, _),
  have := nnreal.summable_comp_injective (F.nnreal_summable s) int.coe_nat_injective,
  refine (tsum_le_tsum _ ((to_Lbar r' S F).summable s) this).trans
    (nnreal.tsum_comp_le_tsum_of_inj (F.nnreal_summable s) int.coe_nat_injective),
  intro n,
  simp only [nnreal.coe_nat_abs, to_Lbar_to_fun, function.comp_app, zpow_coe_nat],
  split_ifs, { rw [nnnorm_zero, zero_mul], exact zero_le' }, { refl }
end

@[simps] def to_Lbar_hom : comphaus_filtered_pseudo_normed_group_with_Tinv_hom r'
  (laurent_measures r' S) (Lbar r' S) :=
{ to_fun := to_Lbar r' S,
  map_zero' := by { ext,
    simp only [to_Lbar_to_fun, zero_apply, if_t_t, Lbar.coe_zero, pi.zero_apply], },
  map_add' := λ F G, by { ext, simp only [to_Lbar_to_fun, add_apply, Lbar.coe_add, pi.add_apply],
    split_ifs, { rw add_zero }, { refl } },
  strict' := λ c F (hF : ∥F∥₊ ≤ c), (nnnorm_to_Lbar r' S F).trans hF,
  continuous' := λ c, begin
    let f : _ := _, show continuous f,
    rw Lbar_le.continuous_iff,
    intros N,
    let e : ℕ ↪ ℤ := ⟨coe, int.coe_nat_injective⟩,
    let T : finset ℤ := (finset.range (N + 1)).map e,
    let g : laurent_measures_bdd r' S T c → Lbar_bdd r' ⟨S⟩ c N := λ F,
    { to_fun := λ s n, if n = 0 then 0 else F s ⟨n, _⟩,
      coeff_zero' := λ s, if_pos rfl,
      sum_le' := _ },
    have : Lbar_le.truncate N ∘ f = g ∘ truncate T,
    { dsimp [f], ext F s ⟨(_|n), hn⟩, { simp only [fin.mk_zero, Lbar_bdd.coeff_zero], },
      simp only [Lbar_le.truncate_to_fun, Lbar_bdd.coe_mk, coe_coe, int.coe_nat_succ,
        truncate_to_fun, subtype.coe_mk, subtype.ext_iff, fin.coe_zero, nat.succ_ne_zero, if_false],
      exact to_Lbar_to_fun r' S F s (n+1), },
    { rw this, exact continuous_of_discrete_topology.comp (truncate_continuous _ _ _ _) },
    { simpa only [coe_coe, finset.mem_map, finset.mem_range, function.embedding.coe_fn_mk,
        int.coe_nat_inj', exists_prop, exists_eq_right] using n.2, },
    { cases S, refine le_trans (finset.sum_le_sum _) F.bound, dsimp,
      rintro s -,
      erw [finset.sum_attach', finset.sum_map, ← fin.sum_univ_eq_sum_range],
      refine finset.sum_le_sum (λ i hi, _),
      simp only [finset.mem_map, finset.mem_range, exists_prop, exists_eq_right, nnreal.coe_nat_abs,
        embedding_like.apply_eq_iff_eq, function.embedding.coe_fn_mk, subtype.coe_mk, zpow_coe_nat],
      rw dif_pos, swap, { exact i.2 },
      split_ifs, { rw [nnnorm_zero, zero_mul], exact zero_le' }, { refl } }
  end,
  map_Tinv' := λ F, begin
    erw [Tinv_apply, Lbar.Tinv_apply],
    ext s (_|n),
    { simp only [to_Lbar_to_fun, eq_self_iff_true, if_true, Lbar.Tinv_zero], },
    { simp only [to_Lbar_to_fun, nat.succ_ne_zero, int.coe_nat_succ, shift_to_fun_to_fun,
        Lbar.Tinv_succ], }
  end }

@[simps]
def to_Lbar_nat_trans : laurent_measures.fintype_functor r' ⟶ Lbar.fintype_functor r' :=
{ app := λ S, to_Lbar_hom r' S,
  naturality' := λ S₁ S₂ f, begin
    ext,
    simp only [fintype_functor_map, category_theory.comp_apply, to_Lbar_hom_to_fun, to_Lbar_to_fun,
      Lbar.fintype_functor_map_to_fun, Lbar.map_to_fun, map_hom, map_apply,
      comphaus_filtered_pseudo_normed_group_with_Tinv_hom.coe_mk],
    split_ifs, { simp only [finset.sum_const_zero], }, { refl }
  end }
.

end laurent_measures

namespace Lbar

open category_theory ProFiltPseuNormGrpWithTinv₁

theorem short_exact (S : Profinite) [fact (r' < 1)] :
  short_exact
    ((condensify_map
      (whisker_right (invpoly.to_laurent_measures_nat_trans r') (to_CHFPNG₁ r'))).app S)
    ((condensify_map
      (whisker_right (laurent_measures.to_Lbar_nat_trans r') (to_CHFPNG₁ r'))).app S) :=
begin
  refine condensify_exact _ _ 1 le_rfl 1 le_rfl _ _ _ _ _ S,
  { apply invpoly.to_laurent_measures_injective },
  { intro S, ext F s (_|n); refl, },
  { rintro S c F ⟨hF1, hF2⟩,
    simp only [whisker_right_app, laurent_measures.to_Lbar_nat_trans_app, functor.comp_map,
      set.mem_inter_eq, set.mem_preimage, set.mem_singleton_iff] at hF1 hF2,
    change laurent_measures.to_Lbar r' S F = 0 at hF1,
    change F ∈ pseudo_normed_group.filtration (laurent_measures r' S) c at hF2,
    show F ∈ invpoly.to_laurent_measures r' S '' (pseudo_normed_group.filtration (invpoly r' S) (1 * c)),
    -- Probably good to define `laurent_measures.truncate` that truncates `F` to only the negative powers of `T⁻¹`.
    -- Use that to get the desired `invpoly`.
    sorry },
  { apply laurent_measures.to_Lbar_surjective },
  { rintro S c F hF,
    -- Do something similar to the above
    sorry }
end

end Lbar
