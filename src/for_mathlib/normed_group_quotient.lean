import analysis.normed_space.normed_group_hom

import .quotient_group .real_Inf

open_locale nnreal

variables {V V₁ V₂ V₃ : Type*}
variables [normed_group V] [normed_group V₁] [normed_group V₂] [normed_group V₃]
variables (f g : normed_group_hom V₁ V₂)

namespace add_subgroup

instance {M : Type*} [normed_group M] {A : add_subgroup M} :
  is_closed (A.topological_closure : set M) := is_closed_closure

end add_subgroup

--move this somewhere
/-- If `A` if an additive subgroup of a normed group `M` and `f : normed_group_hom M N` is such that
`f a = 0` for all `a ∈ A`, then `f a = 0` for all `a ∈ A.topological_closure`. -/
lemma zero_of_closure {M N : Type*} [normed_group M] [normed_group N] (A : add_subgroup M)
  (f : normed_group_hom M N) (hf : ∀ a ∈ A, f a = 0) : ∀ m ∈ A.topological_closure, f m = 0 :=
show closure (A : set M) ≤ f ⁻¹' {0},
from Inf_le ⟨is_closed.preimage (normed_group_hom.continuous f) (t1_space.t1 0), hf⟩

namespace normed_group_hom -- probably needs to change
section quotient

open quotient_add_group

variables {M N : Type*} [normed_group M] [normed_group N]

