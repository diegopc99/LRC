function [encoded_shards] = encode(data, galois_subsets, n, k)
    fprintf('Starting encoding...\n');
    encoded_shards = gf(zeros(n, k * ceil(length(data)/k)), 8); % Adjust size to handle all data
    
    for i = 1:k:length(data)
        %% Matrix a formed by data symbols
        data_matrix = [data(i) data(i+1); data(i+2) data(i+3)];
        
        %% Polynomial representation
        polynomial_coeffs = [data_matrix(1,1) data_matrix(1,2) 0 data_matrix(2,1) data_matrix(2,2)];
        
        %% Transform to Galois field
        galois_polynomial = gf(polynomial_coeffs, 8);
        
        %% Encoded vector
        encoded_values = polyval(galois_polynomial, galois_subsets);
        
        %% Store encoded data into shards
        block_index = ceil(i / k);  % Correct indexing for shards
        for shard_index = 1:n
            encoded_shards(shard_index, block_index) = encoded_values(shard_index);
        end
    end
       
    fprintf('Encoding complete.\n');
    encoded_shards = uint8(double(encoded_shards.x)); % Convert back to uint8 format
end