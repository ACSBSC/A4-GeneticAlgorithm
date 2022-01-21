
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

function bestProportions(portfolio, meanStandardA, correlationMatrix, L, U)

end

# Output [[i, xi]]
