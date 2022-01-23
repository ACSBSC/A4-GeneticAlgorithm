using Pkg
#Pkg.add("LaTeXStrings")
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

    for i in 1:K
        index = selected[i]
        𝜇= meanStandardA[index, 1]

        sum+= x[i]*𝜇
    end

    return sum
end

function expectedRisk(K, x, meanStandardA, correlationMatrix, selected)
    sum = 0
    for i = 1:K
        index_i = selected[i]
        𝜎i= meanStandardA[index_i, 2]
        for j in 1:K
            index_j = selected[j]
            𝜎j= meanStandardA[index_j, 2]
            V = 𝜎i*𝜎j*correlationMatrix[index_i,index_j]
            sum+= x[i]*x[j]*V
        end
    end

    return sum
end

function matchConstraints(x, A, L, U)
    K = size(x,1)
    normalisedX = zeros(K)
    C = []
    D = []
    s = sum(x)
    for i in 1:K
        normalisedX[i] = x[i]/s
        if(normalisedX[i] < L)
            push!(C,i)
        else
            push!(D,i)
        end
    end

    if(size(C,1) > 0)
        available = 0
        free = 0
        for i in 1:size(D,1)
            available = available + normalisedX[D[i]]
        end
        free = 1 - L * K
        for i in 1:size(C,1)
            normalisedX[C[i]] = L
        end
        for i in 1:size(D,1)
            normalisedX[D[i]] = L + normalisedX[D[i]] * free/available
        end
    end
    return normalisedX
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

function bestProportions(selectedAssets, meanStandardA, correlationMatrix, L, U, 𝜆)
    nDim = 1
    K = size(selectedAssets,2)
    nParticle = K
    nInter = 4000
    nRun = K
    xs = zeros(K)
    ys = zeros(nRun)

    fitFunc(x) = 𝜆 * expectedRisk(1, x[1], meanStandardA, correlationMatrix, selectedAssets) + (1-𝜆) * (-expectedReturn(1, x[1], meanStandardA, selectedAssets))

    xs = particle_swarm(
        fitFunc,
        nDim,
        nParticle = nParticle,
        nInter = nInter,
    )
    xs = matchConstraints(xs, selectedAssets, L, U)
    s = sum(xs)
    xRisk = expectedRisk(K, xs, meanStandardA, correlationMatrix, selectedAssets)
    xReturn = expectedReturn(K, xs, meanStandardA, selectedAssets)
    optimisation = 𝜆 * xRisk + (1-𝜆) * (-xReturn)

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

    return xs, xRisk, xReturn, optimisation
end
