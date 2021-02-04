import algebra.homology.chain_complex

import normed_group.NormedGroup
import algebra.ordered_group
import facts

universe variables v u
noncomputable theory
open opposite category_theory
open_locale nnreal

/-!
# Systems of complexes of normed abelian groups

In this file we define systems of complexes of normed abelian groups,
along the lines of Definition 9.3 of [Analytic].

## Main declarations

* `system_of_complexes`: a system of complexes of normed abelian groups.
* `is_bdd_exact_for_bdd_degree_above_idx`: an exactness criterion for such systems,
    requiring a suitable interplay between the norms and the algebraic properties of the system.
* `admissible`: such a system is *admissible* if all maps that occur in the system
    are norm-nonincreasing.
-/

-- TODO: at some point we can abstract the following definition over `NormedGroup` and `ℝ≥0`.
-- But I don't think that is relevant for this project.

/-- A system of complexes of normed abelian groups, indexed by `ℝ≥0`.
See also Definition 9.3 of [Analytic].

Implementation detail: `cochain_complex` assumes that the complex is indexed by `ℤ`,
whereas we are interested in complexes indexed by `ℕ`.
We therefore set all objects indexed by negative integers to `0`, in our use case. -/
@[derive category_theory.category]
def system_of_complexes : Type* := ℝ≥0ᵒᵖ ⥤ (cochain_complex NormedGroup)

variables {M M' N : system_of_complexes.{u}} (f : M ⟶ M') (g : M' ⟶ N)

/-- `C.X c i` is the object $C_c^i$ in a system of complexes `C`. -/
def system_of_complexes.X (C : system_of_complexes.{u}) (c : ℝ≥0) (i : ℤ) : NormedGroup :=
(C.obj $ op c).X i

/-- `f.apply c i` is application of the natural transformation `f`: $f_c^i : M_c^i ⟶ N_c^i$. -/
def category_theory.has_hom.hom.apply (f : M ⟶ N) (c : ℝ≥0) (i : ℤ) : M.X c i ⟶ N.X c i :=
(f.app (op c)).f i

namespace system_of_complexes

variables (C C₁ C₂ : system_of_complexes.{u})

/-- `C.res` is the restriction map `C.X c' i ⟶ C.X c i` for a system of complexes `C`,
and nonnegative reals `c ≤ c'`. -/
def res {c' c : ℝ≥0} {i : ℤ} [h : fact (c ≤ c')] : C.X c' i ⟶ C.X c i :=
(C.map (hom_of_le h).op).f i

variables {c₁ c₂ c₃ : ℝ≥0} (i : ℤ)

@[simp] lemma res_comp_res (h₁ : fact (c₂ ≤ c₁)) (h₂ : fact (c₃ ≤ c₂)) :
  @res C _ _ i h₁ ≫ @res C _ _ i h₂ = @res C _ _ i (le_trans h₂ h₁) :=
begin
  have := (category_theory.functor.map_comp C (hom_of_le h₁).op (hom_of_le h₂).op),
  rw [← op_comp] at this,
  delta res,
  erw this,
  refl,
end

@[simp] lemma res_res (h₁ : fact (c₂ ≤ c₁)) (h₂ : fact (c₃ ≤ c₂)) (x : C.X c₁ i) :
  @res C _ _ i h₂ (@res C _ _ i h₁ x) = @res C _ _ i (le_trans h₂ h₁) x :=
by { rw ← (C.res_comp_res i h₁ h₂), refl }

/-- `C.d` is the differential `C.X c i ⟶ C.X c (i+1)` for a system of complexes `C`. -/
def d {c : ℝ≥0} {i : ℤ} :
  C.X c i ⟶ C.X c (i+1) :=
(C.obj $ op c).d i

lemma d_comp_res (h : fact (c₂ ≤ c₁)) :
  @d C c₁ i ≫ @res C _ _ _ h = @res C _ _ i _ ≫ @d C c₂ i :=
homological_complex.comm_at (C.map (hom_of_le h).op) i

lemma d_res (h : fact (c₂ ≤ c₁)) (x) :
  @d C c₂ i (@res C _ _ i _ x) = @res C _ _ _ h (@d C c₁ i x) :=
show (@res C _ _ i _ ≫ @d C c₂ i) x = (@d C c₁ i ≫ @res C _ _ _ h) x,
by rw d_comp_res

