import analysis.normed_space.lp_space
import topology.instances.real
import banach

open_locale nnreal big_operators

noncomputable theory

namespace pBanach

@[derive (module ℝ)]
def lp_type (p : ℝ≥0) := lp (λ n : ℕ, ℝ) p

variable (p : ℝ≥0)

instance : has_coe_to_fun (lp_type p) (λ f, ℕ → ℝ) :=
by { dsimp [lp_type], apply_instance }

instance : has_nnnorm (lp_type p) := has_nnnorm.mk $
λ f, ∑' n : ℕ, ∥ f n ∥₊^(p : ℝ)

@[simps]
instance : has_norm (lp_type p) := has_norm.mk $
λ f, ∑' n : ℕ, ∥ f n ∥^(p : ℝ)

variables {p} [fact (0 < p)]

lemma lp_type.summable (f : lp_type p) :
  summable (λ n, | f n |^(p : ℝ)) :=
begin
  have := f.2, dsimp [lp_type, lp, mem_ℓp] at this,
  rw if_neg at this, rwa if_neg at this,
  { exact ennreal.coe_ne_top },
  { refine (ne_of_gt _),
    exact_mod_cast (fact.out (0 < p)) },
end

variables [fact (p ≤ 1)]

instance : pseudo_metric_space (lp_type p) :=
{ dist := λ f g, ∥ f - g ∥,
  dist_self := by sorry ; begin
    have : (p : ℝ) ≠ (0 : ℝ),
    { refine ne_of_gt _, exact_mod_cast (fact.out (0 < p)) },
    intros f, dsimp,
    simp only [abs_zero, sub_self, real.zero_rpow this, tsum_zero],
  end,
  dist_comm := by sorry ; begin
    intros f g, dsimp,
    have : ∀ n, | f n - g n | = | g n - f n |,
    { intros n,
      rw [← neg_neg (f n - g n), abs_neg, neg_sub] },
    simp_rw this,
  end,
  dist_triangle := begin
    intros f g h,
    dsimp,
    have : ∀ n, |f n - h n| ^ (p : ℝ) ≤ | f n - g n | ^ (p : ℝ) + | g n - h n | ^ (p : ℝ),
    { intros n,
      suffices : ∥f n - h n∥₊ ^ (p : ℝ) ≤ ∥ f n - g n ∥₊ ^ (p : ℝ) + ∥ g n - h n ∥₊ ^ (p : ℝ),
      { exact_mod_cast this },
      refine le_trans _ (nnreal.rpow_add_le_add_rpow (∥f n - g n∥₊) (∥g n - h n∥₊) _ _),
      apply nnreal.rpow_le_rpow,
      rw (show (f n - h n = (f n - g n) + (g n - h n)), by abel), apply nnnorm_add_le,
      refine (le_of_lt _), any_goals { exact_mod_cast (fact.out (0 < p)) },
      exact_mod_cast (fact.out (p ≤ 1)) },
    have := tsum_le_tsum this _ _,
    refine le_trans this (le_of_eq _),
    apply tsum_add,
    { have hh := lp_type.summable (f - g), dsimp at hh, exact hh },
    { have hh := lp_type.summable (g - h), dsimp at hh, exact hh },
    { have hh := lp_type.summable (f - h), dsimp at hh, exact hh },
    { apply summable.add,
      have hh := lp_type.summable (f - g), dsimp at hh, exact hh,
      have hh := lp_type.summable (g - h), dsimp at hh, exact hh }
  end }

def has_p_norm : has_p_norm (lp_type p) p :=
{ norm_smul := begin
    intros a f, dsimp,
    have : ∀ n, |a * f n|^(p : ℝ) = |a|^(p : ℝ) * |f n|^(p : ℝ),
    { intros n, rw [abs_mul, real.mul_rpow],
      any_goals { exact abs_nonneg _ } },
    simp_rw this,
    rw tsum_mul_left,
  end,
  triangle := begin
    --TODO: pull out into a separate lemma so that it can be used above in `dist_triangle` as well.
    intros f g, dsimp,
    have : ∀ n, |f n + g n| ^ (p : ℝ) ≤ | f n | ^(p : ℝ) + |g n|^(p : ℝ),
    { intros n,
      suffices : ∥f n + g n∥₊ ^ (p : ℝ) ≤ ∥ f n ∥₊ ^(p : ℝ) + ∥ g n ∥₊^(p : ℝ),
      { exact_mod_cast this },
      refine le_trans _ (nnreal.rpow_add_le_add_rpow _ _ _ _),
      apply nnreal.rpow_le_rpow, apply nnnorm_add_le,
      refine (le_of_lt _), any_goals { exact_mod_cast (fact.out (0 < p)) },
      exact_mod_cast (fact.out (p ≤ 1)) },
    refine le_trans (tsum_le_tsum this _ _) (le_of_eq _),
    { have hh := lp_type.summable (f + g), dsimp at hh, exact hh },
    { apply summable.add,
      exact lp_type.summable f,
      exact lp_type.summable g },
    apply tsum_add,
    exact lp_type.summable f,
    exact lp_type.summable g,
  end,
  uniformity := rfl,
  ..(infer_instance : has_norm (lp_type p)) }

instance : topological_add_group (lp_type p) :=
{ continuous_add := sorry,
  continuous_neg := sorry }

instance : has_continuous_smul ℝ (lp_type p) :=
{ continuous_smul := sorry }

instance : complete_space (lp_type p) :=
sorry

instance : separated_space (lp_type p) :=
sorry

lemma p_banach : p_banach (lp_type p) p :=
{ exists_p_norm := nonempty.intro $ has_p_norm }

def lp (p : ℝ≥0) [fact (0 < p)] [fact (p ≤ 1)] : pBanach p :=
{ V := lp_type p,
  p_banach' := p_banach }

end pBanach
