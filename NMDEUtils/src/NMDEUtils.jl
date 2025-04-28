module NMDEUtils
#region module

using LinearAlgebra
using Statistics
using NonlinearSolve

struct InitialValueProblem
    dy::Function
    y₀::Float64
    interval::Tuple{Float64,Float64}
    exactSolution::Function
end

struct IVPSolution
    x::Vector{Float64}
    y::Vector{Float64}
    exactSolution::Vector{Float64}
end

struct RungeKuttaExplicit
    a::Vector{Float64}
    b::Matrix{Float64}
    c::Vector{Float64}
    name::Union{Missing,String}
end

ExplicitEuler = RungeKuttaExplicit(
    [0],
    [0;;],
    [1],
    "Euler Explícito",
)
TrapezoidalMethod = RungeKuttaExplicit(
    [0, 1],
    [0 0; 1 0],
    [1 / 2, 1 / 2],
    "Método do Trapézio",
)
RK3Classic = RungeKuttaExplicit(
    [0, 1 / 2, 3 / 4],
    [0 0 0; 1/2 0 0; 0 3/4 0],
    [2 / 9, 3 / 9, 4 / 9],
    "Runge-Kutta de 3a Ordem",
)
RK4Classic = RungeKuttaExplicit(
    [0, 1 / 2, 1 / 2, 1],
    [0 0 0 0; 1/2 0 0 0; 0 1/2 0 0; 0 0 1 0],
    [1 / 6, 2 / 6, 2 / 6, 1 / 6],
    "Runge_kutta de 4a Ordem",
)
ModifiedEuler = RungeKuttaExplicit(
    [0, 1 / 2],
    [0 0; 1/2 0],
    [0, 1],
    "Euler Modificado",
)
ImprovedEuler = RungeKuttaExplicit(
    [0, 1],
    [0 0; 1 0],
    [1 / 2, 1 / 2],
    "Euler Aperfeiçoado",
)

function solveExplicit(ivp::InitialValueProblem, method::RungeKuttaExplicit; stepSize::Float64=1e-1)
    xRange = ivp.interval[1]:stepSize:ivp.interval[2]
    ySolution = zeros(size(xRange))
    ySolution[1] = ivp.y₀
    exactSolution = ivp.exactSolution.(xRange)
    k = zeros(size(method.a))
    for iₓ in eachindex(xRange)[1:end-1]
        for iₖ in eachindex(k)
            xₖ = xRange[iₓ] + stepSize * method.a[iₖ]
            yₖ = ySolution[iₓ] + stepSize * (k[1:iₖ] ⋅ method.b[iₖ, 1:iₖ])
            k[iₖ] = ivp.dy(xₖ, yₖ)
        end
        ySolution[iₓ+1] = ySolution[iₓ] + stepSize * (method.c ⋅ k)
    end
    return IVPSolution(xRange, ySolution, exactSolution)
end

function implicitEuler(ivp::InitialValueProblem; stepSize::Float64=1e-1)
    xRange = ivp.interval[1]:stepSize:ivp.interval[2]
    ySolution = zeros(size(xRange))
    ySolution[1] = ivp.y₀
    exactSolution = ivp.exactSolution.(xRange)
    toRoot(yₖ, p) = p[1] + stepSize * ivp.dy(p[2], yₖ) - yₖ
    for iₓ in eachindex(xRange)[1:end-1]
        prob = NonlinearProblem(toRoot, ySolution[iₓ], [ySolution[iₓ], xRange[iₓ+1]])
        sol = solve(prob; maxiters=20)
        ySolution[iₓ+1] = sol.u
    end
    return IVPSolution(xRange, ySolution, exactSolution)
end

function solutionMeanError(sol::IVPSolution)
    abs.(sol.y - sol.exactSolution) |> mean
end

export InitialValueProblem, IVPSolution, RungeKuttaExplicit
export ExplicitEuler, TrapezoidalMethod, RK3Classic, RK4Classic, ModifiedEuler, ImprovedEuler
export solveExplicit, implicitEuler, solutionMeanError

function test_NMDEUtils()
    # Define a sample problem
    test_ivp = InitialValueProblem(
        (x, y) -> x - y + 2,
        2,
        (0, 1),
        x -> exp(-x) + x + 1
    )

    # Solve for each
    sol = solveExplicit(test_ivp, ExplicitEuler)
    sol_t = solveExplicit(test_ivp, TrapezoidalMethod)
    sol_3 = solveExplicit(test_ivp, RK3Classic)
    sol_4 = solveExplicit(test_ivp, RK4Classic)
    sol_imp = implicitEuler(test_ivp)

    @info ExplicitEuler.name (sol |> solutionMeanError)
    @info "Euler Implícito" (sol_imp |> solutionMeanError)
    @info TrapezoidalMethod.name (sol_t |> solutionMeanError)
    @info RK3Classic.name (sol_3 |> solutionMeanError)
    @info RK4Classic.name (sol_4 |> solutionMeanError)
end

export test_NMDEUtils

#endregion
end