/-- Convenience definition:
The identity morphism of an object in the system of complexes
when it is given by different indices that are not
definitionally equal. -/
def congr {c c' : ℝ≥0} {i i' : ℤ} (hc : c = c') (hi : i = i') :
  C.X c i ⟶ C.X c' i' :=
eq_to_hom $ by { subst hc, subst hi }

variables (M M' N)

lemma d_apply (f : M ⟶ N) {c : ℝ≥0} {i : ℤ} (m : M.X c i) :
  N.d (f.apply c i m) = f.apply c (i + 1) (M.d m) :=
begin
  have h : ((M.obj (op c)).d i ≫ (f.app (op c)).f (i + 1)) m =
    (f.app (op c)).f (i + 1) ((M.obj (op c)).d i m),
  { exact coe_comp ((M.obj (op c)).d i) ((f.app (op c)).f (i + 1)) m },
  rwa [homological_complex.comm_at (f.app (op c)) i] at h,
end

lemma res_comp_apply (f : M ⟶ N) (c c' : ℝ≥0) [h : fact (c ≤ c')] (i : ℤ) :
  @system_of_complexes.res M c' c _ _ ≫ (f.apply c i) =
  f.apply c' i ≫ (@system_of_complexes.res N c' c _ _) :=
begin
  have step1 := f.naturality (hom_of_le h).op,
  have step2 := congr_arg differential_object.hom.f step1,
  exact congr_fun step2 i
end

lemma res_apply (f : M ⟶ N) (c c' : ℝ≥0) [h : fact (c ≤ c')] {i : ℤ} (m : M.X c' i) :
  @system_of_complexes.res N c' c _ _ (f.apply c' i m) =
  f.apply c i (@system_of_complexes.res M c' c _ _ m) :=
begin
  show (f.apply c' i ≫ (@system_of_complexes.res N c' c _ _)) m =
    (@system_of_complexes.res M c' c _ _ ≫ (f.apply c i)) m,
  rw res_comp_apply
end

/-- A system of complexes is *admissible*
if all the differentials and restriction maps are norm-nonincreasing.

See Definition 9.3 of [Analytic]. -/
structure admissible (C : system_of_complexes) : Prop :=
(d_norm_noninc : ∀ c i (x : C.X c i), ∥C.d x∥ ≤ ∥x∥)
(res_norm_noninc : ∀ c' c i h (x : C.X c' i), ∥@res C c' c i h x∥ ≤ ∥x∥)

/-
Peter Scholze:
(Note that `k` plays a strange double role in Definition 9.3,
quantifying both the depth of restriction and the increase in norm;
somehow it was not necessary to disentangle this for the argument,
so I used one variable for two distinct things.
Only one of them really needs to be `≥1`,
the one parametrizing the depth of restriction.
If one wants to get good estimates at some point,
it may be useful to introduce two parameters here.)

https://leanprover.zulipchat.com/#narrow/stream/266894-liquid/topic/bounded.20exactness/near/220823654
-/

/-- `is_bdd_exact_for_bdd_degree_above_idx k m c₀` is a predicate on systems of complexes.

A system of complexes `C` is *`≤ k`-exact in degrees `≤ m` for `c ≥ c₀`*
if the following condition is satisfied:
For all `c ≥ c₀` and all `x : C.X (k * c) i` with `i ≤ m` there is some `y : C.X c (i-1)`
(which is defined to be `0` when `i = 0`) such that `∥(C.res x) - (C.d y)∥ ≤ k * ∥C.d x∥`.

See Definition 9.3 of [Analytic].

Implementation details:
* Because our chain complexes are indexed by `ℤ` instead of `ℕ`,
  and we make sure that objects indexed by negative integers are `0`,
  we automatically take care of the parenthetical condition about `i = 0`.
* The original text bounds `i` as `i ≤ m`, and then requires `y : C.X c (i-1)`.
  We change this to `i < m` and `y : C.X c i`, because this has better definitional properties.
  (This is a hack around an inconvenience known as dependent type theory hell.) -/
def is_bdd_exact_for_bdd_degree_above_idx
  (k : ℝ≥0) (m : ℤ) [hk : fact (1 ≤ k)] (c₀ : ℝ≥0) : Prop :=
∀ c ≥ c₀, ∀ i < m,
∀ x : C.X (k * c) (i+1),
∃ y : C.X c i, ∥(C.res x) - (C.d y)∥ ≤ k * ∥C.d x∥

/-- Weak version of `is_bdd_exact_for_bdd_degree_above_idx`. -/
--TODO: equivalence for complete spaces
def is_weak_bdd_exact_for_bdd_degree_above_idx
  (k : ℝ≥0) (m : ℤ) [hk : fact (1 ≤ k)] (c₀ : ℝ≥0) : Prop :=
∀ c ≥ c₀, ∀ i < m,
∀ x : C.X (k * c) (i+1),
∀ (ε : ℝ) (hε : 0 < ε), ∃ y : C.X c i, ∥(C.res x) - (C.d y)∥ ≤ k * ∥C.d x∥ + ε

namespace is_bdd_exact_for_bdd_degree_above_idx

variables {C C₁ C₂}
variables {k k' : ℝ≥0} {m m' : ℤ} {c₀ c₀' : ℝ≥0} [fact (1 ≤ k)] [fact (1 ≤ k')]

