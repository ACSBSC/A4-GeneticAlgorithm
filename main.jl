<<<<<<< HEAD
# include("ga.jl")
include("s2.jl")
=======
include("ga.jl")
using Plots

function paretoFinder(sol, riskReturn)
    paretoPortfolios  = Array{Float64}(undef, 0, 7)
    bestPortfolios  = Array{Float64}(undef, 0, 7)
    for i in 1: size(sol, 1)
        for j in 1:size(riskReturn, 1)
            if (sol[i,2] < riskReturn[j,1]+0.00003 && sol[i,2] > riskReturn[j,1]-0.00003) && (sol[i,3] < riskReturn[j,2]+0.00003 && sol[i,3] > riskReturn[j,2]-0.00003)
                paretoPortfolios = [paretoPortfolios; reshape(sol[i,:], (1,7))]
                sol[i,7] = true
            end
            if (sol[i,2] > riskReturn[j,1]) && (sol[i,3] < riskReturn[j,2]+0.00003 && sol[i,3] > riskReturn[j,2]-0.00003)
                bestPortfolios = [bestPortfolios; reshape(sol[i,:], (1,7))]
            end
        end
    end
    return paretoPortfolios, sol, bestPortfolios
end



>>>>>>> e8e2584edcc3e6c9dd3333ec75f5a145f51d7e2a

function main(args)
    @show args
    if (size(args, 1) < 1)
        println("Error : the program expects 1 argument.")
        println("Usage : julia main_bp.jl parameters_file_path")
        return
    elseif (size(args, 1) > 1)
        println(
            "Warning : too many arguments (1 expected). Only 1 will be considered.",
        )
    end

    path = "./A4-portfolios/" * args[1]
    var = split(args[1], ".")
    path2 = "./A4-portfolios/" * var[1] * "_eff.txt"
    println(path2)
    K = 5
    L = 0.1
    U = 1
    P = 101
    N = 0

    meanStandardA = Array{Float64}(undef, 0, 2)
    indexCorrelationA = Array{Float64}(undef, 0, 3)
    riskReturn = Array{Float64}(undef, 0, 2)

    open(path2) do f

        # line_number
        line = 0
        # read till end of file
        while !eof(f)
            # read a new / next line for every iteration
            s = readline(f)

            chunks = split(s, ' ')
            temp = [parse(Float64, x) for x in chunks]
            temp = reshape(temp, (1, 2))
            riskReturn = [riskReturn; temp]
        end
    end

    open(path) do f

        # line_number
        line = 0
        # read till end of file
        while !eof(f)
            # read a new / next line for every iteration
            s = readline(f)
            if line == 0
                N = parse(Int64, s)
            elseif line <= N
                chunks = split(s, ' ')
                temp = [parse(Float64, x) for x in chunks]
                temp = reshape(temp, (1, 2))
                meanStandardA = [meanStandardA; temp]

            else
                chunks = split(s, ' ')
                temp = [parse(Float64, x) for x in chunks]
                temp = reshape(temp, (1, 3))
                indexCorrelationA = [indexCorrelationA; temp]
            end

            line += 1

        end

    end

    correlationMatrix = zeros((N, N))

    for k = 1:size(indexCorrelationA, 1)
        i = floor(Int, indexCorrelationA[k, 1])
        j = floor(Int, indexCorrelationA[k, 2])
        correlationMatrix[i, j] = indexCorrelationA[k, 3]
        correlationMatrix[j, i] = indexCorrelationA[k, 3]
    end
    #
    # #store best portfolio and rest of them, ony best porfolio will be saved
    # bestPortfolios  = Array{Float64}(undef, 0, 7)
    # portfolios  = Array{Float64}(undef, 0, 7)
    # pareto = Array{Float64}(undef, 0, 7)
    #
    # # here should be the loop for the lambdas
    # step = 1/P
    # 𝜆s = collect(0.01:step:1)
    #
    # for 𝜆 in 𝜆s
    #     println("Selecting best portfolios for lambda ", 𝜆)
    #     sol = geneticAlgorithm(N, K, 𝜆, L, U, correlationMatrix, meanStandardA)
    #
    #     #plot risk vs return scatter plot
    #
    #     paretoPortfolios, sol, best  = paretoFinder(sol, riskReturn)
    #
    #     scatter(sol[:,3],sol[:,2], reuse = false, color = "orange", label = "Portfolios")
    #     scatter!(best[:,3],best[:,2], reuse = false, color = "red", label = "Best portfolios")
    #     scatter!(paretoPortfolios[:,3],paretoPortfolios[:,2], reuse = false, color = "black", label = "Pareto front")
    #
    #     f = plot!(riskReturn[:,2],riskReturn[:,1],title = "Efficient frontier for lambda = "*string(𝜆), ylabel="Return", xlabel="Risk",color = "blue", label = "Efficient Frontier Line")
    #     png(f,string("Plots/figure_Return_Risk_lambda_"*string(𝜆)*".jpg"))
    #
    #     bestPortfolios  = [bestPortfolios  ; best; paretoPortfolios]
    #     portfolios = [portfolios; sol]
    #     pareto = [pareto; paretoPortfolios]
    # end
    # println()
    # println("Finished calculation of portfolios for each lambda")
    # #Final plots for every lambda
    # println()
    # println("Start Plotting...")
    # scatter(portfolios[:,3],portfolios[:,2], reuse = false, color = "yellow", label = "Portfolios")
    # scatter!(bestPortfolios[:,3],bestPortfolios[:,2], reuse = false, color = "red", label = "Best Portfolios")
    # scatter!(pareto[:,3],pareto[:,2], reuse = false, color = "black", label = "Paretos")
    # f2 = plot!(riskReturn[:,2],riskReturn[:,1],title = "Efficient frontier", ylabel="Return", xlabel="Risk",color = "blue")
    # println()
    # println("Finish Plotting || Starting to save the plot...")
    # png(f2,string("Results/figure_Return_Risk.jpg"))
    # println("Plot saved!")
    # println()
    # println("Code Stops!")

    print(bestProportions([1,2,3,4,5], meanStandardA, correlationMatrix, L, U, 0.4))


end

main(ARGS)
