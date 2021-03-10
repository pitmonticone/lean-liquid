import pseudo_normed_group.profinitely_filtered

open pseudo_normed_group profinitely_filtered_pseudo_normed_group
open_locale nnreal big_operators

local attribute [instance] type_pow

/-- A *profinitely filtered pseudo normed topological group with action by `T⁻¹`* is
a profinitely filtered pseudo normed topological group `M` together with a
nonnegative real `r` and homomorphism `Tinv : M → M` such that
`Tinv x ∈ filtration M (r⁻¹ * c)` for all `x ∈ filtration M c`.

Morphisms are continuous and strict homomorphisms. -/
class profinitely_filtered_pseudo_normed_group_with_Tinv (r : out_param $ ℝ≥0) (M : Type*)
  extends profinitely_filtered_pseudo_normed_group M :=
(Tinv : profinitely_filtered_pseudo_normed_group_hom M M)
(Tinv_mem_filtration : ∀ c x, x ∈ filtration c → Tinv x ∈ filtration (r⁻¹ * c))

namespace profinitely_filtered_pseudo_normed_group_with_Tinv

variables {r : ℝ≥0} {M M₁ M₂ M₃ : Type*}
variables [profinitely_filtered_pseudo_normed_group_with_Tinv r M]
variables [profinitely_filtered_pseudo_normed_group_with_Tinv r M₁]
variables [profinitely_filtered_pseudo_normed_group_with_Tinv r M₂]
variables [profinitely_filtered_pseudo_normed_group_with_Tinv r M₃]

@[simps]
def Tinv₀ (c : ℝ≥0) (x : filtration M c) : filtration M (r⁻¹ * c) :=
⟨Tinv (x : M), Tinv_mem_filtration _ _ x.2⟩

lemma Tinv₀_continuous (c : ℝ≥0) : continuous (@Tinv₀ r M _ c) :=
Tinv.continuous _ $ λ x, rfl
end profinitely_filtered_pseudo_normed_group_with_Tinv

section
set_option old_structure_cmd true

open profinitely_filtered_pseudo_normed_group_with_Tinv

structure profinitely_filtered_pseudo_normed_group_with_Tinv_hom (r : ℝ≥0) (M₁ M₂ : Type*)
  [profinitely_filtered_pseudo_normed_group_with_Tinv r M₁]
  [profinitely_filtered_pseudo_normed_group_with_Tinv r M₂]
  extends M₁ →+ M₂ :=
