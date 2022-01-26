import Mbar.functor
import combinatorial_lemma.finite

import category_theory.limits.preserves.finite

noncomputable theory

open_locale nnreal big_operators

universe u

section
variables (r : ℝ≥0) [fact (0 < r)] (Λ : Type u) [polyhedral_lattice Λ]

def foo (M : Type*) [profinitely_filtered_pseudo_normed_group_with_Tinv r M] :
  profinitely_filtered_pseudo_normed_group_with_Tinv r (Λ →+ M) :=
  by apply_instance

#check polyhedral_lattice.add_monoid_hom.profinitely_filtered_pseudo_normed_group_with_Tinv
#print foo

lemma polyhedral_exhaustive
  (M : ProFiltPseuNormGrpWithTinv₁ r) (x : Λ →+ M) :
  ∃ c : ℝ≥0, x ∈ pseudo_normed_group.filtration (Λ →+ M) c :=
begin
  obtain ⟨ι,hι,l,hl,h⟩ := polyhedral_lattice.polyhedral Λ,
  resetI,
  let cs : ι → ℝ≥0 := λ i, (M.exhaustive r (x (l i))).some,
  -- This should be easy, using the fact that (l i) ≠ 0.
  have : ∃ c : ℝ≥0, ∀ i, cs i ≤ c * ∥l i∥₊, sorry,
  obtain ⟨c,hc⟩ := this,
  use c,
  rw generates_norm.add_monoid_hom_mem_filtration_iff hl x,
  intros i,
  apply pseudo_normed_group.filtration_mono (hc i),
  apply (M.exhaustive r (x (l i))).some_spec,
end

def polyhedral_postcompose {M N : ProFiltPseuNormGrpWithTinv₁ r} (f : M ⟶ N) :
  profinitely_filtered_pseudo_normed_group_with_Tinv_hom r
  (Λ →+ M) (Λ →+ N) :=
{ to_fun := λ x, f.to_add_monoid_hom.comp x,
  map_zero' := by simp,
  map_add' := by { intros, ext, dsimp, erw [f.to_add_monoid_hom.map_add], refl, },
  strict' := begin
      obtain ⟨ι,hι,l,hl,h⟩ := polyhedral_lattice.polyhedral Λ,
      resetI,
      intros c x hx,
      erw generates_norm.add_monoid_hom_mem_filtration_iff hl at hx ⊢,
      intros i,
      apply f.strict,
      exact hx i,
    end,
  continuous' := sorry,
  map_Tinv' := sorry }

/-- the functor `M ↦ Hom(Λ, M), where both are considered as objects in
  `ProFiltPseuNormGrpWithTinv₁.{u} r` -/
def hom_functor : ProFiltPseuNormGrpWithTinv₁.{u} r ⥤ ProFiltPseuNormGrpWithTinv₁.{u} r :=
{ obj := λ M,
  { M := Λ →+ M,
    str := infer_instance,
    exhaustive' := by { apply polyhedral_exhaustive } },
  map := λ M N f, polyhedral_postcompose _ _ f,
  map_id' := λ M, begin
    ext,
    dsimp [polyhedral_postcompose],
    simp,
  end,
  map_comp' := λ M N L f g, begin
    ext,
    dsimp [polyhedral_postcompose],
    simp,
  end }

open category_theory.limits

/-

Hom(Λ, lim_i A_i)_{≤ c} should be "the same" as
lim_i Hom(Λ, A_i)_{≤ c}

I'm fairly sure this is correct, but this will be a bit of a challenge to prove...

-/

instance (c) : preserves_limits (
  hom_functor r Λ ⋙
  ProFiltPseuNormGrpWithTinv₁.to_PFPNG₁ r ⋙
  ProFiltPseuNormGrp₁.level.obj c ) := sorry

end

/-- Lemma 9.8 of [Analytic] -/
lemma lem98 (r' : ℝ≥0) [fact (0 < r')] [fact (r' < 1)]
  (Λ : Type*) [polyhedral_lattice Λ] (S : Profinite) (N : ℕ) [hN : fact (0 < N)] :
  pseudo_normed_group.splittable (Λ →+ (Mbar.functor r').obj S) N (lem98.d Λ N) :=
begin
  -- This reduces to `lem98_finite`: See the first lines of the proof in [Analytic].
  sorry
end
