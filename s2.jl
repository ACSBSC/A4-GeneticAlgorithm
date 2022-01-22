
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
    for i in 1:K
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

function bestProportions(selected, meanStandardA, correlationMatrix, L, U, K, 𝜆)
    x = [0.1,0.15,0.20,0.25,0.3]
    ret = expectedReturn(K, x, meanStandardA, selected)
    risk = expectedRisk(K, x, meanStandardA, correlationMatrix, selected)
    E = 𝜆*risk - (1-𝜆)*ret
    return x, ret, risk, E
end

# Output [[i, xi]]
