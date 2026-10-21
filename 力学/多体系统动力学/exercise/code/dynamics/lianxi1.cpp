#include <Eigen/Dense>
#include <iostream>
#include <cmath>
#include <algorithm>

using namespace Eigen;
using namespace std;

double l1 = 1.0;
double l2 = 1.0;
double l3 = 1.2;
double l4 = 2.0;
double m1 = 1.0;
double m2 = 1.0;
double g = -9.8;

int GuassSolver(const MatrixXd &A, const VectorXd &b, VectorXd &x, double tol = 1e-12)
{
    int n = A.rows();
    x.resize(n);
    if (n == 0)
        return 0;

    MatrixXd M = A;
    VectorXd rhs = b;

    for (int k = 0; k < n; k++)
    {

        int p = k;
        double maxAbs = abs(M(k, k));

        for (int i = k + 1; i < n; i++)
        {
            const double v = abs(M(i, k));
            if (v > maxAbs)
            {
                maxAbs = v;
                p = i;
            }
        }

        if (maxAbs <= tol)
            return 3;

        if (p != k)
        {
            M.row(k).swap(M.row(p));
            swap(rhs(k), rhs(p));
        }

        double pivotVal = M(k, k);

        for (int i = k + 1; i < n; i++)
        {
            double factor = M(i, k) / pivotVal;

            if (factor == 0.0)
                continue;

            M.row(i).segment(k, n - k) -= factor * M.row(k).segment(k, n - k);
            rhs(i) -= factor * rhs(k);
        }
    }

    for (int i = n - 1; i >= 0; --i)
    {
        double sum = rhs(i);

        for (int j = i + 1; j < n; ++j)
        {
            sum -= M(i, j) * x(j);
        }

        if (std::abs(M(i, i)) <= tol)
            return 3;

        x(i) = sum / M(i, i);
    }

    return 0;
}

VectorXd constraint(const VectorXd &q)
{
    const double x1 = q(0), y1 = q(1), x2 = q(2), y2 = q(3);

    VectorXd c(3);
    c << x1 * x1 + y1 * y1 - l1 * l1,
        (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1) - l2 * l2,
        (x2 - l4) * (x2 - l4) + y2 * y2 - l3 * l3;
    return c;
}

MatrixXd constraintJacobian(const VectorXd &q)
{
    const double x1 = q(0), y1 = q(1), x2 = q(2), y2 = q(3);

    MatrixXd C(3, 4);
    C << 2.0 * x1, 2.0 * y1, 0.0, 0.0,
        2.0 * (x1 - x2), 2.0 * (y1 - y2), 2.0 * (x2 - x1), 2.0 * (y2 - y1),
        0.0, 0.0, 2.0 * (x2 - l4), 2.0 * y2;
    return C;
}

double potential(const VectorXd &q)
{
    return m1 * g * q(1) + m2 * g * q(3);
}

MatrixXd weightedHessian(const VectorXd &q, const VectorXd &lam)
{
    MatrixXd H = MatrixXd::Zero(4, 4);

    H(0, 0) += 2.0 * lam(0);
    H(1, 1) += 2.0 * lam(0);

    H(0, 0) += 2.0 * lam(1);
    H(2, 2) += 2.0 * lam(1);
    H(1, 1) += 2.0 * lam(1);
    H(3, 3) += 2.0 * lam(1);
    H(0, 2) -= 2.0 * lam(1);
    H(2, 0) -= 2.0 * lam(1);
    H(1, 3) -= 2.0 * lam(1);
    H(3, 1) -= 2.0 * lam(1);

    // c3 = (x2-l4)² + y2² - l3²  →  H_c3 = diag(0, 0, 2, 2)
    H(2, 2) += 2.0 * lam(2);
    H(3, 3) += 2.0 * lam(2);

    return H;
}

VectorXd residual(const VectorXd &x)
{
    const VectorXd q = x.head(4);
    const VectorXd lam = x.tail(3);

    VectorXd fx(4);
    fx << 0.0, m1 * g, 0.0, m2 * g; // f_x = (0, m1 g, 0, m2 g)

    VectorXd F(7);
    F.head(4) = fx + constraintJacobian(q).transpose() * lam;
    F.tail(3) = constraint(q);
    return F;
}

