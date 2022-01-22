# Pkg.add("MLJParticleSwarmOptimization")
# using MLJ,
# MLJDecisionTreeInterface, MLJParticleSwarmOptimization, Plots, StableRNGs

# Pkg.add(PackageSpec(url = "https://github.com/bingining/PSO.jl.git"))
using Pkg
Pkg.add("LaTeXStrings")
using Plots, LaTeXStrings
include("pso.jl")

# Size of stocks
# 𝜇, 𝜎  --> meanStandardA
# p --> correlationMatrix
# Vij = pij*𝜎i*𝜎j
# L investment
# U investment
# L<=xi<=U          Sum(Xi)<=U

function expectedReturn(K, x, meanStandardA, selected)
    sum = 0
    println(x)
    for i = 1:K
        index = selected[i]
        𝜇 = meanStandardA[index, 1]
        println(𝜇)
        sum += x[i] * 𝜇
    end
    println(sum)
    return sum
end

function expectedRisk(K, x, meanStandardA, correlationMatrix, selected)
    sum = 0
    for i = 1:K
        index_i = selected[i]
        𝜎i = meanStandardA[index_i, 1]
        for j = 1:K
            index_j = selected[j]
            𝜎j = meanStandardA[index_j, 1]
            V = 𝜎i * 𝜎j * correlationMatrix[i, j]
            sum += x[i] * x[j] * V
        end
    end
    println(sum)
    return sum
end

function particle_swarm(
    fitFunc::Function,
    nDim::Int;
    nParticle = 100,
    nInter::Int = 4000,
)
    s = Swarm(fitFunc, nDim, nParticle = nParticle, nInter = nInter)
    initSwarm(s)

    for i in s.nInter
        updateSwarm(s)
    end
    # s.gBest
    particles = s.particles
    particlesBest = zeros(size(particles,1))
    for i = 1:size(particles,1)
        particlesBest[i] = particles[i].fitpBest
    end
    particlesBest
end

function bestProportions(portfolio, meanStandardA, correlationMatrix, 𝜆)
# function bestProportions()
    nDim = 2
    # nParticle = size(portfolio,1)
    nParticle = 5
    nInter = 4000
    nRun = 5
    # xs = Array{Float}(undef, nRun)
    K = size(portfolio,1)
    xs = zeros(K)
    ys = zeros(nRun)

    fitFunc(x) = 𝜆 * expectedRisk(K, xs, meanStandardA, correlationMatrix, portfolio)
    + (1-𝜆) * (-expectedReturn(K, xs, meanStandardA, portfolio))
    # fitFunc(x) = (x[1] - 1 / 2)^2 + (x[2] - 1 / 2)^2

    # for i = 1:nRun
    #     xs[i], ys[i] = particle_swarm(
    #         fitFunc,
    #         nDim,
    #         nParticle = nParticle,
    #         nInter = nInter,
    #     )
    # end

    xs = particle_swarm(
        fitFunc,
        nDim,
        nParticle = nParticle,
        nInter = nInter,
    )
    xRisk = expectedRisk(K, xs, meanStandardA, correlationMatrix, portfolio)
    xReturn = expectedReturn(K, xs, meanStandardA, portfolio)
    optimisation = 𝜆 * xRisk + (1-𝜆) * (-xReturn)

    # print(size(xs))
    # print(xs)

    # gr()
    # scatter(
    #     xs,
    #     ys,
    #     markersize = 2,
    #     c = :blue,
    #     xlims = (0.2, 0.8),
    #     ylims = (0.2, 0.8),
    #     label = L"f(x,y) = (x-0.5)^2 + (y-0.5)^2",
    #     title = "$nParticle particles, $nInter iterations, $nRun PSO runs",
    # )
    # xlabel!("x")
    # ylabel!("y")
    # gr()
    # histogram2d(
    #     xs,
    #     ys,
    #     nbins = 300,
    #     xlims = (0.4, 0.6),
    #     ylims = (0.4, 0.6),
    #     label = L"f(x,y) = (x-0.5)^2 + (y-0.5)^2",
    #     title = "$nParticle particles, $nInter iterations, $nRun PSO runs",
    # )
    # xlabel!("x")
    # ylabel!("y")

    return (xs, xRisk, xReturn, optimisation)
end

# Output [[i, xi]]
