import numpy as np

def solve_heat(M, N, tol=1e-6, max_iter=10000, method='gauss_seidel', omega=1.5):
    θ = np.zeros((N+1, M+1))  # (y, x)

    # Dirichlet BCs
    θ[:, 0] = 75      # Left wall (x=0)
    θ[0, :] = 50      # Bottom wall (y=0)
    θ[-1, :] = 0      # Top wall (y=N)

    θ_new = θ.copy()

    for _ in range(max_iter):
        max_diff = 0.0

        for j in range(1, N):     # y direction (1 to N-1)
            for i in range(1, M): # x direction (1 to M-1)

                right = θ[j, i+1] if i+1 <= M-1 else θ[j, i-1]  # Neumann at right

                θ_old = θ[j, i] if method != 'jacobi' else θ_new[j, i]

                update = (right + θ[j, i-1] + θ[j+1, i] + θ[j-1, i]) / 4

                if method == 'sor':
                    update = θ_old + omega * (update - θ_old)

                diff = abs(update - θ_old)
                max_diff = max(max_diff, diff)

                if method == 'jacobi':
                    θ_new[j, i] = update
                else:
                    θ[j, i] = update

        # Apply Neumann at right wall (after inner loops)
        θ[1:N, M] = θ[1:N, M-1]

        if method == 'jacobi':
            θ, θ_new = θ_new, θ

        if max_diff < tol:
            break

    return θ