MatrixXd jacobian(const VectorXd &x)
{
    const VectorXd q = x.head(4);
    const VectorXd lam = x.tail(3);

    const MatrixXd C = constraintJacobian(q);

    MatrixXd J = MatrixXd::Zero(7, 7);
    J.topLeftCorner(4, 4) = weightedHessian(q, lam);
    J.topRightCorner(4, 3) = C.transpose();
    J.bottomLeftCorner(3, 4) = C;
    return J; // 右下 3×3 保持为 0
}

bool newtonSolve(VectorXd &x, int maxIter, double tol)
{
    for (int iter = 0; iter < maxIter; ++iter)
    {
        const VectorXd F = residual(x);
        if (F.norm() < tol)
            return true;

        const MatrixXd J = jacobian(x);
        const VectorXd rhs = -F;
        /

            VectorXd dx;
        if (GuassSolver(J, rhs, dx) != 0)
            return false;

        x += dx;

        if (dx.norm() < 1e-14)
            break;
    }

    return residual(x).norm() < 1e-9;
}

double secondOrderQ(const VectorXd &x)
{
    const VectorXd q = x.head(4);
    const VectorXd lam = x.tail(3);
    const MatrixXd C = constraintJacobian(q); // 3×4

    VectorXd d(4);
    for (int i = 0; i < 4; ++i)
    {
        MatrixXd minor(3, 3);
        int col = 0;
        for (int j = 0; j < 4; ++j)
        {
            if (j == i)
                continue;
            minor.col(col) = C.col(j);
            ++col;
        }
        d(i) = ((i % 2 == 0) ? 1.0 : -1.0) * minor.determinant();
    }

    const MatrixXd H = weightedHessian(q, lam);
    return d.dot(H * d);
}

int main()
{

    cout << "l1=" << l1 << ", l2=" << l2 << ", l3=" << l3
         << ", l4=" << l4 << ", m1=" << m1 << ", m2=" << m2
         << ", g=" << g << "\n\n";

    const int nStarts = 4;
    const double q0s[nStarts][4] = {
        {0.5, 0.9, 1.4, 1.0},
        {0.5, -0.9, 1.4, -1.0},
        {0.3, 1.0, 1.1, 1.1},
        {0.3, -1.0, 1.1, -1.1},
    };

    VectorXd sols[8];
    int found = 0;

    for (int s = 0; s < nStarts; ++s)
    {
        VectorXd x(7);
        x << q0s[s][0], q0s[s][1], q0s[s][2], q0s[s][3], 1.0, 1.0, 1.0;

        if (!newtonSolve(x, 100, 1e-10))
            continue;

        bool isNew = true;
        for (int k = 0; k < found; ++k)
        {
            if ((x - sols[k]).norm() < 1e-6)
            {
                isNew = false;
                break;
            }
        }

        if (isNew && found < 8)
            sols[found++] = x;
    }

    cout << "共找到 " << found << " 个驻点解：\n";

    for (int k = 0; k < found; ++k)
    {
        const VectorXd x = sols[k];
        const VectorXd q = x.head(4);
        const VectorXd lam = x.tail(3);

        const double f = potential(q);
        const double Q = secondOrderQ(x);

        cout << "\n解 " << k + 1 << "：\n";
        cout << "  (x1, y1) = (" << q(0) << ", " << q(1) << ")\n";
        cout << "  (x2, y2) = (" << q(2) << ", " << q(3) << ")\n";
        cout << "  (λ1, λ2, λ3) = (" << lam(0) << ", " << lam(1) << ", " << lam(2) << ")\n";
        cout << "  势能 f = " << f << "\n";
        cout << "  二阶判据 Q = " << Q << "  ->  ";

        if (Q > 1e-8)
            cout << "极小值点（稳定）\n";
        else if (Q < -1e-8)
            cout << "非极小值点（不稳定/鞍点）\n";
        else
            cout << "退化，需看更高阶\n";
    }

    return 0;
}
