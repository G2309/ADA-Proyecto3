"""
Proyecto 3 - ADA
Gustavo Adolfo Cruz Bardales 
22779
"""

mutable struct MTFList
    elements::Vector{Int}
    
    function MTFList(initial_config::Vector{Int})
        new(copy(initial_config))
    end
end

function mtf_access(mtf_list::MTFList, element::Int)
    position = findfirst(x -> x == element, mtf_list.elements)
    
    if position === nothing
        error("Elemento $element no encontrado en la lista")
    end
    
    # Mover el elemento al frente
    accessed_element = mtf_list.elements[position]
    deleteat!(mtf_list.elements, position)
    pushfirst!(mtf_list.elements, accessed_element)
    
    return position  # Costo de acceso
end

function process_sequence(initial_config::Vector{Int}, sequence::Vector{Int}; verbose::Bool=true)
    mtf_list = MTFList(initial_config)
    total_cost = 0
    
    if verbose
        println("Configuración inicial: ", mtf_list.elements)
        println("=" ^ 60)
    end
    
    for (i, request) in enumerate(sequence)
        cost = mtf_access(mtf_list, request)
        total_cost += cost
        
        if verbose
            println("Solicitud $i: elemento=$request, costo=$cost")
            println("Nueva configuración: ", mtf_list.elements)
            println("-" ^ 40)
        end
    end
    
    if verbose
        println("COSTO TOTAL: $total_cost")
        println("=" ^ 60)
    end
    
    return total_cost, mtf_list.elements
end

function find_best_case_sequence(config::Vector{Int}, length::Int=20)
    # El mejor caso es acceder siempre al primer elemento
    best_sequence = fill(config[1], length)
    cost, _ = process_sequence(config, best_sequence, verbose=false)
    return best_sequence, cost
end

function find_worst_case_sequence(config::Vector{Int}, length::Int=20)
    # El peor caso es acceder siempre al último elemento
    worst_sequence = fill(config[end], length)
    cost, _ = process_sequence(config, worst_sequence, verbose=false)
    return worst_sequence, cost
end

mutable struct IMTFList
    elements::Vector{Int}
    
    function IMTFList(initial_config::Vector{Int})
        new(copy(initial_config))
    end
end

function imtf_access(imtf_list::IMTFList, element::Int, remaining_sequence::Vector{Int})
    position = findfirst(x -> x == element, imtf_list.elements)
    
    if position === nothing
        error("Elemento $element no encontrado en la lista")
    end
    
    # Verificar si el elemento está en los próximos position-1 elementos
    look_ahead_count = min(position - 1, length(remaining_sequence))
    should_move_to_front = false
    
    if look_ahead_count > 0
        next_elements = remaining_sequence[1:look_ahead_count]
        should_move_to_front = element in next_elements
    end
    
    # Mover al frente solo si se cumple la condición
    if should_move_to_front
        accessed_element = imtf_list.elements[position]
        deleteat!(imtf_list.elements, position)
        pushfirst!(imtf_list.elements, accessed_element)
    end
    
    return position
end

function process_sequence_imtf(initial_config::Vector{Int}, sequence::Vector{Int}; verbose::Bool=true)
    imtf_list = IMTFList(initial_config)
    total_cost = 0
    
    if verbose
        println("Configuración inicial (IMTF): ", imtf_list.elements)
        println("=" ^ 60)
    end
    
    for (i, request) in enumerate(sequence)
        remaining_seq = sequence[i+1:end]
        cost = imtf_access(imtf_list, request, remaining_seq)
        total_cost += cost
        
        if verbose
            println("Solicitud $i: elemento=$request, costo=$cost")
            println("Nueva configuración: ", imtf_list.elements)
            println("-" ^ 40)
        end
    end
    
    if verbose
        println("COSTO TOTAL (IMTF): $total_cost")
        println("=" ^ 60)
    end
    
    return total_cost, imtf_list.elements
end

# Prints para responder las preguntas que nos pusieron en el documento 

println("ALGORITMO MOVE TO FRONT (MTF) - ANÁLISIS")
println("=" ^ 80)

println("\n1. SECUENCIA: [0,1,2,3,4,0,1,2,3,4,0,1,2,3,4,0,1,2,3,4]")
config1 = [0, 1, 2, 3, 4]
sequence1 = [0, 1, 2, 3, 4, 0, 1, 2, 3, 4, 0, 1, 2, 3, 4, 0, 1, 2, 3, 4]
cost1, _ = process_sequence(config1, sequence1)

println("\n2. SECUENCIA: [4,3,2,1,0,1,2,3,4,3,2,1,0,1,2,3,4]")
sequence2 = [4, 3, 2, 1, 0, 1, 2, 3, 4, 3, 2, 1, 0, 1, 2, 3, 4]
cost2, _ = process_sequence(config1, sequence2)

println("\n3. MEJOR CASO (20 solicitudes):")
best_seq, best_cost = find_best_case_sequence(config1, 20)
println("Secuencia óptima: ", best_seq)
println("Costo mínimo: ", best_cost)

println("\n4. PEOR CASO (20 solicitudes):")
worst_seq, worst_cost = find_worst_case_sequence(config1, 20)
println("Secuencia del peor caso: ", worst_seq)
println("Costo máximo: ", worst_cost)

println("\n5. SECUENCIAS REPETITIVAS:")
sequence_2s = fill(2, 20)
println("Secuencia de 20 '2's:")
cost_2s, _ = process_sequence(config1, sequence_2s)

sequence_3s = fill(3, 20)
println("\nSecuencia de 20 '3's:")
cost_3s, _ = process_sequence(config1, sequence_3s, verbose=false)
println("Costo total para 20 '3's: ", cost_3s)

println("\nPATRÓN OBSERVADO:")
println("Para cualquier secuencia de 20 elementos iguales:")
println("- Primer acceso: costo = posición inicial del elemento")
println("- Siguientes 19 accesos: costo = 1 cada uno")
println("- Costo total = posición_inicial + 19")

println("\n6. ALGORITMO IMTF vs MTF:")
println("\nIMTF para el MEJOR CASO de MTF:")
cost_imtf_best, _ = process_sequence_imtf(config1, best_seq)

println("\nIMTF para el PEOR CASO de MTF:")
cost_imtf_worst, _ = process_sequence_imtf(config1, worst_seq)

println("\nCOMPARACIÓN DE RESULTADOS:")
println("Mejor caso MTF: ", best_cost, " vs IMTF: ", cost_imtf_best)
println("Peor caso MTF: ", worst_cost, " vs IMTF: ", cost_imtf_worst)
