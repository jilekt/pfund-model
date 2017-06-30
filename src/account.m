function data = account(amount_monthly, percent, years_count)

if length(amount_monthly) == 1
    amount_yearly = 12 * amount_monthly * ones(years_count, 1);
else
    amount_yearly = 12 * amount_monthly;
end

data.years  = (1:years_count).';
data.cumsum.total = zeros(years_count, 1);
data.cumsum.total(1) = amount_yearly(1) * (1 + 0.01 * percent * 0.85);  % tax: 15 %
for year = 2:years_count
    data.cumsum.total(year) = (data.cumsum.total(year-1) + amount_yearly(year)) * (1 + 0.01 * percent * 0.85);  % tax: 15 %
end

end