lemma of_le (hC : C.is_bdd_exact_for_bdd_degree_above_idx k m c₀)
  (hC_adm : C.admissible) (hk : k ≤ k') (hm : m' ≤ m) (hc₀ : c₀ ≤ c₀') :
  C.is_bdd_exact_for_bdd_degree_above_idx k' m' c₀' :=
begin
  intros c hc i hi x,
  haveI : fact (k ≤ k') := hk,
  obtain ⟨y, hy⟩ := hC c (hc₀.trans hc) i (lt_of_lt_of_le hi hm) (C.res x),
  use y,
  simp only [res_res] at hy,
  refine le_trans hy (mul_le_mul _ _ (norm_nonneg _) (nnreal.coe_nonneg _)),
  { simpa only },
  { rw d_res, apply le_trans (hC_adm.res_norm_noninc _ _ _ _ _) _,
    simp only [one_mul, nnreal.coe_one] }
end

lemma of_iso (h : C₁.is_bdd_exact_for_bdd_degree_above_idx k m c₀) (f : C₁ ≅ C₂) :
  C₂.is_bdd_exact_for_bdd_degree_above_idx k m c₀ :=
begin
  intros c hc i hi x,
  specialize h c hc i hi,
  sorry
end

end is_bdd_exact_for_bdd_degree_above_idx

section quotient

open normed_group_hom

variables {M M'}

/-- The quotient of a system of complexes. -/
def is_quotient (f : M ⟶ M') : Prop :=
∀ c i, normed_group_hom.is_quotient (f.apply c i)

/-- The quotient of an admissible system of complexes is admissible. -/
lemma admissible_of_quotient {f : M ⟶ M'} (hquot : is_quotient f) (hadm : M.admissible) :
  M'.admissible :=
begin
  split,
  { intros c i m',
    refine le_of_forall_pos_le_add _,
    intros ε hε,
    obtain ⟨m, hm⟩ := quotient_norm_lift (hquot _ _) hε m',
    rw [← hm.1, d_apply],
    calc ∥(f.apply _ _) (M.d m)∥ ≤ ∥M.d m∥ : quotient_norm_le (hquot _ _) _
      ... ≤ ∥m∥ : hadm.d_norm_noninc _ _ m
      ... ≤ ∥m'∥ + ε : le_of_lt hm.2
      ... = ∥(f.apply _ _) m∥ + ε : by rw [hm.1] },
  { intros c' c i hc m',
    letI h := hc,
    refine le_of_forall_pos_le_add _,
    intros ε hε,
    obtain ⟨m, hm⟩ := quotient_norm_lift (hquot _ _) hε m',
    rw [← hm.1, res_apply],
    calc ∥(f.apply _ _) (M.res m)∥ ≤ ∥(M.res) m∥ : quotient_norm_le (hquot _ _) _
      ... ≤ ∥m∥ : hadm.res_norm_noninc c' c _ hc m
      ... ≤ ∥m'∥ + ε : le_of_lt hm.2
      ... = ∥(f.apply _ _) m∥ + ε : by rw [hm.1] }
end

end quotient

end system_of_complexes

-- #lint- only unused_arguments def_lemma doc_blame
