function [recov_shards] = recover(recov_shards, removed_shard_index, n, subsets_gf)

    % Process each missing shard
    for i = 1:length(removed_shard_index)
        missing_index = removed_shard_index(1,i); % Get the index of the missing shard
        
        % Ensure missing_index is valid
        if missing_index < 1 || missing_index > n
            error('Error: Invalid missing shard index %d (out of bounds)', missing_index);
        end
        
        % Determine recovery shards based on missing_index
        if mod(missing_index, 3) == 0 % Multiple of 3
            if missing_index - 2 < 1 || missing_index - 1 < 1
                error('Recovery not possible: Required shards missing.');
            end
            a = [subsets_gf(missing_index - 2), 1; 
                 subsets_gf(missing_index - 1), 1];
            aux_index = [missing_index - 2, missing_index - 1];
            
        elseif mod(missing_index, 2) == 0 % Multiple of 2 (but not 3)
            if missing_index - 1 < 1 || missing_index + 1 > n
                error('Recovery not possible: Required shards missing.');
            end
            a = [subsets_gf(missing_index - 1), 1; 
                 subsets_gf(missing_index + 1), 1];
            aux_index = [missing_index - 1, missing_index + 1];
            
        else % Odd index (not a multiple of 2 or 3)
            if missing_index + 1 > n || missing_index + 2 > n
                error('Recovery not possible: Required shards missing.');
            end
            a = [subsets_gf(missing_index + 1), 1; 
                 subsets_gf(missing_index + 2), 1];
            aux_index = [missing_index + 1, missing_index + 2];
        end

        % Debugging Information
        fprintf('Recovering shard %d using shards %d and %d\n', missing_index, aux_index(1), aux_index(2));

        % Recover the missing shard by solving the system of equations
        for m = 1:length(recov_shards(aux_index(1),:)) % Iterate over columns
            b = [recov_shards(aux_index(1), m); 
                recov_shards(aux_index(2), m)];
            
            % Solve for the missing shard
            removedShard = a\b;
            
            % Ensure correct indexing
            recov_shards(missing_index, m) = removedShard(1,1) * subsets_gf(missing_index) + removedShard(2,1);
        end
    end
end