function [decoded_data] = decode(encoded_shards, galois_subsets, n, k)
    total_symbols = k * length(encoded_shards);
    decoded_symbols = gf(zeros(total_symbols, 1), 8);
    
    fprintf('Starting decoding process...\n');
    
    for block_index = 1:size(encoded_shards, 2)
        shard_dimensions = size(encoded_shards);
        % Construct the coefficient matrix based on subset values
        coefficient_matrix = [galois_subsets(1)^4 galois_subsets(1)^3 galois_subsets(1) 1;
                              galois_subsets(2)^4 galois_subsets(2)^3 galois_subsets(2) 1;
                              galois_subsets(5)^4 galois_subsets(5)^3 galois_subsets(5) 1;
                              galois_subsets(8)^4 galois_subsets(8)^3 galois_subsets(8) 1];
        
        % Extract the corresponding encoded values
        encoded_values = [encoded_shards(1, block_index); 
                          encoded_shards(2, block_index); 
                          encoded_shards(5, block_index); 
                          encoded_shards(8, block_index)];
        
        % Solve for the original message values
        decoded_block = coefficient_matrix \ encoded_values;
        
        % Store the decoded message symbols in the evaluation array
        start_index = (block_index - 1) * k + 1;
        decoded_symbols(start_index:start_index + k - 1, 1) = decoded_block;
    end
    
    fprintf('Decoding complete.\n');
    
    % Convert decoded Galois field data back to uint8 format
    decoded_data = uint8(double(decoded_symbols.x));

    % Trim the decoded data by calculating the expected number of data elements
    expected_length = k * floor(shard_dimensions(2) * n / (k * n));
    decoded_data = decoded_data(1:expected_length); % Trim excess data
end
