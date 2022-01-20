#Genetic Algorithm
include("s2.jl")

function select(fit, K)
    
end

function crossover_mutation(stocks, P, lambda, correlationMatrix, meanStandardA)
    size = 1/P
    lambdas = collect(0.01:size:1)
    ret = 0.0
    risk = 0.0
    E = 1000.0

    for l in lambdas
        tempRet = 0.0
        tempRisk = 0.0
        tempE = 0.0
        for i in 1:size(stocks, 1)
            sumRisk = 0
           for j in  1:size(stocks, 1)
                V = correlationMatrix[i,j]*meanStandardA[i,2]*meanStandardA[j,2]
                sumRisk+= stock[i, 2] * V * stock[j, 2]
           end
           tempRisk+=sumRisk

           tempRet += stock[i, 2] * meanStandardA[i,1]

        end

        tempE = l*tempRisk - (1-l)*tempRet

        if tempE < E
            E = tempE
            risk = tempRisk
            ret = tempRet
            lambda = l
        end
    end
    
end


function genteticAlgorithm(population, K, P, correlationMatrix, meanStandardA)
    num_gen = 10

    lambda = 0.01
    ret = 0.0
    risk = 0.0
    E = 0.0

    fitness = swarm_particle(population)
    
    for gen in 1:num_gen
        p_next = Array{Float64}(undef, 0, 2)
        for pair in 1:size(fitness, 1)
            stocks = select(fitness, K)
            lambda, ret, risk, E = crossover_mutation(stocks, P, lambda, correlationMatrix, meanStandardA)
        end
    end
end


