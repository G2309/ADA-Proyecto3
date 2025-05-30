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

