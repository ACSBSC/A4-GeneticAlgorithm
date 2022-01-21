#Genetic Algorithm

# Size of stocks
# 𝜇, 𝜎  --> meanStandardA
# p --> correlationMatrix
# Vij = pij*𝜎i*𝜎j
# L investment
# U investment
# L<=xi<=U 
# P --> where 𝜆 comes from


#include("s2.jl")

function expectedRetrun()

end
function expectedRisk()

end

#tournament selection
# 𝜇
# output [index] 
function selection(population, fitness, K, N, U) 
    
    stocks = zeros(Int, K)
    x = zeros(Float64, K)
    
    #select stocks
    for i in 1:K
        num = floor(Int, rand(1:5))
       
        winner = population[floor(Int, rand(1:N))]
       
        for j in 1:num
            pos = population[floor(Int, rand(1:N))]
            if fitness[pos]>fitness[winner] && (pos in stocks) == false
                winner = pos
            end
        end
        stocks[i] = winner
        
    end
    println()
    i = 1
    for s in stocks
        x[i] = fitness[s]
        i+=1
    end

    #normalize xi so that its sum is U
    return stocks, x
end

# one point crossover, change 𝜇 values between the selected stocks
function crossover(selected, meanStandardA, K)
    
    println()
    for i in 1:K-1
        𝜇= meanStandardA[selected[i], 1]
        meanStandardA[selected[i], 1] = meanStandardA[selected[i+1], 1]
        meanStandardA[selected[i+1], 1] = 𝜇
    end
    println()
    
    return meanStandardA
end

# swap numbers within 𝜎 of the selected stocks
# one random stock is mutated
function mutation(selected, meanStandardA, K)
    println()
    for i in 1:K
        𝜇= meanStandardA[selected[i], 1]
        meanStandardA[selected[i], 1] = meanStandardA[selected[i+1], 1]
        meanStandardA[selected[i+1], 1] = 𝜇
    end
    println()
    return meanStandardA
end



function geneticAlgorithm(N, K, P, U, correlationMatrix, meanStandardA, riskReturn)
    num_gen = 10
    pareto = false
    population = collect(1:N)
    step = 1/P
    𝜆 = collect(0.01:step:1)
    
    step = 1/(N+3)
    
    fitness = collect(0.1:step:1)
   
    sol = Array{Float64}(undef, 0, 2)
    

    for gen in 1:num_gen
        p_next = Array{Float64}(undef, 0, 0)
        
        for pair in 1:size(fitness, 1)/K
            
            selected, x = selection(population, fitness, K, N, U)
            meanStandardA = crossover(selected, meanStandardA, K)
            
            meanStandardA = mutation(selected, meanStandardA, K)

            #p_next = [p_next, selected] #array of indexes
            
            
            #E will be calculated and added to E array
            #Risk and return are calculated and added to its arrays
            #sol = [sol; [gen, 𝜆, ret, risk, E, Pareto, selected, x]]
        end
        
    end

    #plot risk vs return scatter plot

end


