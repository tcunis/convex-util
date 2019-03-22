function s = structure(A)
% Compute sparsity structure for CASADI symbolic A.

    Asp = sparsity(A);
    
    [sp1,sp2] = get_triplet(Asp);
    sp3 = ones(length(sp1),1);
    
    s = sparse(sp1+1,sp2+1,sp3);
end
