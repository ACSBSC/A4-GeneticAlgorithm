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
# 𝜇
# output [index] 
function selection(population, correlationMatrix) 
    stocks = Array{Int64}(undef, 0, 1)
    for i in 1:5

        stocks = [stocks; winner]
    end
    return stocks
end

# one point crossover, change 𝜇 values between the selected stocks
function crossover(selected, correlationMatrix)
    
    for i in 1:5
    
    end
    return correlationMatrix
end

function mutation()

end



function genteticAlgorithm(N)
    num_gen = 10
    pareto = false
    population = collect(1:N)
    𝜆 = 0.01
    for gen in 1:num_gen
        p_next = Array{Float64}(undef, 0, 0)
        for pair in 1:size(fitness, 1)/5
            
            selected = selection(population, correlationMatrix)
            correlationMatrix = crossover(selected, correlationMatrix)
            selected = mutation()

            p_next = [p_next, selected] #array of indexes

        end

    end

    #plot risk vs return scatter plot


end


