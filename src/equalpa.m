function pa = equalpa(user, total)
% PA is a vector of equal long-term rates of interest (p.a.)
% USER is a scalar/vector of amounts
% TOTAL is vector of final cumulated amounts

if length(user) == 1
    user = user * ones(size(total));
end

pa = zeros(size(total));
for i = 1:length(total)
    pa(i) = fminsearch(@(p) abs(total(i) - cinterest(user(1:i), p)), 0);
end

end


function total_end = cinterest(amounts, percent)  % compound interest

total_end = 0;
for i = 1:length(amounts)
    total_end = (total_end + amounts(i)) * (1 + 0.01 * percent);
end

end
