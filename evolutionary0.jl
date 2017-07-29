# DO NOT MODIFY THIS CODE


function make_g1()
  g = fill(0, 63, 63)
  for i in 1:21
    for j in 22:63
      g[i, j] = 1
      g[j, i] = 1
    end
  end
  return g
end

function make_g2()
  g = fill(0, 63, 63)
  g[1,62] = 1
  g[62,1] = 1
  for i in 1:62
    g[i,63] = 1
    g[63,i] = 1
    if i - 1 > 0
      g[i, i-1] = 1
      g[i - 1, i] = 1
    end
  end
  return g
end

function make_g3()
  g = fill(0, 63, 63)
  for i in 1:31
    g[i, 2 * i] = 1
    g[2 * i, i] = 1
    g[i, 2 * i + 1] = 1
    g[2 * i + 1, i] = 1
  end
  return g
end

g1 = make_g1()
g2 = make_g2()
g3 = make_g3()

function fit(g, x)
  if length(x) == 1 # clever! to save time, return 1 if length of x is 1 as it's obviously an independent set so we don't have to perform the checks below
    return 1
  end

  #traverse the array that represents our solution and check on the adjacency matrix if any of the nodes are connected
  #if so, our fitness is zero as the set is not a solution
  for i in 1:length(x) - 1
    for j in i:length(x)
      if g[x[i], x[j]] == 1 || g[x[j], x[i]] == 1
        return 0
      end
    end
  end

  return length(x) #if execution reached this point, array representing the set is an independent set, so return the length of the array as fitness
end

function gen()
  return [rand(1:63)] # sweet and elegant function generating an array with a single randomly generated vertex
end

function mut(x, s)
  rate = Int(round(5 * s)) # mutation rate goes down proportionally to the number of generations executed, approximating 0 and defining how many vertices will be added to the array that represents a solution set
  new = fill(0, rate)
  filled = 0
  while filled < rate
    r = rand(1:63) #gets random node
    if r in new || r in x # if node already exists in the received set or in the new one, ignore node and continue
      continue
    end
    new[filled + 1] = r #if node is not in the set, add to it
    filled += 1 #variable that controls the loop
  end
  return cat(1, x, new) #after defining vertices that will be added, concatenate with original set and return
end

# END OF UNMODIFIABLE SECTION

# You can add more functions, but you can only change the ev method
# Do NOT modify p or g!

function ev(graph)
  p = 10 # DO NOT CHANGE!
  g = 100 # DO NOT CHANGE!
  initialSelectionSize = 5 # number of individuals that will be selected to be mutated in each generation (initial selection)
                          # initial selection strategy = random
  finalSelectionSize = 5  # number of individuals that will be selected to be compared against a mutated individual

  # initializing population with empty items
  pop = fill([0], p)

  # populate with randomly generated individuals: for this algorithm, we've defined that our initial individuals will be
  # sets with only one vertex randomly chosen (rand(1:63)) -- trivial graph
  for i in 1:p
    pop[i] = gen()
  end

  # run for "g" generations
  for generation in 1:g

    # select a predefined number of individuals to be mutated in each generation (initial selection)
    # for each mutated individual, get a random opponent, make them fight and
    for count in 1:initialSelectionSize
      x = rand(1:p) # random element to be mutated
      x_mutant = mut(pop[x], ( (g - generation + 1.0) / g ) ) # random element is mutated based on a mutation rate

      for count2 in 1:finalSelectionSize
        y = rand(1:p) # another random individual that will fight the mutated individual
        parent1 = rand(1:p) # randomly selected parent 1
        parent2 = rand(1:p) # randomly selected parent 2

        child = cross(pop[parent1], pop[parent2]) # naughty parents have sex and make a baby

        # compare mutant against the other unlucky randomly selected individual
        # if mutation did not produce a fitter individual than this other, mutant is going to be discarded and the
        # other random individual lives.
        if fit(graph, x_mutant) > fit(graph, pop[y])
          pop[y] = x_mutant
          break
        end

        # after crossover, replaces parent with resulting child if its fitter
        if fit(graph, child) > fit(graph, pop[parent1])
          pop[parent1] = child
        elseif fit(graph, child) > fit(graph, pop[parent2])
          pop[parent2] = child
        end
      end #end for

    end #end for

  end #end ev function

  return pop # return a population the same size as the initial one, but beautiful, fit, healthy and hopefully converging to the optimal solution =]

end

# reproduction: get half of each set and combine
function cross(parent1, parent2)
  halfParent1Index = Int(round(length(parent1)/2))
  halfParent2Index = Int(round(length(parent2)/2))

  if rand(0:1) === 0
    return vcat(parent1[1:halfParent1Index], parent2[halfParent2Index:length(parent2)])
  else
    return vcat(parent2[1:halfParent2Index], parent1[halfParent1Index:length(parent1)])
  end
end

# DO NOT MODIFY!

function do_and_print(graph, which)
  answer = ev(graph) # run evolutionary algorithm for g1,g2 or g3 depending on what we're receiving
  best = answer[1] # answer = evolved population. get the first individual and put it in the "best" variable
  best_fit = fit(graph, answer[1]) # calculate the fit of the individual above and store it in the "best_fit" variable
  @printf("Results for graph %d\n", which) # Results for graph 1, 2 or 3

  # for each individual in the returned population that has been put through evolution, print
  # the number of the answer corresponding to its position in the population, the array itself and its fit
  # e.g.: 1: [1,23,5,8], fitness: 4
  # find the best fit in the population and assign the individual to "best" and the fit to "best_fit"
  for i in 1:length(answer)
    @printf("%d: %s, fitness %d\n", i, answer[i], fit(graph, answer[i]))
    if (best_fit < fit(graph, answer[i]))
      best = answer[i]
      best_fit = fit(graph, answer[i])
    end
  end

  # print best answer alongside its fitness
  # e.g.: Best: 1, fitness: 16
  @printf("Best: %s, fitness %d\n", best, best_fit)

  # print "End of results for graph 1, 2 or 3"
  @printf("End of results for graph %d\n\n", which)
end

# execution starts here
#do_and_print(g1, 1)
#do_and_print(g2, 2)
#do_and_print(g3, 3)

# END OF UNMODIFIABLE SECTION