/-- The definition of the norm on the quotient by an additive subgroup. -/
noncomputable
instance norm_on_quotient (S : add_subgroup M) : has_norm (quotient S) :=
{ norm := λ x, Inf (norm '' {m | mk' S m = x}) }

lemma image_norm_nonempty {S : add_subgroup M} :
  ∀ x : quotient S, (norm '' {m | mk' S m = x}).nonempty :=
begin
  rintro ⟨m⟩,
  rw set.nonempty_image_iff,
  use m,
  change mk' S m = _,
  refl
end

lemma bdd_below_image_norm (s : set M) : bdd_below (norm '' s) :=
begin
  use 0,
  rintro _ ⟨x, hx, rfl⟩,
  apply norm_nonneg
end

lemma quotient_norm_neg {S : add_subgroup M} (x : quotient S) : ∥-x∥ = ∥x∥ :=
begin
  suffices : norm '' {m | mk' S m = x} = norm '' {m | mk' S m = -x},
    by simp only [this, norm],
  ext r,
  split,
  { rintros ⟨m, hm : mk' S m = x, rfl⟩,
    subst hm,
    rw ← norm_neg,
    exact ⟨-m, by simp only [(mk' S).map_neg, set.mem_set_of_eq], rfl⟩ },
  { rintros ⟨m, hm : mk' S m = -x, rfl⟩,
    use -m,
    simp [hm] }
end

/-- The norm of the projection is smaller or equal to the norm of the original element. -/
lemma quotient_norm_mk_le (S : add_subgroup M) (m : M) :
  ∥mk' S m∥ ≤ ∥m∥ :=
begin
  apply real.Inf_le,
  use 0,
  { rintros _ ⟨n, h, rfl⟩,
    apply norm_nonneg },
  { apply set.mem_image_of_mem,
    rw set.mem_set_of_eq }
end

/-- The norm of the image under the natural morphism to the quotient. -/
lemma quotient_norm_mk_eq (S : add_subgroup M) (m : M) :
  ∥mk' S m∥ = Inf ((λ x, ∥m + x∥) '' S) :=
begin
  change Inf _ = _,
  congr' 1,
  simp only [mk'_eq_mk'_iff],
  ext r,
  split,
  { rintros ⟨y, h, rfl⟩,
    use [y - m, h],
    simp },
  { rintros ⟨y, h, rfl⟩,
    use m + y,
    simpa using h },
end

lemma quotient_norm_nonneg (S : add_subgroup M) : ∀ x : quotient S, 0 ≤ ∥x∥ :=
begin
  rintros ⟨m⟩,
  change 0 ≤ ∥mk' S m∥,
  apply real.lb_le_Inf _ (image_norm_nonempty _),
  rintros _ ⟨n, h, rfl⟩,
  apply norm_nonneg
end

/-- The quotient norm is nonnegative. -/
lemma norm_mk_nonneg (S : add_subgroup M) (m : M) : 0 ≤ ∥mk' S m∥ :=
quotient_norm_nonneg S _

lemma quotient_norm_eq_zero_iff (S : add_subgroup M) (m : M) :
  ∥mk' S m∥ = 0 ↔ m ∈ closure (S : set M) :=
begin
  have : 0 ≤ ∥mk' S m∥ := norm_mk_nonneg S m,
  rw [← this.le_iff_eq, quotient_norm_mk_eq, real.Inf_le_iff],
  simp_rw [zero_add],
  { calc (∀ ε > (0 : ℝ), ∃ r ∈ (λ x, ∥m + x∥) '' (S : set M), r < ε) ↔
        (∀ ε > 0, (∃ x ∈ S, ∥m + x∥ < ε)) : by simp [set.bex_image_iff]
     ... ↔ ∀ ε > 0, (∃ x ∈ S, ∥m + -x∥ < ε) : _
     ... ↔ ∀ ε > 0, (∃ x ∈ S, x ∈ metric.ball m ε) : by simp [dist_eq_norm, ← sub_eq_add_neg, norm_sub_rev]
     ... ↔ m ∈ closure ↑S : by simp [metric.mem_closure_iff, dist_comm],
    apply forall_congr, intro ε, apply forall_congr, intro  ε_pos, rw S.exists_mem_iff_exists_neg_mem },
  { use 0,
    rintro _ ⟨x, x_in, rfl⟩,
    apply norm_nonneg },
  rw set.nonempty_image_iff,
  use [0, S.zero_mem]
end

lemma norm_mk_lt {S : add_subgroup M} (x : (quotient S)) {ε : ℝ} (hε : 0 < ε) :
  ∃ (m : M), quotient_add_group.mk' S m = x ∧ ∥m∥ < ∥x∥ + ε :=
begin
  obtain ⟨_, ⟨m : M, H : mk' S m = x, rfl⟩, hnorm : ∥m∥ < ∥x∥ + ε⟩ :=
    real.lt_Inf_add_pos (bdd_below_image_norm _) (image_norm_nonempty x) hε,
  subst H,
  exact ⟨m, rfl, hnorm⟩,
end

lemma norm_mk_lt' (S : add_subgroup M) (m : M) {ε : ℝ} (hε : 0 < ε) :
  ∃ s ∈ S, ∥m + s∥ < ∥mk' S m∥ + ε :=
begin
  obtain ⟨n : M, hn : mk' S n = mk' S m, hn' : ∥n∥ < ∥mk' S m∥ + ε⟩ :=
    norm_mk_lt (quotient_add_group.mk' S m) hε,
  rw mk'_eq_mk'_iff at hn,
  use [n - m, hn],
  rwa [add_sub_cancel'_right]
end

lemma quotient_norm_add_le (S : add_subgroup M) (x y : quotient S) : ∥x + y∥ ≤ ∥x∥ + ∥y∥ :=
begin
  refine le_of_forall_pos_le_add (λ ε hε, _),
  replace hε := half_pos hε,
  obtain ⟨m, rfl, hm : ∥m∥ < ∥mk' S m∥ + ε / 2⟩ := norm_mk_lt x hε,
  obtain ⟨n, rfl, hn : ∥n∥ < ∥mk' S n∥ + ε / 2⟩ := norm_mk_lt y hε,
  calc ∥mk' S m + mk' S n∥ = ∥mk' S (m +  n)∥ : by rw (mk' S).map_add
  ... ≤ ∥m + n∥ : quotient_norm_mk_le S (m + n)
  ... ≤ ∥m∥ + ∥n∥ : norm_add_le _ _
  ... ≤ ∥mk' S m∥ + ∥mk' S n∥ + ε : by linarith
end

/-- The quotient norm of `0` is `0`. -/
lemma norm_mk_zero (S : add_subgroup M) : ∥(0 : (quotient S))∥ = 0 :=
begin
  erw quotient_norm_eq_zero_iff,
  exact subset_closure S.zero_mem
end

/-- If `(m : M)` has norm equal to `0` in `quotient S` for a closed subgroup `S` of `M`, then
`m ∈ S`. -/
lemma norm_zero_eq_zero (S : add_subgroup M) (hS : is_closed (↑S : set M)) (m : M)
  (h : ∥(quotient_add_group.mk' S) m∥ = 0) : m ∈ S :=
by rwa [quotient_norm_eq_zero_iff, hS.closure_eq] at h

/-- The seminorm on `quotient S` is actually a norm when S is closed. -/
lemma quotient.is_normed_group.core (S : add_subgroup M) [hS : is_closed (S : set M)] :
  normed_group.core (quotient S) :=
begin
  split,
  { rintros ⟨m⟩,
    erw [quotient_norm_eq_zero_iff, hS.closure_eq, mk'_eq_zero_iff],
    refl },
  { exact quotient_norm_add_le S },
  { simp [quotient_norm_neg] }
end

/-- The quotient in the category of normed groups. -/
noncomputable
instance normed_group_quotient (S : add_subgroup M) [hS : is_closed (S : set M)] :
  normed_group (quotient S) := normed_group.of_core (quotient S) (quotient.is_normed_group.core S)

/-- The morphism from a norrmed group to the quotient by a closed subgroup. -/
noncomputable
def normed_group.mk (S : add_subgroup M) [is_closed (S : set M)] :
  normed_group_hom M (quotient S) :=
{ bound' := ⟨1, λ m, by simpa [one_mul] using quotient_norm_mk_le  _ m⟩,
  ..quotient_add_group.mk' S }

/-- `normed_group.mk S` agrees with `quotient_add_group.mk' S`. -/
@[simp]
lemma normed_group.mk.apply (S : add_subgroup M) [is_closed (S : set M)] (m : M) :
  normed_group.mk S m = quotient_add_group.mk' S m := rfl

/-- `normed_group.mk S` is surjective. -/
lemma surjective_normed_group.mk (S : add_subgroup M) [is_closed (S : set M)] :
  function.surjective (normed_group.mk S) :=
surjective_quot_mk _

/-- The kernel of `normed_group.mk S` is `S`. -/
lemma normed_group.mk.ker (S : add_subgroup M) [is_closed (S : set M)] :
  (normed_group.mk S).ker = S := quotient_add_group.ker_mk  _

/-- `is_quotient f`, for `f : M ⟶ N` means that `N` is isomorphic to the quotient of `M`
by the kernel of `f`. -/
structure is_quotient (f : normed_group_hom M N) : Prop :=
(surjective : function.surjective f)
(norm : ∀ x, ∥f x∥ = Inf ((λ m, ∥x + m∥) '' f.ker))

/-- Given  `f : normed_group_hom M N` such that `f s = 0` for all `s ∈ S`, where,
`S : add_subgroup M` is closed, the induced morphism `normed_group_hom (quotient S) N`. -/
noncomputable
def lift {N : Type*} [normed_group N] (S : add_subgroup M) [is_closed (S : set M)]
  (f : normed_group_hom M N) (hf : ∀ s ∈ S, f s = 0) :
  normed_group_hom (quotient S) N :=
{ bound' :=
  begin
    obtain ⟨c : ℝ≥0, hcpos : (0 : ℝ) < c, hc : f.bound_by c⟩ := f.bound,
    refine ⟨c, λ mbar, le_of_forall_pos_le_add (λ ε hε, _)⟩,
    obtain ⟨m : M, rfl : mk' S m = mbar, hmnorm : ∥m∥ < ∥mk' S m∥ + ε/c⟩ :=
      norm_mk_lt mbar (div_pos hε hcpos),
    calc ∥f m∥ ≤ c * ∥m∥ : hc m
    ... ≤ c*(∥mk' S m∥ + ε/c) : ((mul_lt_mul_left hcpos).mpr hmnorm).le
    ... = c * ∥mk' S m∥ + ε : by rw [mul_add, mul_div_cancel' _ hcpos.ne.symm]
  end,
  .. quotient_add_group.lift S f.to_add_monoid_hom hf }

--@[simp]
lemma lift_mk  {N : Type*} [normed_group N] (S : add_subgroup M) [is_closed (S : set M)]
  (f : normed_group_hom M N) (hf : ∀ s ∈ S, f s = 0) (m : M) :
  lift S f hf (normed_group.mk S m) = f m := rfl

lemma lift_unique {N : Type*} [normed_group N] (S : add_subgroup M) [is_closed (S : set M)]
  (f : normed_group_hom M N) (hf : ∀ s ∈ S, f s = 0)
  (g : normed_group_hom (quotient S) N) :
  g.comp (normed_group.mk S) = f → g = lift S f hf :=
begin
  intro h,
  ext,
  rcases surjective_normed_group.mk _ x with ⟨x,rfl⟩,
  change (g.comp (normed_group.mk S) x) = _,
  rw h,
  refl,
end

/-- `normed_group.mk S` satisfies `is_quotient`. -/
lemma is_quotient_quotient (S : add_subgroup M) [is_closed (S : set M)] :
  is_quotient (normed_group.mk S) :=
⟨surjective_normed_group.mk S, λ m, by simpa [normed_group.mk.ker S] using quotient_norm_mk_eq _ m⟩

lemma quotient_norm_lift {f : normed_group_hom M N} (hquot : is_quotient f) {ε : ℝ} (hε : 0 < ε)
  (n : N) : ∃ (m : M), f m = n ∧ ∥m∥ < ∥n∥ + ε :=
begin
  obtain ⟨m, rfl⟩ := hquot.surjective n,
  have nonemp : ((λ m', ∥m + m'∥) '' f.ker).nonempty,
  { rw set.nonempty_image_iff,
    exact ⟨0, is_add_submonoid.zero_mem⟩ },
  have bdd : bdd_below ((λ m', ∥m + m'∥) '' f.ker),
  { use 0,
    rintro _ ⟨x, hx, rfl⟩,
    apply norm_nonneg },
  rcases real.lt_Inf_add_pos bdd nonemp hε with ⟨_, ⟨⟨x, hx, rfl⟩, H : ∥m + x∥ < Inf ((λ (m' : M), ∥m + m'∥) '' f.ker) + ε⟩⟩,
  exact ⟨m+x, by rw [f.map_add,(normed_group_hom.mem_ker f x).mp hx, add_zero],
               by rwa hquot.norm⟩,
end

lemma quotient_norm_le {f : normed_group_hom M N} (hquot : is_quotient f) (m : M) : ∥f m∥ ≤ ∥m∥ :=
begin
  rw hquot.norm,
  apply real.Inf_le,
  { use 0,
    rintros _ ⟨m', hm', rfl⟩,
    apply norm_nonneg },
  { exact ⟨0, f.ker.zero_mem, by simp⟩ }
end

end quotient

end normed_group_hom
