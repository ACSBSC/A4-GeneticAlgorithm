#Genetic Algorithm

# Size of stocks
# 𝜇, 𝜎  --> meanStandardA
# p --> correlationMatrix
# Vij = pij*𝜎i*𝜎j
# L investment
# U investment
# L<=xi<=U 
# P --> where 𝜆 comes from


include("s2.jl")


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

    return meanStandardA
end



function geneticAlgorithm(N, K, 𝜆, L, U, correlationMatrix, meanStandardA)
    num_gen = 10
    
    population = collect(1:N)
   
    sol = Array{Float64}(undef, 0, 6)
    
    x = [0.2, 0.35, 0.15, 0.2, 0.1]

    for gen in 1:num_gen
        p_next = Array{Int}(undef, 0, 5)
        
        for pair in 1:N/K
            
            selected = selection(population, meanStandardA, K, N)
            
            meanStandardA = crossover(selected, meanStandardA, K)            
            meanStandardA = mutation(selected, meanStandardA)
            
            selected = reshape(selected, (1,5))
            p_next = [p_next; selected] #array of indexes
            
            x, ret, risk = swarm_particle(N, meanStandardA, correlationMatrix, L, U)

            #ret = expectedRetrun(K, x, meanStandardA, selected)
            #risk = expectedRisk(K, x, meanStandardA, correlationMatrix, selected)
            #E will be calculated and added to E array
            #Risk and return are calculated and added to its arrays
            E = 𝜆*risk - (1-𝜆)*ret
            sol = [sol; reshape([𝜆, ret, risk, E, selected, x], (1,6))]
        end
        
    end
    println()
    println(sol)

end


