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
end

ExplicitEuler = RungeKuttaExplicit([0], [0;;], [1])
TrapezoidalMethod = RungeKuttaExplicit([0, 1], [0 0; 1 0], [1 / 2, 1 / 2])
RK3Classic = RungeKuttaExplicit([0, 1 / 2, 3 / 4], [0 0 0; 1/2 0 0; 0 3/4 0], [2 / 9, 3 / 9, 4 / 9])
RK4Classic = RungeKuttaExplicit([0, 1 / 2, 1 / 2, 1], [0 0 0 0; 1/2 0 0 0; 0 1/2 0 0; 0 0 1 0], [1 / 6, 2 / 6, 2 / 6, 1 / 6])
ModifiedEuler = RungeKuttaExplicit([0, 1 / 2], [0 0; 1/2 0], [0, 1])
ImprovedEuler = RungeKuttaExplicit([0, 1], [0 0; 1 0], [1 / 2, 1 / 2])

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

METHODS_NAMES_DICT = Dict(
    "ExplicitEuler" => "Euler Explícito",
    "TrapezoidalMethod" => "Método dos Trapézios",
    "RK3Classic" => "Runge-Kutta de 3a ordem",
    "RK4Classic" => "Runge-Kutta de 4a ordem",
    "implicitEuler" => "Euler Implícito",
    "ModifiedEuler" => "Euler Modificado",
    "ImprovedEuler" => "Euler Aperfeiçoado"
)