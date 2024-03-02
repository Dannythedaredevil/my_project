/-
Daniel Kazem Lou
s43dkaze
-/
import Mathlib.Tactic
import Mathlib.Algebra.Parity
import Mathlib.Data.Int.Dvd.Basic
import Mathlib.Data.Int.Units
import Mathlib.Data.Nat.Factorial.Basic
import Mathlib.Data.Nat.GCD.Basic
import Mathlib.Data.Nat.Sqrt
import Mathlib.Algebra.Associated
import Mathlib.Algebra.CharP.Basic
import Mathlib.NumberTheory.Padics.PadicNumbers
import Mathlib.Order.Bounds.Basic
import Mathlib.NumberTheory.Divisors
import Mathlib.RingTheory.Int.Basic
import Mathlib.Data.Nat.Digits
import Mathlib.Data.Nat.MaxPowDiv
import Mathlib.Data.Nat.Prime


/-
The nth Harmonic number is not an integer. This proof is due to Kürschák.
-/
open BigOperators

def harmonic : ℕ → ℚ := fun n => ∑ i in Finset.range n, (↑(i + 1))⁻¹

@[simp]
lemma harmonic_zero : harmonic 0 = 0 :=
  rfl

@[simp]
lemma harmonic_succ (n : ℕ) : harmonic (n + 1) = harmonic n + (↑(n + 1))⁻¹ := by
  apply Finset.sum_range_succ

lemma harmonic_pos {n : ℕ} (Hn : n ≠ 0) : 0 < harmonic n :=
  Finset.sum_pos (fun _ _ => inv_pos.mpr (by norm_cast; linarith))
  (by rwa [Finset.nonempty_range_iff])

theorem padicValRat_two_harmonic (n : ℕ) : padicValRat 2 (harmonic n) = -Nat.log 2 n := by
  induction' n with n ih
  · simp
  · rcases eq_or_ne n 0 with rfl | hn
    · simp
    rw [harmonic_succ]
    have key : padicValRat 2 (harmonic n) ≠ padicValRat 2 (↑(n + 1))⁻¹
    · rw [ih, padicValRat.inv, padicValRat.of_nat, Ne, neg_inj, Nat.cast_inj]
      exact Nat.log_ne_padicValNat_succ hn
    rw [padicValRat.add_eq_min (harmonic_succ n ▸ (harmonic_pos n.succ_ne_zero).ne')
        (harmonic_pos hn).ne' (inv_ne_zero (Nat.cast_ne_zero.mpr n.succ_ne_zero)) key, ih,
        padicValRat.inv, padicValRat.of_nat, min_neg_neg, neg_inj, ← Nat.cast_max, Nat.cast_inj]
    exact Nat.max_log_padicValNat_succ_eq_log_succ n

lemma padicNorm_two_harmonic {n : ℕ} (hn : n ≠ 0) :
    ‖(harmonic n : ℚ_[2])‖ = 2 ^ (Nat.log 2 n) := by
  rw [padicNormE.eq_padicNorm, padicNorm.eq_zpow_of_nonzero (harmonic_pos hn).ne',
    padicValRat_two_harmonic, neg_neg, zpow_coe_nat, Rat.cast_pow, Rat.cast_coe_nat, Nat.cast_ofNat]

/-- The n-th harmonic number is not an integer for n ≥ 2. -/
theorem harmonic_not_int {n : ℕ} (h : 2 ≤ n) : ¬ (harmonic n).isInt := by
  apply padicNorm.not_int_of_not_padic_int 2
  rw [padicNorm.eq_zpow_of_nonzero (harmonic_pos (ne_zero_of_lt h)).ne',
      padicValRat_two_harmonic, neg_neg, zpow_coe_nat]
  exact one_lt_pow one_lt_two (Nat.log_pos one_lt_two h).ne'
