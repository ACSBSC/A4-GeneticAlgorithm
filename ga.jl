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

function expectedRetrun(K, x, meanStandardA, selected)
    sum = 0
    println(x)
    for i in 1:K
        index = selected[i]
        𝜇= meanStandardA[index, 1]
        println(𝜇)
        sum+= x[i]*𝜇
    end
    println(sum)
    return sum
end
function expectedRisk(K, x, meanStandardA, correlationMatrix, selected)
    sum = 0
    for i in 1:K
        index_i = selected[i]
        𝜎i= meanStandardA[index_i, 1]
        for j in 1:K
            index_j = selected[j]
            𝜎j= meanStandardA[index_j, 1]
            V = 𝜎i*𝜎j*correlationMatrix[i,j]
            sum+= x[i]*x[j]*V
        end
    end
    println(sum)
    return sum
end

#tournament selection
# fitness
# output [index] 
function selection(population, meanStandardA, K, N) 
    
    stocks = zeros(Int, K)
    x = zeros(Float64, K)
    
    #select stocks
    for i in 1:K
        num = floor(Int, rand(1:5))
       
        winner = population[floor(Int, rand(1:N))]
       
        for j in 1:num
            pos = population[floor(Int, rand(1:N))]
            if meanStandardA[pos,1]>meanStandardA[winner,1] && (pos in stocks) == false
                winner = pos
            end
        end
        stocks[i] = winner
        
    end

    #normalize xi so that its sum is U
    return stocks
end

# one point crossover, change 𝜇 values between the selected stocks
function crossover(selected, meanStandardA, K)
    
    println()
    for i in 1:K-1
        𝜇= meanStandardA[selected[i], 1]
        meanStandardA[selected[i], 1] = meanStandardA[selected[i+1], 1]
        meanStandardA[selected[i+1], 1] = 𝜇
    end
 
    
    return meanStandardA
end

# swap numbers within 𝜎 of the selected stocks
# one random stock is mutated
function mutation(selected, meanStandardA)
    rnd = rand(1:5)
    
    𝜎 = string(meanStandardA[selected[rnd], 2])
    m = sizeof(𝜎)
    𝜎 = split(𝜎, "")
    n = 𝜎[m-1]
    𝜎[m-1] = 𝜎[m]
    𝜎[m] = n
    𝜎 = join(𝜎)
    𝜎 = parse(Float64,  𝜎)
    meanStandardA[selected[rnd], 2] = 𝜎

    println()
    return meanStandardA
end



function geneticAlgorithm(N, K, 𝜆, U, correlationMatrix, meanStandardA)
    num_gen = 10
    
    population = collect(1:N)
    
    step = 1/(N+3)
    
    fitness = collect(0.1:step:1)
   
    sol = Array{Float64}(undef, 0, (5+2*K))
    

    for gen in 1:num_gen
        p_next = Array{Int}(undef, 0, 5)
        
        for pair in 1:N/K
            
            selected = selection(population, meanStandardA, K, N)
            
            meanStandardA = crossover(selected, meanStandardA, K)            
            meanStandardA = mutation(selected, meanStandardA)
            
            selected = reshape(selected, (1,5))
            p_next = [p_next; selected] #array of indexes
            
            #s2 swarm particle
            ret = expectedRetrun(K, x, meanStandardA, selected)
            #risk = expectedRisk(K, x, meanStandardA, correlationMatrix, selected)
            #E will be calculated and added to E array
            #Risk and return are calculated and added to its arrays
            #sol = [sol; [𝜆, ret, risk, E, selected, x]]
        end
        
    end

    

end


