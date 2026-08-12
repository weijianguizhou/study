"""
Direction Cosine Matrix (Rotation Matrix) Calculator
====================================================
Based on the Rodrigues' rotation formula introduced in ch01 Sec.1
"Simple Rotation":

    b = a*cos(theta) - (a x lambda)*sin(theta) + lambda*(lambda.a)*(1 - cos(theta))

Rewriting the above as b = A * a gives the matrix form

    A = I*cos(theta) + (1 - cos(theta)) * (lambda)(lambda)^T
        + sin(theta) * [lambda]_x

where [lambda]_x is the skew-symmetric cross-product matrix of the
unit axis vector lambda. This program implements a mechanical
calculation of the direction cosine matrix from an axis vector and
an angle, with self-checks for orthogonality, determinant, and axis
fixity.

Usage
-----
    from 方向余弦矩阵 import rotation_matrix
    A = rotation_matrix([0, 0, 1], 90)   # 90 deg about z
    b = A @ a                            # rotate vector a
"""

import numpy as np
import sys

# Force UTF-8 output to avoid GBK encoding errors on Windows cmd
try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass


def normalize_axis(axis):
    """
    Step 1: Normalize the rotation axis to a unit vector.

    Parameters
    ----------
    axis : array_like, shape (3,)
        Any non-zero 3D vector.

    Returns
    -------
    u : numpy.ndarray, shape (3,)
        Unit vector in the same direction as `axis`, with ||u|| = 1.

    Raises
    ------
    ValueError
        If `axis` is the zero vector.
    """
    axis = np.asarray(axis, dtype=float).reshape(3)
    norm = np.linalg.norm(axis)
    if norm < 1e-12:
        raise ValueError("Axis vector must be non-zero.")
    return axis / norm


def rodrigues_matrix(u, theta_rad):
    """
    Step 2: Apply Rodrigues' formula with the already-normalized
    axis `u` and the angle in radians.

        A = I*cos(theta) + (1 - cos(theta)) * u*u^T
            + sin(theta) * [u]_x

    Parameters
    ----------
    u : array_like, shape (3,)
        Unit axis vector (use `normalize_axis` first).
    theta_rad : float
        Rotation angle in radians.

    Returns
    -------
    A : numpy.ndarray, shape (3, 3)
        Direction cosine matrix.
    """
    u = np.asarray(u, dtype=float).reshape(3)
    c = np.cos(theta_rad)
    s = np.sin(theta_rad)
    one_minus_c = 1.0 - c
    l1, l2, l3 = u[0], u[1], u[2]

    a11 = c + l1*l1 * one_minus_c
    a12 = -l3*s + l1*l2 * one_minus_c
    a13 =  l2*s + l3*l1 * one_minus_c
    a21 =  l3*s + l1*l2 * one_minus_c
    a22 = c + l2*l2 * one_minus_c
    a23 = -l1*s + l2*l3 * one_minus_c
    a31 = -l2*s + l3*l1 * one_minus_c
    a32 =  l1*s + l2*l3 * one_minus_c
    a33 = c + l3*l3 * one_minus_c

    return np.array([[a11, a12, a13],
                     [a21, a22, a23],
                     [a31, a32, a33]])


def rotation_matrix(axis, theta_deg):
    """
    Compute the direction cosine matrix from a rotation axis
    (any non-zero 3D vector) and a rotation angle (in degrees).

    Parameters
    ----------
    axis : array_like, shape (3,)
        Rotation axis direction (need not be unit length; will be
        normalized automatically).
    theta_deg : float
        Rotation angle in degrees. Sign follows the right-hand rule
        about the axis, consistent with Rodrigues' formula.

    Returns
    -------
    A : numpy.ndarray, shape (3, 3)
        Direction cosine matrix such that b = A @ a.

    Raises
    ------
    ValueError
        If the axis vector is the zero vector.
    """
    # Step 1: normalize the rotation axis
    u = normalize_axis(axis)

    # Step 2: apply Rodrigues' formula (angle converted to radians)
    A = rodrigues_matrix(u, np.deg2rad(theta_deg))
    return A