(strict' : ∀ ⦃c x⦄, x ∈ filtration M₁ c → to_fun x ∈ filtration M₂ c)
(continuous' : ∀ c, @continuous (filtration M₁ c) (filtration M₂ c) _ _ $
  λ x, ⟨to_fun x, strict' x.2⟩)
(map_Tinv' : ∀ x, to_fun (Tinv x) = Tinv (to_fun x))

end

attribute [nolint doc_blame] profinitely_filtered_pseudo_normed_group_with_Tinv_hom.mk
  profinitely_filtered_pseudo_normed_group_with_Tinv_hom.to_add_monoid_hom

namespace profinitely_filtered_pseudo_normed_group_with_Tinv_hom

open profinitely_filtered_pseudo_normed_group_with_Tinv

variables {r : ℝ≥0} {M M₁ M₂ M₃ : Type*}
variables [profinitely_filtered_pseudo_normed_group_with_Tinv r M]
variables [profinitely_filtered_pseudo_normed_group_with_Tinv r M₁]
variables [profinitely_filtered_pseudo_normed_group_with_Tinv r M₂]
variables [profinitely_filtered_pseudo_normed_group_with_Tinv r M₃]
variables (f g : profinitely_filtered_pseudo_normed_group_with_Tinv_hom r M₁ M₂)

instance : has_coe_to_fun (profinitely_filtered_pseudo_normed_group_with_Tinv_hom r M₁ M₂) :=
⟨_, profinitely_filtered_pseudo_normed_group_with_Tinv_hom.to_fun⟩

@[simp] lemma coe_mk (f) (h₁) (h₂) (h₃) (h₄) (h₅) :
  ⇑(⟨f, h₁, h₂, h₃, h₄, h₅⟩ : profinitely_filtered_pseudo_normed_group_with_Tinv_hom r M₁ M₂) = f :=
rfl

@[simp] lemma mk_to_monoid_hom (f) (h₁) (h₂) (h₃) (h₄) (h₅) :
  (⟨f, h₁, h₂, h₃, h₄, h₅⟩ :
    profinitely_filtered_pseudo_normed_group_with_Tinv_hom r M₁ M₂).to_add_monoid_hom =
    ⟨f, h₁, h₂⟩ := rfl

@[simp] lemma map_zero : f 0 = 0 := f.to_add_monoid_hom.map_zero

@[simp] lemma map_add (x y) : f (x + y) = f x + f y := f.to_add_monoid_hom.map_add _ _

@[simp] lemma map_sum {ι : Type*} (x : ι → M₁) (s : finset ι) :
  f (∑ i in s, x i) = ∑ i in s, f (x i) :=
f.to_add_monoid_hom.map_sum _ _

@[simp] lemma map_sub (x y) : f (x - y) = f x - f y := f.to_add_monoid_hom.map_sub _ _

@[simp] lemma map_neg (x) : f (-x) = -(f x) := f.to_add_monoid_hom.map_neg _

lemma strict : ∀ ⦃c x⦄, x ∈ filtration M₁ c → f x ∈ filtration M₂ c := f.strict'

/-- `f.level c` is the function `filtration M₁ c → filtration M₂ c`
induced by a `profinitely_filtered_pseudo_normed_group_with_Tinv_hom M₁ M₂`. -/
@[simps] def level (c : ℝ≥0) (x : filtration M₁ c) : filtration M₂ c := ⟨f x, f.strict x.2⟩

lemma level_continuous (c : ℝ≥0) : continuous (f.level c) := f.continuous' c

lemma map_Tinv (x : M₁) : f (Tinv x) = Tinv (f x) := f.map_Tinv' x

variables {f g}

@[ext] theorem ext (H : ∀ x, f x = g x) : f = g :=
by cases f; cases g; congr'; exact funext H

instance : has_zero (profinitely_filtered_pseudo_normed_group_with_Tinv_hom r M₁ M₂) :=
⟨{ strict' := λ c x h, zero_mem_filtration _,
   continuous' := λ c, @continuous_const _ (filtration M₂ c) _ _ 0,
   map_Tinv' := λ x, show 0 = Tinv (0 : M₂), from Tinv.map_zero.symm,
   .. (0 : M₁ →+ M₂) }⟩

instance : inhabited (profinitely_filtered_pseudo_normed_group_with_Tinv_hom r M₁ M₂) := ⟨0⟩

lemma coe_inj ⦃f g : profinitely_filtered_pseudo_normed_group_with_Tinv_hom r M₁ M₂⦄
  (h : (f : M₁ → M₂) = g) :
  f = g :=
by cases f; cases g; cases h; refl

/-- The identity function as `profinitely_filtered_pseudo_normed_group_with_Tinv_hom`. -/
@[simps] def id : profinitely_filtered_pseudo_normed_group_with_Tinv_hom r M M :=
{ strict' := λ c x, id,
  continuous' := λ c, by { convert continuous_id, ext, refl },
  map_Tinv' := λ x, rfl,
  .. add_monoid_hom.id _ }

/-- The composition of `profinitely_filtered_pseudo_normed_group_with_Tinv_hom`s. -/
@[simps] def comp
  (g : profinitely_filtered_pseudo_normed_group_with_Tinv_hom r M₂ M₃)
  (f : profinitely_filtered_pseudo_normed_group_with_Tinv_hom r M₁ M₂) :
  profinitely_filtered_pseudo_normed_group_with_Tinv_hom r M₁ M₃ :=
{ strict' := λ c x hx, g.strict (f.strict hx),
  continuous' := λ c, (g.level_continuous c).comp (f.level_continuous c),
  map_Tinv' := λ x,
  calc g (f (Tinv x)) = g (Tinv (f x)) : by rw f.map_Tinv
                  ... = Tinv (g (f x)) : by rw g.map_Tinv,
  .. (g.to_add_monoid_hom.comp f.to_add_monoid_hom) }

/-- The `profinitely_filtered_pseudo_normed_group_hom` underlying a
`profinitely_filtered_pseudo_normed_group_with_Tinv_hom`. -/
def to_profinitely_filtered_pseudo_normed_group_hom :
  profinitely_filtered_pseudo_normed_group_hom M₁ M₂ :=
profinitely_filtered_pseudo_normed_group_hom.mk' f.to_add_monoid_hom
begin
  refine ⟨1, λ c, ⟨_, _⟩⟩,
  { rw one_mul, intros x h, exact f.strict h },
  haveI : fact (1 * c ≤ c) := by { apply le_of_eq, rw one_mul },
  rw (embedding_cast_le (1 * c) c).continuous_iff,
  exact f.level_continuous c
end

/-- If the inverse of `profinitely_filtered_pseudo_normed_group_with_Tinv_hom` is strict, then it
is a `profinitely_filtered_pseudo_normed_group_with_Tinv_hom`. -/
def inv_of_equiv_of_strict (e : M₁ ≃+ M₂) (he : ∀ x, f x = e x)
  (strict : ∀ ⦃c x⦄, x ∈ filtration M₂ c → e.symm x ∈ filtration M₁ c) :
  profinitely_filtered_pseudo_normed_group_with_Tinv_hom r M₂ M₁ :=
{ strict' := strict,
  continuous' := λ c,
  begin
    simp only [add_equiv.coe_to_add_monoid_hom, add_monoid_hom.to_fun_eq_coe],
    have hcont := f.continuous' c,
    set g : (filtration M₂ c) → (filtration M₁ c) :=
      λ x, ⟨e.symm x, strict x.2⟩ with hg,
    set f₁ : (filtration M₁ c) → (filtration M₂ c) := λ x, ⟨f x, f.strict x.2⟩ with hf₁,
    change continuous g,
    have hleft : function.left_inverse g f₁ := λ x, by { rw [hg, hf₁], simp [he], },
    have hright : function.right_inverse g f₁,
    { intro x; rw [hg, hf₁]; simp [e.apply_symm_apply, he] },
    have hinj : function.injective f₁ := function.has_left_inverse.injective ⟨g, hleft⟩,
    rw continuous_iff_is_closed,
    intros U hU,
    rw [← set.image_eq_preimage_of_inverse hleft hright],
    exact closed_embedding.is_closed_map (continuous.closed_embedding hcont hinj) U hU,
  end,
  map_Tinv' := λ x,
  begin
    simp only [add_equiv.coe_to_add_monoid_hom, add_monoid_hom.to_fun_eq_coe],
    apply e.injective,
    rw [e.apply_symm_apply, ← he, map_Tinv, he, e.apply_symm_apply],
  end,
  .. e.symm.to_add_monoid_hom }

@[simp]
lemma inv_of_equiv_of_strict.apply (x : M₁) (e : M₁ ≃+ M₂) (he : ∀ x, f x = e x)
  (strict : ∀ ⦃c x⦄, x ∈ filtration M₂ c → e.symm x ∈ filtration M₁ c) :
  (inv_of_equiv_of_strict e he strict) (f x) = x := by simp [inv_of_equiv_of_strict, he]

@[simp]
lemma inv_of_equiv_of_strict_symm.apply (x : M₂) (e : M₁ ≃+ M₂) (he : ∀ x, f x = e x)
  (strict : ∀ ⦃c x⦄, x ∈ filtration M₂ c → e.symm x ∈ filtration M₁ c) :
  f (inv_of_equiv_of_strict e he strict x) = x := by simp [inv_of_equiv_of_strict, he]

end profinitely_filtered_pseudo_normed_group_with_Tinv_hom

namespace punit

instance profinitely_filtered_pseudo_normed_group_with_Tinv (r : ℝ≥0) :
  profinitely_filtered_pseudo_normed_group_with_Tinv r punit :=
{ Tinv := profinitely_filtered_pseudo_normed_group_hom.id,
  Tinv_mem_filtration := λ c x h, set.mem_univ _,
  .. punit.profinitely_filtered_pseudo_normed_group }

end punit
