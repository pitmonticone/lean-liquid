import banach
import real_measures
import condensed.ab
import category_theory.abelian.ext
import for_mathlib.Profinite.extend
import for_mathlib.abelian_category

/-!
# Liquid Tensor Experiment

## The main challenge

The main challenge of the liquid tensor experiment is
a formalisation of the first theorem in Peter Scholze's blogpost
https://xenaproject.wordpress.com/2020/12/05/liquid-tensor-experiment/

Theorem 1.1 (Clausen--Scholze)
Let `0 < p' < p ≤ 1` be real numbers, let `S` be a profinite set, and let `V` be a `p`-Banach space.
Let `ℳ p' S` be the space of `p'`-measures on `S`. Then
$$ Ext^i (ℳ p' S, V) = 0 $$
for `i ≥ 1`.

-/

noncomputable theory

open_locale nnreal
open opposite category_theory

namespace liquid_tensor_experiment

variables (p' p : ℝ≥0) [fact (0 < p')] [fact (p' ≤ 1)] [fact (p' < p)] [fact (p ≤ 1)]

def real_measures.condensed : Profinite ⥤ Condensed Ab :=
Profinite.extend (real_measures.functor p') ⋙ CompHausFiltPseuNormGrp₁.to_Condensed

local notation `ℳ_{` p' `}` S := (real_measures.condensed p').obj S

abbreviation Ext (i : ℕ) (A B : Condensed Ab) :=
((Ext ℤ (Condensed Ab) i).obj (op A)).obj B

instance : has_coe (pBanach p) (Condensed Ab) :=
{ coe := λ V, Condensed.of_top_ab V }

variables (S : Profinite.{1})
variables (V : pBanach p)

theorem main_challenge (i : ℕ) (hi : 0 < i) :
  Ext i (ℳ_{p'} S) V ≅ 0 :=
sorry

end liquid_tensor_experiment
