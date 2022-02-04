-- import topology.algebra.infinite_sum
import data.finset.nat_antidiagonal
import analysis.normed_space.basic
import analysis.specific_limits

noncomputable theory

open metric finset --filter
open_locale nnreal classical big_operators topological_space

namespace aux_thm69

section equivalences_def

-- for mathlib?
def range_equiv_Icc {n d : ℤ} (m : ℕ) (hm : n - d = m) :
  range m.succ ≃ (Icc d n) :=
begin
  refine ⟨λ a, ⟨a + d, mem_Icc.mpr ⟨_, _⟩⟩, _, _, _⟩,
  { exact (le_add_iff_nonneg_left _).mpr (int.of_nat_nonneg _) },
  { refine add_le_of_le_sub_right _,
    exact (int.coe_nat_le.mpr (nat.le_of_lt_succ $ (@mem_range m.succ a).mp a.2)).trans hm.ge },
  { rintro ⟨a, hha⟩,
    refine ⟨(a - d).nat_abs, mem_range_succ_iff.mpr _⟩,
    lift (a - d) to ℕ using (sub_nonneg.mpr ((mem_Icc).mp hha).1) with ad had,
    rw [int.nat_abs_of_nat, ← (int.coe_nat_le_coe_nat_iff _ _), had, ← hm],
    exact sub_le_sub_right ((mem_Icc).mp hha).2 _ },
  { exact λ x, subtype.ext (by simp) },
  { rintro ⟨x, hx⟩,
    simp [int.nat_abs_of_nonneg (sub_nonneg.mpr (mem_Icc.mp hx).1), sub_add_cancel] }
end

