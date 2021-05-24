import polyhedral_lattice.Hom
import Mbar.pseudo_normed_group

import normed_spectral

import pseudo_normed_group.homotopy

import thm95.constants
import thm95.double_complex
import thm95.row_iso

noncomputable theory

universe variable u

open_locale nnreal -- enable the notation `ℝ≥0` for the nonnegative real numbers.

open polyhedral_lattice opposite
open thm95.universal_constants system_of_double_complexes category_theory breen_deligne
open ProFiltPseuNormGrpWithTinv (of)

section

variables (BD : package)
variables (r r' : ℝ≥0) [fact (0 < r)] [fact (0 < r')] [fact (r < r')] [fact (r' ≤ 1)]
variables (V : SemiNormedGroup.{u}) [normed_with_aut r V]
variables (c_ c' : ℕ → ℝ≥0) [BD.data.very_suitable r r' c_] [package.adept BD c_ c']
variables (M : ProFiltPseuNormGrpWithTinv.{u} r')
variables (m : ℕ)
variables (Λ : PolyhedralLattice.{u})

def NSH_aux_type (N : ℕ) (M : (ProFiltPseuNormGrpWithTinv r')ᵒᵖ) :=
normed_spectral_homotopy
  ((BD_system_map (BD.data.sum (2^N)) c_ (rescale_constants c_ (2^N)) r V).app M)
  m (k' c' m) (ε m) (c₀ Λ c' r r' m) (H BD c' r r' m)

section

variables {BD r r' V c_ c' m}

lemma NSH_h_aux {c x : ℝ≥0} {q' : ℕ} (hqm : q' ≤ m+1) :
  c * (c' q' * x) ≤ k' c' m * c * x :=
calc c * (c' q' * x)
    = c' q' * (c * x) : mul_left_comm _ _ _
... ≤ k' c' m * (c * x) : mul_le_mul' (c'_le_k' _ _ hqm) le_rfl
... = k' c' m * c * x : (mul_assoc _ _ _).symm

def NSH_h {M : (ProFiltPseuNormGrpWithTinv r')ᵒᵖ} (q q' : ℕ) (c : ℝ≥0) :
  ((BD.data.system c_ r V r').obj M) (k' c' m * c) q' ⟶
    ((((data.mul (2 ^ N₂ c' r r' m)).obj BD.data).system
      (rescale_constants c_ (2 ^ N₂ c' r r' m)) r V r').obj M) c q :=
if hqm : q' ≤ m + 1
then
begin
  refine (universal_map.eval_CLCFPTinv _ _ _ _ _ _).app _,
  { exact (data.homotopy_mul BD.data BD.homotopy (N₂ c' r r' m)).hom q q' },
  { dsimp,
    exact universal_map.suitable.le _ _ (c * (c' q' * c_ q')) _
      infer_instance le_rfl (NSH_h_aux hqm), }
end
else 0

lemma NSH_h_bound_by {M : (ProFiltPseuNormGrpWithTinv r')ᵒᵖ}
  (q : ℕ) (hqm : q ≤ m) (c : ℝ≥0) [fact (c₀ Λ c' r r' m ≤ c)] :
  normed_group_hom.bound_by
    (@NSH_h BD r r' _ _ _ _ V _ c_ c' _ _ m M q (q+1) c)
    (H BD c' r r' m) :=
begin
  rw [NSH_h, dif_pos (nat.succ_le_succ hqm)],
  apply universal_map.eval_CLCFPTinv₂_bound_by,
  exact (bound_by_H BD c' r r' _ hqm),
end

instance NSH_δ_res' (N i : ℕ) (c : ℝ≥0) [hN : fact (k' c' m ≤ 2 ^ N)] :
  fact (k' c' m * c * rescale_constants c_ (2 ^ N) i ≤ c * c_ i) :=
begin
  refine ⟨_⟩,
  calc k' c' m * c * (c_ i * (2 ^ N)⁻¹)
     = (k' c' m * (2 ^ N)⁻¹) * (c * c_ i) : by ring1
  ... ≤ 1 * (c * c_ i) : mul_le_mul' _ le_rfl
  ... = c * c_ i : one_mul _,
  apply mul_inv_le_of_le_mul (pow_ne_zero _ $ @two_ne_zero ℝ≥0 _ _),
  rw one_mul,
  exact hN.1
end

variables (c')

@[simps f]
def NSH_δ_res {BD : data} [BD.suitable c_]
  (N : ℕ) [fact (k' c' m ≤ 2 ^ N)] (c : ℝ≥0) {M : (ProFiltPseuNormGrpWithTinv r')ᵒᵖ} :
  ((BD.system c_ r V r').obj M).obj (op c) ⟶
    ((BD.system (rescale_constants c_ (2 ^ N)) r V r').obj M).obj (op (k' c' m * c)) :=
{ f := λ i, (@CLCFPTinv.res r V _ _ r' _ _ _ _ _ (NSH_δ_res' _ _ _)).app M,
  comm' :=
  begin
    intros i j hij,
    dsimp [data.system_obj, data.complex],
    exact nat_trans.congr_app (universal_map.res_comp_eval_CLCFPTinv r V r' _ _ _ _ _) M,
  end }
.

variables {c'}

def NSH_δ {M : (ProFiltPseuNormGrpWithTinv r')ᵒᵖ} (c : ℝ≥0) :
  ((BD.data.system c_ r V r').obj M).obj (op c) ⟶
    ((((data.mul (2 ^ N₂ c' r r' m)).obj BD.data).system
      (rescale_constants c_ (2 ^ N₂ c' r r' m)) r V r').obj M).obj (op (k' c' m * c)) :=
NSH_δ_res c' (N₂ c' r r' m) _ ≫ (BD_map (BD.data.proj (2 ^ N₂ c' r r' m)) _ _ r V _).app M

lemma NSH_δ_bound_by {M : (ProFiltPseuNormGrpWithTinv r')ᵒᵖ} (c : ℝ≥0) (q : ℕ) :
  normed_group_hom.bound_by ((@NSH_δ BD r r' _ _ _ _ V _ c_ c' _ _ m M c).f q) (ε m) :=
begin
  refine (normed_group_hom.bound_by.comp'
    (r ^ (b c' r r' m)) (N c' r r' m) _ (mul_comm _ _) _ _).le _,
  { apply universal_map.eval_CLCFPTinv₂_bound_by,
    apply universal_map.proj_bound_by },
  { refine @CLCFPTinv.res_bound_by_pow r V _ _ r' _ _ _ _ _ _ _ ⟨_⟩ _,
    dsimp only [unop_op, rescale_constants],
    simp only [← mul_assoc, mul_right_comm _ c],
    simp only [mul_right_comm _ (c_ q)],
    refine mul_le_mul' _ le_rfl,
    refine mul_le_mul' _ le_rfl,
    apply N₂_spec },
  { apply r_pow_b_le_ε }
end

variables (V c' m)

open homological_complex category_theory.preadditive

end

def NSH_aux' (M) (hδ) : NSH_aux_type BD r r' V c_ c' m Λ (N₂ c' r r' m) M :=
{ h := λ q q' c, NSH_h q q' c,
  h_bound_by := by { rintro q q' hqm rfl, apply NSH_h_bound_by Λ q hqm },
  δ := NSH_δ,
  hδ := hδ,
  δ_bound_by := λ c hc q hqm, by apply NSH_δ_bound_by }
.

def NSH_aux (M) : NSH_aux_type BD r r' V c_ c' m Λ (N₂ c' r r' m) M :=
NSH_aux' BD r r' V c_ c' m Λ M
begin
  introsI c hc q hqm,
  haveI hqm_ : fact (q ≤ m) := ⟨hqm⟩,
  rw [NSH_δ, NSH_h, NSH_h, dif_pos (nat.succ_le_succ hqm), dif_pos (hqm.trans (nat.le_succ _))],
  erw [homological_complex.comp_f],
  dsimp only [unop_op, NSH_δ_res_f, data.system_res_def, quiver.hom.apply,
    BD_system_map_app_app, BD_map_app_f, data.system_obj_d],
  simp only [← universal_map.eval_CLCFPTinv_def],
  have hcomm := (data.homotopy_mul BD.data BD.homotopy (N₂ c' r r' m)).comm q,
  simp only [universal_map.res_comp_eval_CLCFPTinv_absorb, hcomm, ← nat_trans.app_add, add_assoc,
    ← nat_trans.comp_app, ← category.assoc, ← universal_map.eval_CLCFPTinv_comp,
    universal_map.eval_CLCFPTinv_comp_res_absorb, ← universal_map.eval_CLCFPTinv_add],
  congr' 2,
  rw [← add_assoc, add_comm, @prev_d_eq _ _ _ _ _ _ _ _ q (q+1)],
  swap, { dsimp, refl },
  congr' 1,
  rw add_comm,
  congr' 1,
  rw d_next_nat,
end
.

def NSC_htpy :
  normed_spectral_homotopy
    ((thm95.double_complex BD.data c_ r r' V Λ M (N c' r r' m)).row_map 0 1)
      m (k' c' m) (ε m) (c₀ Λ c' r r' m) (H BD c' r r' m) :=
(NSH_aux BD r r' V c_ c' m Λ (op (Hom Λ M))).of_iso _ _ _
  (iso.refl _) (thm95.mul_rescale_iso_row_one BD.data c_ r V _ _ (by norm_cast) Λ M)
  (λ _ _ _, rfl) (thm95.mul_rescale_iso_row_one_strict BD.data c_ r V _ _ (by norm_cast) Λ M)
  (by apply thm95.row_map_eq_sum_comp)

end
