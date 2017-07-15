function pa = equalpa(user, total)
% PA is a vector of equal long-term rates of interest (p.a.)
% USER is a scalar/vector of amounts for year/all years
% TOTAL is a vector of final cumulated amounts

if length(user) == 1
    user = user * ones(size(total));
end

pa = zeros(size(total));
for i = 1:length(total)
    pa(i) = fminsearch(@(p) abs(total(i) - cinterest(user(1:i), p)), 0);
end

end


function total = cinterest(amounts, p)  % compound interest

total = 0;
for i = 1:length(amounts)
    % input amount increases linearly during year
    total = total + amounts(i) + (total + 0.5 * amounts(i)) * p / 100;
end

end