--for `mathlib`?
def equiv_bdd_integer_nat (N : ℤ) : ℕ ≃ {x // N ≤ x} :=
begin
  fconstructor,
  { exact λ n, ⟨n + N, le_add_of_nonneg_left (int.coe_nat_nonneg n)⟩ },
  { rintro ⟨x, hx⟩,
    use (int.eq_coe_of_zero_le (sub_nonneg.mpr hx)).some },
  { intro a,
    simp_rw [add_tsub_cancel_right],
    exact (int.coe_nat_inj $ Exists.some_spec $ int.eq_coe_of_zero_le $ int.of_nat_nonneg a).symm },
  { rintro ⟨_, hx⟩,
    simp only,
    exact add_eq_of_eq_sub ((int.eq_coe_of_zero_le (sub_nonneg.mpr hx)).some_spec).symm }
end

def equiv_Icc_bdd_nonneg {d : ℤ} (hd : 0 ≤ d) : {x // d ≤ x } ≃
  {x // x ∉ range (int.eq_coe_of_zero_le hd).some}:=
begin
  fconstructor,
  { rintro ⟨_, h⟩,
    have := (int.eq_coe_of_zero_le (hd.trans h)).some_spec,
    rw [(int.eq_coe_of_zero_le hd).some_spec, this, int.coe_nat_le, ← not_lt, ← mem_range] at h,
    exact ⟨_, h⟩ },
  { rintro ⟨_, h⟩,
    rw [mem_range, nat.lt_iff_add_one_le, not_le, nat.lt_add_one_iff, ← int.coe_nat_le,
      ← (int.eq_coe_of_zero_le hd).some_spec] at h,
    exact ⟨_, h⟩ },
  { rintro ⟨_, h⟩,
    simp only [int.coe_nat_inj', int.of_nat_eq_coe],
    exact (int.eq_coe_of_zero_le (hd.trans h)).some_spec.symm },
  { rintro ⟨_, h⟩,
    simp only [int.coe_nat_inj', int.of_nat_eq_coe],
    exact ((@exists_eq' _ _).some_spec).symm },
end

def T {d : ℤ} (hd : d < 0) : finset {x : ℤ // d ≤ x} := Ico ⟨d, le_of_eq rfl⟩ ⟨0, le_of_lt hd⟩

def equiv_Ico_nat_neg {d : ℤ} (hd : d < 0) : { y : {x : ℤ // d ≤ x } // y ∉ T hd } ≃ ℕ :=
begin
  fconstructor,
  { rintro ⟨⟨a, ha⟩, hx⟩,
    have : 0 ≤ a,
    simpa only [subtype.mk_le_mk, subtype.mk_lt_mk, not_and, not_lt, ha, forall_true_left] using (not_iff_not_of_iff mem_Ico).mp hx,
    use (int.eq_coe_of_zero_le this).some },
  { intro n,
    use n,
    have : d ≤ n,
    repeat { exact le_of_lt (lt_of_lt_of_le hd (int.of_nat_nonneg n))},
    apply (not_iff_not_of_iff mem_Ico).mpr,
    simp only [subtype.mk_lt_mk, not_and, not_lt, implies_true_iff, int.coe_nat_nonneg] at * },
    { rintro ⟨⟨x, hx⟩, h⟩,
      simp only,
      have := (not_iff_not_of_iff mem_Ico).mp h,
      simp only [subtype.mk_le_mk, not_and, not_lt, hx, forall_true_left] at this,
      exact (Exists.some_spec (int.eq_coe_of_zero_le this)).symm },
    { intro n,
      simp only [int.coe_nat_inj'],
      exact ((@exists_eq' _ _).some_spec).symm },
end

def R {d n : ℤ} (hn : 0 ≤ n - d) : finset {x : ℤ // d ≤ x} := Icc ⟨d, le_of_eq rfl⟩ ⟨n, int.le_of_sub_nonneg hn⟩

def equiv_Icc_R {d n : ℤ} (hn : 0 ≤ n - d) : Icc d n ≃ R hn :=
begin
  fconstructor,
  { rintro ⟨m, hm⟩,
    replace hm := mem_Icc.mp hm,
    use ⟨m, hm.1⟩,
    dsimp [R],
    rw mem_Icc,
    use and.intro (subtype.mk_le_mk.mpr hm.1) (subtype.mk_le_mk.mpr hm.2) },
  { dsimp [R],
    rintro ⟨⟨x, hx⟩, h⟩,
    rw mem_Icc at h,
    use x,
    rw mem_Icc,
    use and.intro hx (subtype.mk_le_mk.mp h.2) },
  { simp only [id.def],
    rintro ⟨⟨x, hx⟩, h⟩,
    all_goals {simp only}, },
  { simp only [id.def],
    dsimp [R],
    rintro ⟨⟨x, hx⟩, h⟩,
    simp only },
end

def equiv_compl_R_bdd {d n : ℤ} (hn : 0 ≤ n - d): {a : ℤ // n.succ ≤ a } ≃
  ((R hn)ᶜ : set {x : ℤ // d ≤ x}) :=
begin
  fconstructor,
  { rintro ⟨m, hm⟩,
    have hd : d ≤ m := (int.le_add_one (int.le_of_sub_nonneg hn)).trans hm,
    use ⟨m, hd⟩,
    dsimp only [R],
    simpa [mem_coe, set.mem_compl_eq, mem_Icc, subtype.mk_le_mk, not_and, hd, forall_true_left, not_le, int.lt_iff_add_one_le, hm] },
  { rintro ⟨⟨x, hx⟩, h_mem⟩,
    dsimp only [R] at h_mem,
    simp only [subtype.mk_le_mk, coe_Icc, not_and, not_le, set.mem_compl_eq, set.mem_Icc, hx, forall_true_left, int.lt_iff_add_one_le] at h_mem,
    use ⟨x, h_mem⟩ },
  { rintro ⟨_, _⟩, simp only [id.def] },
  { rintro ⟨⟨_, _⟩, _⟩, simpa }
end

end equivalences_def

section equivalences_lemma

--for mathlib?
lemma sum_reverse {β : Type*} [add_comm_group β] (f : ℤ → β) (n : ℕ) :
  ∑ l in (range n.succ), (f (n - l)) = ∑ l in (range n.succ), f l :=
begin
  induction n with n hn generalizing f,
  { simp only [zero_sub, int.coe_nat_zero, sum_singleton, neg_zero, range_one] },
  { rw [sum_range_succ', sum_range_succ (f ∘ coe)],
    simp only [←hn, int.coe_nat_zero, add_sub_add_right_eq_sub, function.comp_app, sub_zero,
      int.coe_nat_succ] }
end

lemma sum_range_sum_Icc' {α : Type*} [field α] (f : ℤ → α) {n d : ℤ} (hn : 0 ≤ n - d) :
 ∑ l in (range (int.eq_coe_of_zero_le hn).some.succ), (f (n - l)) * 2 ^ l =
 ∑ k in (Icc d n), (f k) * 2 ^ (n - k) :=
begin
  let m := (int.eq_coe_of_zero_le hn).some,
  have h := (int.eq_coe_of_zero_le hn).some_spec.symm,
  have sum_swap : ∑ (l : ℕ) in range m.succ, f (n - l) * 2 ^ l =
    ∑ (l : ℕ) in range m.succ, f (l + d) * 2 ^ (m - l),
  { convert (sum_reverse (λ l, f (n - l) * 2 ^ l) m).symm using 1,
    { simp_rw ← zpow_coe_nat },
    refine sum_congr rfl (λ x hx, _),
    congr' 1,
    { rw [sub_sub_assoc_swap, add_comm n, add_sub_assoc],
      exact congr_arg f ((add_right_inj _).mpr (eq_sub_iff_add_eq.mpr (eq_sub_iff_add_eq'.mp h))) },
    { simp only [← zpow_of_nat, int.of_nat_eq_coe, ← int.sub_nat_nat_eq_coe, int.sub_nat_nat_of_le
        (nat.lt_succ_iff.mp (mem_range.mp hx))] } },
  rw [sum_swap, ← sum_finset_coe, ← sum_finset_coe _ (Icc _ _)],
  refine fintype.sum_equiv (range_equiv_Icc _ h.symm) _ _ (λ x, _),
  dsimp [range_equiv_Icc],
  rw [← sub_sub, sub_right_comm, ← zpow_coe_nat],
  refine congr_arg ((*) _) (congr_arg (pow 2) _),
  have := @nat.cast_sub ℤ _ _ _ _ (mem_range_succ_iff.mp x.2),
  simpa only [this, h, int.nat_cast_eq_coe_nat, sub_left_inj, subtype.val_eq_coe],
end

lemma sum_range_sum_Icc (f : ℤ → ℝ) (n d : ℤ) (hn : 0 ≤ n - d) :
 ∑ l in (range (int.eq_coe_of_zero_le hn).some.succ), (f (n - l)) * 2 ^ l =
 ∑ k in (Icc d n), (f k) * 2 ^ (n - k) :=
sum_range_sum_Icc' f hn


lemma equiv_Icc_bdd_nonneg_apply {d : ℤ} (hd : 0 ≤ d) (x : {x // d ≤ x}) :
  ((equiv_Icc_bdd_nonneg hd x) : ℤ) = x.1 :=
begin
  rcases x with ⟨_, h⟩,
  exact (Exists.some_spec (int.eq_coe_of_zero_le (hd.trans h))).symm,
end


lemma equiv_Ico_nat_neg_apply {d : ℤ} (hd : d < 0) {y : {x : ℤ // d ≤ x}} (h : y ∉ T hd) : y.1 = (equiv_Ico_nat_neg hd) ⟨y, h⟩ :=
begin
  rcases y with ⟨_, hy⟩,
  have := (not_iff_not_of_iff mem_Ico).mp h,
  simp only [subtype.mk_le_mk, subtype.mk_lt_mk, not_and, not_lt, hy, forall_true_left] at this,
  exact (Exists.some_spec (int.eq_coe_of_zero_le this))
end

lemma equiv_Icc_R_apply {d n : ℤ} (hn : 0 ≤ n - d) (x : Icc d n) : ((equiv_Icc_R hn x) : ℤ) =
  (x : ℤ) := by {rcases x, refl}

lemma equiv_compl_R_bdd_apply {d n : ℤ} (hn : 0 ≤ n - d) (x : {a : ℤ // n.succ ≤ a }) :
(equiv_compl_R_bdd hn x : ℤ) = (x : ℤ) := by {rcases x with ⟨y, hy⟩, simpa}

lemma sum_Icc_sum_tail (f : ℤ → ℤ) (n d : ℤ)
  (hf : (has_sum (λ x : ℤ, (f x : ℝ) * (2 ^ x)⁻¹) 0))
  (hd : ∀ n : ℤ, n < d → f n = 0)
  (hn : 0 ≤ n - d) : - ∑ k in (Icc d n), ((f k) : ℝ) * 2 ^ (n - k) =
  2 ^ n * tsum (λ x : {a : ℤ // n.succ ≤ a }, (f x : ℝ) * (2 ^ x.1)⁻¹) :=
begin
  simp_rw [zpow_sub₀ (@two_ne_zero ℝ _ _), div_eq_mul_inv, ← mul_assoc, (mul_comm _ ((2 : ℝ) ^ n)), mul_assoc, ← mul_sum, neg_mul_eq_mul_neg, mul_eq_mul_left_iff],
  apply or.intro_left,
  have H_supp : function.support (λ n : ℤ, (f n  : ℝ) * (2 ^ n)⁻¹) ⊆ { a : ℤ | d ≤ a},
  { rw function.support_subset_iff,
    intro _,
    rw [← not_imp_not, not_not, mul_eq_zero],
    intro hx,
    simp only [not_le, set.mem_set_of_eq] at hx,
    apply or.intro_left,
    exact int.cast_eq_zero.mpr (hd _ hx), },
  rw ← (@has_sum_subtype_iff_of_support_subset ℝ ℤ _ _ (λ n : ℤ, ( f n ) * (2 ^ n)⁻¹) _ _ H_supp) at hf,
  let g := (λ n : {x : ℤ // d ≤ x}, ( f n : ℝ) * (2 ^ n.1)⁻¹),
  have hg : has_sum g 0 := hf,
  have := @sum_add_tsum_compl _ _ _ _ _ g _ (R hn) hg.summable,
  rw [hg.tsum_eq, add_eq_zero_iff_eq_neg] at this,
  replace this := neg_eq_iff_neg_eq.mpr this.symm,
  convert this using 1,
  { simp only [neg_inj],
    have h_R := @fintype.sum_equiv (Icc d n) (R hn) _ _ _ _ (equiv_Icc_R hn) ((λ x : ℤ, ((f x : ℝ) * (2 ^ x)⁻¹)) ∘ coe) (g ∘ coe),
    rw @sum_subtype ℝ ℤ _ (∈ Icc d n) _ (Icc d n) _ (λ x, ((f x) : ℝ) * (2 ^x)⁻¹),
    rw @sum_subtype ℝ _ _ (∈ R hn) _ (R hn) _ (λ x, g x),
    simp only,
    refine h_R _,
    { intro x,
      dsimp [g],
      rw [← coe_coe, equiv_Icc_R_apply hn x] },
    all_goals { intro _, refl } },
  { dsimp only [g],
    refine eq.trans _ (@equiv.tsum_eq _ _ _ _ _ _ (equiv_compl_R_bdd hn) (λ x, (f x : ℝ) * (2 ^ (x.1 : ℤ))⁻¹)),
    apply tsum_congr,
    intro x,
    simp_rw [← coe_coe],
    nth_rewrite_rhs 0 [subtype.val_eq_coe],
    rw [← coe_coe, equiv_compl_R_bdd_apply hn x, ← subtype.val_eq_coe], }
end

end equivalences_lemma

section summability

lemma summable_shift (f : ℤ → ℝ) (N : ℤ) :
  summable (λ x : ℕ, f (x + N)) ↔ summable (λ x : {x // N ≤ x}, f x) :=
@equiv.summable_iff _ _ _ _ _ (λ x : {x // N ≤ x}, f x) (equiv_bdd_integer_nat N)


lemma int_tsum_shift (f : ℤ → ℝ) (N : ℤ) :
  ∑' (x : ℕ), f (x + N) = ∑' (x : {x // N ≤ x}), f x :=
begin
  apply (equiv.refl ℝ).tsum_eq_tsum_of_has_sum_iff_has_sum rfl,
  intro _,
  apply (@equiv.has_sum_iff ℝ _ ℕ _ _ (f ∘ coe) _ ((equiv_bdd_integer_nat N))),
end

-- lemma aux_summable_iff_on_nat' {f : ℤ → ℤ} {ρ : ℝ≥0} (d : ℤ) (h : ∀ n : ℤ, n < d → f n = 0) :
--   summable (λ n, ∥ f n ∥ * ρ ^ n) ↔ summable (λ n : ℕ, ∥ f (n + d) ∥ * ρ ^ (n + d : ℤ)) :=
-- begin
--   have hf : function.support (λ n : ℤ, ∥ f n ∥ * ρ ^ n) ⊆ { a : ℤ | d ≤ a},
--   { rw function.support_subset_iff,
--     intro x,
--     rw [← not_imp_not, not_not, mul_eq_zero],
--     intro hx,
--     simp only [not_le, set.mem_set_of_eq] at hx,
--     apply or.intro_left,
--     rw norm_eq_zero,
--     exact h x hx },
--   have h1 := λ a : ℝ,
--     @has_sum_subtype_iff_of_support_subset ℝ ℤ _ _ (λ n : ℤ, ∥ f n ∥ * ρ ^ n) _ _ hf,
--   have h2 := λ a : ℝ,
--     @equiv.has_sum_iff ℝ {b : ℤ // d ≤ b} ℕ _ _ ((λ n, ∥ f n ∥ * ρ ^ n) ∘ coe) _
--     (equiv_bdd_integer_nat d),
--   exact exists_congr (λ a, ((h2 a).trans (h1 a)).symm),
-- end

lemma aux_summable_iff_on_nat {f : ℤ → ℝ} {ρ : ℝ≥0} (d : ℤ) (h : ∀ n : ℤ, n < d → f n = 0) :
  summable (λ n, ∥ f n ∥ * ρ ^ n) ↔ summable (λ n : ℕ, ∥ f (n + d) ∥ * ρ ^ (n + d : ℤ)) :=
begin
  have hf : function.support (λ n : ℤ, ∥ f n ∥ * ρ ^ n) ⊆ { a : ℤ | d ≤ a},
  { rw function.support_subset_iff,
    intro x,
    rw [← not_imp_not, not_not, mul_eq_zero],
    intro hx,
    simp only [not_le, set.mem_set_of_eq] at hx,
    apply or.intro_left,
    rw norm_eq_zero,
    exact h x hx },
  have h1 := λ a : ℝ,
    @has_sum_subtype_iff_of_support_subset ℝ ℤ _ _ (λ n : ℤ, ∥ f n ∥ * ρ ^ n) _ _ hf,
  have h2 := λ a : ℝ,
    @equiv.has_sum_iff ℝ {b : ℤ // d ≤ b} ℕ _ _ ((λ n, ∥ f n ∥ * ρ ^ n) ∘ coe) _
    (equiv_bdd_integer_nat d),
  exact exists_congr (λ a, ((h2 a).trans (h1 a)).symm),
end

lemma summable_iff_on_nat {f : ℤ → ℝ} {ρ : ℝ≥0} (d : ℤ) (h : ∀ n : ℤ, n < d → f n = 0) :
  summable (λ n, ∥ f n ∥ * ρ ^ n) ↔ summable (λ n : ℕ, ∥ f n ∥ * ρ ^ (n : ℤ)) :=
begin
  apply (aux_summable_iff_on_nat d h).trans,
  -- apply (aux_summable_iff_on_nat' d h).trans,
  simp only [@summable_shift (λ n, ∥ f n ∥ * ρ ^n) d, zpow_coe_nat],
  by_cases hd : 0 ≤ d,
  { set m := (int.eq_coe_of_zero_le hd).some,
    convert (@equiv.summable_iff _ _ _ _ _ (λ x : {x : ℕ // x ∉ range m},
      ∥ f x ∥ * ρ ^ (x : ℤ)) (equiv_Icc_bdd_nonneg hd)).trans (@finset.summable_compl_iff _ _ _ _ _
      (λ n : ℕ, ∥ f n ∥ * ρ ^ n) (range m)),
    ext ⟨_, _⟩,
    simp only [function.comp_app, subtype.coe_mk, ← zpow_coe_nat, ← coe_coe,
      equiv_Icc_bdd_nonneg_apply] },
  { rw not_le at hd,
    have h_fin := @finset.summable_compl_iff _ _ _ _ _
      (λ n : {x // d ≤ x }, ∥ f n ∥ * ρ ^ (n : ℤ)) (T hd),
    apply ((@finset.summable_compl_iff _ _ _ _ _
      (λ n : {x // d ≤ x }, ∥ f n ∥ * ρ ^ (n : ℤ)) (T hd)).symm).trans,
    refine iff.trans _ (@equiv.summable_iff _ _ _ _ _ (λ n : ℕ, ∥ f n ∥ * ρ ^ n)
      (equiv_Ico_nat_neg hd)),
    apply summable_congr,
    rintro ⟨⟨x, hx⟩, h⟩,
    simp only [function.comp_app, subtype.coe_mk, ← (equiv_Ico_nat_neg_apply hd h),
      subtype.val_eq_coe, ← zpow_coe_nat] }
end

lemma int.summable_iff_on_nat {f : ℤ → ℤ} {ρ : ℝ≥0} (d : ℤ) (h : ∀ n : ℤ, n < d → f n = 0) :
summable (λ n, ∥ f n ∥ * ρ ^ n) ↔ summable (λ n : ℕ, ∥ f n ∥ * ρ ^ (n : ℤ)) :=
  begin
    apply summable_iff_on_nat d,
    simpa only [int.cast_eq_zero],
  end


-- **[FAE]** Need to copy the proof of summable_smaller_radius, split it into two lemmas
  -- and remove it altogether from `thm69.lean`
lemma summable_smaller_radius_norm {f : ℤ → ℤ} {ρ : ℝ≥0} (d : ℤ) (ρ_half : 1 / 2 < ρ)
(hf : summable (λ n : ℤ, ∥ f n ∥ * ρ ^ n))
  (hd : ∀ n : ℤ, n < d → f n = 0) : --(F : ℒ S) (s : S) :
  summable (λ n, ∥ f n ∥ * (1 / 2) ^ n) :=
begin
  have pos_half : ∀ n : ℕ, 0 ≤ ∥ f n ∥ * (1 / 2) ^ n,
  { intro n,
    apply mul_nonneg (norm_nonneg (f n)),
    simp only [one_div, zero_le_one, inv_nonneg, zero_le_bit0, pow_nonneg] },
  have half_le_ρ : ∀ n : ℕ, ∥ f n ∥ * (1 / 2) ^ n ≤ ∥ f n ∥ * ρ ^ n,
  { intro n,
    apply monotone_mul_left_of_nonneg (norm_nonneg (f n)),
    apply pow_le_pow_of_le_left,
    simp only [one_div, zero_le_one, inv_nonneg, zero_le_bit0],
    exact le_of_lt ρ_half },
  have h_nat_half : summable (λ n : ℕ, ∥ f n ∥ * (1 / 2 : ℝ≥0) ^ n) :=
    summable_of_nonneg_of_le pos_half half_le_ρ ((int.summable_iff_on_nat d _).mp hf),
  apply (int.summable_iff_on_nat d _).mpr h_nat_half,
  all_goals {apply hd},
end


lemma summable_smaller_radius {f : ℤ → ℤ} {ρ : ℝ≥0} (d : ℤ)
(hf : summable (λ n : ℤ, ∥ f n ∥ * ρ ^ n))
  (hd : ∀ n : ℤ, n < d → f n = 0) (hρ : (1 / 2) < ρ) : --(F : ℒ S) (s : S) :
  summable (λ n, (f n : ℝ) * (1 / 2) ^ n) :=
  begin
  apply summable_of_summable_norm,
  simp_rw [normed_field.norm_mul, normed_field.norm_zpow, normed_field.norm_div, real.norm_two,
      norm_one],
  exact summable_smaller_radius_norm d hρ hf hd,
  end

-- lemma goofy {r : ℝ≥0} (f : ℤ → ℤ) (hf : summable (λ n, ∥ f n ∥ * r ^ n)) (b : ℕ)
-- : (λ n : ℕ, (2 * r : ℝ) ^ n * ∥∑' (x : ℕ), (1 / 2 : ℝ) ^ (n + 1 + x : ℤ) * (f (n + 1 + x : ℤ))∥) b
--   ≤ (λ n : ℕ, (2 * r : ℝ) ^ n * ∥∑' (x : ℕ), (1 / 2 : ℝ) ^ (x + 1) * (f (x + 1))∥) b:=
-- begin
-- end

-- lemma half_ne_zero : (1 / 2 : ℝ) ≠ 0 := by {simp only [one_div, ne.def, inv_eq_zero, bit0_eq_zero,
--     one_ne_zero, not_false_iff]}

-- lemma heather {r : ℝ≥0} (f : ℤ → ℤ) : --(h : summable (λ kl: ℕ × ℕ, (1 / 2 : ℝ) *
--   -- ∥ f (kl.fst + 1 + kl.snd) ∥ * r ^ (kl.snd) )) :
--   summable (λ (n : ℕ), 1 / 2 * ∑' (i : ℕ), (f (n + 1 + i) : ℝ) * (1 / 2) ^ i * ↑r ^ n) :=
-- begin
--   have easy : ∀ (n : ℕ), summable (λ (i : ℕ), (f (n + 1 + i) : ℝ) *
--     (1 / 2) ^ i * ↑r ^ n),
--   { intro n,
--     apply summable.mul_right,
--     sorry,
--   },
--   set ϕ := (λ lj: ℕ × ℕ, (1 / 2 : ℝ) * f (lj.fst + 1 + lj.snd) * (1 / 2)^(lj.snd) * r ^ (lj.fst) ),
--   set ψ := (λ n : ℕ, (1/2 : ℝ) * ∑' (i : ℕ), (f (n + 1 + i) : ℝ) * (1 / 2)^i * r^n),
--   have crux : summable ϕ, --   have H : ∀ b : ℕ, has_sum (λ i : ℕ, ϕ(b, i)) (ψ b),
--   { intro n,
--     dsimp [ϕ, ψ, tsum],
--     rw [dif_pos (easy n)],
--     simp_rw mul_assoc,
--     rw [← has_sum_mul_left_iff (ne_of_gt (@one_half_pos ℝ _))],
--     exact Exists.some_spec _, },
--   have := has_sum.prod_fiberwise crux.has_sum H,
--   -- have := has_sum.prod_fiberwise crux.has_sum H,
--   -- have hope := @has_sum.prod_fiberwise _ _ _ _ _ _ _ ϕ ψ (∑' mn : ℕ × ℕ, ϕ mn) crux.has_sum H,
--   exact this.summable,
-- end

def nat_lt_nat := { x : ℕ × ℕ // x.snd < x.fst }
local notation `𝒮` := nat_lt_nat

--move me in the section below
lemma summable.summable_on_𝒮 (f g : ℕ → ℝ) (hf : summable (λ n, ∥ f n ∥))
  (hg : summable (λ n, ∥ g n ∥)) : summable (λ x : ℕ × ℕ, f (x.fst + 1 + x.snd) * g (x.snd)) :=
begin
  sorry
end

-- def 𝒮_equiv : ℕ × ℕ ≃ 𝒮 :=
-- begin
--   fconstructor,
--   { intro lk,

--   },
-- end


lemma prod_nat_summable {f : ℤ → ℤ} {r : ℝ≥0} (d : ℤ)
  (r_pos : 0 < r)
  (hf : summable (λ n : ℤ, ∥ f n ∥ * r ^ n))
  (hd : ∀ n : ℤ, n < d → f n = 0)
  : summable (λ lj: ℕ × ℕ, (1 / 2 : ℝ) * ∥ (f (lj.fst + 1 + lj.snd) : ℝ)
    * (1/2)^(lj.snd) ∥ * r ^ (lj.fst)) :=
begin
  have aux_rw : ∀ (lj : ℕ × ℕ), ↑(f (↑(lj.fst) + 1 + lj.snd)) * (1 / 2 * (1 / 2) ^ lj.snd *
    ((r : ℝ) ^ lj.fst)) = ↑(f (↑(lj.fst) + 1 + lj.snd)) * (r : ℝ) ^ (lj.fst + 1 + lj.snd) *
      (1 / (2 * r) ) ^ (lj.snd + 1),
  { rintro ⟨l, j⟩,
    simp only,
    rw [mul_assoc, mul_assoc, mul_eq_mul_left_iff],
    apply or.intro_left,
    simp only [one_div, inv_pow₀, div_pow, one_div],
    rw [mul_pow, mul_inv₀, ← mul_assoc ((r : ℝ) ^ (l + 1 + j)) _ _,
      mul_comm ((r : ℝ) ^ (l + 1 + j)) _, ← mul_assoc, ← zpow_coe_nat _ (l + 1 + j)],
    nth_rewrite 1 [← zpow_coe_nat _ (j + 1)],
    nth_rewrite 1 mul_assoc,
    rw [← zpow_neg₀, ← zpow_add₀],
    simp only [int.coe_nat_add, int.coe_nat_succ, neg_add_rev],
    rw [← neg_add, ← sub_eq_add_neg],
    simp only [add_sub_add_right_eq_sub, add_tsub_cancel_right],
    rw [zpow_coe_nat, mul_eq_mul_right_iff],
    apply or.intro_left,
    rw [add_comm, ← mul_inv₀, inv_inj₀, pow_add, pow_one],
    simp only [ne.def, nnreal.coe_eq_zero],
    exact ne_of_gt r_pos },
  have half_norm : (1 / 2 : ℝ) = ∥ (1 / 2  : ℝ) ∥ := by { simp only [one_div,
    normed_field.norm_inv, real.norm_two]},
  have r_norm : ∀ (n : ℕ), (r : ℝ) ^ n = ∥ (r : ℝ) ^ n ∥ := by { simp only [normed_field.norm_pow,
    nnreal.norm_eq, eq_self_iff_true, forall_const] },
  conv
  begin
    congr,
    funext,
    rw [half_norm, ← normed_field.norm_mul, ← half_norm, r_norm lj.fst, ← normed_field.norm_mul,
      ← mul_assoc, mul_comm (1 / 2 : ℝ) _, mul_assoc, mul_assoc, ← mul_assoc (1 / 2 : ℝ) _,
        aux_rw lj],--, normed_field.norm_mul],
  end,
  have hf_real : summable (λ n : ℕ, ∥ ((f n) : ℝ) * r ^ n ∥), sorry,
  -- have hd_real : (hd : ∀ n : ℤ, n < d → f n = 0)
  have geom : summable (λ n : ℕ, ∥ 1 / (2 * r : ℝ) ^ n ∥),
  { conv
    begin
      congr,
      funext,
      rw normed_field.norm_div,
      rw norm_one,
      rw normed_field.norm_pow,
      --rw one_pow,
      -- rw ← div_pow,
    end,
    sorry
    --apply summable_geometric_iff_norm_lt_1.mpr
  },
  have almost_there := hf_real.mul_norm geom,
  simp only at almost_there,
  sorry,
end


lemma fiberwise_summable_norm {f : ℤ → ℤ} {r : ℝ≥0} (d : ℤ) (r_half : 1 / 2 < r)
(r_pos' : 0 < r) (hf : summable (λ n : ℤ, ∥ f n ∥ * r ^ n))
  (hd : ∀ n : ℤ, n < d → f n = 0) :
  summable (λ (n : ℕ), 1 / 2 * ∥ ∑' (i : ℕ), (f (n + 1 + i) : ℝ) * (1 / 2) ^ i ∥ * ↑r ^ n) :=
begin
  have r_pos : ∀ (b : ℕ), 0 < (r : ℝ) ^ b := pow_pos r_pos',
  have smaller_shift : ∀ (b : ℕ), summable (λ j : ℕ, ∥ (f (b + 1 + j) : ℝ)  * (1 / 2 ) ^ j ∥),
  { intro b,
    have b_half_norm : ∥ (1 / 2 : ℝ) ^ (b + 1) ∥ ≠ 0,
    { simp only [one_div, normed_field.norm_inv, normed_field.norm_pow, real.norm_two, ne.def,
      inv_eq_zero, pow_eq_zero_iff, nat.succ_pos', bit0_eq_zero, one_ne_zero, not_false_iff] },
    rw [summable_mul_right_iff b_half_norm],
    simp_rw [← normed_field.norm_mul, mul_assoc, ← pow_add, add_comm _ (b + 1), ← zpow_coe_nat,
      int.coe_nat_add, int.coe_nat_one],
    have half_coe : ((1 / 2 : ℝ≥0) : ℝ) = (1 / 2 : ℝ),
    { rw [one_div, nonneg.coe_inv, nnreal.coe_bit0,
      nonneg.coe_one, one_div] },
    have := (@int.summable_iff_on_nat f (1 / 2 : ℝ≥0) d hd).mp,
    simp_rw half_coe at this,
    replace := this (summable_smaller_radius_norm d r_half hf hd),
    convert (summable.comp_injective this (add_right_injective (b + 1))),
    funext n,
    rw [add_comm, add_comm],
    simp only [function.comp_app, int.coe_nat_add, int.coe_nat_succ, normed_field.norm_mul,
      normed_field.norm_zpow, one_div, normed_field.norm_inv, real.norm_two, mul_eq_mul_right_iff,
      int.norm_cast_real, eq_self_iff_true, true_or], },
  set ϕ := (λ lj: ℕ × ℕ, (1 / 2 : ℝ) * ∥ (f (lj.fst + 1 + lj.snd) : ℝ) * (1/2)^(lj.snd) ∥ *
    r ^ (lj.fst) ),
  have H : ∀ b : ℕ, summable (λ i : ℕ, ϕ(b, i)),
  { intro n,
    exact (summable_mul_right_iff (ne_of_gt (r_pos n))).mp ((smaller_shift n).mul_left (1 / 2)) },
  have := (has_sum.prod_fiberwise (prod_nat_summable d r_pos' hf hd).has_sum (λ b, (H b).has_sum)).summable,
  dsimp [ϕ] at this,
  apply summable_of_nonneg_of_le _ _ this,
  { intro b,
    apply mul_nonneg (mul_nonneg _ (norm_nonneg _)) (le_of_lt (r_pos b)),
    simp only [one_div, inv_nonneg, zero_le_bit0, zero_le_one] },
  { intro b,
    simp_rw mul_assoc,
    rw [tsum_mul_left, mul_le_mul_left (@one_half_pos ℝ _), tsum_mul_right,
      mul_le_mul_right (r_pos b)],
    exact norm_tsum_le_tsum_norm (smaller_shift b), },
end

-- lemma aux_pos_terms {r : ℝ≥0} (f : ℤ → ℤ) (n : ℕ) : 0 ≤ (2 * r : ℝ) ^ n *
--   ∥∑' (x : ℕ), (1 / 2 : ℝ) ^ (n + 1 + x) * ↑(f (n + 1 + x))∥ :=

lemma summable_convolution {r : ℝ≥0} (r_pos: 0 < r) (r_half : 1 / 2 < r) (f : ℤ → ℤ) (d : ℤ)
  (hf : summable (λ n, ∥ f n ∥ * r ^ n)) (hd : ∀ n : ℤ, n < d → f n = 0)
  (hd_shift : ∀ (n : ℤ), n < d → ∥∑' (i : ℕ), (f (n + 1 + i) : ℝ) * (1 / 2) ^ i∥ = 0)
    :
  summable (λ n : ℤ, (1 / 2) * ∥ tsum (λ i : ℕ, ((f (n + 1 + i)) : ℝ) * (1 / 2) ^ i) ∥ * r ^ n) :=
begin
  suffices h_on_nat : summable (λ (n : ℕ),
    (1 / 2) * ∥∑' (i : ℕ), (f (n + 1 + i) : ℝ) * (1 / 2) ^ i∥ * (r : ℝ) ^ n),
  { simp_rw mul_assoc at ⊢ h_on_nat,
    rw [← summable_mul_left_iff (ne_of_gt (@one_half_pos ℝ _))] at ⊢ h_on_nat,
    refine (@summable_iff_on_nat (λ n, ∑' (i : ℕ), (f (n + 1 + i)) * (1 / 2) ^ i)
      r d _).mpr h_on_nat,
    intros n hn,
    exact norm_eq_zero.mp (hd_shift n hn) },
  apply fiberwise_summable_norm d r_half r_pos hf hd,
end


-- #exit
-- sorry;{
--   { have half_norm : (1 / 2 : ℝ) = ∥ (1 / 2  : ℝ) ∥ := by { simp only [one_div,
--     normed_field.norm_inv, real.norm_two]},
--     rw half_norm,
--     simp_rw [mul_comm, ← normed_field.norm_mul, ← tsum_mul_left, ← mul_assoc],
--     rw ← half_norm,
--     simp_rw [← (pow_succ (1 / 2 : ℝ) _)],
--     convert_to summable (λ (lj : ℕ × ℕ), (1 / 2 : ℝ) * ∥ (f (lj.fst + 1 + lj.snd) : ℝ) *
--       (1 / 2) ^ (lj.snd) ∥ * r ^ (lj.fst)) using 0,
--     sorry,
--     sorry, },
--     -- convert_to summable (λ (n : ℕ), ∥∑' (x : ℕ), ( 1 / (2 * r : ℝ))^ (x + 1) * (r: ℝ) ^ (n + 1 + x : ℤ)
--     --   * (f (n + 1 + x))∥),
--     -- sorry,



--     --wrong
--     -- convert_to summable (λ (n : ℕ), ((2 : ℝ) * r) ^ n * ∥∑' (x : ℕ), (1 / 2 : ℝ) ^ (n + 1 + x : ℤ)
--     --   * (f (n + 1 + x))∥),
--     -- { funext n,
--     --   nth_rewrite_rhs 0 [mul_pow],
--     --   nth_rewrite_rhs 1 [mul_comm],
--     --   nth_rewrite_rhs 0 [mul_assoc],
--     --   rw mul_eq_mul_left_iff,
--     --   apply or.intro_left,
--     --   nth_rewrite_rhs 0 [← inv_inv₀ (2 : ℝ)],
--     --   nth_rewrite_rhs 0 [← zpow_neg_one],
--     --   nth_rewrite_rhs 0 [← zpow_of_nat],
--     --   nth_rewrite_rhs 0 [← zpow_mul₀],
--     --   nth_rewrite_rhs 0 [inv_eq_one_div],
--     --   rw [neg_one_mul, int.of_nat_eq_coe, half_norm, ← normed_field.norm_zpow,
--     --     ← normed_field.norm_mul ((1 / 2 : ℝ) ^ (- ↑n)) _, ← half_norm],
--     --   simp_rw [← tsum_mul_left, ← mul_assoc, ← zpow_add₀ $ one_div_ne_zero $ @two_ne_zero ℝ _ _,
--     --    add_assoc, neg_add_cancel_left, add_comm _ 1],
--     --   refl },

--     --   apply summable_of_nonneg_of_le _ (goofy f hf),
--     --   { have temp : ∥ (2 * r : ℝ) ∥ < 1, sorry,
--     --     apply summable.mul_right,
--     --     exact summable_geometric_of_norm_lt_1 temp,
--     --     --refine (summable_geometric_of_norm_lt_1 _).mul_right,
--     --   -- apply geom
--     --     },--intro b, exact aux_pos_terms f b},
--     --   { intro b,
--     --     have : (0 : ℝ) < (2 * ↑r) ^ b,
--     --     { apply pow_pos,
--     --       apply mul_pos,
--     --       simp only [zero_lt_bit0, zero_lt_one, nnreal.coe_pos],
--     --       simpa only [nnreal.coe_pos] },
--     --   exact aux_pos_terms f b }},

--   }
-- end


end summability

end aux_thm69