def verify(A, axis, tol=1e-9, verbose=True):
    """
    Verify the three key properties of a direction cosine matrix:
        (1) Orthogonality   A^T A = I
        (2) Determinant     det(A) = 1   (right-hand rotation)
        (3) Axis fixity     A * lambda = lambda
    """
    lam = np.asarray(axis, dtype=float).reshape(3)
    lam = lam / np.linalg.norm(lam)

    ortho_err = np.linalg.norm(A.T @ A - np.eye(3))
    det_err   = abs(np.linalg.det(A) - 1.0)
    axis_err  = np.linalg.norm(A @ lam - lam)

    passed = (ortho_err < tol) and (det_err < tol) and (axis_err < tol)
    if verbose:
        print("  - Orthogonality   ||A^T A - I||   = "
              f"{ortho_err:.2e}  {'OK' if ortho_err < tol else 'FAIL'}")
        print("  - Determinant     |det(A) - 1|    = "
              f"{det_err:.2e}  {'OK' if det_err < tol else 'FAIL'}")
        print("  - Axis fixed      ||A*lam - lam|| = "
              f"{axis_err:.2e}  {'OK' if axis_err < tol else 'FAIL'}")
    return passed


def pretty_print(A, title="Direction Cosine Matrix A"):
    """Print a 3x3 matrix in a clean fixed-width format (6 decimals)."""
    print()
    print(title)
    print("-" * len(title))
    for row in A:
        cells = "  ".join(f"{v:>10.6f}" for v in row)
        print(f"[ {cells} ]")
    print()


# ------------------- Examples and self-checks -------------------
if __name__ == "__main__":

    print("=" * 60)
    print("Direction Cosine Matrix - Simple Rotation")
    print("=" * 60)

    # Example 1: 90 degree rotation about the z-axis
    print("\n[Example 1] 90 degree rotation about z-axis (0, 0, 1)")
    A1 = rotation_matrix([0, 0, 1], 90)
    pretty_print(A1, "A1")
    print("Property check:")
    verify(A1, [0, 0, 1])

    # Example 2: 120 degree rotation about (1, 1, 1)/sqrt(3)
    print("\n[Example 2] 120 degree rotation about axis (1, 1, 1)")
    A2 = rotation_matrix([1, 1, 1], 120)
    pretty_print(A2, "A2")
    print("Property check:")
    verify(A2, [1, 1, 1])

    # Example 3: rotate a vector and check magnitude is preserved
    print("\n[Example 3] Apply A2 to a = (1, 0, 0); verify ||b|| = ||a||")
    a = np.array([1.0, 0.0, 0.0])
    b = A2 @ a
    print(f"  a      = {a}")
    print(f"  b=A2*a = {b}")
    na, nb = np.linalg.norm(a), np.linalg.norm(b)
    ok = abs(na - nb) < 1e-9
    print(f"  ||a||={na:.6f}, ||b||={nb:.6f}  "
          f"{'magnitude preserved' if ok else 'magnitude NOT preserved'}")

    # Example 4: negative angle (reverse rotation)
    print("\n[Example 4] -90 degree rotation about z-axis (reverse of Ex 1)")
    A4 = rotation_matrix([0, 0, 1], -90)
    pretty_print(A4, "A4")
    composite_err = np.linalg.norm(A1 @ A4 - np.eye(3))
    print(f"  Composite check: ||A1 @ A4 - I|| = {composite_err:.2e}  "
          f"{'OK' if composite_err < 1e-9 else 'FAIL'}")

    # Example 5: oblique axis with non-unit length (auto-normalized)
    print("\n[Example 5] Axis (2, -3, 5), angle 73.5 deg (axis is auto-normalized)")
    A5 = rotation_matrix([2, -3, 5], 73.5)
    pretty_print(A5, "A5")
    print("Property check:")
    verify(A5, [2, -3, 5])
