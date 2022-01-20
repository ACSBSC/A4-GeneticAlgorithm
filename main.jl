function main(args)
    @show args
    if(size(args,1) < 1)
      println("Error : the program expects 1 argument.")
      println("Usage : julia main_bp.jl parameters_file_path")
      return;
    elseif (size(args,1) > 1)
      println("Warning : too many arguments (1 expected). Only 1 will be considered.")
    end

    path = args[1]
    K = 5
    L = 0.1
    U = 1
    P = 101
    N = 0

    meanStandardA = Array{Float64}(undef, 0, 2) 
    indexCorrelationA = Array{Float64}(undef, 0, 3)

    open(path) do f

        # line_number
        line = 0         
        # read till end of file
        while ! eof(f) 
           # read a new / next line for every iteration 
           s = readline(f)       
           if line == 0
                N = parse(Int64, s)
           elseif line <= N
                chunks = split(s, ' ')
                temp = [parse(Float64,x) for x in chunks]
                temp = reshape(temp, (1,2))
                meanStandardA = [meanStandardA; temp]

           else
                chunks = split(s, ' ')
                temp = [parse(Float64,x) for x in chunks]
                temp = reshape(temp, (1,3))
                indexCorrelationA = [indexCorrelationA; temp]
           end

           line += 1
  
        end
       
    end

    correlationMatrix = zeros((N,N))
 
    for k in 1:size(indexCorrelationA, 1)
        i = floor(Int, indexCorrelationA[k,1])
        j = floor(Int, indexCorrelationA[k,2])
        correlationMatrix[i,j]= indexCorrelationA[k,3]
        correlationMatrix[j,i]= indexCorrelationA[k,3]
    end

end

main(ARGS)